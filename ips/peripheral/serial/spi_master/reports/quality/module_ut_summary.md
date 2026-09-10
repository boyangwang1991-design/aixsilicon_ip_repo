# module_ut

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: module_ut
status: pass
eda_profile: commercial-systemverilog
tool: write_quality_evidence.py
tool_version: '1.0'
command: python scripts/write_quality_evidence.py
artifacts:
- path: build/ut/queues-0.log
  sha256: f03e00969b3d02de5dcd9e535a729113f9bed5a4b27368d51ea0a1f79eed96d1
- path: build/ut/queues-1.log
  sha256: 9d773da242674e45f834b45c4637c619459ec3b2e23207ecaad7c070b2d12a4e
- path: verification/unit_test/ut_spi_queues.sv
  sha256: 92060a9bda7d027206d5e91ac4414bfd890cc76dd907e339be3e6ca808c1a98b
- path: build/ut/engine-0.log
  sha256: 2fd5c6f6294874af0aabd6742153192d84df9b0ee15e08bb0a9bff143ba1a2ba
- path: build/ut/engine-1.log
  sha256: 5d103985bdd1f2f076c858e507cada68578fa002bdfaa45fd9b4250d74a94865
- path: verification/unit_test/ut_spi_engine.sv
  sha256: 2badec1e6a45671e201e16c4f96f7d269c193f721be76029510fe953d10b1fcd
checks:
  ut_spi_queues:
    status: pass
    compile_log: build/ut/queues-0.log
    run_log: build/ut/queues-1.log
  ut_spi_engine:
    status: pass
    compile_log: build/ut/engine-0.log
    run_log: build/ut/engine-1.log
test_count: 2
END_REPORT_META -->

Isolated queue/engine tests. See raw logs and unit-tests.json for the real commands.
