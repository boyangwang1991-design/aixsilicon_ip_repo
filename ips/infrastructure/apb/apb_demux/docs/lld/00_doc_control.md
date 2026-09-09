<!-- LLD_DOC_META
schema_version: 2.0

ip_name: apb_demux
ip_display_name: APB Demux (1-to-N APB Router)

delivery_model: parameterized

lrs_baseline: LRS-APB_DEMUX-V100
hld_baseline: HLD-APB_DEMUX-V100
document_version: 1.0.0
status: draft

microarchitecture_baseline: LLD-APB_DEMUX-V100
END_LLD_DOC_META -->

# APB Demux — LLD 文档控制

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 文档目的

本文档基于已冻结的 HLD，定义 APB Demux 的**周期级微架构（LLD）**，回答：

> **HOW IS THE IP IMPLEMENTED AT CYCLE LEVEL?**

主要定义：

- 模块内部状态与周期行为；
- 地址译码组合逻辑；
- 请求 fanout 与响应 mux；
- Decode Miss / Timeout / Response Register 时序；
- 复位行为；
- PPA 微架构决策；
- 验证关注点与 RTL 映射。

## 2. LLD / RTL / VPLAN 边界

### LLD 负责

- FSM 状态与转移（如有）；
- 组合/时序数据通路；
- 复位语义；
- PPA 微架构决策；
- 寄存器字段行为（`register_model=none` 时 N/A）。

### LLD 不负责

- testcase / assertion / coverage 实现（VPLAN）；
- SystemVerilog 代码（RTL）；
- 具体工具约束（SDC）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
