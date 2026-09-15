# 模块 UT 执行结果

结果来自本批实际编译与仿真；输入集合及内容在执行前后核对。该结果仅用于模块 UT，UVM 与形式签核分别执行。

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
- path: build/sim/run/ut/batch_1789371377402536245/inputs.json
  sha256: 9984b8ad8fad6d2cb9aca1a215b773cf7103a05a29bf1a3179bae9ba488797f4
- path: build/sim/run/ut/batch_1789371377402536245/inputs.before.sha256
  sha256: b47dfa7e82b6912197cb7a66f2f99cdc3d84c66c2414413d32ca726d51623457
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux.compile.log
  sha256: be5cdade09680b187e7f30a477518b5a6dc5bd72f5674b1eca7f5d27497cb288
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux.run.log
  sha256: 4a1a591d2985de700dc994434b5aebbe8bc501cc6c4760b1c58d417f3d178ded
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux/aixsilicon_ip_apb_secure_demux_1.0.0/ut_top-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 2d1928436aba7edb0de2b83c2cbe8b80768d4c11cea6e7607118528cc530817d
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access.compile.log
  sha256: 50f16dcb6bbddbafcfe4b1c61c83b3cc501ec7c6bfdeb06a5d2f5638daabea97
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access.run.log
  sha256: bc773f027148f2c9d52a6a74de145908c340f7dec5a4f92eff7cf40eadba3fef
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access/aixsilicon_ip_apb_secure_demux_1.0.0/ut_access-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 13c89d89fdfb7cddb1f7752e95d143e7fa2a9b5ec14169a4880f37d34de775c8
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr.compile.log
  sha256: b952df5f2ea5f5e0e14ff6fa7082bb7dbdc02968810f3532d615a7d1eb967a26
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr.run.log
  sha256: 87d54fcf053cbfbc7f388957310f5d4d268840624b0843bcea012db076da8367
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr/aixsilicon_ip_apb_secure_demux_1.0.0/ut_csr-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: c28bdc54ce1f87a9b82375579e362ec740bf57ea5cdaf409a9ac77e18e243b24
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock.compile.log
  sha256: d217ac90935f53b3140b48e56f90973640d4a26bde95e112ef45cfa82c205f2f
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock.run.log
  sha256: 1f81204f9e9e0fe9a02cedf305948be12d81797df835b49a00d76a4884b02299
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock/aixsilicon_ip_apb_secure_demux_1.0.0/ut_native-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: b01cb5cd899ae4a6042f7d5cf644f305694202bc3f9053fe416198161186426f
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode.compile.log
  sha256: 987a59fcd85866ca16a839ee65a4513e591bb640b2069226c63d898a57e4e219
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode.run.log
  sha256: 3061c9e2ee70cc512fedae0c6bf4c1e9e24ca656025fcc28441b5c4ad2db99a0
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode/aixsilicon_ip_apb_secure_demux_1.0.0/ut_decode-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: e0ccf48f639c54cc0b6bf2347afa287094acd6a4e88e4198f991669eb2031fc7
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx.compile.log
  sha256: 383f97097b024103ba932cc359c14d028e2cfd87aa47b15286a52c3cb6c479c7
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx.run.log
  sha256: 1bd252769497d368968468cda96253900a6c145b19d03dc61bbf657b14dfa9f7
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx/aixsilicon_ip_apb_secure_demux_1.0.0/ut_dfx-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: c820bf31b0b098da3762d394a6d733dcf0d00f747f1c67f602da5fcec12888a6
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events.compile.log
  sha256: 995069bc7f41d7f31f54b3bdd3e7a874d47930ac4628260a39c0d1f5f4cdf2ef
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events.run.log
  sha256: 78ad019b07c76041b8bff4e8d5dcbbe1d98b622e9e8a4390431e5d3843f61c47
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events/aixsilicon_ip_apb_secure_demux_1.0.0/ut_events-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: bf49ae4ff31a928d1fb2589f17bb850828588f0a6b89b53723b6827f6d16f513
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq.compile.log
  sha256: 5a6b8902fe31d88af7b2fec802d15660ee99857566ece75d46d7c5e527740b54
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq.run.log
  sha256: cd4cf71536af4c924718b699cc86389c62ace1cf23fdc63c62e0ec94a07d5b50
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq/aixsilicon_ip_apb_secure_demux_1.0.0/ut_irq-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: cb87a8be6f2bd67ce00e55f64fcf3910498093d57bd22116a4f1a16c07b84490
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy.compile.log
  sha256: dcf55d9c26302019c75c2ef63b80a7a1733afb924ff9e099d23f7cf9cd533535
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy.run.log
  sha256: 819e0f231f65157e6aebc8782f0ed4de5008e45966b212ef3f1c66463a8e288a
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy/aixsilicon_ip_apb_secure_demux_1.0.0/ut_policy-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: f61eee70b4850c97ee8adbb4dfb4993e92b03052f553c708e8537cdb6447433d
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge.compile.log
  sha256: c784d016d0d505c5de39e69c5ea5e064da7411e006cf363895a1126de0914e04
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge.run.log
  sha256: 69499b59f7f8ba8cb61e4d8cd6a8c0d67beabc01ebf9648d7f5b3e225becccd5
- path: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge/aixsilicon_ip_apb_secure_demux_1.0.0/ut_bridge-vcs/aixsilicon_ip_apb_secure_demux_1.0.0
  sha256: 2623d1fa79c497a62d69a266b8a667df821f9f4255707f859026f62a4764fbdd
- path: build/sim/run/ut/batch_1789371377402536245/inputs.after.sha256
  sha256: b47dfa7e82b6912197cb7a66f2f99cdc3d84c66c2414413d32ca726d51623457
checks:
  ut_apb_secure_demux:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_top
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_top
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux.run.log
  ut_apb_secure_demux_access:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_access
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_access
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_access.run.log
  ut_apb_secure_demux_csr:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_csr
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_csr
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr.run.log
  ut_apb_secure_demux_csr_regblock:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_native
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_native
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_csr_regblock.run.log
  ut_apb_secure_demux_decode:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_decode
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_decode
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_decode.run.log
  ut_apb_secure_demux_dfx:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_dfx
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_dfx
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_dfx.run.log
  ut_apb_secure_demux_events:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_events
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_events
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_events.run.log
  ut_apb_secure_demux_irq:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_irq
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_irq
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_irq.run.log
  ut_apb_secure_demux_policy:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_policy
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_policy
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_policy.run.log
  ut_apb_secure_demux_register_bridge:
    status: pass
    compile_exit: 0
    run_exit: 0
    compile_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_bridge
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge
    - --setup
    - --build
    - aixsilicon:ip:apb_secure_demux:1.0.0
    run_command:
    - fusesoc
    - --verbose
    - --config
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/package/fusesoc.conf
    - --cores-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux
    - run
    - --target=ut_bridge
    - --build-root
    - /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge
    - --run
    - aixsilicon:ip:apb_secure_demux:1.0.0
    compile_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge.compile.log
    run_log: build/sim/run/ut/batch_1789371377402536245/ut_apb_secure_demux_register_bridge.run.log
module_coverage:
  apb_secure_demux:
  - ut_apb_secure_demux
  apb_secure_demux_access:
  - ut_apb_secure_demux_access
  apb_secure_demux_csr:
  - ut_apb_secure_demux_csr
  apb_secure_demux_csr_regblock:
  - ut_apb_secure_demux_csr_regblock
  apb_secure_demux_decode:
  - ut_apb_secure_demux_decode
  apb_secure_demux_dfx:
  - ut_apb_secure_demux_dfx
  apb_secure_demux_events:
  - ut_apb_secure_demux_events
  apb_secure_demux_irq:
  - ut_apb_secure_demux_irq
  apb_secure_demux_policy:
  - ut_apb_secure_demux_policy
  apb_secure_demux_register_bridge:
  - ut_apb_secure_demux_register_bridge
inputs_manifest:
  path: build/sim/run/ut/batch_1789371377402536245/inputs.before.sha256
  sha256: b47dfa7e82b6912197cb7a66f2f99cdc3d84c66c2414413d32ca726d51623457
inputs_after_manifest:
  path: build/sim/run/ut/batch_1789371377402536245/inputs.after.sha256
  sha256: b47dfa7e82b6912197cb7a66f2f99cdc3d84c66c2414413d32ca726d51623457
END_REPORT_META -->
