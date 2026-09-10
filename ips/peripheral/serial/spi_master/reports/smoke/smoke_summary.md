# FuseSoC smoke

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: smoke
status: pass
eda_profile: commercial-systemverilog
tool: summarize_acceptance.py
tool_version: '1.0'
command: python scripts/summarize_acceptance.py
artifacts:
- path: reports/smoke/smoke_junit.xml
  sha256: 44f454be28f40b8bf41ec6b644a4f471716f64a0c19f66f3fc4f6175a6fcb1b4
- path: reports/smoke/fusesoc-smoke.log
  sha256: e34890862a0979eb93133aa5098370d75825387a56ad8a6adca2326f0682a5ab
END_REPORT_META -->
实际运行 tc_spi_apb，零 UVM error/fatal，无重复 testname。
