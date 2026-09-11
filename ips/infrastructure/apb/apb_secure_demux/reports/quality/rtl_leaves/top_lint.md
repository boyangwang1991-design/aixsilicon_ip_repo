# SpyGlass Lint 报告 — apb_secure_demux

> **工具**: SpyGlass | **日期**: 2026-09-11T08:32:24Z | **Gate**: G3 前置

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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_secure_demux)"
    log: build/rtl/lint_top/spyglass-1/apb_secure_demux/lint/lint_rtl/spyglass.log
    log_sha256: c9aae2cbdaa7f34e3af0e8c212f33b805feaee0c75317b268cb838ce2455b774
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_secure_demux --filelist build/rtl/top.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
