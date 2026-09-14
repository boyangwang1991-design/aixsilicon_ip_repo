# GPIO 参数执行评审

七个真实硬件配置、八次 UVM 执行全部通过：N_GPIO=1/8/31/33/64/128 各运行 CONFIG；N_GPIO=32、CFG_PARITY_EN=1 运行 CONFIG 和 PARITY。默认 N_GPIO=32、CFG_PARITY_EN=0 另有全量三 seed 回归。

此前 269 个 schema 配置校验不等同硬件覆盖。其余 20 参数中的禁用分支、同步深度和组合配置仍需扩展仿真；本报告不冒充完整参数空间 PASS。

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: param_execution
status: fail
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: See bound run manifests
artifacts:
- path: reports/quality/param_hardware_runs.json
  sha256: ab72ddd8267f8d484bb57ffb36c76c9c4108966b3a74cfbba9bbf056949c7d85
- path: build/param_uvm_n1_p0.log
  sha256: 111f1ee50e334fca65496a926df8c209115b0758b45fe19761874102f9dd9d9c
- path: build/param_uvm_n8_p0.log
  sha256: 589c67f8071ebf5765eb6fdf2da1096f9236a6824b1fe796601f966d80469c4a
- path: build/param_uvm_n31_p0.log
  sha256: b3c5f9e466b1098a9beefdb5a3cb78002edc73383873464ff8ae4fd0cc28f687
- path: build/param_uvm_n33_p0.log
  sha256: 4f94679a0dfcedea7bcd334c7cf65cd9952fff317b66fc5d77569dee72e18eae
- path: build/param_uvm_n64_p0.log
  sha256: 0c2c61b9c4271f2c71b4668b0f2b98592993b52690e791d1f8b2936c13762d98
- path: build/param_uvm_n128_p0.log
  sha256: 3cf59ddb1cac298b01e77440f638ed2a2db0c6925c20ce1a9e8d5a1947b47467
- path: build/param_uvm_n32_p1.log
  sha256: f5e9b941515780ff4f3c9f174313d56b9a49cf3bb146e43d67b8a55f5b6bbbdd
- path: build/sim/uvm/n1_p0_1j1q05q9/build.json
  sha256: aad7e5ca21a02b70ee2bbee4a14de7415f67f7bdfcc0214aeb34bcdfdc9d633c
- path: build/sim/uvm/n1_p0_1j1q05q9/config_1_a0tiscn9/run.log
  sha256: 9fd7f29a4222b423782b39d4fb4c340745f3b677884583936afd01d87c077dec
- path: build/sim/uvm/n1_p0_1j1q05q9/results.json
  sha256: 3102d53b81ad7d278a04364df7747112a640ec3be228cf2719eacb9e30ad03f1
- path: build/sim/uvm/n8_p0_tptnrbti/build.json
  sha256: 3a10f439f7be73ce004a0fb10011f3c3662af6c1e19a5f76070076c744463e79
- path: build/sim/uvm/n8_p0_tptnrbti/config_1_zbt5k6im/run.log
  sha256: 46beaefa1fa9d29d3b383af7b52ae6655be0043177cb23e7128325e33dec97bb
- path: build/sim/uvm/n8_p0_tptnrbti/results.json
  sha256: dde0e2608848f9ac7c85062ef3dbe55e07873d66af9a70485c8b9a6128de3e68
- path: build/sim/uvm/n31_p0_w20bx2rm/build.json
  sha256: 9733789ced0fbeeaf3ce160fee79373f3fc237b3ada0ca563f3a459d72bca348
- path: build/sim/uvm/n31_p0_w20bx2rm/config_1_7hv75rp8/run.log
  sha256: a7162da4dda224e7efecdf695789ff84e80181497ae274f3cf243fe06e1c8b13
- path: build/sim/uvm/n31_p0_w20bx2rm/results.json
  sha256: c9f75f4249b229a8b5ea82bf2d515383f95897af66b8d165f236004dae923a31
- path: build/sim/uvm/n33_p0_wwjbo0e5/build.json
  sha256: a8b25ed222df7ff8893444e5cdf6d98d312cf7cc6a83f939886105f97e98b5fa
- path: build/sim/uvm/n33_p0_wwjbo0e5/config_1_y_inpx0r/run.log
  sha256: d8c706fe0931affdc7f4c0ed36063e0275f21d783ac5a8beeb6dc5bf6435563e
- path: build/sim/uvm/n33_p0_wwjbo0e5/results.json
  sha256: 34b869aa4c244a928b7330c4baece35b9bf0bac92d604b3e446d38c0de89e11a
- path: build/sim/uvm/n64_p0_abu1ojx8/build.json
  sha256: fd1ce7de46aad25db55d27908382ed7d02e8ed181ea2027d835417174a240973
- path: build/sim/uvm/n64_p0_abu1ojx8/config_1_4yac4kia/run.log
  sha256: 41cc8e6aa17241432f5897ad5651f9f9b534716fe4812faa5c7840c3785bc232
- path: build/sim/uvm/n64_p0_abu1ojx8/results.json
  sha256: 91d12acace96c2569880d488c911d22de0815814af23ab0369b689a66ad60add
- path: build/sim/uvm/n128_p0_55e2xdal/build.json
  sha256: ccdaf0006940f2d30ec2394a89f73c38eff095f079770e746c16d220ba08a33a
- path: build/sim/uvm/n128_p0_55e2xdal/config_1_1hmil3bi/run.log
  sha256: 5d380c281fda267607380b9d21436db7a6a71e429f54736b41db7e2e3a429325
- path: build/sim/uvm/n128_p0_55e2xdal/results.json
  sha256: 75c48b25db30660014061905543f5f10474aa33a1c1ecec41172015c8ffa086b
- path: build/sim/uvm/n32_p1_2j5rqjg9/build.json
  sha256: a8336d64e6a193921d6194c455d3029f8a98db2c6717168cd5711cf55ac2951e
- path: build/sim/uvm/n32_p1_2j5rqjg9/config_1_7cxhfleq/run.log
  sha256: 260367d70fc666ef5dc2f5728b6a68c67b0a21143b112625db998e91c7422928
- path: build/sim/uvm/n32_p1_2j5rqjg9/parity_1_5u564dx2/run.log
  sha256: 6060d3dbc29729663fb83f7ce69d911b8789ef390689e811916d366ce7a26eeb
- path: build/sim/uvm/n32_p1_2j5rqjg9/results.json
  sha256: a2bb712e66f61e91601a6c609a2b801b847868deef94607a88576182241db206
hardware_configurations: 7
executions: 8
conditions:
- 269 schema configurations are not 269 hardware simulations
- Only N_GPIO boundary values and CFG_PARITY_EN=1 executed; remaining parameter combinations
  not closed
END_REPORT_META -->
