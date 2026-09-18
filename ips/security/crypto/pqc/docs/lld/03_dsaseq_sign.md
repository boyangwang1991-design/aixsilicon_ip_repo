# DSA Sign 串行数据通路（candidate）

pure ML-DSA使用完整message/context形成mu。仅从WORKKEY读取私钥，entropy_policy=0使用全零rnd，
1/2接收32B健康且tag匹配的专用随机输入。SHAKE256(K||rnd||mu,64)导出rhoprime。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.DSASEQ.SIGN
name: pqc_dsa_sign
parent_ref: LLD.MOD.PQC.DSASEQ
hld_ref: [HLD.MOD.PQC.DSASEQ]
req_ref: [LRS.FUNC.PQC.DSA_SIGN.001, LRS.FUNC.PQC.DSA_SIGN.002]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_dsa_sign
END_LLD_MODULE_META -->

页0–6为s1_hat，7–13为y_hat，14为w累加，15为矩阵，16为c_hat，17/18为临时，
19–23为候选signature，24–25为w1编码，26为codec临时，27为初始context，28为message分块。
先ExpandMask并NTT，逐行A*y、INTT与HighBits，H(mu||w1)导出挑战；随后计算所有z及范数。
第二轮重算A*y，逐行从WORKKEY读取s2/t0、NTT和挑战乘法，累计r0、ct0范数及hint重量。
不因正常范数拒绝提前退出；每次尝试固定1500000周期边界，超过预算失败关闭。
只在该边界决定接受或重试；公开MAX_ATTEMPTS=256与nonce上界共同限制。候选拒绝不触发DMA。
接受后编码ctilde/z/hint，清除其余SRAM页及本地秘密寄存器，才允许签名DMA及completion/IRQ。
超时、引擎错误、撤销及clear走故障清除。Level2与物理侧信道签核仍保持原合同开放。

<!-- RTL_MAP_META
id: RTL.PQC.DSA_SIGN
rtl_file: rtl/pqc_dsa_sign.sv
rtl_module: pqc_dsa_sign
implements: [LLD.MOD.PQC.DSASEQ.SIGN]
END_RTL_MAP_META -->
