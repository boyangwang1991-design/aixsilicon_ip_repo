# SpyGlass Lint 报告 — apb_cdc_bridge_top

> **工具**: SpyGlass | **日期**: 2026-09-08T01:43:25Z | **Gate**: G3 前置

## REPORT_META
<!-- REPORT_META
ip_name: apb_cdc_bridge
report_type: rtl_check
status: fail
eda_profile: commercial-systemverilog
schema_version: "2.0"
checks:
  lint:
    status: fail
    exit_code: 0
    tool: spyglass
    tool_version: "SpyGlass_vX-2025.06"
    command: "spyglass -shell < spyglass_lint.tcl (goal cdc/cdc_setup_check, top apb_cdc_bridge_top)"
    log: build/rtl/cdc_spyglass/spyglass-1/apb_cdc_bridge_top/cdc/cdc_setup_check/spyglass.log
    log_sha256: b059a92cccd233875c476ea943bda44b0931f0400e550602c94092eb32bce922
END_REPORT_META -->

## 1. 运行

```bash
bash scripts/spyglass_lint.sh --top apb_cdc_bridge_top --filelist rtl/filelist.f
```

## 2. 结果

| 项 | 值 |
|----|-----|
| Fatal | 见日志 |
| Error | 见日志 |
| exit_code | 0 |
