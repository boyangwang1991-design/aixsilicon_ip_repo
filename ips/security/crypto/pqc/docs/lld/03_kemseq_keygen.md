# KEM KeyGen 串行程序与托管集成（candidate）

本增量按 VPLAN 阶段5接通 KeyGen；三个 KEM 子程序共用现有 POLY/Keccak/codec/sampler，
不新增算法计算引擎。G2 全 IP 技术冻结仍开放；本册先约束 SCA_LEVEL<2 的真实功能路径。
Level2 双 share、随机刷新与完整身份原语仍由原有安全合同约束，不能用本路径替代。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KEMSEQ.KEYGEN
name: pqc_kem_keygen
parent_ref: LLD.MOD.PQC.KEMSEQ
hld_ref: [HLD.MOD.PQC.KEMSEQ]
req_ref: [LRS.FUNC.PQC.KEM_KEYGEN.001]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_kem_keygen
END_LLD_MODULE_META -->

## 运算及存储

锁存pset，接受恰好64B健康且tag匹配的熵，前32B为d、后32B为z。
FIPS203 KeyGen_internal / K-PKE.KeyGen：G(d||k)得到rho/sigma；依nonce采样s/e并NTT，
按A[i,j]=SampleNTT(rho||j||i)计算t=A*s+e。ByteEncode12(t)||rho写公钥页16–17。
私钥ByteEncode12(s)||ek||H(ek)||z通过独立generated_word写WORKKEY，不进入公共DMA。

| 页 | 内容/生命周期 |
|---|---|
| 0–3 | s_hat，NTT后保持至私钥序列化 |
| 8 | t累积，每行全页清零 |
| 9 | 本行e_hat |
| 10 | 矩阵A临时多项式 |
| 11 | ByteEncode12临时页，96word有效 |
| 16–17 | 公钥，唯一允许KeyGen输出DMA读取的算法页 |
| 22 | 托管确认后的4B句柄 |
| 23 | completion |

按一请求/等待/退休串行执行。每行先采样e并NTT，再全长矩阵MAC、加e、打包、公钥复制。
采样XOF有限上界耗尽为错误，不能使用部分多项式。私钥流最后字握手后，清除页0–11与本地
seed/hash寄存器。内部超时失败关闭；公开输出必须等待WORKKEY检查与完整托管成功。

## 托管身份与退休

TOP在接受KeyGen时锁存专用可信上下文：epoch、generated_handle、owner、domain。
该上下文来自Key Manager专用输入，普通描述符/CSR不能设置来源标志。
transaction为内部递增计数器，溢出拒绝；Key Manager须在PQC复位后更新epoch以拒绝旧ACK。
新生成标志只从当前KeyGen成功的内部路径产生；导入接口无托管启动入口。

托管头携带transaction/epoch/handle/owner/domain/algo/pset/bytes；头接受后逐word请求WORKKEY，
一个未决读，响应锁存后才发valid。背压时数据、last、所有身份保持；末字接受后才接收ACK。
ACK的transaction、epoch、handle、owner/domain、bytes必须全部匹配且success=1才可提交。
不匹配ACK不能前进；匹配失败、超时、清除或撤销禁止成功。清除/撤销优先于同拍末字/ACK。

顺序为generated WORKKEY完整扫描→托管头/私钥流→匹配成功ACK→公钥DMA B响应→句柄DMA
B响应→completion B响应→IRQ。普通DMA没有读取WORKKEY或私钥流的选择项。
本阶段的owner/domain约束只定义托管接口；既有导入路径完整身份扩展仍不得隐式宣称完成。

<!-- RTL_MAP_META
id: RTL.PQC.KEM_KEYGEN
rtl_file: rtl/pqc_kem_keygen.sv
rtl_module: pqc_kem_keygen
implements: [LLD.MOD.PQC.KEMSEQ.KEYGEN]
END_RTL_MAP_META -->

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.WORKKEY.CUSTODY
name: pqc_key_custody
parent_ref: LLD.MOD.PQC.WORKKEY
hld_ref: [HLD.MOD.PQC.WORKKEY]
req_ref: [LRS.INTF.PQC.KEY_MANAGER.001]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_key_custody
END_LLD_MODULE_META -->

<!-- RTL_MAP_META
id: RTL.PQC.KEY_CUSTODY
rtl_file: rtl/pqc_key_custody.sv
rtl_module: pqc_key_custody
implements: [LLD.MOD.PQC.WORKKEY.CUSTODY]
END_RTL_MAP_META -->
