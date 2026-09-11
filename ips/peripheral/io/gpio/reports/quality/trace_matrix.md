# Requirements Traceability Matrix

| Trace | Links | Unlinked sources |
|---|---:|---:|
| req_to_hld | 258 | 0 |
| hld_to_lld | 12 | 0 |
| lld_to_rtl | 0 | 12 |
| req_to_test | 382 | 0 |

## Gap analysis

- `req_to_hld`: none
- `hld_to_lld`: none
- `lld_to_rtl`: `LLD.MOD.GPIO.AON`, `LLD.MOD.GPIO.APB`, `LLD.MOD.GPIO.CAPTURE`, `LLD.MOD.GPIO.DIAG`, `LLD.MOD.GPIO.FIFO`, `LLD.MOD.GPIO.INPUT`, `LLD.MOD.GPIO.IRQ`, `LLD.MOD.GPIO.MAILBOX`, `LLD.MOD.GPIO.OUTPUT`, `LLD.MOD.GPIO.REG`, `LLD.MOD.GPIO.SECURITY`, `LLD.MOD.GPIO.TOP`
- `req_to_test`: none

## Execution closure

static trace precheck; execution results not evaluated

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: rtm
status: fail
eda_profile: commercial-systemverilog
tool: build_trace.py
tool_version: '2.0'
command: build_trace.py --phase precheck
phase: precheck
artifacts:
- path: trace/req_to_hld.yaml
  sha256: a4908902d9a48048aceaba6274b7f57516e6ad5b081506fd2ade341b0c112baa
- path: trace/hld_to_lld.yaml
  sha256: c76771be9a62a4d1af585051d6305d6b09af8c6f10bf03399d2ea47832581ecc
- path: trace/lld_to_rtl.yaml
  sha256: e65c26a87df632fe441ba82f172ce30a2203ffd2fb7599a17434a91ccc14ae3f
- path: trace/req_to_test.yaml
  sha256: 05d11c861c8759bddc32de3769b1ebb43b0fe39a93920cad57a5154b31a866e7
END_REPORT_META -->
