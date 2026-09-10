# AXI Memory Protection Unit — 接口需求（INTF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 接口概览 / Interface Overview

| 接口组 | 方向 | 协议 | 说明 |
|--------|------|------|------|
| `S_AXI` | Slave | AXI4 Full | 上游 Master 访问（受保护 datapath 入口） |
| `M_AXI` | Master | AXI4 Full | 下游 Slave / Interconnect（允许路径转发） |
| `APB4` | Slave | APB4 | 配置接口（Region/Master/Lock/Violation 寄存器） |
| `IRQ` | Output | Level | Violation 中断 |
| `RST_N` | Input | Async/Low | 异步复位 |
| `CLK` | Input | — | 主时钟 |

## 2. 接口需求

### 2.1 AXI4 从接口

#### LRS.INTF.AXI_MPU.AXI_SLAVE.001 AXI4 从接口协议

<!-- LRS_META
id: LRS.INTF.AXI_MPU.AXI_SLAVE.001
category: INTF
feature: axi_slave_interface
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-002
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供符合 AXI4 Full 协议规范的从接口 `S_AXI`，支持独立的 AR/R 与 AW/W/B
通道以及完整的 AXI burst（INCR/FIXED/WRAP）。配置接口 `APB4` 与受保护的 AXI
datapath 必须独立。

#### Acceptance Criteria

- AXI4 协议断言检查通过；
- `S_AXI` 支持合法 burst 的地址握手与数据握手。

---

#### LRS.INTF.AXI_MPU.AXI_SLAVE.002 接口位宽参数

<!-- LRS_META
id: LRS.INTF.AXI_MPU.AXI_SLAVE.002
category: INTF
feature: axi_slave_interface
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

`S_AXI` 与 `M_AXI` 接口位宽应匹配 Generator 参数：`ADDR_WIDTH`、`DATA_WIDTH`、
`ID_WIDTH`。

#### Acceptance Criteria

- 生成 RTL 的端口位宽与 Generator 参数一致。

---

### 2.2 AXI4 主接口

#### LRS.INTF.AXI_MPU.AXI_MASTER.001 AXI4 主接口转发

<!-- LRS_META
id: LRS.INTF.AXI_MPU.AXI_MASTER.001
category: INTF
feature: axi_master_interface
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-002
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供符合 AXI4 Full 协议规范的 `M_AXI` 主接口。合法访问的 AR/AW/W 信号应
转发至 `M_AXI`，来自下游的 R/B 响应应返回至 `S_AXI`。

#### Acceptance Criteria

- 合法事务在 `M_AXI` 上完整出现且 `S_AXI` 收到正确响应；
- 非法事务不出现在 `M_AXI`（断言：Denied AR/AW shall never reach M_AXI）。

---

### 2.3 APB4 配置接口

#### LRS.INTF.AXI_MPU.APB_CFG.001 APB4 配置接口

<!-- LRS_META
id: LRS.INTF.AXI_MPU.APB_CFG.001
category: INTF
feature: apb_config_interface
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-003
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供符合 APB4 协议规范的配置从接口，支持对 Region 配置、Master Attribute、
全局控制/状态、Violation 状态与中断寄存器的读写访问。APB 数据宽度应为 32 位。

#### Acceptance Criteria

- APB4 协议断言检查通过；
- 配置寄存器可经 APB4 正确读写（受 Lock 保护的寄存器除外）。

---

### 2.4 中断接口

#### LRS.INTF.AXI_MPU.IRQ.001 Violation 中断输出

<!-- LRS_META
id: LRS.INTF.AXI_MPU.IRQ.001
category: INTF
feature: irq_interface
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_irq == true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

当 `HAS_IRQ=1` 时，IP 应提供电平型中断输出 `IRQ`。当 violation interrupt enable
置位且发生 protection violation 时置位，采用 sticky 中断并由软件 W1C 清除。

#### Acceptance Criteria

- 使能后 violation 触发 `IRQ=1`；
- 软件 W1C 清除后 `IRQ` 回到 0（无新 violation 时）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
