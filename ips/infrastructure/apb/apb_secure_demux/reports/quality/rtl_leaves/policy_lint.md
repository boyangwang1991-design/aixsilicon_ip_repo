# SpyGlass Lint 报告 — apb_secure_demux_policy

> **工具**: SpyGlass | **日期**: 2026-09-11T08:04:12Z | **Gate**: G3 前置

## REPORT_META
<!-- REPORT_META
ip_name: apb_secure_demux
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
schema_version: "2.0"
checks:
  lint:
    status: pass
    exit_code: 0
    tool: spyglass
    tool_version: "SpyGlass_vX-2025.06"
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_secure_demux_policy)"
    log: build/rtl/lint_policy/spyglass-1/apb_secure_demux_policy/lint/lint_rtl/spyglass.log
    log_sha256: 60a55909370aa7b64485e458f5656ca82c77efa5804b3ebc9638ed4ba8cecd06
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_secure_demux_policy --filelist build/rtl/policy.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
