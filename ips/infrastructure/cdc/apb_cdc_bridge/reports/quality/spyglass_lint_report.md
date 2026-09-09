# SpyGlass Lint 报告 — apb_cdc_bridge_top

> **工具**: SpyGlass | **日期**: 2026-09-07T12:01:58Z | **Gate**: G3 前置

## REPORT_META
<!-- REPORT_META
ip_name: apb_cdc_bridge
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
    command: "spyglass -shell < spyglass_lint.tcl (goal lint/lint_rtl, top apb_cdc_bridge_top)"
    log: build/rtl/lint_spyglass_tpl/spyglass-1/apb_cdc_bridge_top/lint/lint_rtl/spyglass.log
    log_sha256: 4f6cb8722cca6be5ce2c69548a2195eeb5d4c5f9e303a339f61081c2e92fe595
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
