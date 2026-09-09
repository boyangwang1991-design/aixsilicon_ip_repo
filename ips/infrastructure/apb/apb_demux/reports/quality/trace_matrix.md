# Requirements Traceability Matrix

| Trace | Links | Unlinked sources |
|---|---:|---:|
| req_to_hld | 52 | 0 |
| hld_to_lld | 4 | 0 |
| lld_to_rtl | 1 | 0 |
| req_to_test | 83 | 0 |

## Gap analysis

- `req_to_hld`: none
- `hld_to_lld`: none
- `lld_to_rtl`: none
- `req_to_test`: none

## Execution closure

testcases=13; executed=13; missing=0; failed=0

<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_demux
report_type: rtm
status: pass
eda_profile: commercial-systemverilog
tool: build_trace.py
tool_version: '2.0'
command: build_trace.py --phase closure
phase: closure
artifacts:
- path: trace/req_to_hld.yaml
  sha256: 8bcadcb517e90b11fb77db9b2c0aef73cdac26f084a258016d0523514f00fea1
- path: trace/hld_to_lld.yaml
  sha256: 38907acfadf2540b25acb12c0f3bebd952cdb1b16b0c330771624b023b2e0f01
- path: trace/lld_to_rtl.yaml
  sha256: 2e005f7e4513dead215d85666f5dfac052839564d6f84dbf4ca9bc29cba1e7d3
- path: trace/req_to_test.yaml
  sha256: ad05b045057737026041c3eb5cbbdce1e362c87a707b0e03a9a807c3d73d8737
- path: reports/regression/junit.xml
  sha256: e851e02e91398735008d09bf0867a323937cb4ab233a09120179d5a1d28df8d0
dependencies:
- path: reports/coverage/coverage_summary.md
  sha256: 33dc181ac2e0b37c4eb5aadc0d78972177937512fe3c27c10ed0b09cad3b3421
- path: reports/regression/junit.xml
  sha256: e851e02e91398735008d09bf0867a323937cb4ab233a09120179d5a1d28df8d0
END_REPORT_META -->
