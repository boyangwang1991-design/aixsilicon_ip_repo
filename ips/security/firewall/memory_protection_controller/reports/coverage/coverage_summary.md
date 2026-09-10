# AXI MPU - Coverage Closure Summary

> **IP**: `axi_mpu` · **Gate**: G4 · **Date**: 2026-09-10

## 1. 覆盖率结论

| 指标 | Achieved | Target | 状态 |
|---|---|---|---|
| functional | 100.0 | 100.0 | PASS |
| code | 100.0 | 90.0 | PASS |
| assertion | 100.0 | 100.0 | PASS |

## 2. 依据

- Full regression 14/14 TC PASS（reports/regression/junit.xml, failures=0）
- 功能覆盖组：region/priority、master、security、privilege、operation、
  burst(INCR/FIXED/WRAP)、error response、violation、lock、reset、outstanding、random
- 排除/豁免：无

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: coverage
status: pass
eda_profile: commercial-systemverilog
tool: vcs-coverage
tool_version: W-2024.09-SP1_Full64
command: simv +UVM_TESTNAME=<tc> +ntb_random_seed=1 (cm flow) ; merge in build/cov
coverage:
  functional:
    achieved: 100.0
    target: 100.0
  code:
    achieved: 100.0
    target: 90.0
  assertion:
    achieved: 100.0
    target: 100.0
coverage_source:
  collector: vcs -cm line+cond+fsm+tgl+assert
  collection_command: simv +UVM_TESTNAME=<tc> -cm line+cond+fsm+tgl+assert (14 runs)
  merge_command: urg -dir build/cov/*.vdb -report reports/coverage/raw
  report: reports/coverage/raw/functional_coverage_report.txt
  report_sha256: 897d88dde8dbb6e50c6281167e14d005b60ce94f0281989c59f5dd4720b9c472
exclusions: []
waivers: []
dependencies:
- path: reports/regression/regression_summary.md
  sha256: eceb47591a7784fd6cce373e2d9eb537ca7548b0a793b7997550e4abeacd4966
artifacts:
- path: reports/regression/regression_summary.md
  sha256: eceb47591a7784fd6cce373e2d9eb537ca7548b0a793b7997550e4abeacd4966
- path: reports/coverage/raw/functional_coverage_report.txt
  sha256: 897d88dde8dbb6e50c6281167e14d005b60ce94f0281989c59f5dd4720b9c472
END_REPORT_META -->
