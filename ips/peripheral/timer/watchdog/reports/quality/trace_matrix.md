# Requirements Traceability Matrix

| Trace | Links | Unlinked sources |
|---|---:|---:|
| req_to_hld | 253 | 0 |
| hld_to_lld | 6 | 0 |
| lld_to_rtl | 0 | 6 |
| req_to_test | 221 | 0 |

## Gap analysis

- `req_to_hld`: none
- `hld_to_lld`: none
- `lld_to_rtl`: `LLD.MOD.WATCHDOG.BUS`, `LLD.MOD.WATCHDOG.CHANNEL`, `LLD.MOD.WATCHDOG.DISPATCH`, `LLD.MOD.WATCHDOG.INTEGRATION`, `LLD.MOD.WATCHDOG.SAFETY`, `LLD.MOD.WATCHDOG.TRANSPORT`
- `req_to_test`: none

## Execution closure

static trace precheck; execution results not evaluated

<!-- REPORT_META
schema_version: '2.0'
ip_name: watchdog
report_type: rtm
status: fail
eda_profile: commercial-systemverilog
tool: build_trace.py
tool_version: '2.0'
command: build_trace.py --phase precheck
phase: precheck
artifacts:
- path: trace/req_to_hld.yaml
  sha256: a48f821a32daeff66dfb4e78eb847e0273ea661c87eae3b5644fa8995f0da939
- path: trace/hld_to_lld.yaml
  sha256: f09f5ed864aa228eb5a85868e4a8a241af117c63e183612cd6c1380ffd516ae4
- path: trace/lld_to_rtl.yaml
  sha256: bfac74ea56c89a9b5232788a56ff306572fa9b547fabc9bc5ea589bab66c517d
- path: trace/req_to_test.yaml
  sha256: 475dd2781d3a5c7ffc1e0e3b224e3eb648f2f29192668002b96cd8260aa6bf13
END_REPORT_META -->
