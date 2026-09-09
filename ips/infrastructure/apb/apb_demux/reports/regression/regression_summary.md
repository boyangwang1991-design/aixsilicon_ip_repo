# Verification Execution Evidence

Smoke is the mandatory preflight subset. Full regression then runs every reachable testcase.

<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_demux
report_type: regression
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: make -C verification/sim regression
artifacts:
- path: reports/smoke/smoke_junit.xml
  sha256: d7131562f13364cd2ff31c3d48722a549a91191d60ce65e165adf0e06a558254
- path: reports/regression/junit.xml
  sha256: e851e02e91398735008d09bf0867a323937cb4ab233a09120179d5a1d28df8d0
- path: build/sim/run/tc_address_decode.log
  sha256: 66ed7638fd7286b38a6c274068cd059beeeebc653d02f91b0e2f029a43f3ad2c
- path: build/sim/run/tc_apb4.log
  sha256: e9f42c7a183fbb424790923ff31082919f8b3881078ca3d2497e14991c1c1799
- path: build/sim/run/tc_assertions.log
  sha256: 40737c10daf8b1e1e68d4fd591e28421f8512f364b51ce7adef7c31e931c1c14
- path: build/sim/run/tc_decode_miss.log
  sha256: a81ccb4dc47a7d9bd44f2cc59ee48322d93a6bb20dabbc400729849351c22188
- path: build/sim/run/tc_num_slaves_sweep.log
  sha256: d00c62f2183708c18b1c99ee7d021412a1823418e9ada4c3eec03d951cb3a76f
- path: build/sim/run/tc_output_register.log
  sha256: 1a8e32e2652517a81f068e71e722bc5defa675667cc18c3a59ee7e654271b1c7
- path: build/sim/run/tc_psel_onehot.log
  sha256: 3972a48c1f2e7325bda71b6e14071baf502e31d896c664727efc51b70d0e5063
- path: build/sim/run/tc_pslverr.log
  sha256: dda5bb1a2e672d11cb3b6886a987b8b4589708a8f4668fa2de55b6ab2600249d
- path: build/sim/run/tc_remap.log
  sha256: 7162589b96809f1cd4c4f55fdbb66361c3672e843114af4d60d1725abe139372
- path: build/sim/run/tc_reset.log
  sha256: ff813cd3dcf81ebd7b2b2c6484eeaedad6c9c8c2c02e0db5dd57c4c085065346
- path: build/sim/run/tc_sanity.log
  sha256: 5fc2700f7b35e6cb7561f9b1256e5134506ed24b938345ae75a45b21259bee90
- path: build/sim/run/tc_timeout.log
  sha256: 9954829eff13b23dbf21a719a2e0edf3ad07c776abf240caf737a4f22d74ed13
- path: build/sim/run/tc_wait_states.log
  sha256: 7a0112f96ff9f4b435dd54d0cdfb882fea3f27b29dffd8b070b453b2e005831b
dependencies:
- path: reports/smoke/smoke_junit.xml
  sha256: d7131562f13364cd2ff31c3d48722a549a91191d60ce65e165adf0e06a558254
smoke_executions:
- testcase_id: TC.FUNC.APB_DEMUX.05.001.MISS
  implementation: verification/tc/tc_decode_miss.sv
  log: build/sim/run/tc_decode_miss.log
  log_sha256: a81ccb4dc47a7d9bd44f2cc59ee48322d93a6bb20dabbc400729849351c22188
- testcase_id: TC.INTF.APB_DEMUX.01.001.SAN
  implementation: verification/tc/tc_sanity.sv
  log: build/sim/run/tc_sanity.log
  log_sha256: 5fc2700f7b35e6cb7561f9b1256e5134506ed24b938345ae75a45b21259bee90
executions:
- testcase_id: TC.DFX.APB_DEMUX.01.001.ASSERT
  implementation: verification/tc/tc_assertions.sv
  log: build/sim/run/tc_assertions.log
  log_sha256: 40737c10daf8b1e1e68d4fd591e28421f8512f364b51ce7adef7c31e931c1c14
- testcase_id: TC.FUNC.APB_DEMUX.01.001.DEC
  implementation: verification/tc/tc_address_decode.sv
  log: build/sim/run/tc_address_decode.log
  log_sha256: 66ed7638fd7286b38a6c274068cd059beeeebc653d02f91b0e2f029a43f3ad2c
- testcase_id: TC.FUNC.APB_DEMUX.01.002.PARAM
  implementation: verification/tc/tc_num_slaves_sweep.sv
  log: build/sim/run/tc_num_slaves_sweep.log
  log_sha256: d00c62f2183708c18b1c99ee7d021412a1823418e9ada4c3eec03d951cb3a76f
- testcase_id: TC.FUNC.APB_DEMUX.02.001.PSEL
  implementation: verification/tc/tc_psel_onehot.sv
  log: build/sim/run/tc_psel_onehot.log
  log_sha256: 3972a48c1f2e7325bda71b6e14071baf502e31d896c664727efc51b70d0e5063
- testcase_id: TC.FUNC.APB_DEMUX.03.001.WAIT
  implementation: verification/tc/tc_wait_states.sv
  log: build/sim/run/tc_wait_states.log
  log_sha256: 7a0112f96ff9f4b435dd54d0cdfb882fea3f27b29dffd8b070b453b2e005831b
- testcase_id: TC.FUNC.APB_DEMUX.04.001.ERR
  implementation: verification/tc/tc_pslverr.sv
  log: build/sim/run/tc_pslverr.log
  log_sha256: dda5bb1a2e672d11cb3b6886a987b8b4589708a8f4668fa2de55b6ab2600249d
- testcase_id: TC.FUNC.APB_DEMUX.05.001.MISS
  implementation: verification/tc/tc_decode_miss.sv
  log: build/sim/run/tc_decode_miss.log
  log_sha256: a81ccb4dc47a7d9bd44f2cc59ee48322d93a6bb20dabbc400729849351c22188
- testcase_id: TC.FUNC.APB_DEMUX.06.001.REMAP
  implementation: verification/tc/tc_remap.sv
  log: build/sim/run/tc_remap.log
  log_sha256: 7162589b96809f1cd4c4f55fdbb66361c3672e843114af4d60d1725abe139372
- testcase_id: TC.FUNC.APB_DEMUX.07.001.TOUT
  implementation: verification/tc/tc_timeout.sv
  log: build/sim/run/tc_timeout.log
  log_sha256: 9954829eff13b23dbf21a719a2e0edf3ad07c776abf240caf737a4f22d74ed13
- testcase_id: TC.FUNC.APB_DEMUX.08.001.OREG
  implementation: verification/tc/tc_output_register.sv
  log: build/sim/run/tc_output_register.log
  log_sha256: 1a8e32e2652517a81f068e71e722bc5defa675667cc18c3a59ee7e654271b1c7
- testcase_id: TC.INTF.APB_DEMUX.01.001.SAN
  implementation: verification/tc/tc_sanity.sv
  log: build/sim/run/tc_sanity.log
  log_sha256: 5fc2700f7b35e6cb7561f9b1256e5134506ed24b938345ae75a45b21259bee90
- testcase_id: TC.INTF.APB_DEMUX.01.002.APB4
  implementation: verification/tc/tc_apb4.sv
  log: build/sim/run/tc_apb4.log
  log_sha256: e9f42c7a183fbb424790923ff31082919f8b3881078ca3d2497e14991c1c1799
- testcase_id: TC.RESET.APB_DEMUX.01.001.RST
  implementation: verification/tc/tc_reset.sv
  log: build/sim/run/tc_reset.log
  log_sha256: ff813cd3dcf81ebd7b2b2c6484eeaedad6c9c8c2c02e0db5dd57c4c085065346
END_REPORT_META -->
