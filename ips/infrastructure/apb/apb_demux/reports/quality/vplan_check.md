<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: vplan_check
status: pass
tool: extract_verification.py
tool_version: "2.0"
command: "uv run python $SUITE_DIR/skills/06-verification-plan/scripts/extract_verification.py --testplan-dir docs/verification --requirements model/requirements.yaml --output model/verification.yaml --ip-name apb_demux"
artifacts:
  - path: model/verification.yaml
    sha256: "<generated-by-extractor>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# 验证方案质量检查报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| 验证级别 | regression |
| LRS/HLD/LLD Baseline | V100 系列 |

## 2. 验证对象统计

| 对象 | 数量 |
|------|------|
| Feature | 12 |
| Testcase | 13 |
| Assertion | 6 |
| Coverage | 9 |

## 3. 检查项

| 检查项 | 状态 |
|--------|------|
| 每 testcase 有 implementation（verification/tc/*.sv） | ✅ |
| 每 testcase 恰好引用一个 feature | ✅ |
| 每 feature 有 req_ref 且引用有效需求 | ✅ |
| must 需求被 testcase 或 assertion 承接 | ✅ |
| 至少一个 smoke tier testcase | ✅（TC.INTF.01.001.SAN、TC.FUNC.05.001.MISS） |
| tier 值合法（smoke/regression/extended） | ✅ |
| 每 testcase 有 oracle/stimulus/expected/timeout | ✅ |

## 4. 结论

验证方案 **pass**。`model/verification.yaml` 已生成，可作 UVM 模板实例化与 RTL 实现输入。
