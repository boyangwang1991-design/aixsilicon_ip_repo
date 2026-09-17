# PQC L1 模块职责

### HLD.MOD.PQC.POLY — 双模多项式引擎

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.POLY
name: pqc_poly_engine
responsibility: 双模 NTT/INTT/pointwise MAC/系数加减/条件约减，rounding/hint 由 codec 承担
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.PERF.PQC.LATENCY.001
- LRS.CFG.PQC.NTT_LANES.001
- LRS.CONS.PQC.CONST.001
- LRS.PERF.PQC.MODEL.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.RANDOM
- HLD.IF.INT.PQC.PRIM
- HLD.IF.INT.PQC.PAGE
END_HLD_MODULE_META -->

#### Responsibility

以统一 32 bit 物理蝶形承载 KEM（q=3329，16 bit 系数）与 DSA（q=8380417，32 bit 系数）
两个域；提供 NTT/INTT/MAC/约减，rounding/hint 统一由 codec 承担。

#### Architecture Role

共享底座的核心：双模而非双引擎，显著降低面积；常量 ROM 保存经生成与审计的 roots、
逆根与约减常量，杜绝运行时任意模数。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.PRIM | input | sequencers | primitive 命令 |
| HLD.IF.INT.PQC.PAGE | input/output | `pqc_secure_sram_ctrl` | 系数页读写 |

#### Non-Responsibility

- 不做采样与 XOF 展开；
- 不做字节编码；
- 不允许软件指定任意模数；仅选择固定的 KEM/DSA 域。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.KECCAK — 共享哈希引擎

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.KECCAK
name: pqc_keccak
responsibility: Keccak-f[1600] 24 轮，SHA3-256/512、SHAKE128/256 增量流
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.DSA_MU.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.CFG.PQC.KECCAK_ROUNDS.001
- LRS.PERF.PQC.OVERLAP.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.RANDOM
- HLD.IF.INT.PQC.PRIM
- HLD.IF.INT.PQC.SQZ
END_HLD_MODULE_META -->

#### Responsibility

提供 64 bit rate 侧数据通路的 absorb/squeeze 流、域分离与硬件 padding，管理两个独立
Keccak context（消息增量哈希 + 矩阵/采样 XOF）。

#### Architecture Role

Keccak 是全部哈希、矩阵展开与采样的共同来源；双 context + block 边界切换使单
permutation 数据通路满足"消息哈希与 XOF 并存"而无需第二套 permutation。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.PRIM | input | sequencers | 哈希/流命令 |
| HLD.IF.INT.PQC.SQZ | output | `pqc_sampler` | squeeze 字节流 |

#### Non-Responsibility

- 不执行采样判定；
- 不解析算法结构；
- 不允许软件抢占 context。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.SAMPLER — 采样器

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.SAMPLER
name: pqc_sampler
responsibility: rejection/CBD/ExpandA/ExpandS/ExpandMask/SampleInBall 采样
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.DSA_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.SQZ
- HLD.IF.INT.PQC.PAGE
END_HLD_MODULE_META -->

#### Responsibility

从 SHAKE squeeze 流按 mode 产生系数：KEM uniform/rejection、KEM CBD、DSA uniform matrix、
DSA eta、DSA gamma1 mask、DSA SampleInBall；XOF squeeze 自动续块。

#### Architecture Role

把"字节流 → 系数"的规范映射集中，拒绝的候选不写入 polynomial buffer，保证 buffer 中
只有合法系数。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.SQZ | input | `pqc_keccak` | squeeze 字节 |
| HLD.IF.INT.PQC.PAGE | output | `pqc_secure_sram_ctrl` | 写入系数页 |

#### Non-Responsibility

- 不实现 permutation；
- 不做字节编码（pack/unpack）；
- 不做范数检查。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.CODEC — 编解码与 rounding

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.CODEC
name: pqc_codec
responsibility: bit pack/unpack、Compress/Decompress、Power2Round/HighBits/LowBits/MakeHint/UseHint、norm
  check
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_VERIFY.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.RANDOM
- HLD.IF.INT.PQC.PRIM
- HLD.IF.INT.PQC.PAGE
END_HLD_MODULE_META -->

#### Responsibility

任意 bit offset 的 little-endian bit packing、参数集相关压缩/解压、DSA rounding/hint
计算与全系数遍历的 norm check（OR-reduce，不在首个违例处停止）。

#### Architecture Role

规范编码的唯一边界；`canonical_ok` 输出与"始终消费配置长度"共同保证解析侧信道最小化。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.PRIM | input | sequencers | codec 命令 |
| HLD.IF.INT.PQC.PAGE | input/output | `pqc_secure_sram_ctrl` | coefficient/packed buffer |

#### Non-Responsibility

- 不生成随机字节；
- 不执行 NTT；
- 不做采样拒绝判定。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。


## Level 2 各资源责任

KECCAK 持有两 share 状态与 HPC3+ χ；POLY 持有隔离算术 share 通路；
CODEC 负责规范域转换、masked 比较/模乘/编码；SAMPLER 负责秘密有效计数、
公开访问与 masked 选择。随机 token 均来自 TOP 的 RANDOM 服务，各资源内部不得
私自扩展 LFSR 代替新鲜随机量。算法指令的依赖和转换调用由 sequencer 显式调度，
不允许 POLY 占用 SRAM 等待 CODEC，而 CODEC 又等待同一 SRAM 授权的循环依赖。
