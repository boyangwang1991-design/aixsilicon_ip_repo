# Verification Execution Evidence

Smoke is the mandatory preflight subset. Full regression then runs every reachable testcase.

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: regression
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1_Full64
command: vcs -full64 -sverilog -ntb_opts uvm-1.2 -f verification/verification.list
  -top harness; simv +UVM_TESTNAME=<tc> +ntb_random_seed=1
artifacts:
- path: reports/smoke/smoke_junit.xml
  sha256: eb9eb5e2b44889e242c8f21dc945758256be557020aa4ae6e8bd3d7c7a933f60
- path: reports/regression/junit.xml
  sha256: 2679f7e39621a72bef1f756c8c16aa5633ec61316f3814b93e48ef8fac6c7694
- path: build/sim/run/tc_burst_boundary_1.log
  sha256: 4f7d7b7c9c8727380fdc2b416c2970f5cd2ff6b89aa6be99c2acf1a164561e4d
- path: build/sim/run/tc_config_lock_1.log
  sha256: d4d948465db9a220892b3a305fe4a78a63257f01e3c78ff958fc5bdfc8fc0d73
- path: build/sim/run/tc_default_deny_1.log
  sha256: 85853d43cde6ea2071824441b895fda3f9a30a9a6c92098bf3f82e58f8448471
- path: build/sim/run/tc_local_decerr_1.log
  sha256: 70d74c64c2d9c10ea2df11e6ada28b9f0710c9adb4b9f1d3e9c23ba234945ee3
- path: build/sim/run/tc_master_permission_1.log
  sha256: 2496208692e8f862923ff5224b22dd722d1ff6e300be94473ad14ac2c34a6917
- path: build/sim/run/tc_op_permission_1.log
  sha256: 2725d561e1040c4f379d711d266823078f19547c78c34b7a7b2ab0b29e59fa36
- path: build/sim/run/tc_outstanding_1.log
  sha256: 19f7950d313157193535d1794a4d4a9f3c7a2b073f3ddc1c50f2b906055fd490
- path: build/sim/run/tc_privilege_permission_1.log
  sha256: 28108bde4231814af45854cbc3a210a583827692f1c53c75635def56e636fe59
- path: build/sim/run/tc_random_traffic_1.log
  sha256: 07da37cba4fc2145e82c731e1336b7f109559cff9c28cf7959c8064ed9353082
- path: build/sim/run/tc_region_boundary_1.log
  sha256: ede68614ef7c1710ac1f6ef090c947e768b55213f0dbff37e9ef891c5aae64ca
- path: build/sim/run/tc_reset_behavior_1.log
  sha256: 3786cb77d0c773d29cc00f832fa4d9201df94d397d2d65c5d062f6a5c70b940a
- path: build/sim/run/tc_security_permission_1.log
  sha256: 4228f8ec4e87c72285f2915ab756262b2f194d981faeefe9dcaa9341750c9e9d
- path: build/sim/run/tc_smoke_basic_1.log
  sha256: c21d7dc0778cfe65d77b890b0c7c3222ee17914dbb6ddb02df4182f835515092
- path: build/sim/run/tc_violation_capture_1.log
  sha256: 9633f896d63fbdd6f7bbc6b9cf067aeb6e3ba7926c210b939a744c7069421f3e
dependencies:
- path: reports/smoke/smoke_junit.xml
  sha256: eb9eb5e2b44889e242c8f21dc945758256be557020aa4ae6e8bd3d7c7a933f60
smoke_executions:
- testcase_id: TC.AXI_MPU.SMOKE.001
  implementation: verification/tc/tc_smoke_basic.sv
  log: build/sim/run/tc_smoke_basic_1.log
  log_sha256: c21d7dc0778cfe65d77b890b0c7c3222ee17914dbb6ddb02df4182f835515092
executions:
- testcase_id: TC.AXI_MPU.BURST.001
  implementation: verification/tc/tc_burst_boundary.sv
  log: build/sim/run/tc_burst_boundary_1.log
  log_sha256: 4f7d7b7c9c8727380fdc2b416c2970f5cd2ff6b89aa6be99c2acf1a164561e4d
- testcase_id: TC.AXI_MPU.DEFAULT_DENY.001
  implementation: verification/tc/tc_default_deny.sv
  log: build/sim/run/tc_default_deny_1.log
  log_sha256: 85853d43cde6ea2071824441b895fda3f9a30a9a6c92098bf3f82e58f8448471
- testcase_id: TC.AXI_MPU.ERR_RESP.001
  implementation: verification/tc/tc_local_decerr.sv
  log: build/sim/run/tc_local_decerr_1.log
  log_sha256: 70d74c64c2d9c10ea2df11e6ada28b9f0710c9adb4b9f1d3e9c23ba234945ee3
- testcase_id: TC.AXI_MPU.LOCK.001
  implementation: verification/tc/tc_config_lock.sv
  log: build/sim/run/tc_config_lock_1.log
  log_sha256: d4d948465db9a220892b3a305fe4a78a63257f01e3c78ff958fc5bdfc8fc0d73
- testcase_id: TC.AXI_MPU.MASTER.001
  implementation: verification/tc/tc_master_permission.sv
  log: build/sim/run/tc_master_permission_1.log
  log_sha256: 2496208692e8f862923ff5224b22dd722d1ff6e300be94473ad14ac2c34a6917
- testcase_id: TC.AXI_MPU.OP.001
  implementation: verification/tc/tc_op_permission.sv
  log: build/sim/run/tc_op_permission_1.log
  log_sha256: 2725d561e1040c4f379d711d266823078f19547c78c34b7a7b2ab0b29e59fa36
- testcase_id: TC.AXI_MPU.OUTSTANDING.001
  implementation: verification/tc/tc_outstanding.sv
  log: build/sim/run/tc_outstanding_1.log
  log_sha256: 19f7950d313157193535d1794a4d4a9f3c7a2b073f3ddc1c50f2b906055fd490
- testcase_id: TC.AXI_MPU.PRIVILEGE.001
  implementation: verification/tc/tc_privilege_permission.sv
  log: build/sim/run/tc_privilege_permission_1.log
  log_sha256: 28108bde4231814af45854cbc3a210a583827692f1c53c75635def56e636fe59
- testcase_id: TC.AXI_MPU.RANDOM.001
  implementation: verification/tc/tc_random_traffic.sv
  log: build/sim/run/tc_random_traffic_1.log
  log_sha256: 07da37cba4fc2145e82c731e1336b7f109559cff9c28cf7959c8064ed9353082
- testcase_id: TC.AXI_MPU.REGION.001
  implementation: verification/tc/tc_region_boundary.sv
  log: build/sim/run/tc_region_boundary_1.log
  log_sha256: ede68614ef7c1710ac1f6ef090c947e768b55213f0dbff37e9ef891c5aae64ca
- testcase_id: TC.AXI_MPU.RESET.001
  implementation: verification/tc/tc_reset_behavior.sv
  log: build/sim/run/tc_reset_behavior_1.log
  log_sha256: 3786cb77d0c773d29cc00f832fa4d9201df94d397d2d65c5d062f6a5c70b940a
- testcase_id: TC.AXI_MPU.SECURITY.001
  implementation: verification/tc/tc_security_permission.sv
  log: build/sim/run/tc_security_permission_1.log
  log_sha256: 4228f8ec4e87c72285f2915ab756262b2f194d981faeefe9dcaa9341750c9e9d
- testcase_id: TC.AXI_MPU.SMOKE.001
  implementation: verification/tc/tc_smoke_basic.sv
  log: build/sim/run/tc_smoke_basic_1.log
  log_sha256: c21d7dc0778cfe65d77b890b0c7c3222ee17914dbb6ddb02df4182f835515092
- testcase_id: TC.AXI_MPU.VIOLATION.001
  implementation: verification/tc/tc_violation_capture.sv
  log: build/sim/run/tc_violation_capture_1.log
  log_sha256: 9633f896d63fbdd6f7bbc6b9cf067aeb6e3ba7926c210b939a744c7069421f3e
END_REPORT_META -->
