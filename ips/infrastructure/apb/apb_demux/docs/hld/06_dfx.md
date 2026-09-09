# APB Demux — HLD 约束

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 架构约束

### 1.1 配置校验约束

#### HLD.CONSTRAINT.APB_DEMUX.CFG_VALIDATION 配置合法性约束

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.APB_DEMUX.CFG_VALIDATION
constraint: NUM_SLAVES>0；地址在 ADDR_WIDTH 范围；地址区域不重叠；power-of-two 对齐；数组长度一致；TIMEOUT_CYCLES>0（当使能时）
status: enforced
req_ref:
  - LRS.CONS.APB_DEMUX.01.001
  - LRS.CONS.APB_DEMUX.01.002
  - LRS.CONS.APB_DEMUX.01.003
  - LRS.CONS.APB_DEMUX.01.004
  - LRS.CONS.APB_DEMUX.01.005
  - LRS.CONS.APB_DEMUX.01.006
applicability:
  expr: "true"
END_HLD_CONSTRAINT_META -->

##### 需求描述

1. 通过配置校验脚本（Python）在编译前检查配置合法性。

---

### 1.2 单时钟域约束

#### HLD.CONSTRAINT.APB_DEMUX.SINGLE_CLK 单时钟域约束

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.APB_DEMUX.SINGLE_CLK
constraint: 所有逻辑在单一 PCLK 域，无 CDC
status: enforced
req_ref:
  - LRS.INTF.APB_DEMUX.03.001
  - LRS.RESET.APB_DEMUX.01.001
applicability:
  expr: "true"
END_HLD_CONSTRAINT_META -->

##### 需求描述

1. 跨时钟访问通过独立 APB CDC Bridge 完成（out of scope）。

---

## 2. DFT / Observability

本 IP 为纯逻辑互联，DFX 能力通过协议断言（SVA）提供：

- `$onehot0(M_PSEL)`；
- Wait-state 期间信号稳定；
- Decode 正确性 / Decode Miss 错误响应。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
