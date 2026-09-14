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
- path: reports/module_ut/run.f8iplv3x/ut_gpio.run.log
  sha256: 233a423896d439cec4a8ccc038ee7264604511aae5b106f197c91d834761404a
- path: reports/module_ut/run.f8iplv3x/ut_gpio.compile.log
  sha256: 0f13d255c7dc3b361943f22fd17ebe21875b1b05105546c90e3cb7001fd2652c
- path: reports/module_ut/run.f8iplv3x/ut_gpio_aon_mailbox.run.log
  sha256: 0a52d70d710220c9afd7571b9c53752da0c23f1ccdfd50691893059a45541c3d
- path: reports/module_ut/run.f8iplv3x/ut_gpio_aon_mailbox.compile.log
  sha256: 4a8204bc190cf255a6f7ad179bc758bfa450b5a5b18be9179a72f2c3b05c5d3a
- path: reports/module_ut/run.f8iplv3x/ut_gpio_aon_wake.run.log
  sha256: b6788771b24ff4929076f36875faa34b32916f78fd615b69639813c166e37a8a
- path: reports/module_ut/run.f8iplv3x/ut_gpio_aon_wake.compile.log
  sha256: 9c72ae986c5550ec82ce22cbaf9b5217131208ce3539ecf51df31ddff6f16aac
- path: reports/module_ut/run.f8iplv3x/ut_gpio_apb_if.run.log
  sha256: e0d5897365346425b7e06f342f2c0ec71e5ba8f8b21581fc83cc21e4a40b8968
- path: reports/module_ut/run.f8iplv3x/ut_gpio_apb_if.compile.log
  sha256: 6a6c094d8d60eb23c57c6dc3379ce455c84e47f737529135b6765a58364808bf
- path: reports/module_ut/run.f8iplv3x/ut_gpio_capture.run.log
  sha256: c1bc20194931b51fa7db94a95806b4feb8bf6ad182914f05b0b8778b2b3a63aa
- path: reports/module_ut/run.f8iplv3x/ut_gpio_capture.compile.log
  sha256: 2f4eac479e32050a0751bb01772842a7b1b269254712e3e0e393bcaa12037c13
- path: reports/module_ut/run.f8iplv3x/ut_gpio_diag.run.log
  sha256: ab6e5d097aa7404def89d57ea63db21dc57fb5e906dabc4949d14d9b42c6234c
- path: reports/module_ut/run.f8iplv3x/ut_gpio_diag.compile.log
  sha256: 6d10bfa03c3a73bd3985dea3e86bf3853986bd1dd866c079fd25c39d854547ab
- path: reports/module_ut/run.f8iplv3x/ut_gpio_event_fifo.run.log
  sha256: 2897d6dbb19ffa0b51e8594b02ab52bd0fbe30bc2489c328375eb5cf1f49812b
- path: reports/module_ut/run.f8iplv3x/ut_gpio_event_fifo.compile.log
  sha256: e983727ec0df1155b107f0f2073b9a4a2f1ffa8a442e94011c8225fad38a366b
- path: reports/module_ut/run.f8iplv3x/ut_gpio_input.run.log
  sha256: bc7da9d117e41d69588595f87fbe0231d6d80c4f601e609a5912e3964d0ec24d
- path: reports/module_ut/run.f8iplv3x/ut_gpio_input.compile.log
  sha256: 9f62a1fa9fab3c0f24c5662b219f7d1a486dfe3ff0be1eb79f048fbe8eb02079
- path: reports/module_ut/run.f8iplv3x/ut_gpio_irq.run.log
  sha256: 1eabd5090de24c77b18c8aa161eecdcc374fd30fa152432d5b907c5d80e17b6d
- path: reports/module_ut/run.f8iplv3x/ut_gpio_irq.compile.log
  sha256: 8ed369f191e2d5b11f263c789e92662bdb71e632fbfa149cb1645100286bdeb6
- path: reports/module_ut/run.f8iplv3x/ut_gpio_output.run.log
  sha256: 44decbaec13655592288b0b91128bb9be645e514e598d51672a3bb249d99ebbc
- path: reports/module_ut/run.f8iplv3x/ut_gpio_output.compile.log
  sha256: e319b771e97635609918e2945dc626c16a55bfa25b9a47e935b6ba7dca2ae4ba
- path: reports/module_ut/run.f8iplv3x/ut_gpio_read_path.run.log
  sha256: 45b6cbb77caf1de44ecc9c95c06a19f0c354ccb32aa62cf516adfb1da8767ba6
- path: reports/module_ut/run.f8iplv3x/ut_gpio_read_path.compile.log
  sha256: b16c0e97211fb140c54f731d6ab32507d38b284d8918f11e9ecc437c3b4d0a9b
- path: reports/module_ut/run.f8iplv3x/ut_gpio_regfile.run.log
  sha256: 566f196bdd8f944534dac0f52662904bfce1df09f6c200908fb27ecfae985cc9
- path: reports/module_ut/run.f8iplv3x/ut_gpio_regfile.compile.log
  sha256: 0efe370d57690291102854444c8d1b1596e6d28afd5e5bdfd837af5b791882f1
- path: reports/module_ut/run.f8iplv3x/ut_gpio_security.run.log
  sha256: 5406d1507bbf82a3dd21470be37d5dfb20cbdc88591d2e39f6e961ca9afe87f7
- path: reports/module_ut/run.f8iplv3x/ut_gpio_security.compile.log
  sha256: cde24b9c5d300c759ab07d0497c8f7accc3d07349b1033ea65ef0a953c57deb8
- path: build/sim/run/ut/run.f8iplv3x/inputs.json
  sha256: f27b42acb2c4d1fbc32639e637e26ccd24d3a6d67d8595141b04130e1649b236
- path: build/sim/run/ut/run.f8iplv3x/inputs.before.sha256
  sha256: 648d70a75ade2911e16e5c80f0e2dae5baf3833c129e80c8f2a5724ff82a2112
- path: build/sim/run/ut/run.f8iplv3x/inputs.after.sha256
  sha256: 648d70a75ade2911e16e5c80f0e2dae5baf3833c129e80c8f2a5724ff82a2112
checks:
  ut_gpio:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio.run.log
  ut_gpio_aon_mailbox:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_aon_mailbox.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_aon_mailbox.run.log
  ut_gpio_aon_wake:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_aon_wake.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_aon_wake.run.log
  ut_gpio_apb_if:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_apb_if.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_apb_if.run.log
  ut_gpio_capture:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_capture.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_capture.run.log
  ut_gpio_diag:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_diag.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_diag.run.log
  ut_gpio_event_fifo:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_event_fifo.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_event_fifo.run.log
  ut_gpio_input:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_input.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_input.run.log
  ut_gpio_irq:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_irq.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_irq.run.log
  ut_gpio_output:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_output.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_output.run.log
  ut_gpio_read_path:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_read_path.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_read_path.run.log
  ut_gpio_regfile:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_regfile.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_regfile.run.log
  ut_gpio_security:
    status: pass
    exit_code: 0
    compile_log: reports/module_ut/run.f8iplv3x/ut_gpio_security.compile.log
    run_log: reports/module_ut/run.f8iplv3x/ut_gpio_security.run.log
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
  path: build/sim/run/ut/run.f8iplv3x/inputs.before.sha256
  sha256: 648d70a75ade2911e16e5c80f0e2dae5baf3833c129e80c8f2a5724ff82a2112
inputs_after_manifest:
  path: build/sim/run/ut/run.f8iplv3x/inputs.after.sha256
  sha256: 648d70a75ade2911e16e5c80f0e2dae5baf3833c129e80c8f2a5724ff82a2112
END_REPORT_META -->
