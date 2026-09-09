<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: lld_check
status: pass
tool: extract_lld.py
tool_version: "2.0"
command: "uv run python $SUITE_DIR/skills/05-lld-microdesign/scripts/extract_lld.py --lld-dir docs/lld --output model/micro_design.yaml --ip-name apb_demux"
artifacts:
  - path: model/micro_design.yaml
    sha256: "<generated-by-extractor>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# LLD 质量检查报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| 微架构版本 | 1.0.0 |
| HLD Baseline | HLD-APB_DEMUX-V100 |
| G2 状态 | pass |

## 2. 微架构对象统计

| 对象 | 数量 |
|------|------|
| 模块 | 1（apb_demux_top） |
| 数据通路 | 3（decode / response mux / remap） |
| FSM | 1（timeout 计数） |
| Reset | 1 |
| Error | 1（decode miss） |
| PPA 决策 | 2（decoder / mux） |
| 架构决策 | 1（单模块） |
| RTL 映射 | 1 |

## 3. G2 检查

| 检查项 | 状态 |
|--------|------|
| 所有 HLD module 被 LLD module 承接 | ✅ |
| module 与子对象引用闭合 | ✅ |
| FSM/datapath/reset/error 完整 | ✅ |
| register_model=none，无寄存器分支 | ✅ |

## 4. 结论

G2 门禁 **pass**。微架构模型已抽取至 `model/micro_design.yaml`，可作 RTL 与验证方案输入。
