# AXI Memory Protection Unit — Generator 需求（GEN）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. Generator 需求

### 1.1 Generator 输入输出

#### LRS.GEN.AXI_MPU.INPUT.001 Generator 配置输入

<!-- LRS_META
id: LRS.GEN.AXI_MPU.INPUT.001
category: GEN
feature: generator_io
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

Generator 应接受 YAML 配置输入，至少包含：interface（protocol/addr_width/
data_width/id_width）、protection（region_num/master_num/secure/privilege/
execute/master_identity/master_security_attribution）、region
（runtime_configurable/address_mode/overlap_policy）、transaction
（read_outstanding/write_outstanding/fixed_burst/incr_burst/wrap_burst/
burst_boundary_check）、violation（logging/irq/counter/capture_policy）、
configuration（interface=apb4）、implementation（pipeline）。

#### Acceptance Criteria

- Generator 接受契约 §43 的 YAML 结构；
- 非法配置被校验拒绝。

---

#### LRS.GEN.AXI_MPU.OUTPUT.001 Generator 输出

<!-- LRS_META
id: LRS.GEN.AXI_MPU.OUTPUT.001
category: GEN
feature: generator_io
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

Generator 应输出可综合 SystemVerilog RTL（含 CSR RTL）、寄存器模型（SystemRDL
派生）、C header 与 FuseSoC core。行为逻辑用 SystemVerilog，结构变化用 Python
Hardware IR/Graph 表达。

#### Acceptance Criteria

- 生成 RTL 通过 lint/elaboration；
- CSR RTL/C header 与 SystemRDL 一致。

---

### 1.2 确定性生成

#### LRS.GEN.AXI_MPU.DETERMINISM.001 确定性生成

<!-- LRS_META
id: LRS.GEN.AXI_MPU.DETERMINISM.001
category: GEN
feature: determinism
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

#### Requirement

相同 Generator 配置输入应产生逐字节一致的 RTL 输出（确定性生成）。

#### Acceptance Criteria

- 两次生成产物哈希一致。

---

### 1.3 结构与规模

#### LRS.GEN.AXI_MPU.STRUCTURE.001 结构裁剪

<!-- LRS_META
id: LRS.GEN.AXI_MPU.STRUCTURE.001
category: GEN
feature: structure_scaling
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

Generator 应根据 Region 数选择不同结构：`REGION_NUM <= 4` 用 Flat comparator；
`<= 16` 用 Parallel comparator + priority tree；`> 16` 用 Hierarchical match +
optional pipeline。具体 threshold 属于 implementation policy，不构成 architectural
software contract。Generator 不得把普通 Region 地址与访问策略直接硬编码进 RTL
（除非选择 Static Region Profile）。

#### Acceptance Criteria

- Region 数变化时生成器选择对应结构；
- 默认配置为 runtime configurable Region。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
