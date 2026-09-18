# KEM Encaps 首条集成数据通路

本册细化 KEMSEQ 中 Encaps 的串行程序，不改变 HLD 引擎边界。实现先覆盖非掩码
Encaps，保持共享 Keccak/POLY/SAMPLER/CODEC。完整 KeyGen/Decaps/DSA/Level2仍须
分别闭合，不能把本路径通过计为整个IP完成。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KEMSEQ.ENCAPS
name: pqc_kem_encaps
parent_ref: LLD.MOD.PQC.KEMSEQ
hld_ref: [HLD.MOD.PQC.KEMSEQ]
req_ref: [LRS.FUNC.PQC.KEM_ENCAPS.001, LRS.FUNC.PQC.KEM_DATAFLOW.001]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_kem_encaps
END_LLD_MODULE_META -->

## 数据及页面

所有系数均为标准模3329余数。t_hat放0..3页，y_hat放4..7页，accumulator放8页，
noise放9页，单矩阵元素放10页，packed临时放11页。每页256个32-bit word。
输入公钥从word4096起，输出密文从word5120起，shared secret从word5632起，
completion从word5888起。最大k=4时区域无重叠，最小32KiB SRAM可容纳。
页号仅属于本Encaps程序，不同时执行其他算法。DMA offset加上固定区基址；FE已核验固定长度，最大输入/输出均1568B，地址不超过最小SRAM容量。

接受命令后读取整个pk；逐poly复制96个packed word到11页并UNPACK到t页，
逐系数检查小于3329。rho为末32B。H(pk)用SHA3-256；通过entropy valid/ready接受
32B m，G(m||H(pk))用SHA3-512，前32B为K、后32B为r。随机数据小端逐byte装载。
域标签为{algo=1,pset}；health/tag错误不能继续。

PRF=SHAKE256(r||nonce)：y nonce0..k-1使用eta1（512为3，其他2），e1/e2 nonce
k..2k使用eta2=2。y经NTT保留；每个u[i]先清accumulator，逐j执行
SampleNTT(rho||i||j)和MAC(A[j,i],y[j])，再INTT、加e1、Compress_du、PACK。
v清accumulator后逐j MAC(t[j],y[j])，INTT、加e2、加消息Decompress1，Compress_dv、PACK。
每poly packed结果复制到连续输出区，K写入单独安全输出区。

## 握手与退出

只允许一个引擎原语未决；start为一拍，WAIT只接受对应引擎done，不OR全部done。
请求字段在等待期间保持。SRAM请求在ready时完成；Keccak流只在valid/ready递增。
矩阵XOF采用有界4096B输出，Sampler结束后排空剩余字节；如果输出耗尽仍不足256
系数则失败关闭，不能使用部分矩阵。此上限属于候选实现限制，完整无限XOF续块仍须闭合。

算法done表示全部内部结果写回完成；TOP随后按dst0密文、dst1秘密、completion顺序
调用DMA，全部B响应成功才向FE反馈done。错误或取消抑制新请求和成功反馈，已展示
AXI事务由DMA排空。zeroize优先于任意握手，并擦除m/r/K和调度寄存器。
内部缓存只在当前命令使用；退休清除仍由统一FAULT流程负责。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KEMSEQ.ENCAPS
module_ref: LLD.MOD.PQC.KEMSEQ.ENCAPS
input_width: 32
output_width: 32
operators: [hash_pk, derive_key_randomness, cbd_ntt, matrix_mac, inverse_ntt, add_noise_message, compress_pack]
representation: normalized_kem_coefficients_and_serialized_bytes
req_ref: [LRS.FUNC.PQC.KEM_ENCAPS.001]
END_LLD_DATAPATH_META -->

<!-- RTL_MAP_META
id: RTL.PQC.KEM_ENCAPS
rtl_file: rtl/pqc_kem_encaps.sv
rtl_module: pqc_kem_encaps
implements: [LLD.MOD.PQC.KEMSEQ.ENCAPS, LLD.DP.PQC.KEMSEQ.ENCAPS]
END_RTL_MAP_META -->

## 顶层事务与完成格式

TOP在合法Encaps命令启动时锁存typed command，先DMA读SRC0到4096，再启动本模块。
TX_INPUT→TX_COMPUTE→TX_CT→TX_CT_GAP→TX_SS→TX_RECORD→TX_COMMIT→TX_DONE。
DMA保持done直到req撤销；TX_CT_GAP提供撤销周期，不能在同一个done上跳过SS。
completion为32B小端8个word：command_id/status/output0_len/output1_len/verify_valid/
error_info/cycles/reserved。非Verify的verify_valid为0。cycles为本次调度经过周期数。
TX_RECORD逐word写入5888区；COMMIT等待completion的B响应成功后才向FE提交alg_done。
FE再提交本地状态和IRQ。任何DMA错误、非canonical公钥、entropy异常都不能发布成功。
当前只允许SCA_LEVEL<2的Encaps完整程序；其余操作报错，不再运行旧占位sequencer后假报成功。
CAPABILITY参数集位不能解读为所有操作已完整实现，发布门禁仍未关闭。

Keccak支持valid=0/last=1空输入标记，所以本非空流必须把last限定在H_BYTE的valid周期；
从SRAM预取最后字节时不得提前断言last。端到端仿真用于检查此集成约束。
