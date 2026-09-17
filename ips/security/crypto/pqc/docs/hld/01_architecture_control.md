# PQC L1 模块职责

### HLD.MOD.PQC.TOP — 顶层与安全边界

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.TOP
name: pqc_top
responsibility: 集成总线接口、安全边界与各 L1 模块，不承担计算
req_ref:
- LRS.CONS.PQC.LANG.001
- LRS.CONS.PQC.CORE.001
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.CFG.PQC.ALGO_MASK.001
- LRS.INTF.PQC.ENTROPY.001
- LRS.INTF.PQC.CLKRESET.001
- LRS.RESET.PQC.CLK.001
- LRS.CONS.PQC.DELIVER.001
- LRS.CONS.PQC.API.001
- LRS.SEC.PQC.CT.002
- LRS.DFX.PQC.SCAN.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.EXT.PQC.APB
- HLD.IF.EXT.PQC.DMA
- HLD.IF.INT.PQC.RANDOM
- HLD.IF.EXT.PQC.ENTROPY
- HLD.IF.EXT.PQC.SIDEBAND
- HLD.IF.EXT.PQC.KEY_MANAGER
END_HLD_MODULE_META -->

#### Responsibility

`pqc_top` 提供 IP 外部边界，实例化并连接全部 L1 模块，承载安全边界语义：任何秘密
中间值不跨出该边界；标准 API 允许输出的 shared secret 仅经授权安全输出，
新生成私钥仅经专用 Key Manager 托管接口离开计算子边界。

#### Architecture Role

统一的安全与集成入口，使 `pqc_cmd_frontend` 专注于 command/policy，数据通路模块
保持纯计算，便于独立验证与后续 SKU 裁剪。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.EXT.PQC.APB | input | CPU | 控制与寄存器访问 |
| HLD.IF.EXT.PQC.DMA | output | SoC 内存 | 数据搬运 |
| HLD.IF.EXT.PQC.ENTROPY | input | TRNG/DRBG | 随机量 |
| HLD.IF.EXT.PQC.SIDEBAND | input/output | 安全子系统 | lifecycle/tamper/zeroize/irq |

#### Non-Responsibility

- 不实现密码算法运算；
- 不实现 SoC 级地址译码与 IOMMU；
- 不实现 TRNG。

---



配置与集成约束见寄存器架构、域策略和 LLD 交接；本模块存在不代表端到端命令已完成。

### HLD.MOD.PQC.FE — 命令前端

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.FE
name: pqc_cmd_frontend
responsibility: APB 寄存器、descriptor 抓取与校验、权限与策略、门铃与 completion
req_ref:
- LRS.FUNC.PQC.CMD.001
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.003
- LRS.FUNC.PQC.CMD.004
- LRS.FUNC.PQC.CMD.005
- LRS.FUNC.PQC.CMD.006
- LRS.REG.PQC.ID.001
- LRS.REG.PQC.CTRL.001
- LRS.REG.PQC.STATUS.001
- LRS.REG.PQC.INTR.001
- LRS.REG.PQC.ALERT.001
- LRS.CFG.PQC.FEATURE_FLAGS.001
- LRS.CFG.PQC.EXEC_MODE.001
- LRS.INTF.PQC.APB.001
- LRS.REG.PQC.RESULT.001
- LRS.REG.PQC.ERRCODE.001
- LRS.REG.PQC.PERF.001
- LRS.REG.PQC.COMPLETION.001
- LRS.DFX.PQC.DEBUG.001
- LRS.DFX.PQC.PERFCNT.001
- LRS.CONS.PQC.REG.001
- LRS.FUNC.PQC.CMD.007
- LRS.FUNC.PQC.CMD.008
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.EXT.PQC.APB
- HLD.IF.INT.PQC.DESC
- HLD.IF.INT.PQC.DISPATCH
- HLD.IF.INT.PQC.COMPL
END_HLD_MODULE_META -->

#### Responsibility

解析 128 B 命令描述符，执行 ABI/对齐/reserved/CRC/长度/capability 校验，管理寄存器
与中断，发布 completion record，执行 BUSY 期间配置锁定。

#### Architecture Role

把所有非法输入拦截在任何秘密访问之前，是"错误在访问秘密前终止"这一需求的唯一实现点。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.EXT.PQC.APB | input | CPU | 寄存器访问 |
| HLD.IF.INT.PQC.DESC | input | `pqc_dma` | descriptor 抓取数据 |
| HLD.IF.INT.PQC.DISPATCH | output | sequencers | 派发已校验命令 |
| HLD.IF.INT.PQC.COMPL | input/output | sequencers | completion 状态汇聚 |

#### Non-Responsibility

- 不解析算法级数据结构（key/ciphertext/signature 语义）；
- 不执行密码运算；
- 不管理 key slot 内容。

---



配置与集成约束见寄存器架构、域策略和 LLD 交接；本模块存在不代表端到端命令已完成。

### HLD.MOD.PQC.KEMSEQ — ML-KEM 序列控制器

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.KEMSEQ
name: pqc_kem_seq
responsibility: ML-KEM KeyGen/Encaps/Decaps 全流程控制含隐式拒绝与重加密
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.002
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.KEM_LEN.001
- LRS.PERF.PQC.NOSW.001
- LRS.SEC.PQC.CT.001
applicability:
  expr: ENABLE_ALGO_MASK & 0x7
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.DISPATCH
- HLD.IF.INT.PQC.PRIM
- HLD.IF.INT.PQC.PAGE
- HLD.IF.INT.PQC.COMPL
- HLD.IF.INT.PQC.KEY_MATERIAL
END_HLD_MODULE_META -->

#### Responsibility

按 FIPS 203 顺序编排 ExpandA、CBD、NTT、pointwise MAC、Compress/Decompress 与
Decaps 的重加密 + 常数时间 compare/select。

#### Architecture Role

把 ML-KEM 的算法语义集中在单一序列控制器，使 poly/keccak/sampler/codec 保持通用，
并在 Decaps 强制走统一隐式拒绝路径。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.DISPATCH | input | `pqc_cmd_frontend` | 已校验命令 |
| HLD.IF.INT.PQC.PRIM | output | poly/keccak/sampler/codec | primitive 派发 |
| HLD.IF.INT.PQC.PAGE | output | `pqc_secure_sram_ctrl` | 页生命周期管理 |
| HLD.IF.INT.PQC.COMPL | output | `pqc_cmd_frontend` | completion |

#### Non-Responsibility

- 不实现 ML-DSA 流程；
- 不实现 primitive 内部运算；
- 不决定 descriptor 合法性。

---



配置与集成约束见寄存器架构、域策略和 LLD 交接；本模块存在不代表端到端命令已完成。

### HLD.MOD.PQC.DSASEQ — ML-DSA 序列控制器

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.DSASEQ
name: pqc_dsa_seq
responsibility: ML-DSA KeyGen/Sign/Verify 流程含拒绝采样循环与原子 commit
req_ref:
- LRS.FUNC.PQC.DSA_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.FUNC.PQC.DSA_SIGN.002
- LRS.FUNC.PQC.DSA_SIGN.003
- LRS.FUNC.PQC.DSA_VERIFY.001
- LRS.FUNC.PQC.DSA_MU.001
- LRS.FUNC.PQC.DSA_MESSAGE.001
- LRS.PERF.PQC.SIGNBUBBLE.001
- LRS.CFG.PQC.FEATURE_FLAGS.001
- LRS.PERF.PQC.NOSW.001
- LRS.SEC.PQC.CT.001
applicability:
  expr: ENABLE_ALGO_MASK & 0x38
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.DISPATCH
- HLD.IF.INT.PQC.PRIM
- HLD.IF.INT.PQC.PAGE
- HLD.IF.INT.PQC.STAGE
- HLD.IF.INT.PQC.COMPL
- HLD.IF.INT.PQC.KEY_MATERIAL
END_HLD_MODULE_META -->

#### Responsibility

编排 ExpandA/ExpandS/ExpandMask、SampleInBall、Power2Round/HighBits/LowBits/MakeHint/
UseHint 与范数检查，实现完整拒绝采样循环、attempt 上限检测与 staging buffer 原子 commit。

#### Architecture Role

Sign 的拒绝采样循环与侧信道复杂度最高，集中于该模块使失败路径不污染其他模块；
`HLD.IF.INT.PQC.STAGE` 保证失败 attempt 不产生任何可见输出。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.DISPATCH | input | `pqc_cmd_frontend` | 已校验命令 |
| HLD.IF.INT.PQC.PRIM | output | poly/keccak/sampler/codec | primitive 派发 |
| HLD.IF.INT.PQC.PAGE | output | `pqc_secure_sram_ctrl` | 页生命周期管理 |
| HLD.IF.INT.PQC.STAGE | output | `pqc_dma` | 原子 commit 候选签名 |
| HLD.IF.INT.PQC.COMPL | output | `pqc_cmd_frontend` | completion |

#### Non-Responsibility

- 不实现 ML-KEM 流程；
- 不实现 primitive 内部运算；
- 不管理 key slot 权限。

---



配置与集成约束见寄存器架构、域策略和 LLD 交接；本模块存在不代表端到端命令已完成。


## 需求分配的具体执行责任

- TOP 管理熵来源选择与健康/生命周期隔离；标准参数/常量属于可信构建输入。
  集成文档和 API 的能力承诺必须与实际硬件一致，不由包装层伪造结果。
- FE 负责参数集裁剪、PIO 与 DMA 模式互斥、完整命令 shadow、自检/清零入口、
  结果/错误/完成记录与五类 IRQ，以及公开粗粒度性能统计。无效配置在秘密访问前拒绝。
- KEMSEQ 对外长度、公共 key canonicality 与完整加/解密/重加密负责；invalid ciphertext
  位不进入错误分类。秘密只能通过授权材料接口进入，随机输入经批准熵路径进入。
- DSASEQ 负责 pure/Hash-ML-DSA 域分离、context 与分段消息，拒绝循环重放时保持 mu 与
  只属于该命令的 rho''；所有原语由硬件闭环，无软件算法回退。按用户接受的策略采用固定尝试调度与可变总时延；仍须验证时延分布
  和秘密的独立性，不能仅由原语 UT 证明。

TOP 内部随机分配归 HLD.IF.INT.PQC.RANDOM，缓存和消费身份不得由普通总线读取；
完整清除汇聚必须包括该服务。Level 2 转换与采样的公开调度合同见 09_masking_execution.md。
