# Requirements Traceability Matrix

| Trace | Links | Unlinked sources |
|---|---:|---:|
| req_to_hld | 93 | 0 |
| hld_to_lld | 3 | 0 |
| lld_to_rtl | 4 | 0 |
| req_to_test | 196 | 0 |

## Gap analysis

- `req_to_hld`: none
- `hld_to_lld`: none
- `lld_to_rtl`: none
- `req_to_test`: none

## Execution closure

testcases=10; executed=23; missing=0; failed=0

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: rtm
status: pass
eda_profile: commercial-systemverilog
tool: build_trace.py
tool_version: '2.0'
command: build_trace.py --phase closure
phase: closure
artifacts:
- path: trace/req_to_hld.yaml
  sha256: 3e4550769fc1964267f5d3e31ee3242ef6f5241e93a6b4696f0db603fadb0ae6
- path: trace/hld_to_lld.yaml
  sha256: 9712abb2f18bf7433156855f2e23c9ddc31830a9e03e9a423d6115a97fda702d
- path: trace/lld_to_rtl.yaml
  sha256: 0b2d82563cbbf2808a5447ac36ebbb3ed9f14c1f89eda7a7c9759448be4cf505
- path: trace/req_to_test.yaml
  sha256: 94cd0cd4365a58cf09f41152ff2260c612dfd834d89f012bf06691d624744a5f
- path: reports/regression/junit.xml
  sha256: 92652099cf1f062554fed3f82e4cb7a07441541d740c21d1df4772e04b3418f1
dependencies:
- path: reports/coverage/coverage_summary.md
  sha256: 43d7e452728e8ab0ce195b6b3a762b56ff3cfc00e5b23b4258f04fc976eca622
- path: reports/regression/junit.xml
  sha256: 92652099cf1f062554fed3f82e4cb7a07441541d740c21d1df4772e04b3418f1
END_REPORT_META -->
