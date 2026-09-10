# SpyGlass Lint 报告 — spi_master_top

> **工具**: SpyGlass | **日期**: 2026-09-10T12:09:53Z | **Gate**: G3 前置

## REPORT_META
<!-- REPORT_META
ip_name: spi_master
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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top spi_master_top)"
    log: build/rtl/lint_spyglass/spyglass-1/spi_master_top/lint/lint_rtl/spyglass.log
    log_sha256: 493a182b968d10dfa8f60983bfc0c519b01fda34528eb1c6a821909a2070fdd8
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top spi_master_top --filelist rtl/filelist.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
