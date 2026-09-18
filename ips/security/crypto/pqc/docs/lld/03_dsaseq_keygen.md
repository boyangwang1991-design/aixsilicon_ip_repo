# DSA KeyGen 数据通路（candidate）

SCA_LEVEL<2的pure ML-DSA KeyGen复用POLY/Keccak/sampler/codec。
专用接口接收32B健康且tag={2,pset}的xi；SHAKE256(xi||k||l,128)导出rho/rhoprime/K。
ExpandS产生s1/s2，NTT(s1)与ExpandA矩阵MAC后INTT并加s2，Power2Round得到t1/t0。
公钥为rho||ByteEncode10(t1)，tr=SHAKE256(pk,64)。私钥按rho||K||tr||s1||s2||t0编码，
直接流入WORKKEY；复用专用托管头、完整身份ACK及公开输出退休合同。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.DSASEQ.KEYGEN
name: pqc_dsa_keygen
parent_ref: LLD.MOD.PQC.DSASEQ
hld_ref: [HLD.MOD.PQC.DSASEQ]
req_ref: [LRS.FUNC.PQC.DSA_KEYGEN.001]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_dsa_keygen
END_LLD_MODULE_META -->

页0–6保存s1_hat，8–15保存s2，16–23保存编码t0；24为累加、25为矩阵临时、26为编码、
27为系数转换、28–30为公钥。生成私钥前逐s1多项式INTT还原；完成后清除页0–27与seed寄存器。
公开公钥从页28读取；句柄和completion仅在私钥清除及完整托管ACK后覆盖原秘密页。
私钥长度2560/4032/4896 B，WORKKEY usage为Sign位1、algo=2；KEM保持algo=1及Decaps位2。
采样XOF耗尽、引擎失败、超时、清除或撤销禁止公开成功输出。完整Level2合同仍开放。

<!-- RTL_MAP_META
id: RTL.PQC.DSA_KEYGEN
rtl_file: rtl/pqc_dsa_keygen.sv
rtl_module: pqc_dsa_keygen
implements: [LLD.MOD.PQC.DSASEQ.KEYGEN]
END_RTL_MAP_META -->

## 程序数据通路对象

以下对象的32-bit宽度指受保护的本地word数据通路；SHAKE字节接口、64-bit熵输入
及可信身份头仍按各自端口宽度传输。算术由共享引擎执行，程序自身保持单未决操作。
正常握手停顿保留地址、数据、返回状态和计数；clear优先屏蔽所有请求及结果。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.DSA_KEYGEN.PROGRAM
module_ref: LLD.MOD.PQC.DSASEQ.KEYGEN
width: 32
operators:
- entropy_xi_capture
- shared_shake_dispatch
- shared_expand_s_a_dispatch
- shared_ntt_matrix_mac_dispatch
- power2round_t1_t0_split
- private_workkey_serialization
- secret_word_scrub
req_ref:
- LRS.FUNC.PQC.DSA_KEYGEN.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

