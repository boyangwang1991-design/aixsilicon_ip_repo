# Module UT execution

Results are from this immutable batch only. This is not UVM regression or formal signoff.

<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_secure_demux
report_type: module_ut
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1 (also present in raw logs)
command: uv run python scripts/run_module_ut.py
test_count: 10
artifacts:
- path: build/sim/run/ut/batch_1789118072424261579/inputs.json
  sha256: bad3f2d699b284245ba4fb5aea3490e0af70a78592bb97e3cd7ad9db532445bf
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux.compile.log
  sha256: ad8330d2cc52ea7d95ab66c128bc240ee93ad501f5c53781d386e38d0cb74c61
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux.run.log
  sha256: f4063cf130092ab37930952c6a11f30bf0366be4b83ee322dd901d4e2ff453a9
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux/aixsilicon_ip_apb_secure_demux_1.0.0/ut_top-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: cb7dc8fc5137affcf5abb8ff70d912f8d53c399db82fdb338a2596388ef0af09
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access.compile.log
  sha256: 28ebfb0cdf9841b7319623c172ab8a2393fcf90bfa93e07bbeb1bc3383d8485e
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access.run.log
  sha256: b65c80a8060535f84edc5a2926a0a2f558caf1fc9e3cc4363d3262e788105f73
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access/aixsilicon_ip_apb_secure_demux_1.0.0/ut_access-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 313fab269ab0ac09bf3f058e4bc326a95bca5548dd8bc4823ec0b5409ac1c5ef
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr.compile.log
  sha256: 37f2bdca912263b31a1d3761213edb4265e97acb50e8812befe69adb68d1883d
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr.run.log
  sha256: ba459143d9010d6c8b84f9603710febb6bfaae983088782111371309783b94f4
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr/aixsilicon_ip_apb_secure_demux_1.0.0/ut_csr-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 28ee500e7cc880697ee855fedc2cf51f6d64275d060fa09ca877f8f3c7b957c7
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock.compile.log
  sha256: b944fff9876cc610975c74be2732b81d1f192031873e32f9d63a6d4cf7a7a6c9
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock.run.log
  sha256: edc1df6ac5227f06f481bde64bf979f896721b70f6985d534f5731caa57ea79f
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock/aixsilicon_ip_apb_secure_demux_1.0.0/ut_native-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 6709e4fb9b886edc8b1e14ed5035d619c4b1e11683208f8843b6130fb8161a73
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode.compile.log
  sha256: 22ac9f432b86eaa89bbb48a83236aa3ac6fa5674f500cddcd8b0434e3ef6aa39
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode.run.log
  sha256: 8f420af14405d5ab3b52893281e007fd88aef42350f987f10d4eb18f204c0c42
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode/aixsilicon_ip_apb_secure_demux_1.0.0/ut_decode-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 8b922a68449c41932a9abcd7d4eae1d02c7362e87d77d18a360bbc4d407827d5
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx.compile.log
  sha256: d681f98b5856e786159addbdb6e55e36bfc3f39bb3344d5b8249e83ac4ab4900
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx.run.log
  sha256: 0797dd7845b1164822400a317a3e9927fe02c60674679d0b677e4c89479b1c01
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx/aixsilicon_ip_apb_secure_demux_1.0.0/ut_dfx-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 9da22df1ffb10a48ba186b2b579508eddaf3e66a662b0c7be38f00c114c4d1b0
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events.compile.log
  sha256: 8943cf29e64c9f468b6677d24da7dbd475968c872a4a7361bb68d47695da14b2
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events.run.log
  sha256: 48d834cd54139d65bb48e1006ccf63819e37c82e21855f63b6c6fc55b546b0bd
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events/aixsilicon_ip_apb_secure_demux_1.0.0/ut_events-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 8003252996a9ea68539a22c5bf6fb3f733423f75dfff2a6b65b901373db235fb
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq.compile.log
  sha256: 6f2c93d06ba6d9d512eafcc3f7dce97c17e80750f6dfd83fb3eb2c7b96046c1d
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq.run.log
  sha256: 5d23b88c23bf004c20a6d9dec0595c69c635d9e85bb67749347e20de372f0640
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq/aixsilicon_ip_apb_secure_demux_1.0.0/ut_irq-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 921fa37cda8f671183f61ae4711c20a9ea0c8ef213077bf1a2cfd3b34f800c42
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy.compile.log
  sha256: a2b25759861f6df3ea533a8ff492589ab11d6959e187dc31f66e9d1e7ee052b2
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy.run.log
  sha256: f810ade5d43fbfc9b325bfe874235599d6282d7ca1525b20394f1b54319aa5b5
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy/aixsilicon_ip_apb_secure_demux_1.0.0/ut_policy-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 168eb7448a3c5f40958ea0e71c4eb18506c29ed40e6ca0fab9188f471a63eb49
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge.compile.log
  sha256: 3e90398901398d79b4875917e26051a99c1df8b1cc1421078839ac7921c4ad91
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge.run.log
  sha256: 37d658cfc37c29170ae2d49405972bd862062d7b0dfade9f95db06959c3926b2
- path: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge/aixsilicon_ip_apb_secure_demux_1.0.0/ut_bridge-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: b2846479ed4946517332fef0f5b97b9adb7fca1a5e858995b7bc3772ee4f7387
checks:
  ut_apb_secure_demux:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_top
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_top
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux.run.log
  ut_apb_secure_demux_access:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_access
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_access
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_access.run.log
  ut_apb_secure_demux_csr:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_csr
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_csr
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr.run.log
  ut_apb_secure_demux_csr_regblock:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_native
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_native
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_csr_regblock.run.log
  ut_apb_secure_demux_decode:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_decode
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_decode
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_decode.run.log
  ut_apb_secure_demux_dfx:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_dfx
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_dfx
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_dfx.run.log
  ut_apb_secure_demux_events:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_events
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_events
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_events.run.log
  ut_apb_secure_demux_irq:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_irq
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_irq
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_irq.run.log
  ut_apb_secure_demux_policy:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_policy
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_policy
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_policy.run.log
  ut_apb_secure_demux_register_bridge:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_bridge
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_bridge
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge.compile.log
    run_log: build/sim/run/ut/batch_1789118072424261579/ut_apb_secure_demux_register_bridge.run.log
END_REPORT_META -->
