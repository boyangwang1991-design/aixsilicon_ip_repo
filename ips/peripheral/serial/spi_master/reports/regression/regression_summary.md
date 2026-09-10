# 回归结果

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: regression
status: pass
eda_profile: commercial-systemverilog
tool: summarize_acceptance.py
tool_version: '1.0'
command: python scripts/summarize_acceptance.py
artifacts:
- path: reports/quality/regression-small-1.json
  sha256: bf0687bd933ddb8d97d21c2fa5ce6684637817644e473776252440854639e1a3
- path: reports/quality/regression-default-1.json
  sha256: b9f40f455ed09820b68d3caf1cbee1ab8cd6d305f16e2d1b933cfd1c3b2f55fd
- path: reports/quality/regression-default-17.json
  sha256: 2690afbf94dba91cd8273ccfa80799df0203a2d8412238c12aebaea8ac9e7ea4
- path: reports/quality/regression-default-101.json
  sha256: 51d00b48a3ee4e510cdafbe6edfb9a1f5c302a8fedda993fa4837547a63ade29
- path: reports/quality/regression-default-2026.json
  sha256: 08ce5c9b9bd5655997924730dacc9133e6e5db88e1e2477e83ce80280347541a
- path: reports/quality/regression-max-1.json
  sha256: 00e9c1e00c606eba4c3273ed916cd041bb04e99f9a151232e011a24c22acd0f8
- path: reports/quality/regression-asymmetric-1.json
  sha256: cb798778eba58233fc1c19fa45643b81e680990221dadf62803a13c8dd3604a9
- path: reports/quality/unit-tests.json
  sha256: 0b7a025e580daa4463c1f881d9e1d439b728fdd49d3c7e8a8b07a2eabb3cd321
- path: reports/quality/negative-parameters.json
  sha256: 9d7f23224b6359beb649bd00ddd687e8b3a6201de89d61fddc0aa8596b0a1164
- path: reports/quality/delivery-check.json
  sha256: ad6ac1f72e274faedd628f49f9ea6c7e6a2efb1b7eff5c96cd8c709d3188dad6
- path: reports/regression/junit.xml
  sha256: 92652099cf1f062554fed3f82e4cb7a07441541d740c21d1df4772e04b3418f1
- path: reports/smoke/smoke_junit.xml
  sha256: 44f454be28f40b8bf41ec6b644a4f471716f64a0c19f66f3fc4f6175a6fcb1b4
- path: build/sim/default/irq_1.log
  sha256: ff83e3ac13cf9e5d67457e459d79197e53917f16d9b87019ca4e47586d862e4a
- path: build/sim/default/extended_1.log
  sha256: 1c22aab23d98e375020577036c653fcddd50fdb1592f11acca829037738c10e2
- path: build/sim/default/random_1.log
  sha256: 647f6e0db8f4e170f16c3ef523c4afbf3c2fbc4ab8d89206f467192622617691
- path: build/sim/default/races_1.log
  sha256: f9b5627e0480cf4c5b89ea5670920a918aa473f03ad1074cb0e6051786f7796e
- path: build/delivery/driver-1.log
  sha256: 69b38b8a8d5a2dfe08767fa56c88923af477f0dc322b79c46c63a5a334c2188a
- path: build/sim/default/apb_1.log
  sha256: a7039638053b35954552e60c9e29c9aed819c1372fdaeb0cac3da8c34af54219
- path: build/sim/default/modes_1.log
  sha256: a7b17020fc675d5dcd1f0603fc0c8ca391caab681317d25fd4d97660a93c1a57
- path: build/sim/default/commands_1.log
  sha256: 613b4901e2eeb837cfee4f0e7ce871a4ed884e2d7260b29e1213aa944aaa46ce
- path: build/sim/default/fifo_stall_1.log
  sha256: 18f0313a47c74e58c50bad58443eb775f1276e37fa7ee4b5d70c57f5c5c7a9b8
- path: build/sim/default/recovery_1.log
  sha256: 182815020c76e47ca55156ef2ad30bf199bfd2d9c4c402a0bf58e6f830261948
- path: reports/smoke/fusesoc-smoke.log
  sha256: e34890862a0979eb93133aa5098370d75825387a56ad8a6adca2326f0682a5ab
executions:
- testcase_id: TC.SPI_MASTER.IRQ.001
  implementation: verification/tc/tc_spi_irq.sv
  log: build/sim/default/irq_1.log
  log_sha256: ff83e3ac13cf9e5d67457e459d79197e53917f16d9b87019ca4e47586d862e4a
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.EXTENDED.001
  implementation: verification/tc/tc_spi_extended.sv
  log: build/sim/default/extended_1.log
  log_sha256: 1c22aab23d98e375020577036c653fcddd50fdb1592f11acca829037738c10e2
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.RANDOM.001
  implementation: verification/tc/tc_spi_random.sv
  log: build/sim/default/random_1.log
  log_sha256: 647f6e0db8f4e170f16c3ef523c4afbf3c2fbc4ab8d89206f467192622617691
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.RACES.001
  implementation: verification/tc/tc_spi_races.sv
  log: build/sim/default/races_1.log
  log_sha256: f9b5627e0480cf4c5b89ea5670920a918aa473f03ad1074cb0e6051786f7796e
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.DELIVERY.001
  implementation: scripts/check_delivery.py
  log: build/delivery/driver-1.log
  log_sha256: 69b38b8a8d5a2dfe08767fa56c88923af477f0dc322b79c46c63a5a334c2188a
  executor: static+c
- testcase_id: TC.SPI_MASTER.APB.001
  implementation: verification/tc/tc_spi_apb.sv
  log: build/sim/default/apb_1.log
  log_sha256: a7039638053b35954552e60c9e29c9aed819c1372fdaeb0cac3da8c34af54219
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.MODES.001
  implementation: verification/tc/tc_spi_modes.sv
  log: build/sim/default/modes_1.log
  log_sha256: a7b17020fc675d5dcd1f0603fc0c8ca391caab681317d25fd4d97660a93c1a57
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.COMMANDS.001
  implementation: verification/tc/tc_spi_commands.sv
  log: build/sim/default/commands_1.log
  log_sha256: 613b4901e2eeb837cfee4f0e7ce871a4ed884e2d7260b29e1213aa944aaa46ce
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.FIFO_STALL.001
  implementation: verification/tc/tc_spi_fifo_stall.sv
  log: build/sim/default/fifo_stall_1.log
  log_sha256: 18f0313a47c74e58c50bad58443eb775f1276e37fa7ee4b5d70c57f5c5c7a9b8
  executor: vcs-uvm
- testcase_id: TC.SPI_MASTER.RECOVERY.001
  implementation: verification/tc/tc_spi_recovery.sv
  log: build/sim/default/recovery_1.log
  log_sha256: 182815020c76e47ca55156ef2ad30bf199bfd2d9c4c402a0bf58e6f830261948
  executor: vcs-uvm
smoke_executions:
- testcase_id: TC.SPI_MASTER.APB.001
  implementation: verification/tc/tc_spi_apb.sv
  log: reports/smoke/fusesoc-smoke.log
  log_sha256: e34890862a0979eb93133aa5098370d75825387a56ad8a6adca2326f0682a5ab
dependencies:
- path: reports/smoke/smoke_junit.xml
  sha256: 44f454be28f40b8bf41ec6b644a4f471716f64a0c19f66f3fc4f6175a6fcb1b4
END_REPORT_META -->
共 53 项执行证据：39 项 UVM 配置/种子运行、2 项模块 UT、11 项非法参数拒绝、1 项静态和 C 驱动检查。全部通过。源文件和日志哈希已重新核验。
