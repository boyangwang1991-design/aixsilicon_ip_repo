# APB Demux — 约束需求（CONS）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 约束需求 / Integration Constraints

### 1.1 配置合法性校验

#### LRS.CONS.APB_DEMUX.01.001 端口数量约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.001
category: CONS
feature: config_validation
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

配置校验脚本应检查 `NUM_SLAVES > 0`。

#### Acceptance Criteria

- `NUM_SLAVES <= 0` 时配置校验报错。

---

#### LRS.CONS.APB_DEMUX.01.002 地址范围约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.002
category: CONS
feature: config_validation
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

配置校验脚本应检查所有地址（`BASE_ADDR`、`ADDR_MASK`）在 `ADDR_WIDTH` 表示
范围以内。

#### Acceptance Criteria

- 超出地址范围时配置校验报错。

---

#### LRS.CONS.APB_DEMUX.01.003 地址区域不重叠约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.003
category: CONS
feature: config_validation
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

配置校验脚本应检查地址区域 overlap：任何两个 slave address windows 不允许
重叠。

#### Acceptance Criteria

- 地址重叠时配置校验报错。

---

#### LRS.CONS.APB_DEMUX.01.004 对齐约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.004
category: CONS
feature: config_validation
priority: P1
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

采用 power-of-two window 时，配置校验脚本应检查 `SIZE = 2^N` 且
`BASE_ADDR % SIZE == 0`。

#### Acceptance Criteria

- 非对齐基地址配置校验报错。

---

#### LRS.CONS.APB_DEMUX.01.005 数组长度一致性约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.005
category: CONS
feature: config_validation
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

配置校验脚本应检查 `BASE_ADDR`、`ADDR_MASK` 配置数组长度与 `NUM_SLAVES`
一致。

#### Acceptance Criteria

- 数组长度不一致时配置校验报错。

---

#### LRS.CONS.APB_DEMUX.01.006 超时周期合法性约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.01.006
category: CONS
feature: config_validation
priority: P1
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

配置校验脚本应检查 `TIMEOUT_CYCLES` 合法：`TIMEOUT_ENABLE=1` 时
`TIMEOUT_CYCLES > 0`。

#### Acceptance Criteria

- `TIMEOUT_ENABLE=1` 且 `TIMEOUT_CYCLES=0` 时配置校验报错。

---

### 1.2 实现约束

#### LRS.CONS.APB_DEMUX.02.001 单文件 RTL 约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.02.001
category: CONS
feature: implementation_constraint
priority: P1
status: active
verification_method:
  - review
END_LRS_META -->

#### Requirement

本 IP 推荐保持实现简单，主 RTL 保持为参数化 SystemVerilog 模块
（`apb_demux_top.sv`），不建议进一步拆分大量小型 RTL module。

#### Acceptance Criteria

- RTL 结构简洁，符合"Address Decoder + PSEL Generator + Response MUX"定位。

---

#### LRS.CONS.APB_DEMUX.02.002 参数化复用约束

<!-- LRS_META
id: LRS.CONS.APB_DEMUX.02.002
category: CONS
feature: implementation_constraint
priority: P0
status: active
verification_method:
  - review
END_LRS_META -->

#### Requirement

参数变化不应重新生成一份新的 APB Demux RTL。所有合法参数组合均应复用同一套
经过验证的 SystemVerilog 实现。

#### Acceptance Criteria

- 相同 RTL 支持所有合法参数组合；
- 参数化校验通过配置脚本完成。

---
