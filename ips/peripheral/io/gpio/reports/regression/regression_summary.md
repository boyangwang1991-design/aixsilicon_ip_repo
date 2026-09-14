# Verification Execution Evidence

Smoke is the mandatory preflight subset. Full regression then runs every reachable testcase.

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: regression
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: make -C verification/sim run-existing BUILD=build/sim/uvm/n32_p0_4j4rox4a
  TESTS="config apb input filter output irq security lowpower aon capture fifo diag
  parity reset" SEEDS="1 17 101"
artifacts:
- path: reports/smoke/smoke_junit.xml
  sha256: d4c5c860a48357db19363b7b2c6e582c4763284e9c3952e0ae2c72aa38e955f5
- path: reports/regression/junit.xml
  sha256: 501b20565453565792a5fc20460936c0992178ac716d64cd040ce987b61d81f9
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/aon_1/run.log
  sha256: e5dd6081efccba6ff8a2119901b8cc563ae0b4b3556c4fbee69b9e723030ae7f
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/apb_1/run.log
  sha256: 9f18318db3efb734a9f05fdb26132350729120876d8d453d6651abeb9791033d
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/capture_1/run.log
  sha256: 5da9e5d8ea74c5daa821b7d97b228efc683d6c149ab4d7d8840d79a6288f7826
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/config_1/run.log
  sha256: 05c14c822b97183d58d07a1239076b382e6f9f6783505a6a060ae8b349d9dc64
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/diag_1/run.log
  sha256: a9dff30f4173d6f76d71bf8193a8b4750f4dd80ad65db76c2c83f432d4f9d640
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/fifo_1/run.log
  sha256: dbf8e0b5c7353f86963cc2c26aa0932736747e4989628bef47b49abdff075e0a
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/input_1/run.log
  sha256: 6b1628000ebbd0acc1b5253684b8ab485f9157170b35b229fb043483288aab19
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/irq_1/run.log
  sha256: a4592f00fec54327f3cb6960d4671a6980747bcb5fe9f5a2e3c24c1ffee6af2a
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/lowpower_1/run.log
  sha256: ad3e6b1e33ee9c9f7f5369c570e9237372b201ae8438914c467b2cc251410b3c
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/output_1/run.log
  sha256: 4e96d40d43c53fc09a1bee870e0c815e49bd678460ca651b0c8d8a58acf4a5ba
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/parity_1/run.log
  sha256: 66a1514f1b558f476dcdeef611f9e5d38984ee6fae08c2222d9261e09d513c67
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/reset_1/run.log
  sha256: 0bfc919e23c9fa4ab040ad2f888b18d5f79efc0c7ef3b3d22ea773b18a135107
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/security_1/run.log
  sha256: 884ae7cd0015d22da919c9a8bba8a4400d731909d163068c5916955e95378cca
- path: build/sim/uvm/n32_p0_4j4rox4a/batch_d69mnooo/filter_1/run.log
  sha256: 6cd8a49fe2bea2290a8b035b09520ae03a83f124ff0fef370ba9c6736643ee6c
- path: reports/static/delivery_execution.log
  sha256: 454317bc58a60531dc26cdd984af8e3cc06eef2a7e0b30492201cc07590d87de
- path: reports/static/delivery_execution.json
  sha256: c6d2dc06ebb593691c86c2c75a0f61c48b198082e67d89d770e8f6c28afae168
dependencies:
- path: reports/smoke/smoke_junit.xml
  sha256: d4c5c860a48357db19363b7b2c6e582c4763284e9c3952e0ae2c72aa38e955f5
smoke_executions:
- testcase_id: TC.GPIO.APB.001
  implementation: verification/tc/tc_gpio_apb.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/apb_1/run.log
  log_sha256: 9f18318db3efb734a9f05fdb26132350729120876d8d453d6651abeb9791033d
executions:
- testcase_id: TC.GPIO.AON.001
  implementation: verification/tc/tc_gpio_aon.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/aon_1/run.log
  log_sha256: e5dd6081efccba6ff8a2119901b8cc563ae0b4b3556c4fbee69b9e723030ae7f
- testcase_id: TC.GPIO.APB.001
  implementation: verification/tc/tc_gpio_apb.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/apb_1/run.log
  log_sha256: 9f18318db3efb734a9f05fdb26132350729120876d8d453d6651abeb9791033d
- testcase_id: TC.GPIO.CAPTURE.001
  implementation: verification/tc/tc_gpio_capture.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/capture_1/run.log
  log_sha256: 5da9e5d8ea74c5daa821b7d97b228efc683d6c149ab4d7d8840d79a6288f7826
- testcase_id: TC.GPIO.CONFIG.001
  implementation: verification/tc/tc_gpio_config.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/config_1/run.log
  log_sha256: 05c14c822b97183d58d07a1239076b382e6f9f6783505a6a060ae8b349d9dc64
- testcase_id: TC.GPIO.DELIVERY.001
  implementation: scripts/check_delivery.py
  proof_kind: static
  execution_manifest: reports/static/delivery_execution.json
  log: reports/static/delivery_execution.log
  log_sha256: 454317bc58a60531dc26cdd984af8e3cc06eef2a7e0b30492201cc07590d87de
- testcase_id: TC.GPIO.DIAG.001
  implementation: verification/tc/tc_gpio_diag.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/diag_1/run.log
  log_sha256: a9dff30f4173d6f76d71bf8193a8b4750f4dd80ad65db76c2c83f432d4f9d640
- testcase_id: TC.GPIO.FIFO.001
  implementation: verification/tc/tc_gpio_fifo.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/fifo_1/run.log
  log_sha256: dbf8e0b5c7353f86963cc2c26aa0932736747e4989628bef47b49abdff075e0a
- testcase_id: TC.GPIO.FILTER.001
  implementation: verification/tc/tc_gpio_filter.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_d69mnooo/filter_1/run.log
  log_sha256: 6cd8a49fe2bea2290a8b035b09520ae03a83f124ff0fef370ba9c6736643ee6c
- testcase_id: TC.GPIO.INPUT.001
  implementation: verification/tc/tc_gpio_input.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/input_1/run.log
  log_sha256: 6b1628000ebbd0acc1b5253684b8ab485f9157170b35b229fb043483288aab19
- testcase_id: TC.GPIO.IRQ.001
  implementation: verification/tc/tc_gpio_irq.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/irq_1/run.log
  log_sha256: a4592f00fec54327f3cb6960d4671a6980747bcb5fe9f5a2e3c24c1ffee6af2a
- testcase_id: TC.GPIO.LOWPOWER.001
  implementation: verification/tc/tc_gpio_lowpower.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/lowpower_1/run.log
  log_sha256: ad3e6b1e33ee9c9f7f5369c570e9237372b201ae8438914c467b2cc251410b3c
- testcase_id: TC.GPIO.OUTPUT.001
  implementation: verification/tc/tc_gpio_output.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/output_1/run.log
  log_sha256: 4e96d40d43c53fc09a1bee870e0c815e49bd678460ca651b0c8d8a58acf4a5ba
- testcase_id: TC.GPIO.PARITY.001
  implementation: verification/tc/tc_gpio_parity.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/parity_1/run.log
  log_sha256: 66a1514f1b558f476dcdeef611f9e5d38984ee6fae08c2222d9261e09d513c67
- testcase_id: TC.GPIO.RESET.001
  implementation: verification/tc/tc_gpio_reset.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/reset_1/run.log
  log_sha256: 0bfc919e23c9fa4ab040ad2f888b18d5f79efc0c7ef3b3d22ea773b18a135107
- testcase_id: TC.GPIO.SECURITY.001
  implementation: verification/tc/tc_gpio_security.sv
  log: build/sim/uvm/n32_p0_4j4rox4a/batch_2h8vgfil/security_1/run.log
  log_sha256: 884ae7cd0015d22da919c9a8bba8a4400d731909d163068c5916955e95378cca
END_REPORT_META -->
