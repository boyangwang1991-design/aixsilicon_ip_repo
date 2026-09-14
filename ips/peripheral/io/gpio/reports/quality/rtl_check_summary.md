<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
checks:
  lint:
    status: pass
    exit_code: 0
    tool: spyglass
    tool_version: X-2025.06
    command:
    - bash
    - -ec
    - uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter
      run --target=lint --build-root=build/rtl/resume_lint_03 aixsilicon:ip:gpio:0.1.0;
      cat build/rtl/resume_lint_03/aixsilicon_ip_gpio_0.1.0/lint-spyglass/sg_shell.log
    log: build/rtl/resume_lint_03.log
    log_sha256: 13fb46259ece0b8a9826693f1228c5d295cc235330018b87aba4dfcfb7e6400d
    execution_manifest:
      path: build/rtl/resume_lint_03.json
      sha256: c69da92ba4f02ae702da62dc1d6bd28513357d77924a23767173e2c7dc47d0bc
  elab:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: W-2024.09-SP1
    command:
    - bash
    - -ec
    - uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter
      run --setup --build --target=elab --build-root=build/rtl/resume_elab_02 aixsilicon:ip:gpio:0.1.0;
      cat build/rtl/resume_elab_02/aixsilicon_ip_gpio_0.1.0/elab-vcs/compile.log
    log: build/rtl/resume_elab_02.log
    log_sha256: a2a57b821d9fd78e4d4e2c44eac0ecad3d08a6549386fe7eed3955eb82ab6e85
    execution_manifest:
      path: build/rtl/resume_elab_02.json
      sha256: 0c86162eaf5d8a3356fd78c79ca29f9bf37e40c03a9355761bd53bf382df6cc3
  synth:
    status: pass
    exit_code: 0
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command:
    - env
    - IP_ROOT=/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio
    - GPIO_PDK_SETUP=/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/build/rtl/pdk_setup.tcl
    - GPIO_SYNTH_SDC=/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/constraints/gpio_characterization.sdc
    - GPIO_SYNTH_PARAMETERS=N_GPIO=8
    - bash
    - -ec
    - uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter
      run --target=synth --build-root=build/rtl/resume_synth_02 aixsilicon:ip:gpio:0.1.0;
      cat build/rtl/resume_synth_02/aixsilicon_ip_gpio_0.1.0/synth-design_compiler/reports/synth.log
      build/rtl/resume_synth_02/aixsilicon_ip_gpio_0.1.0/synth-design_compiler/reports/area.rpt
    log: build/rtl/resume_synth_02.log
    log_sha256: 8118df4ce52b5f1a68a47da496284131334af2a707f36d6077d858330b5c0560
    execution_manifest:
      path: build/rtl/resume_synth_02.json
      sha256: fa01051312e93dd84307ca8ce0558b201b56a303575cc4d960d16e75337a9656
END_REPORT_META -->
