# APB Demux — HLD 风险与 G1 门禁

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 架构风险

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| 大 NUM_SLAVES 时 mux/fanout 时序 | Medium | 可选 OUTPUT_REGISTER；建议 ≤32；超大规模升级为 hierarchical interconnect |
| 地址配置 overlap 导致译码歧义 | Medium | 配置校验脚本强制非重叠 |
| Decode Miss 导致 APB hang | High | 立即 error 响应 + timeout 兜底 |
| 组合路径过长 | Low | 有效位比较优化；综合工具优化 |

## 2. 待确认问题

| # | 问题 | 状态 |
|---|------|------|
| 1 | NUM_SLAVES 上限是否需要 >32 | 默认 ≤32，可参数化扩展 |

## 3. 评审检查清单

| 检查项 | 状态 |
|--------|------|
| 架构目标与 LRS 对齐 | ✅ |
| 模块划分清晰且每个模块有 req_ref | ✅ |
| 所有 must 需求被模块引用 | ✅ |
| 单时钟域、无 CDC 声明 | ✅ |
| 寄存器架构 N/A 声明（register_model=none） | ✅ |
| 接口（外部/内部）完整 | ✅ |
| 性能/PPA 预算定义 | ✅ |
| 安全 N/A 声明 | ✅ |

## 4. G1 门禁

<!-- HLD_GATE_META
gate: G1
status: pass
architecture_freeze: true

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
END_HLD_GATE_META -->

## 5. 输出物清单

- `docs/hld/index.md` ~ `08_risk_checklist.md`（本套文档）
- `model/architecture.yaml`、`external_interface.yaml`、`internal_interface.yaml`、
  `clock_domains.yaml`、`cdc_paths.yaml`（extractor 生成）

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
