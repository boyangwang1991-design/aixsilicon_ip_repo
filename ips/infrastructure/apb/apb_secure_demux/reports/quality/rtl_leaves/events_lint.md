# SpyGlass Lint 报告 — apb_secure_demux_events

> **工具**: SpyGlass | **日期**: 2026-09-11T07:49:26Z | **Gate**: G3 前置

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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_secure_demux_events)"
    log: build/rtl/lint_events/spyglass-1/apb_secure_demux_events/lint/lint_rtl/spyglass.log
    log_sha256: b8de62e1ffae6b2f2fc6b7ea6c371fe8a1286bd8a1fa5fc20166177680a3e348
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_secure_demux_events --filelist build/rtl/events.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
