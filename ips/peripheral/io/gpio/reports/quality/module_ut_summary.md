<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: module_ut
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
test_count: 13
command: bash verification/unit_test/run_ut.sh
artifacts:
- path: reports/module_ut/run.pcmihh5i/ut_gpio.run.log
  sha256: da9ef669d3eb8ceea7fb37c4b0bf69bd78dff6af06afe1a3d51cc652adf65d3e
- path: reports/module_ut/run.pcmihh5i/ut_gpio.compile.log
  sha256: b85d7958269c12988f39b0f8098bb8cbb1855b1be554d412dc8c3ff879e0bdae
- path: reports/module_ut/run.pcmihh5i/ut_gpio_aon_mailbox.run.log
  sha256: 427a8f201d7959005d91638a6de4ddc9fee4a808d3006fe3579216aaf1474510
- path: reports/module_ut/run.pcmihh5i/ut_gpio_aon_mailbox.compile.log
  sha256: 3b9b4ce6c3c1d82ab7fac4a42173c6f984cd1c262e0d3aec87db46c3be3855aa
- path: reports/module_ut/run.pcmihh5i/ut_gpio_aon_wake.run.log
  sha256: 003d18d3013d5a5acd162cddc4f7b67dc3f6471701d3777b6cb2b7a9110ab60f
- path: reports/module_ut/run.pcmihh5i/ut_gpio_aon_wake.compile.log
  sha256: f389be18a36b199958c22426ea5ed9fb3bcd512b3e55ffd948a6434cf76f0983
- path: reports/module_ut/run.pcmihh5i/ut_gpio_apb_if.run.log
  sha256: 48baadcc7d47218493d64f56d411d6a1a383f3d583cf8f0cf6be2e046289ec56
- path: reports/module_ut/run.pcmihh5i/ut_gpio_apb_if.compile.log
  sha256: 893ec1661b2d97736618f98bf33fbfb34a61296ea0fa6fa1adac22e27dba0b7a
- path: reports/module_ut/run.pcmihh5i/ut_gpio_capture.run.log
  sha256: f678efddaba7d87755ac50a6ff1e868d07e12fac06b246b40958cd89a320ffd9
- path: reports/module_ut/run.pcmihh5i/ut_gpio_capture.compile.log
  sha256: 0ccdea18141e8501e2c7a871eb4728863dc2a7c701409998461d47111031bc18
- path: reports/module_ut/run.pcmihh5i/ut_gpio_diag.run.log
  sha256: 72fdb2a4942573823ad38b53f7d8732e9961938a8f2f6203b5f960a8e80f77a0
- path: reports/module_ut/run.pcmihh5i/ut_gpio_diag.compile.log
  sha256: b5543c9b93ebe7c55c4be60ec348d451732dc1308cea76417b6d93ad612096f5
- path: reports/module_ut/run.pcmihh5i/ut_gpio_event_fifo.run.log
  sha256: 0dded9e080ea3a48e393bc4620e7e9bc1ac505aa3d5b0c609da86e6b614bbaed
- path: reports/module_ut/run.pcmihh5i/ut_gpio_event_fifo.compile.log
  sha256: 045c9b411659800b19e83c1f5aede702cd7d165561c33530b5cd41e1b54d6751
- path: reports/module_ut/run.pcmihh5i/ut_gpio_input.run.log
  sha256: 07b3e3f6d39170d0b53079e9dbf7256db9917a774570307e01646fbd2e5c521b
- path: reports/module_ut/run.pcmihh5i/ut_gpio_input.compile.log
  sha256: 8fb2334fb6fb3dfebcba78a4a7c86fa5a0ca63f3e8cec11405af59dc0c609464
- path: reports/module_ut/run.pcmihh5i/ut_gpio_irq.run.log
  sha256: a94803f54ffdf433e0fe9b6bff2883bd3786b70c8042c4a0d6f3e0abc500b14b
- path: reports/module_ut/run.pcmihh5i/ut_gpio_irq.compile.log
  sha256: 1f34c10f1d4d4bf6836e07bc872cee652dab7b89af41c695313bf2a02078ec9c
- path: reports/module_ut/run.pcmihh5i/ut_gpio_output.run.log
  sha256: 8be92e1c5dee9386413b1e7e161f8198c7a93e389a1840f227f6f68782c831fa
- path: reports/module_ut/run.pcmihh5i/ut_gpio_output.compile.log
  sha256: ab3744837c8486c0342453533441e0bf31b4d7354f133ba45823f8a3084f1697
- path: reports/module_ut/run.pcmihh5i/ut_gpio_read_path.run.log
  sha256: da1a2d0a93bcdcbfadcf5bc5a5ebf93666c67e043e76b8e6868e3aedc30704cd
- path: reports/module_ut/run.pcmihh5i/ut_gpio_read_path.compile.log
  sha256: b0de470ef7468d0a48374bb0846da201e1e3b663110ce8f0ce3235c0e9f334fc
- path: reports/module_ut/run.pcmihh5i/ut_gpio_regfile.run.log
  sha256: 9d6655332460bc20f7afa2d0c846e67c80e86066e89eb6d75d12281e1914977c
- path: reports/module_ut/run.pcmihh5i/ut_gpio_regfile.compile.log
  sha256: 8f5c211130e1c7adf30e2fd30bb59970611908e128d9f3bed97ea6490b08df11
- path: reports/module_ut/run.pcmihh5i/ut_gpio_security.run.log
  sha256: 4538f7fcc32c5eea9f388cbac6835702e1c78dae5b011c9634e9c30b5fe8ff2b
- path: reports/module_ut/run.pcmihh5i/ut_gpio_security.compile.log
  sha256: 29ec204b4ed59573dd9a9c4b0ede35b53a7b5fd934b3559b2c5d166f27888120
- path: build/sim/run/ut/run.pcmihh5i/inputs.json
  sha256: a875760730bdb7bbc246e37a51efb0028111a93f676a4aa0cfef9e63af52283c
- path: build/sim/run/ut/run.pcmihh5i/inputs.before.sha256
  sha256: 6f93c4e540473246e55ee5d6180461b982a97eadf05adb48a917ca8bd8014e5d
- path: build/sim/run/ut/run.pcmihh5i/inputs.after.sha256
  sha256: 6f93c4e540473246e55ee5d6180461b982a97eadf05adb48a917ca8bd8014e5d
checks:
  ut_gpio:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio.run.log
  ut_gpio_aon_mailbox:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_aon_mailbox.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_aon_mailbox.run.log
  ut_gpio_aon_wake:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_aon_wake.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_aon_wake.run.log
  ut_gpio_apb_if:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_apb_if.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_apb_if.run.log
  ut_gpio_capture:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_capture.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_capture.run.log
  ut_gpio_diag:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_diag.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_diag.run.log
  ut_gpio_event_fifo:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_event_fifo.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_event_fifo.run.log
  ut_gpio_input:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_input.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_input.run.log
  ut_gpio_irq:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_irq.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_irq.run.log
  ut_gpio_output:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_output.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_output.run.log
  ut_gpio_read_path:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_read_path.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_read_path.run.log
  ut_gpio_regfile:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_regfile.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_regfile.run.log
  ut_gpio_security:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.pcmihh5i/ut_gpio_security.compile.log
    run_log: reports/module_ut/run.pcmihh5i/ut_gpio_security.run.log
module_coverage:
  gpio:
  - ut_gpio
  gpio_aon_mailbox:
  - ut_gpio_aon_mailbox
  gpio_aon_wake:
  - ut_gpio_aon_wake
  gpio_apb_if:
  - ut_gpio_apb_if
  gpio_capture:
  - ut_gpio_capture
  gpio_diag:
  - ut_gpio_diag
  gpio_event_fifo:
  - ut_gpio_event_fifo
  gpio_input:
  - ut_gpio_input
  gpio_irq:
  - ut_gpio_irq
  gpio_output:
  - ut_gpio_output
  gpio_regfile:
  - ut_gpio_regfile
  gpio_security:
  - ut_gpio_security
  gpio_csr:
  - ut_gpio_read_path
  gpio_csr_adapter:
  - ut_gpio_read_path
inputs_manifest:
  path: build/sim/run/ut/run.pcmihh5i/inputs.before.sha256
  sha256: 6f93c4e540473246e55ee5d6180461b982a97eadf05adb48a917ca8bd8014e5d
inputs_after_manifest:
  path: build/sim/run/ut/run.pcmihh5i/inputs.after.sha256
  sha256: 6f93c4e540473246e55ee5d6180461b982a97eadf05adb48a917ca8bd8014e5d
END_REPORT_META -->
