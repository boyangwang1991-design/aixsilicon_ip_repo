# PQC 加速器高层设计：性能与容量架构

## 代码结构与周期预算

本轮不开展物理 PPA 表征。400 MHz 只用于规划周期换算；不声称达到该实际频率。
预算对象为运算资源、每块周期、存储逻辑容量和端口压力。用户已确认保留 1/2 轮结构，
以可达周期预算替代 DMA 峰值 50% 目标，授权见 `docs/reviews/g0_throughput_authorization.md`。

| 维度 | 预算口径 |
|---|---|
| 频率 | 400 MHz 仅为周期换算规划，不宣称物理收敛 |
| 面积 | lane/share/gadget、数据存储与端口计量 |
| 功耗 | 翻转、随机流量与公开条件门控的结构分析 |
| 安全增量 | Level 2 双域存储、寄存器隔离与随机缓存另计 |

本轮不执行实测 PPA 签核，遵从 LRS 的 ppa_signoff=none。
---

### HLD.PERF.PQC.KEM768

<!-- HLD_PERF_META
id: HLD.PERF.PQC.KEM768
req_ref:
- LRS.PERF.PQC.LATENCY.001
metric: latency
target: ML-KEM-768 Encaps < 100us, Decaps < 100us @400MHz 2-lane
allocated_to:
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
applicability:
  expr: 'NTT_LANES>=2'
END_HLD_PERF_META -->

---

### HLD.PERF.PQC.DSA65VERIFY

<!-- HLD_PERF_META
id: HLD.PERF.PQC.DSA65VERIFY
req_ref:
- LRS.PERF.PQC.LATENCY.001
metric: latency
target: ML-DSA-65 Verify < 250us @400MHz 2-lane
allocated_to:
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.POLY
applicability:
  expr: 'NTT_LANES>=2'
END_HLD_PERF_META -->

---

### HLD.PERF.PQC.DSA65SIGN

<!-- HLD_PERF_META
id: HLD.PERF.PQC.DSA65SIGN
req_ref:
- LRS.PERF.PQC.LATENCY.001
- LRS.PERF.PQC.SIGNBUBBLE.001
metric: latency
target: ML-DSA-65 Sign P50 < 300us, P99 < 1ms（统计分位数）
allocated_to:
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.CODEC
applicability:
  expr: 'NTT_LANES>=2'
END_HLD_PERF_META -->

---

### HLD.PERF.PQC.HASHBW

<!-- HLD_PERF_META
id: HLD.PERF.PQC.HASHBW
req_ref:
- LRS.PERF.PQC.OVERLAP.001
metric: throughput
target: Level 0/1 C_block <= ceil(rate_bytes/8)+24/KECCAK_ROUNDS_PER_CYCLE+2；Level 2 C_block <= ceil(rate_bytes/8)+1896+2，随机输入持续 64 bit/cycle
allocated_to:
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.DMA
applicability:
  expr: 'true'
END_HLD_PERF_META -->

---

### HLD.PERF.PQC.SRAM

<!-- HLD_PERF_META
id: HLD.PERF.PQC.SRAM
req_ref:
- LRS.CFG.PQC.LOCAL_SRAM.001
- LRS.FUNC.PQC.KEM_DATAFLOW.001
metric: capacity
target: 峰值工作集 <= LOCAL_SRAM_KIB，矩阵不常驻
allocated_to:
- HLD.MOD.PQC.SRAM
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## 延迟预算归属

| Phase | Budget Owner | Notes |
|---|---|---|
| descriptor fetch + validate | `pqc_cmd_frontend` | 与算法无关的固定开销 |
| Keccak permutations | `pqc_keccak` | `N_perm` 主导 KEM/KeyGen/Sign |
| NTT/INTT stages | `pqc_poly_engine` | `N_ntt`，包括操作数收集、bank 冲突及写回，不假定严格反比 |
| Sampling | `pqc_sampler` | 与 XOF 字节消耗相关 |
| Codec | `pqc_codec` | pack/unpack 与 norm check |
| DMA | `pqc_dma` | 可与计算重叠部分扣除 `T_overlap` |
| Control | sequencers | scoreboard 与分支开销 |

## 容量预算与生命周期

逻辑 polynomial 页为 1 KiB（256×32 bit），Tiny 有 32 页。工作态 Key RAM 另外提供
8 KiB，不与该预算重复计算。ECC 与有效位/标签为额外物理位数，不伪装为可用数据容量。

| 操作阶段 | 同时存活的数据页预算 | 页数上界 |
|---|---|---:|
| KEM KeyGen/Encaps/Decaps | 两个最大向量 8、矩阵/累加/临时 4、公开输入 4、输出/重加密比较 4、流缓冲 2、保留 2 | 24 |
| DSA KeyGen | s1 7、当前矩阵/累加/s2 3、公钥 staging 3、编码临时 3、流缓冲 2、保留 2 | 20 |
| DSA Sign 矩阵阶段 | y 的 NTT 向量 7、w 行结果 8、矩阵/累加/变换临时 3、packed w1 1、消息流 2、保留 2 | 23 |
| DSA Sign 检查/编码阶段 | w 8、z 7、c 1、私钥逐多项式解码/变换/乘积 3、签名 staging 5、流缓冲 2、保留 2 | 28 |
| DSA Verify | z 的 NTT 向量 7、公钥 3、签名 5、矩阵/累加/t1/c 临时 4、流缓冲 2、保留 2 | 23 |

Sign 在挑战哈希确定后释放 y 的 NTT 向量，利用同一 rho''/nonce 重放 y 来形成 z；
秘密 s1/s2/t0 从工作态 Key RAM 逐多项式解码并变换，避免三整向量同时常驻。
w 行在完成对应 r0/c*t0/hint 后退休，签名编码只保留 staging 与必要 z。
这以重复采样/变换换取 Tiny 容量；LLD 的 cycle model 必须计入重算成本。

上述是有语义角色的分配上界，不是 RTL 已实现的测量。LLD 必须给出阶段分配、
最后消费者和复用检查；不能用总数小于 32 代替地址无别名/页授权证明。

## Level 0/1 持续哈希预算

64-bit rate 侧吸收，尾字节 mask，不增加 Keccak permutation 实例。
完整块先按 8 B/cycle 装入 state，随后执行 24/r 个置换周期，留两周期控制预算。
下一块可由 DMA 预取到另一公开 buffer，但同一 sponge 的 state 更新不得重排。

| 函数 | rate B | r=1 周期/块 | r=2 周期/块 | r=1 B/cycle | r=2 B/cycle |
|---|---:|---:|---:|---:|---:|
| SHA3-256 / SHAKE256 | 136 | 43 | 31 | 3.163 | 4.387 |
| SHA3-512 | 72 | 35 | 23 | 2.057 | 3.130 |
| SHAKE128 | 168 | 47 | 35 | 3.574 | 4.800 |

当前 byte RTL 未达到这些目标，必须加宽数据接口与本地供数。每个 8 B 读取需要两个
32-bit bank 提供数据；真实内部等待计入周期。外部背压、首块与最后 padding 分别报告，
不通过 DUT 主动拉低 ready 来扣除内部等待。XOF 输出另计 ceil(output_bytes/8) 与续块置换。
两 context 保存消息与采样状态是上下文复用，不提高单条消息的 sponge 理论上界。

## 架构优化策略

| 维度 | 策略 |
|---|---|
| 性能 | 双模蝶形 lane 参数化；Keccak 与 NTT 重叠；Sign 拒绝后复用消息摘要状态 |
| 面积 | 双模共享单一蝶形数据路径；矩阵流式生成不常驻；DSA rounding/hint 可旁路 |
| 功耗 | 公开状态下时钟门控；重叠减少串行周期；禁止秘密相关门控 |

## 解析 cycle model

`T_operation = N_perm*T_keccak + N_ntt*T_ntt + N_mac*T_mac + N_codec*T_codec + T_dma - T_overlap + T_control`

ML-DSA Sign 分别统计 per-attempt latency 与 attempt count 分布；系统 SLA 使用
P50/P95/P99，不使用不可保证的单一 worst-case。KEM 与 Verify 规定确定性最大周期数。

## Level 2 持续哈希预算

用户已授权按安全等级分列。候选 HPC3+ 两 share 架构采用保守、无重叠的随机数
收集与计算预算：每轮 4800 bit，64 bit/cycle 持续供给时先收集 75 周期，另留
4 周期用于线性变换、gadget 寄存器隔离和轮结果更新。因此置换预算为
24 × (75+4) = 1896 周期，C_block = ceil(R/8)+1896+2。

| 函数 | rate B | Level 2 周期/块 | B/cycle |
|---|---:|---:|---:|
| SHA3-256 / SHAKE256 | 136 | 1915 | 0.071018 |
| SHA3-512 | 72 | 1907 | 0.037756 |
| SHAKE128 | 168 | 1919 | 0.087546 |

这是一项待 LLD/RTL 证明的保守目标，不是已达性能。r=1/2 两种结构均使用此预算，
不能把两个受保护轮串接的寄存器延迟抹去后声称周期减半。随机收集缓存至少承载
一轮 4800 bit，即 600 B，独立于逻辑 polynomial 页。禁止借预取隐去持续随机带宽。
64-bit rate 接口在 Level 2 为每个 share 独立供数；每拍两份 share 共 128 bit，
存储端口按两域各两个 32-bit word 计量。当前 RTL 尚无该供数能力。

初始随机零 sharing 需要 1600 bit，预留 25 拍随机装入与 1 拍控制，共 26 周期，
计入首块。重新初始化和上下文刷新必须按发生次数计量。χ 的输出刷新已包含在
HPC3+ 三个 fresh bit/AND 中；若实际组合验证需要额外刷新，须重开预算评审，
不能靠删去防护满足周期数。上下文保存/恢复在命令周期明细中另外列项。

此表仅覆盖独立哈希流；算法命令还需采样、A2B/B2A、模乘、检查和数据搬运预算。
同周期其他模块争用随机输入时，内部仲裁等待计入算法延迟，不当作外部缺供扣除。
首块初始化、尾块 padding、XOF 输出及外部随机源等待单列原始计数。
