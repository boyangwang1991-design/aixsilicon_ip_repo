# APB Demux — 接口需求（INTF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 接口需求 / Interface Requirements

### 1.1 上游 APB 从接口

#### LRS.INTF.APB_DEMUX.01.001 上游 APB 从接口提供

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.01.001
category: INTF
feature: upstream_apb_interface
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 对上游应表现为 APB Slave，提供信号：`PCLK`、`PRESETn`、`PADDR`、`PSEL`、
`PENABLE`、`PWRITE`、`PWDATA`、`PRDATA`、`PREADY`、`PSLVERR`。

#### Acceptance Criteria

- 上游接口信号完整且符合 APB 协议时序。

---

#### LRS.INTF.APB_DEMUX.01.002 上游 APB4 扩展字段

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.01.002
category: INTF
feature: upstream_apb_interface
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

APB4 profile 下，上游接口应额外提供 `PSTRB`、`PPROT` 信号。APB3 profile 下
这些信号应裁剪。

#### Acceptance Criteria

- APB4 配置下 `PSTRB`/`PPROT` 信号存在并正确参与路由。

---

### 1.2 下游 APB 主接口

#### LRS.INTF.APB_DEMUX.02.001 下游 APB 主接口提供

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.02.001
category: INTF
feature: downstream_apb_interface
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 对每个下游端口应表现为 APB Master，提供信号：`M_PADDR[i]`、`M_PSEL[i]`、
`M_PENABLE[i]`、`M_PWRITE[i]`、`M_PWDATA[i]`、`M_PRDATA[i]`、`M_PREADY[i]`、
`M_PSLVERR[i]`，其中 `i = 0 ... NUM_SLAVES-1`。

#### Acceptance Criteria

- 每个下游端口信号完整且符合 APB Master 时序；
- 下游端口数量等于 `NUM_SLAVES`。

---

#### LRS.INTF.APB_DEMUX.02.002 下游 APB4 扩展字段

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.02.002
category: INTF
feature: downstream_apb_interface
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

APB4 profile 下，每个下游接口应额外提供 `M_PSTRB[i]`、`M_PPROT[i]` 信号。

#### Acceptance Criteria

- APB4 配置下 `M_PSTRB[i]`/`M_PPROT[i]` 存在并与上游捕获的 payload 一致。

---

### 1.3 时钟与复位接口

#### LRS.INTF.APB_DEMUX.03.001 单时钟域接口

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.03.001
category: INTF
feature: clock_reset
priority: P0
status: active
verification_method:
  - review
END_LRS_META -->

#### Requirement

IP 应使用单一 `PCLK` 时钟域，上游与所有下游端口共享同一时钟。本 IP 不提供
跨时钟域访问能力。

#### Acceptance Criteria

- 所有端口共享单一 `PCLK`；
- 跨时钟访问应通过独立 APB CDC Bridge 完成（out of scope）。

---

#### LRS.INTF.APB_DEMUX.03.002 复位接口

<!-- LRS_META
id: LRS.INTF.APB_DEMUX.03.002
category: INTF
feature: clock_reset
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应使用 `PRESETn` 作为复位输入，复位期间所有下游 `M_PSEL[i]` 应保持无效。

#### Acceptance Criteria

- Reset 期间无有效下游 transaction 产生。

---
