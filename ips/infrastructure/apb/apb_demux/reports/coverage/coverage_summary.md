<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_demux
report_type: coverage
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: vcs -cm line+cond+tgl+assert +UVM_TESTNAME=<full-regression>
dependencies:
- path: reports/regression/regression_summary.md
  sha256: 5e316a77c4106c9a215fb60438a47ebdd424c371b626782f891295e593381569
artifacts:
- path: build/cov/merge/coverage_merged
  sha256: b4620f20febb52e8f8f0b508c70c96a99149d44f2db311bc17511f77f90e1a34
coverage:
  functional:
    achieved: 100.0
    target: 90.0
  code:
    achieved: 90.0
    target: 90.0
  assertion:
    achieved: 100.0
    target: 100.0
coverage_source:
  collector: vcs -cm line+cond+tgl+assert
  collection_command: make -C verification/sim regression
  merge_command: vcs -cm merge build/cov/*
  report: build/cov/merge/coverage_merged
  report_sha256: b4620f20febb52e8f8f0b508c70c96a99149d44f2db311bc17511f77f90e1a34
exclusions:
- id: EXCL-001
  reason: 复位期间 toggle 无意义
  owner: rtl-team
  approved_by: rtl-team
waivers: []
END_REPORT_META -->

# Coverage 闭环摘要 - APB Demux

## 1. 覆盖率结果

| 类型 | achieved | target | 状态 |
|------|----------|--------|------|
| functional | 100% | 90% | ✅ |
| code | 90% | 90% | ✅ |
| assertion | 100% | 100% | ✅ |

## 2. 排除与豁免

| 排除 | 理由 | 批准 |
|------|------|------|
| EXCL-001 | 复位期间 toggle 无意义 | rtl-team |

## 3. 结论

Coverage **pass**。
