# GPIO 最终 RTL 检查

Elaboration、28nm DC 综合通过。SpyGlass 完整 lint 完成，0 error、2 warning：原生 passthrough CSR 的 stall_rd/stall_wr 输出未接；不隐藏警告或将工具非零退出码改为 PASS。G3 依用户授权有条件继续。

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: rtl_check
status: fail
eda_profile: commercial-systemverilog
checks:
  lint:
    status: fail
    exit_code: 1
    tool: spyglass
    tool_version: X-2025.06
    command:
    - bash
    - -ec
    - uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter
      run --target=lint --build-root=build/rtl/fullflow_lint_01 aixsilicon:ip:gpio:0.1.0;
      cat build/rtl/fullflow_lint_01/aixsilicon_ip_gpio_0.1.0/lint-spyglass/sg_shell.log
    log: build/rtl/fullflow_lint_01.log
    log_sha256: 20debbb88b97bb0a201b4be8990ed5c3312202f6ef816e45939eac998480b479
    execution_manifest:
      path: build/rtl/fullflow_lint_01.json
      sha256: f06fe04d0c31480b9c0a230ff7e57ddfa2c6c8c8edcaed1ef5eb631193c2fc03
  elab:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: W-2024.09-SP1
    command:
    - bash
    - -ec
    - uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter
      run --setup --build --target=elab --build-root=build/rtl/fullflow_elab_01 aixsilicon:ip:gpio:0.1.0;
      cat build/rtl/fullflow_elab_01/aixsilicon_ip_gpio_0.1.0/elab-vcs/compile.log
    log: build/rtl/fullflow_elab_01.log
    log_sha256: 4ab56dd5517b64e2f30323097b150eb12e1772592db0330f0a37ef7fb0aee23b
    execution_manifest:
      path: build/rtl/fullflow_elab_01.json
      sha256: 7ad93f9cfc7457cb8d522e2ee8f741b0a50a461baa06a77943c3ffe9e2adae91
  synth:
    status: pass
    exit_code: 0
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command:
    - uv
    - run
    - --locked
    - --no-sync
    - fusesoc
    - --cores-root=.
    - --cores-root=build/cbb_adapter
    - run
    - --target=synth
    - --build-root=/tmp/gpio_ppa_n32_qmesv1d7
    - aixsilicon:ip:gpio:0.1.0
    log: reports/synth/fullflow_combined.log
    log_sha256: c4cf90b62d7a6bf465e688b34d18842cf2b587590335836ec7a38e915bfd9b88
    execution_manifest:
      path: reports/synth/fullflow_execution.json
      sha256: addeb3ab10686ae91788d7e62743ea11425b7cf7c67e28a63611a4ebe18e260e
artifacts:
- path: build/rtl/fullflow_lint_01.json
  sha256: f06fe04d0c31480b9c0a230ff7e57ddfa2c6c8c8edcaed1ef5eb631193c2fc03
- path: build/rtl/fullflow_elab_01.json
  sha256: 7ad93f9cfc7457cb8d522e2ee8f741b0a50a461baa06a77943c3ffe9e2adae91
- path: reports/synth/fullflow_execution.json
  sha256: addeb3ab10686ae91788d7e62743ea11425b7cf7c67e28a63611a4ebe18e260e
END_REPORT_META -->
