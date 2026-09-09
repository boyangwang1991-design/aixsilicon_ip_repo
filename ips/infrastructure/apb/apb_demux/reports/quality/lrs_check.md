<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: lrs_check
status: pass
tool: extract_requirements.py
tool_version: "2.0"
command: "uv run python $SUITE_DIR/skills/01-lrs-author/scripts/extract_requirements.py --lrs-dir docs/lrs --output model/requirements.yaml --ip-name apb_demux"
artifacts:
  - path: model/requirements.yaml
    sha256: "<generated-by-extractor>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# LRS 质量检查报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| 文档版本 | 1.0.0 |
| 交付模型 | parameterized |
| 寄存器模型 | none |
| PPA signoff | none |
| G0 状态 | pass |

## 2. 需求统计

| 类别 | 数量 |
|------|------|
| INTF | 6 |
| FUNC | 22 |
| CFG | 9 |
| PERF | 3 |
| RESET | 3 |
| DFX | 3 |
| CONS | 8 |
| REG / LP / SAFE / SEC / GEN | N/A（章节显式声明） |
| **合计** | **55** |

## 3. 类别覆盖检查

| 类别 | 状态 | 说明 |
|------|------|------|
| INTF | ✅ | 1 上游 + N 下游 APB 接口 + 时钟复位 |
| FUNC | ✅ | 地址译码 / 路由 / 响应 / 错误 / remap / timeout / response register |
| CFG | ✅ | 核心参数 + 地址映射 + 可选特性 + profile |
| PERF | ✅ | 低延迟 + PPA + 规模 |
| RESET | ✅ | 单时钟 + PRESETn + 复位行为 |
| DFX | ✅ | 协议断言 |
| CONS | ✅ | 配置合法性 + 实现约束 |
| REG | N/A | `register_model=none`，无软件可见寄存器 |
| LP | N/A | 无专用低功耗需求 |
| SAFE | N/A | 无 ISO 26262 功能安全目标 |
| SEC | N/A | 无软件可访问资产 |
| GEN | N/A | 参数化 IP，不采用 RTL Generator |

## 4. 需求质量检查

| 检查项 | 状态 |
|--------|------|
| 每条需求包含 Requirement + Acceptance Criteria | ✅ |
| 每条 must 需求有 verify_method | ✅ |
| 需求 ID 唯一且符合规范 | ✅ |
| 使用 shall/应，无歧义用词 | ✅ |
| 无实现细节越界 | ✅ |

## 5. 结论

G0 门禁 **pass**。需求模型已从 Markdown 抽取至 `model/requirements.yaml`，
55 条需求冻结，可作为 HLD 的输入。
