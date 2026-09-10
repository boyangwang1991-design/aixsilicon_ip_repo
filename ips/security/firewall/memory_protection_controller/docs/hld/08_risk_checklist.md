# AXI Memory Protection Unit — HLD 风险清单与 G1 门禁

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 风险清单

| ID | 风险 | 影响 | 缓解 |
|----|------|------|------|
| RSK-001 | AW/W 解耦下的非法 write consume 死锁 | 协议违约 | Write Decision Queue 严格关联 AW/W；LLD 验证 |
| RSK-002 | 大 REGION_NUM 下并行比较器时序 | 频率 | 分层匹配 + pipeline（Generator 结构规则） |
| RSK-003 | Burst 边界计算错误（WRAP） | 安全绕过 | Burst Analyzer 形式化验证 |
| RSK-004 | forged Secure AxPROT | 安全绕过 | Master Security Attribution 强制 |
| RSK-005 | Lock 语义歧义 | 配置篡改 | Region/Global Lock 明确语义 + 断言 |

## 2. G1 Gate 状态

<!-- HLD_GATE_META
gate: G1
status: open
architecture_freeze: false
approvals:
  - role: architecture
    status: pending
  - role: rtl
    status: pending
  - role: dv
    status: pending
notes: HLD 编写完成，待 extract_hld.py 抽取与需求覆盖校验通过后置为 pass。
END_HLD_GATE_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
