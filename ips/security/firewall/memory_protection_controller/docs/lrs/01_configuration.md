# AXI Memory Protection Unit — 配置需求（CFG）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. Configuration Model

AXI MPU 是 **Generator IP**：Generator 决定硬件结构与规模，Runtime 寄存器定义
实际地址段与访问策略。

配置类别：

| 类别 | 说明 |
|------|------|
| `generator` | Generator 执行前输入，决定 RTL topology（Region 数、Master 数、位宽、功能使能、pipeline） |
| `runtime` | APB4 寄存器运行时配置（Region BASE/LIMIT、MASTER_MASK、权限位、Lock） |

## 1.1 命名配置（产品配置）

以下是本 IP 的命名产品配置（`model/parameter_space.yaml` 的 `configurations` 段，
由 `extract_parameters.py` 从 `CONFIG_META` 抽取；对应 contract §43 默认生成模型）。

<!-- CONFIG_META
id: CFG_MAIN
purpose: "Axi MPU 主配置：REGION_NUM=16, MASTER_NUM=8, ADDR_WIDTH=48, DATA_WIDTH=128, ID_WIDTH=8, 全部功能使能，PIPELINE=0"
values:
  ADDR_WIDTH: 48
  DATA_WIDTH: 128
  ID_WIDTH: 8
  MASTER_NUM: 8
  MASTER_ID_WIDTH: 4
  REGION_NUM: 16
  READ_OUTSTANDING: 8
  WRITE_OUTSTANDING: 8
  HAS_EXECUTE: true
  HAS_MASTER_ATTR: true
  HAS_IRQ: true
  HAS_VIOLATION_LOG: true
  PIPELINE: 0
  WRAP_SUPPORT: true
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_MINIMAL
purpose: "最小裁剪配置：REGION_NUM=4, MASTER_NUM=2, 无 IRQ/Violation Log/Execute，用于面积敏感场景"
values:
  ADDR_WIDTH: 32
  DATA_WIDTH: 32
  ID_WIDTH: 4
  MASTER_NUM: 2
  MASTER_ID_WIDTH: 1
  REGION_NUM: 4
  READ_OUTSTANDING: 2
  WRITE_OUTSTANDING: 2
  HAS_EXECUTE: false
  HAS_MASTER_ATTR: true
  HAS_IRQ: false
  HAS_VIOLATION_LOG: false
  PIPELINE: 0
  WRAP_SUPPORT: false
END_CONFIG_META -->

## 2. Generator Configuration Summary

> 参数契约由各 `LRS.CFG.*` 需求条目后的 extractor 参数表（`| 参数名 | 类型 |
> 合法值域 | 默认值 | 类别 | 约束 |`）承载，`model/parameter_space.yaml` 由
> `extract_parameters.py` 确定性抽取（派生数据、只读）。

| Parameter | Kind | Type | Default | Legal Values | 对应需求 ID |
|-----------|------|------|---------|--------------|-------------|
| `ADDR_WIDTH` | generator | int | 48 | 32–64 | `LRS.CFG.AXI_MPU.ADDR_WIDTH.001` |
| `DATA_WIDTH` | generator | int | 128 | 32/64/128/256/512 | `LRS.CFG.AXI_MPU.DATA_WIDTH.001` |
| `ID_WIDTH` | generator | int | 8 | 1–16 | `LRS.CFG.AXI_MPU.ID_WIDTH.001` |
| `MASTER_NUM` | generator | int | 8 | 1–64 | `LRS.CFG.AXI_MPU.MASTER_NUM.001` |
| `MASTER_ID_WIDTH` | generator | int | 4 | `$clog2(MASTER_NUM)`–16 | `LRS.CFG.AXI_MPU.MASTER_ID_WIDTH.001` |
| `REGION_NUM` | generator | int | 16 | 1–64（不要求 2 的幂） | `LRS.CFG.AXI_MPU.REGION_NUM.001` |
| `READ_OUTSTANDING` | generator | int | 8 | 1/2/4/8/16 | `LRS.CFG.AXI_MPU.OUTSTANDING.001` |
| `WRITE_OUTSTANDING` | generator | int | 8 | 1/2/4/8/16 | `LRS.CFG.AXI_MPU.OUTSTANDING.001` |
| `HAS_EXECUTE` | generator | bool | 1 | 0/1 | `LRS.CFG.AXI_MPU.FEATURE.001` |
| `HAS_MASTER_ATTR` | generator | bool | 1 | 0/1 | `LRS.CFG.AXI_MPU.FEATURE.001` |
| `HAS_IRQ` | generator | bool | 1 | 0/1 | `LRS.CFG.AXI_MPU.FEATURE.001` |
| `HAS_VIOLATION_LOG` | generator | bool | 1 | 0/1 | `LRS.CFG.AXI_MPU.FEATURE.001` |
| `PIPELINE` | generator | enum | 0 | 0（组合）/1（1-stage） | `LRS.CFG.AXI_MPU.PIPELINE.001` |
| `WRAP_SUPPORT` | generator | bool | 1 | 0/1 | `LRS.CFG.AXI_MPU.BURST.001` |

## 3. Configuration Requirements

### 3.1 地址位宽

#### LRS.CFG.AXI_MPU.ADDR_WIDTH.001 可配置地址位宽

<!-- LRS_META
id: LRS.CFG.AXI_MPU.ADDR_WIDTH.001
category: CFG
feature: ADDR_WIDTH
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `ADDR_WIDTH` | int | 32..64 | 48 | compile_time | 无 |

#### Requirement

Generator 应支持可配置的 AXI 地址位宽 `ADDR_WIDTH`，合法范围 32–64，默认 48。

#### Acceptance Criteria

- 生成器接受 `ADDR_WIDTH ∈ [32,64]` 并产生对应位宽的比较逻辑；
- 地址位宽影响 `REGION_BASE`/`REGION_LIMIT` 与 `VIOL_ADDR` 寄存器位宽。

---

### 3.2 数据与 ID 位宽

#### LRS.CFG.AXI_MPU.DATA_WIDTH.001 可配置数据位宽

<!-- LRS_META
id: LRS.CFG.AXI_MPU.DATA_WIDTH.001
category: CFG
feature: DATA_WIDTH
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `DATA_WIDTH` | int | [32, 64, 128, 256, 512] | 128 | compile_time | 无 |

#### Requirement

Generator 应支持可配置的 AXI 数据位宽 `DATA_WIDTH`，合法值 32/64/128/256/512，
默认 128。

#### Acceptance Criteria

- 生成器接受 `DATA_WIDTH` 取值并产生对应宽度 datapath；
- 数据位宽不改变权限判定逻辑。

---

#### LRS.CFG.AXI_MPU.ID_WIDTH.001 可配置 ID 位宽

<!-- LRS_META
id: LRS.CFG.AXI_MPU.ID_WIDTH.001
category: CFG
feature: ID_WIDTH
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `ID_WIDTH` | int | 1..16 | 8 | compile_time | 无 |

#### Requirement

Generator 应支持可配置的 AXI ID 位宽 `ID_WIDTH`，合法范围 1–16，默认 8。

#### Acceptance Criteria

- 生成器接受 `ID_WIDTH` 并产生对应宽度 AXI ID 通道。

---

### 3.3 Master 规模

#### LRS.CFG.AXI_MPU.MASTER_NUM.001 可配置 Master 数量

<!-- LRS_META
id: LRS.CFG.AXI_MPU.MASTER_NUM.001
category: CFG
feature: MASTER_NUM
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `MASTER_NUM` | int | 1..64 | 8 | structural | 无 |

#### Requirement

Generator 应支持可配置的 Master 身份数量 `MASTER_NUM`，合法范围 1–64，默认 8。
`MASTER_MASK` 位宽与 `MASTER_ATTR` 数组长度应等于 `MASTER_NUM`。

#### Acceptance Criteria

- 生成器接受 `MASTER_NUM` 并产生对应位宽 `MASTER_MASK` 与 `MASTER_ATTR` 数组；
- `MASTER_ID_WIDTH` 应至少为 `$clog2(MASTER_NUM)`。

---

#### LRS.CFG.AXI_MPU.MASTER_ID_WIDTH.001 可配置 Master ID 位宽

<!-- LRS_META
id: LRS.CFG.AXI_MPU.MASTER_ID_WIDTH.001
category: CFG
feature: MASTER_ID_WIDTH
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `MASTER_ID_WIDTH` | int | 1..16 | 4 | compile_time | MASTER_ID_WIDTH >= $clog2(MASTER_NUM) |

#### Requirement

Generator 应支持可配置的 Master ID 位宽 `MASTER_ID_WIDTH`，合法范围
`$clog2(MASTER_NUM)` 至 16，默认 4。非法 Master ID（`master_id >= MASTER_NUM`）
必须被拒绝。

#### Acceptance Criteria

- `master_id >= MASTER_NUM` 时访问被拒绝且记录为 `INVALID_CONTEXT` 原因。

---

### 3.4 Region 规模

#### LRS.CFG.AXI_MPU.REGION_NUM.001 可配置 Region 数量

<!-- LRS_META
id: LRS.CFG.AXI_MPU.REGION_NUM.001
category: CFG
feature: REGION_NUM
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `REGION_NUM` | int | 1..64 | 16 | structural | 无 |

#### Requirement

Generator 应支持可配置的 Protection Region 数量 `REGION_NUM`，合法范围 1–64，
默认 16。推荐支持 4/8/16/32。实现不得假设 `REGION_NUM` 必须是 2 的幂。

#### Acceptance Criteria

- 生成器接受任意合法 `REGION_NUM`（含非 2 的幂如 6/12）并正确生成比较器阵列；
- 非 2 的幂 Region 数不影响功能正确性。

---

### 3.5 Outstanding 深度

#### LRS.CFG.AXI_MPU.OUTSTANDING.001 可配置 Outstanding 深度

<!-- LRS_META
id: LRS.CFG.AXI_MPU.OUTSTANDING.001
category: CFG
feature: OUTSTANDING
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `READ_OUTSTANDING` | int | [1, 2, 4, 8, 16] | 8 | structural | 无 |
| `WRITE_OUTSTANDING` | int | [1, 2, 4, 8, 16] | 8 | structural | 无 |

#### Requirement

Generator 应支持独立可配置的 `READ_OUTSTANDING` 与 `WRITE_OUTSTANDING`，合法值
1/2/4/8/16，默认 8。MPU 不得因为 permission check 强制 AXI 降级为单 outstanding。

#### Acceptance Criteria

- 生成器接受 1–16 的 outstanding 深度并产生对应深度队列；
- 多 outstanding 流量下无功能性降级。

---

### 3.6 功能使能

#### LRS.CFG.AXI_MPU.FEATURE.001 可裁剪功能使能

<!-- LRS_META
id: LRS.CFG.AXI_MPU.FEATURE.001
category: CFG
feature: HAS_
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `HAS_EXECUTE` | bool | [0, 1] | 1 | structural | 无 |
| `HAS_MASTER_ATTR` | bool | [0, 1] | 1 | structural | 无 |
| `HAS_IRQ` | bool | [0, 1] | 1 | structural | 无 |
| `HAS_VIOLATION_LOG` | bool | [0, 1] | 1 | structural | 无 |

#### Requirement

Generator 应支持按功能裁剪：`HAS_EXECUTE`、`HAS_MASTER_ATTR`、`HAS_IRQ`、
`HAS_VIOLATION_LOG` 均为布尔开关（默认 1）。裁剪后对应逻辑与寄存器位不应存在于
生成 RTL 中。

#### Acceptance Criteria

- `HAS_IRQ=0` 时无 IRQ 输出与 IRQ 寄存器；
- `HAS_EXECUTE=0` 时不检查 `EXECUTE_ALLOW`；
- `HAS_VIOLATION_LOG=0` 时无 violation 寄存器组。

---

### 3.7 Pipeline

#### LRS.CFG.AXI_MPU.PIPELINE.001 可配置 Pipeline

<!-- LRS_META
id: LRS.CFG.AXI_MPU.PIPELINE.001
category: CFG
feature: PIPELINE
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `PIPELINE` | enum | [0, 1] | 0 | compile_time | 无 |

#### Requirement

Generator 应支持配置 Permission Engine pipeline：`0`（combinational）或 `1`
（1-stage pipeline），默认 0。目标为支持 1 AXI address request / cycle，不得因
region matching 引入不必要 bubble。

#### Acceptance Criteria

- `PIPELINE=0` 时组合判定路径延迟最小；
- `PIPELINE=1` 时吞吐保持 1 request/cycle 且无协议违约。

---

### 3.8 Burst 支持

#### LRS.CFG.AXI_MPU.BURST.001 可裁剪 WRAP 支持

<!-- LRS_META
id: LRS.CFG.AXI_MPU.BURST.001
category: CFG
feature: WRAP_SUPPORT
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - static
END_LRS_META -->

| `WRAP_SUPPORT` | bool | [0, 1] | 1 | compile_time | 无 |

#### Requirement

Generator 应允许裁剪 WRAP burst 支持（`WRAP_SUPPORT=0`）。INCR 与 FIXED 必须始终
支持。FULL AXI4 Profile 默认支持 WRAP。

#### Acceptance Criteria

- `WRAP_SUPPORT=0` 时 WRAP burst 输入被拒绝或按配置策略处理；
- INCR/FIXED 在任意 Profile 下均受保护。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
