# SpyGlass Lint 报告 — apb_secure_demux_access

> **工具**: SpyGlass | **日期**: 2026-09-11T07:43:06Z | **Gate**: G3 前置

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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_secure_demux_access)"
    log: build/rtl/lint_access/spyglass-1/apb_secure_demux_access/lint/lint_rtl/spyglass.log
    log_sha256: 68e56ff6915443c4973169a71eb29f3c7934573c15882346f4beca1825267ca9
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_secure_demux_access --filelist build/rtl/access.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
