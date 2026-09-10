# AXI Memory Protection Unit（AXI MPU）— 逻辑需求规格（LRS）

> **IP Name**: `axi_mpu`
> **Document**: LRS-AXI_MPU-V100
> **Status**: Draft

## 文档索引

| 章节 | 文件 | 内容 |
|------|------|------|
| 0 | [00_overview.md](00_overview.md) | 文档控制 + 建模规则 + IP Overview（含 `LRS_DOC_META`） |
| 1-3 | [01_configuration.md](01_configuration.md) | Configuration Model + Dependencies（CFG） |
| 5 | [02_interface.md](02_interface.md) | Interface Requirements（INTF） |
| 6 | [03_functional.md](03_functional.md) | Functional Requirements（FUNC） |
| 7 | [04_register.md](04_register.md) | Register Requirements（REG） |
| 8 | [05_performance.md](05_performance.md) | Performance Requirements（PERF） |
| 9 | [06_clock_reset.md](06_clock_reset.md) | Clock & Reset Requirements（RESET） |
| 10 | [07_low_power.md](07_low_power.md) | Low Power（LP） |
| 11 | [08_safety.md](08_safety.md) | Functional Safety（SAFE） |
| 12 | [09_security.md](09_security.md) | Security（SEC） |
| 13 | [10_dfx.md](10_dfx.md) | DFX / Observability（DFX） |
| 14 | [11_generator.md](11_generator.md) | Generator Requirements（GEN） |
| 12 | [12_constraints.md](12_constraints.md) | Integration Constraints（CONS） |
| Gate | [99_quality_gate.md](99_quality_gate.md) | G0 门禁（`LRS_GATE_META`） |

## 上游输入

| ID | 输入文档 | 版本 | 类型 | 说明 |
|----|---------|------|------|------|
| SRC-001 | [`memory_protection_controller_contract.md`](../../memory_protection_controller_contract.md) | Draft | Requirement | AXI MPU 需求与架构规格契约 |
| SRC-002 | AMBA AXI and ACE Protocol Specification (AXI4) | IH0022 | Specification | AXI4 协议规范 |
| SRC-003 | AMBA APB Protocol Specification (APB4) | IHI0024 | Specification | APB4 配置接口协议规范 |
| SRC-004 | AIXSILICON Security Policy | 1.0 | Constraint | 系统安全策略约束 |
