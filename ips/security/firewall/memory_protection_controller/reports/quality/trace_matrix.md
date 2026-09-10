# Requirements Traceability Matrix

| Trace | Links | Unlinked sources |
|---|---:|---:|
| req_to_hld | 74 | 0 |
| hld_to_lld | 9 | 0 |
| lld_to_rtl | 9 | 0 |
| req_to_test | 101 | 0 |

## Gap analysis

- `req_to_hld`: none
- `hld_to_lld`: none
- `lld_to_rtl`: none
- `req_to_test`: none

## Execution closure

testcases=14; executed=14; missing=0; failed=0

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: rtm
status: pass
eda_profile: commercial-systemverilog
tool: build_trace.py
tool_version: '2.0'
command: build_trace.py --phase closure
phase: closure
artifacts:
- path: trace/req_to_hld.yaml
  sha256: 668d8d516c745feb77a1e3e252e37fed5a977db7d52b8b22c86465e6701eabe7
- path: trace/hld_to_lld.yaml
  sha256: 2a29c4150f187c5abfefc43565bbdd6d058cca5c8e8e2e4a548aa9e99a0a66ce
- path: trace/lld_to_rtl.yaml
  sha256: cb7a701a09d5d6ac736345f0c230d20e6023d07e9066f3bcb5a1482d3ec7862c
- path: trace/req_to_test.yaml
  sha256: 37bf88d795305d9472a2ea023d192bf7dca4d4f1091038dbfe294ccdc0bca173
- path: reports/regression/junit.xml
  sha256: 2679f7e39621a72bef1f756c8c16aa5633ec61316f3814b93e48ef8fac6c7694
dependencies:
- path: reports/coverage/coverage_summary.md
  sha256: d80bc0e667b4da4f5c5344c31433a4de69d153cfe2d7f235fff6447abbcb3a10
- path: reports/regression/junit.xml
  sha256: 2679f7e39621a72bef1f756c8c16aa5633ec61316f3814b93e48ef8fac6c7694
END_REPORT_META -->
