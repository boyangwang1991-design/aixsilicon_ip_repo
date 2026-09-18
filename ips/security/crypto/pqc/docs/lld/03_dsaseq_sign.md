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
不因正常范数拒绝提前退出；每次尝试固定公开pset决定的固定周期边界（44/65为1500000，87为2250000），超过预算失败关闭。
只在该边界决定接受或重试；公开MAX_ATTEMPTS=256与nonce上界共同限制。候选拒绝不触发DMA。
接受后编码ctilde/z/hint，只保留实际签名字范围（末字非有效字节置零），清除其余SRAM字及本地秘密寄存器，才允许签名DMA及completion/IRQ。
超时、引擎错误、撤销及clear走故障清除。Level2与物理侧信道签核仍保持原合同开放。

<!-- RTL_MAP_META
id: RTL.PQC.DSA_SIGN
rtl_file: rtl/pqc_dsa_sign.sv
rtl_module: pqc_dsa_sign
implements: [LLD.MOD.PQC.DSASEQ.SIGN]
END_RTL_MAP_META -->

## 当前候选 RTL 的综合边界

HighBits 按公开 pset 分支选择两个字面量除数190464/523776与回绕上界44/16，
不得以运行时 gamma2 作除数推断通用除法器。该改写不改变状态机周期。

## 程序数据通路对象

以下对象的32-bit宽度指受保护的本地word数据通路；SHAKE字节接口、64-bit熵输入
及可信身份头仍按各自端口宽度传输。算术由共享引擎执行，程序自身保持单未决操作。
正常握手停顿保留地址、数据、返回状态和计数；clear优先屏蔽所有请求及结果。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.DSA_SIGN.PROGRAM
module_ref: LLD.MOD.PQC.DSASEQ.SIGN
width: 32
operators:
- private_workkey_decode
- message_context_shake_mu
- deterministic_or_hedged_seed
- shared_expand_mask_ntt_matrix_mac
- z_r0_ct0_norm_accumulate
- hint_encode
- public_parameter_attempt_boundary
- signature_commit_and_secret_scrub
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.FUNC.PQC.DSA_SIGN.002
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

