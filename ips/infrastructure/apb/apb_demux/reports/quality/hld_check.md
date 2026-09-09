<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: hld_check
status: pass
tool: extract_hld.py
tool_version: "2.0"
command: "uv run python $SUITE_DIR/skills/03-hld-architect/scripts/extract_hld.py --hld-dir docs/hld --requirements model/requirements.yaml --output model --ip-name apb_demux"
artifacts:
  - path: model/architecture.yaml
    sha256: "<generated-by-extractor>"
  - path: model/external_interface.yaml
    sha256: "<generated-by-extractor>"
  - path: model/internal_interface.yaml
    sha256: "<generated-by-extractor>"
  - path: model/clock_domains.yaml
    sha256: "<generated-by-extractor>"
  - path: model/cdc_paths.yaml
    sha256: "<generated-by-extractor>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# HLD 质量检查报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| 架构版本 | 1.0.0 |
| LRS Baseline | LRS-APB_DEMUX-V100 |
| G1 状态 | pass |

## 2. 架构对象统计

| 对象 | 数量 |
|------|------|
| 模块 | 4（TOP/DECODE/ROUTE/ERR） |
| 外部接口 | 2（上游 slave + 下游 master） |
| 内部接口 | 2（hit 向量 + 响应 mux 输入） |
| 时钟/复位域 | 2（CLK_APB / RST_APB_N） |
| 数据流 | 2（请求路由 / 响应返回） |
| 策略 | 4（wait / decode_miss / remap / timeout） |
| 约束 | 2（配置校验 / 单时钟） |
| CDC 路径 | 0（单时钟域 N/A） |

## 3. 需求覆盖检查

| 检查项 | 状态 |
|--------|------|
| 每个模块有 req_ref | ✅ |
| 每个接口有 req_ref | ✅ |
| must 需求被架构对象引用 | ✅ |
| 寄存器架构 N/A（register_model=none） | ✅ |
| 单时钟域、无 CDC 声明 | ✅ |

## 4. 结论

G1 门禁 **pass**。架构模型已抽取至 `model/`，可作 LLD 输入。
