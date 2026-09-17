# PQC LRS：性能需求

性能门限在工艺、频率、SRAM 宏与安全等级确定后冻结。以下为 G1 规划目标（2-lane、
400 MHz 目标频率的规划值，非既成事实），本轮以 RTL cycle model 与仿真周期分析核对，不进行物理频率签核。

### LRS.PERF.PQC.OVERLAP.001 计算与 DMA 重叠

<!-- LRS_META
id: LRS.PERF.PQC.OVERLAP.001
category: PERF
feature: perf_overlap
priority: P0
status: active
source_ref:
- pqc_contract.md#§6
applicability:
  expr: 'true'
verification_method:
- simulation
- performance_analysis
END_LRS_META -->

#### Requirement

计算与 DMA 应可在安全的资源条件下重叠，保留 1/2 轮结构配置，并按安全等级
分别制定可达周期预算。令 R 为 rate 字节数、r 为轮结构配置：

- Level 0/1：完整消息块预算 C_block = ceil(R/8) + 24/r + 2 个核心周期。
- Level 2：完整消息块预算由吸收、受保护置换、随机服务和控制的完整调度推导，
  不要求沿用 24/r。HLD 应给出有数值的保守目标和随机服务条件，LLD 固化逐阶段
  周期上界，RTL 按同一边界验收。无数值预算、遗漏转换/刷新或仅计算原语理想周期
  均不视为通过。分级预算不允许降低 Level 2 掩码实现与验证范围。

连续完整块有效吞吐应不低于 R/C_block B/cycle；不再以 AXI 峰值固定比例验收。
安全随机输入的外部缺供单列，DUT 内部收集、分配、刷新和仲裁计入预算。
掩码初始化计入首块，不藏入测量窗口外的重复初始化；每次重新初始化均须报告。

验收测量窗口不含首块启动和末块 padding，但须计入内部存储、仲裁和控制等待。
外部源/AXI 背压单独报告原始总周期与外部等待周期，不得以 DUT 自己产生的背压
作为扣除项。总线与消息源能够持续供数时不得扣除任何内部等待。

#### Acceptance Criteria

- 消息吸收期间出现 Keccak 与 DMA 并行活动；
- 各安全等级稳态完整块周期不超过对应 C_block，实测周期与分项计数一致；
- 四种哈希函数、r=1/2 与三个安全等级分别验收，所有 DMA 宽度保持结果一致；
- 明确报告总吞吐与外部等待调整后的吞吐，不修改原始计数；
- 重叠不改变算法结果。

---

### LRS.PERF.PQC.NOSW.001 无软件算法回退

<!-- LRS_META
id: LRS.PERF.PQC.NOSW.001
category: PERF
feature: perf_nosw
priority: P0
status: active
source_ref:
- pqc_contract.md#§6
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

任一标准参数集不得依赖软件执行 NTT、采样、pack/unpack 或重加密比较；这些应完全由
硬件完成。

#### Acceptance Criteria

- 驱动无需实现任何算法级原语；
- 命令完成不产生需要软件续算的中间状态；
- 无算法级中断回调。

---

### LRS.PERF.PQC.LATENCY.001 操作延迟目标

<!-- LRS_META
id: LRS.PERF.PQC.LATENCY.001
category: PERF
feature: perf_latency
priority: P1
status: active
source_ref:
- pqc_contract.md#§6
- pqc_contract.md#§22
applicability:
  expr: 'NTT_LANES>=2'
verification_method:
- simulation
- performance_analysis
END_LRS_META -->

#### Requirement

在 Balanced 配置（2 lane、400 MHz）下应满足：ML-KEM-768 Encaps/Decaps 各小于
100 us；ML-DSA-65 Verify 小于 250 us；ML-DSA Sign 以统计分位数验收，P50 小于
300 us、P99 小于 1 ms。

#### Acceptance Criteria

- cycle model 预测值与 RTL 仿真测量一致；
- Sign 报告 P50/P95/P99 分位数而非单一 worst-case；
- 以规划频率换算的延迟明确标注为估算，不声称已实现该物理频率。

---

### LRS.PERF.PQC.SIGNBUBBLE.001 Sign 无冗余 bubble

<!-- LRS_META
id: LRS.PERF.PQC.SIGNBUBBLE.001
category: PERF
feature: perf_sign_bubble
priority: P1
status: active
source_ref:
- pqc_contract.md#§6
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

ML-DSA Sign 一次尝试内不应产生非必要 pipeline bubble；拒绝后应复用已合法保留的
消息摘要状态，不重新哈希消息。

#### Acceptance Criteria

- 拒绝轮次之间不重复消息吸收；
- 非拒绝相关 stall 被计量并记录；
- 复用不改变签名结果。

---

### LRS.PERF.PQC.MODEL.001 解析 cycle model

<!-- LRS_META
id: LRS.PERF.PQC.MODEL.001
category: PERF
feature: perf_model
priority: P1
status: active
source_ref:
- pqc_contract.md#§22
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

应建立解析 cycle model：
`T = N_perm*T_keccak + N_ntt*T_ntt + N_mac*T_mac + N_codec*T_codec + T_dma - T_overlap + T_control`。
每个 SKU 应输出每类 operation 的 cycle breakdown、本地 SRAM 峰值、DMA 字节数、
Keccak/NTT utilization；本轮另分析运算资源、存储端口、组合深度及无效切换来源，
不要求输出实测动态功耗或物理面积。

#### Acceptance Criteria

- 模型可复现且与 RTL 周期测量误差在声明范围内；
- 每 SKU 输出完整 breakdown；
- 模型不依赖非生产 debug shortcut。

## 吞吐目标变更依据

用户确认：“保留 1/2 轮结构，按可达周期预算制定吞吐指标”。
旧目标为持续消息哈希 ≥ 主机 DMA 带宽 50%；本轮替换为上述周期预算，
其依据是顺序 sponge 的轮数上界与每周期最多 8 B 的吸收预算。
本次变更不放宽哈希正确性、私钥边界、算法功能或安全性要求。

2026-09-16 用户确认：“按安全等级分别制定周期预算（推荐）”。该授权调整上述吞吐
指标的安全等级适用范围，不豁免 Level 2 功能与安全验证，也不批准下游阶段冻结。
