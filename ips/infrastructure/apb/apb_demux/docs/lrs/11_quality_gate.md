# APB Demux — G0 门禁（LRS_GATE_META）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. G0 门禁状态

<!-- LRS_GATE_META
gate: G0
status: pass
requirement_freeze: true

approvals:
  - role: Architecture
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
  - role: RTL
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
  - role: DV
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
END_LRS_GATE_META -->

## 2. G0 评审检查清单

| 检查项 | 状态 |
|--------|------|
| 需求类别覆盖（INTF/FUNC/CFG/PERF/RESET/DFX/CONS 有需求；REG/LP/SAFE/SEC 显式 N/A） | ✅ |
| 每条 must 需求可验证（verify_method + acceptance criteria） | ✅ |
| 需求 ID 唯一且符合 `LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX>` 规范 | ✅ |
| 需求描述使用 shall/应，无歧义用词 | ✅ |
| 参数化交付模型（delivery_model=parameterized） | ✅ |
| 寄存器模型声明（register_model=none，无软件可见寄存器） | ✅ |
| 无实现细节越界（无 RTL 模块划分/FSM/pipeline 实现方案） | ✅ |

---
