# SpyGlass Lint 报告 — apb_secure_demux_dfx

> **工具**: SpyGlass | **日期**: 2026-09-11T07:56:36Z | **Gate**: G3 前置

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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_secure_demux_dfx)"
    log: build/rtl/lint_dfx/spyglass-1/apb_secure_demux_dfx/lint/lint_rtl/spyglass.log
    log_sha256: 71a6d38fdb86ea57d422daa71f311eba590422529c83134165df9fc6d4e54faa
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_secure_demux_dfx --filelist build/rtl/dfx.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
