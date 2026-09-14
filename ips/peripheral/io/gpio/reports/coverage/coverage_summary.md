# GPIO 覆盖率分析

真实合并 14 个 testcase × seed 1/17/101，共 42 次通过运行。URG 首次在许可检查的分配器中崩溃，保留 urg.log，使用 VCS_USE_MALLOC=1 后生成完整报告。

| 指标 | 全设计工具观测 | DUT 层级 |
|---|---:|---:|
| Line | 88.40% | 88.41% |
| Condition | 38.85% | 38.85% |
| Toggle | 50.47% | 50.63% |
| FSM | 80.00% | 80.00% |
| Branch | 71.53% | 71.48% |
| Assertion | 62.50% | 100.00% |

APB gpio_fcov 的方向、16 个 PSTRB、8 个 PPROT 交叉覆盖为 100%，仅证明已实现的这一覆盖组。VPLAN 的其余 feature covergroup 尚未完整实现；不能将局部 100% 记为全功能签核。原 100% 目标未降低，无人工排除或覆盖豁免。

逐模块原始整数分母见 REPORT_META code_metrics，不能混合单实例/模块定义或 signal/bit 分母。剩余洞集中在多引脚翻转、诊断错误分支、输入滤波组合、FIFO 组合条件与 mailbox FSM 分支。交付保留为技术关闭条件，覆盖率分析动作已经执行。

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: coverage
status: fail
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: See bound run manifests
artifacts:
- path: build/cov/full_42/urgReport_retry/asserts.html
  sha256: 5449300037c84f125c57d3b311677cca278b9fd599dc1a0da4d7397548cfb51b
- path: build/cov/full_42/urgReport_retry/asserts.txt
  sha256: 7d0d86cd2db207bd65824d32571fa7e37e72d71dda5fc083c6dd4d58dfe8f95c
- path: build/cov/full_42/urgReport_retry/dashboard.html
  sha256: 0a1ee8058a44112b66b364ebde9f62d4e69cfc5be29c6648dfe3e6be95c48e69
- path: build/cov/full_42/urgReport_retry/dashboard.txt
  sha256: de721ab1010c2a31b36fb448082409cde6a8d9f5b0786851423616ecc2f3949a
- path: build/cov/full_42/urgReport_retry/groups.html
  sha256: c76c67acb617bdcbd1c50cfa446bca65f94c2d40c5f1d08f59a278c73dc26ff1
- path: build/cov/full_42/urgReport_retry/groups.txt
  sha256: e50ea21fad2852c491ac393fc99603e600d8c59564480a2d92352e59a13c15ad
- path: build/cov/full_42/urgReport_retry/grp0.html
  sha256: 4e7d3ce2c687af082b4551002aa30e1d231d254306f2f0a66bd8dd28913d3b6b
- path: build/cov/full_42/urgReport_retry/grpinfo.txt
  sha256: 941371373b1c62d744846c0780e47e81152e42fd0435f6b99506cbccb3c8b11f
- path: build/cov/full_42/urgReport_retry/hierarchy.html
  sha256: 99ce04ecba22dd3b33d771a0a633f0824a78ece5d799c70295347463254c51ad
- path: build/cov/full_42/urgReport_retry/hierarchy.txt
  sha256: 9d8f23dd8e3b8b2cb49f7d604abee5b47e603ce2d40fa8b19d0155328b22a615
- path: build/cov/full_42/urgReport_retry/mod0.html
  sha256: 27bed10979df72dfe8be48536e3ffcaa3dbe920e7f94422815063dac5e53eae9
- path: build/cov/full_42/urgReport_retry/mod10.html
  sha256: 7d16f337872c306ee912a54956cfc05e72d9f7ccf2412d45b014e5b2007950db
- path: build/cov/full_42/urgReport_retry/mod13.html
  sha256: afbbc93866b6927100e39b1f50e67b3cffc1a5f5c185a271202ef508f422cee3
- path: build/cov/full_42/urgReport_retry/mod16.html
  sha256: 5bfdf1b898710fb04dbf8e5988a553a009062bfe03d4ab8637093d938e4b4004
- path: build/cov/full_42/urgReport_retry/mod16_c12.html
  sha256: 0258ad097bd99eb3b2cae6da08da12c9e606074799ed9108e66280886bbfb078
- path: build/cov/full_42/urgReport_retry/mod16_c13.html
  sha256: 97908193e041b361d52ca159e5a6e0a01a0630e6e2abc02e2a9dd901e6088e30
- path: build/cov/full_42/urgReport_retry/mod16_c14.html
  sha256: 5ceb3f0b1cb786f2ca6526ed94ad6935e6325c3436e792b0fffc0ed37138913f
- path: build/cov/full_42/urgReport_retry/mod18.html
  sha256: 8ad1700db1f1cff4abe884bf63b27a5ac8321f62237538c0c6a3d20430ed434d
- path: build/cov/full_42/urgReport_retry/mod19.html
  sha256: 561cc4e304c0f38898a61069bc003bd85e235d9f91cc0fd3bade57a33d0d0c25
- path: build/cov/full_42/urgReport_retry/mod2.html
  sha256: 5828640c80d979018369cf14a6ce7606a2b3bd76a2d68cf324a3a084626f883a
- path: build/cov/full_42/urgReport_retry/mod20.html
  sha256: 96c628588650ccf54b3e2f710672661e012cfb351e9a8bf39ee5b242bb9409ba
- path: build/cov/full_42/urgReport_retry/mod20_0.html
  sha256: 65a1a273c4f2a8c1529df78e695ff5be9a971b4e0aafb35abd4d62bf461a3981
- path: build/cov/full_42/urgReport_retry/mod20_c15.html
  sha256: 4cca04a4e56f8cf29e32d255631c43943726e2a27b8aa6a4f5f9263a1186696f
- path: build/cov/full_42/urgReport_retry/mod20_c16.html
  sha256: 9a2a6743534dc7d0fccc9ffa49204f3d22be93c8d10c118546b746b3ea85d902
- path: build/cov/full_42/urgReport_retry/mod20_c17.html
  sha256: d418e5c54b043aa84f9c4888d06e946d01776bc3fa0b52db9472b7164cfdd890
- path: build/cov/full_42/urgReport_retry/mod20_c18.html
  sha256: d90a0ac3018124b660b2cd616e8eef6eb4cdc4df49db429a7ff975a3b08d51a1
- path: build/cov/full_42/urgReport_retry/mod21.html
  sha256: 195dd371a47990f0dec5e6711ef1add121749d1bbbf8d7e30c0351114d1843e0
- path: build/cov/full_42/urgReport_retry/mod22.html
  sha256: d4020df16520ffad108e82aaeb073074a43b709b36c96392c9474b05c67f8387
- path: build/cov/full_42/urgReport_retry/mod23.html
  sha256: d0bb534170163447d0c97db5d0b19a2be20267186c5d0929afdd9d20013efc2c
- path: build/cov/full_42/urgReport_retry/mod24.html
  sha256: 735cd9704df2907f57c549370b45a4979da35173df34a85b24b7adc891080dc7
- path: build/cov/full_42/urgReport_retry/mod24_0.html
  sha256: 448e67cab768cda4db0d14bc16fcf3be6c42498e5aca637ccd40856dbcb8462c
- path: build/cov/full_42/urgReport_retry/mod24_c10.html
  sha256: e6041d6025f977ef81745e45e77cda18a38a3c9e1e324944b364a186dc864e57
- path: build/cov/full_42/urgReport_retry/mod24_c11.html
  sha256: 23256d8abcee849ff3ce6cc00c07e60ca4ea50c80964451b0ec4525b9cba6a29
- path: build/cov/full_42/urgReport_retry/mod25.html
  sha256: 378490bdb20c44010b1faaaa50416be580ea108164a5373b1358a3a3a2888178
- path: build/cov/full_42/urgReport_retry/mod3.html
  sha256: e6acc0e41e6fe8bce2f308c21841a92b55d390c6ae1e3260ce8ab507f0b646c8
- path: build/cov/full_42/urgReport_retry/mod3_0.html
  sha256: c48a28a728d83e1c9176cf752c1496d62b80880c7d3c3357aae0b6d64dfef253
- path: build/cov/full_42/urgReport_retry/mod3_c1.html
  sha256: f30dc615e0abc0bf5772fdc977452b02c1a601e08c9f85a808c92abfaaf6de24
- path: build/cov/full_42/urgReport_retry/mod3_c2.html
  sha256: 48a8db49bc595ebfaa88f9942fa513ae2492a39168a1bf91edbccd0eda9dc867
- path: build/cov/full_42/urgReport_retry/mod3_c3.html
  sha256: e1a7afa625e2431e6c69ff5a72c03f3a24f92ebfe5caf49650b7b381e23ae79c
- path: build/cov/full_42/urgReport_retry/mod3_c4.html
  sha256: 34046c5b05b816841075c39eaf2adda42a7fef0dd0af5fd642cbfa4a12de30a1
- path: build/cov/full_42/urgReport_retry/mod3_c5.html
  sha256: 3d957b804f432260c564eb5cf6d481c3f2f0d0f945c42e6bd43c18b3e89adc5f
- path: build/cov/full_42/urgReport_retry/mod3_c6.html
  sha256: 162589068f4f717fe0437bbd888157369910de38b22af90b57893e16c91d79ee
- path: build/cov/full_42/urgReport_retry/mod3_c7.html
  sha256: 1bcca497c785f7a31b352cd778dc4dc4a12887d1ad3683502a3e43ea0c3b9d79
- path: build/cov/full_42/urgReport_retry/mod3_c8.html
  sha256: 56aba82a6838fa7c91b2d7bfe37d008463c97953976532cab0e8ef565b3992ce
- path: build/cov/full_42/urgReport_retry/mod3_c9.html
  sha256: f001fb6a08199b7f09ff4b3c29207d2c11206d0892a9b7936037a445c93aa60b
- path: build/cov/full_42/urgReport_retry/mod4.html
  sha256: 5970296d7c9490b85ebaf06c29ef0fc041c608089dc6478fcca01c35238e5026
- path: build/cov/full_42/urgReport_retry/mod5.html
  sha256: dbf4c3eac4657e62c0eaa3f3cffdfc3ad7fdf054b51f06737ea947544b1372a6
- path: build/cov/full_42/urgReport_retry/mod7.html
  sha256: df4f416d3f95c1ac277ac23e9bee872c549d4be330710c6a4f8c73247499665c
- path: build/cov/full_42/urgReport_retry/mod8.html
  sha256: 525ea79f7525c217e338aa61f3f48600da6cb9beb8df72ed860656e6a5d77971
- path: build/cov/full_42/urgReport_retry/mod9.html
  sha256: 9785a0964a69a14de0bc5a82e64190b09ad5fea4a714dc344015c09a1c1b6599
- path: build/cov/full_42/urgReport_retry/modinfo.txt
  sha256: 643845ee3a895cc740bc18df482391aa65815b8fdb3066ef9f8463bf7b34f8ff
- path: build/cov/full_42/urgReport_retry/modlist.html
  sha256: c87f600b906c082dccf0997aab2426260c8665549ce9111c6acd0a58a8234348
- path: build/cov/full_42/urgReport_retry/modlist.txt
  sha256: 8adee0279f1e78e60dff9336ccd31906983cc492355c1298ec8ce3496bb8d09a
- path: build/cov/full_42/urgReport_retry/tests.html
  sha256: bec779e9318a86b527a5ed5c6b3b96ed5d8df83ea247a9c93242b9863db6471e
- path: build/cov/full_42/urgReport_retry/tests.txt
  sha256: 6e7096914395f44b4a1c46f74aca1c485cdf69ed817fb3502626f006be045475
- path: build/cov/full_42/retry_execution.json
  sha256: f5d22fa967009cec1377547c9c0896dcd924d8beaf430448e7b9b99b7c0414d6
- path: reports/regression/campaign.json
  sha256: 67cf2466b7b1b1641244e2952c1a68ceecee3b621ce6d6a3b777731f708899a1
coverage:
  functional:
    achieved: 100
    target: 100
    scope: implemented gpio_fcov APB group only; full VPLAN functional model incomplete
  code:
    achieved: 65.29
    target: 100
    scope: URG module definition composite, includes verification instrumentation
  assertion:
    achieved: 62.5
    target: 100
    scope: URG all assertions, including UVM infrastructure
coverage_source:
  collector: Synopsys URG W-2024.09-SP1
  collection_command: VCS -cm line+cond+branch+tgl+fsm+assert across 42 passing executions
  merge_command: See build/cov/full_42/retry_execution.json; VCS_USE_MALLOC=1 after
    original allocator crash
  report: build/cov/full_42/urgReport_retry/dashboard.txt
  report_sha256: de721ab1010c2a31b36fb448082409cde6a8d9f5b0786851423616ecc2f3949a
code_metrics:
- metric: line
  scope: gpio
  total: 50
  covered: 50
  target: 100
  report: build/cov/full_42/urgReport_retry/mod0.html
- metric: condition
  scope: gpio
  total: 80
  covered: 41
  target: 100
  report: build/cov/full_42/urgReport_retry/mod0.html
- metric: toggle
  scope: gpio
  total: 169480
  covered: 88482
  target: 100
  report: build/cov/full_42/urgReport_retry/mod0.html
- metric: branch
  scope: gpio
  total: 6
  covered: 6
  target: 100
  report: build/cov/full_42/urgReport_retry/mod0.html
- metric: line
  scope: gpio_csr_checks
  total: 1
  covered: 1
  target: 100
  report: build/cov/full_42/urgReport_retry/mod13.html
- metric: toggle
  scope: gpio_csr_checks
  total: 12
  covered: 10
  target: 100
  report: build/cov/full_42/urgReport_retry/mod13.html
- metric: branch
  scope: gpio_csr_checks
  total: 2
  covered: 2
  target: 100
  report: build/cov/full_42/urgReport_retry/mod13.html
- metric: line
  scope: gpio_irq
  total: 416
  covered: 416
  target: 100
  report: build/cov/full_42/urgReport_retry/mod16.html
- metric: condition
  scope: gpio_irq
  total: 2784
  covered: 816
  target: 100
  report: build/cov/full_42/urgReport_retry/mod16.html
- metric: toggle
  scope: gpio_irq
  total: 1736
  covered: 238
  target: 100
  report: build/cov/full_42/urgReport_retry/mod16.html
- metric: branch
  scope: gpio_irq
  total: 64
  covered: 64
  target: 100
  report: build/cov/full_42/urgReport_retry/mod16.html
- metric: line
  scope: gpio_apb_if
  total: 16
  covered: 15
  target: 100
  report: build/cov/full_42/urgReport_retry/mod18.html
- metric: condition
  scope: gpio_apb_if
  total: 85
  covered: 73
  target: 100
  report: build/cov/full_42/urgReport_retry/mod18.html
- metric: toggle
  scope: gpio_apb_if
  total: 448
  covered: 427
  target: 100
  report: build/cov/full_42/urgReport_retry/mod18.html
- metric: branch
  scope: gpio_apb_if
  total: 15
  covered: 14
  target: 100
  report: build/cov/full_42/urgReport_retry/mod18.html
- metric: line
  scope: gpio_capture
  total: 18
  covered: 16
  target: 100
  report: build/cov/full_42/urgReport_retry/mod19.html
- metric: condition
  scope: gpio_capture
  total: 10
  covered: 10
  target: 100
  report: build/cov/full_42/urgReport_retry/mod19.html
- metric: toggle
  scope: gpio_capture
  total: 530
  covered: 352
  target: 100
  report: build/cov/full_42/urgReport_retry/mod19.html
- metric: branch
  scope: gpio_capture
  total: 8
  covered: 6
  target: 100
  report: build/cov/full_42/urgReport_retry/mod19.html
- metric: line
  scope: gpio_csr
  total: 548
  covered: 522
  target: 100
  report: build/cov/full_42/urgReport_retry/mod2.html
- metric: condition
  scope: gpio_csr
  total: 871
  covered: 709
  target: 100
  report: build/cov/full_42/urgReport_retry/mod2.html
- metric: toggle
  scope: gpio_csr
  total: 136644
  covered: 87154
  target: 100
  report: build/cov/full_42/urgReport_retry/mod2.html
- metric: branch
  scope: gpio_csr
  total: 359
  covered: 348
  target: 100
  report: build/cov/full_42/urgReport_retry/mod2.html
- metric: line
  scope: gpio_aon_wake
  total: 1177
  covered: 1173
  target: 100
  report: build/cov/full_42/urgReport_retry/mod20.html
- metric: condition
  scope: gpio_aon_wake
  total: 3361
  covered: 1423
  target: 100
  report: build/cov/full_42/urgReport_retry/mod20.html
- metric: toggle
  scope: gpio_aon_wake
  total: 4190
  covered: 1435
  target: 100
  report: build/cov/full_42/urgReport_retry/mod20.html
- metric: branch
  scope: gpio_aon_wake
  total: 363
  covered: 298
  target: 100
  report: build/cov/full_42/urgReport_retry/mod20.html
- metric: line
  scope: gpio_security
  total: 10
  covered: 9
  target: 100
  report: build/cov/full_42/urgReport_retry/mod21.html
- metric: condition
  scope: gpio_security
  total: 5
  covered: 4
  target: 100
  report: build/cov/full_42/urgReport_retry/mod21.html
- metric: toggle
  scope: gpio_security
  total: 274
  covered: 14
  target: 100
  report: build/cov/full_42/urgReport_retry/mod21.html
- metric: branch
  scope: gpio_security
  total: 3
  covered: 2
  target: 100
  report: build/cov/full_42/urgReport_retry/mod21.html
- metric: line
  scope: gpio_regfile
  total: 276
  covered: 233
  target: 100
  report: build/cov/full_42/urgReport_retry/mod22.html
- metric: condition
  scope: gpio_regfile
  total: 139
  covered: 84
  target: 100
  report: build/cov/full_42/urgReport_retry/mod22.html
- metric: toggle
  scope: gpio_regfile
  total: 67126
  covered: 2363
  target: 100
  report: build/cov/full_42/urgReport_retry/mod22.html
- metric: branch
  scope: gpio_regfile
  total: 135
  covered: 97
  target: 100
  report: build/cov/full_42/urgReport_retry/mod22.html
- metric: toggle
  scope: gpio_control_if
  total: 2346
  covered: 228
  target: 100
  report: build/cov/full_42/urgReport_retry/mod23.html
- metric: line
  scope: gpio_input
  total: 1291
  covered: 981
  target: 100
  report: build/cov/full_42/urgReport_retry/mod24.html
- metric: condition
  scope: gpio_input
  total: 1925
  covered: 1110
  target: 100
  report: build/cov/full_42/urgReport_retry/mod24.html
- metric: toggle
  scope: gpio_input
  total: 5064
  covered: 1062
  target: 100
  report: build/cov/full_42/urgReport_retry/mod24.html
- metric: branch
  scope: gpio_input
  total: 901
  covered: 529
  target: 100
  report: build/cov/full_42/urgReport_retry/mod24.html
- metric: condition
  scope: gpio_csr_adapter
  total: 9485
  covered: 2958
  target: 100
  report: build/cov/full_42/urgReport_retry/mod3.html
- metric: toggle
  scope: gpio_csr_adapter
  total: 137378
  covered: 86410
  target: 100
  report: build/cov/full_42/urgReport_retry/mod3.html
- metric: line
  scope: gpio_aon_mailbox
  total: 72
  covered: 67
  target: 100
  report: build/cov/full_42/urgReport_retry/mod4.html
- metric: condition
  scope: gpio_aon_mailbox
  total: 42
  covered: 31
  target: 100
  report: build/cov/full_42/urgReport_retry/mod4.html
- metric: toggle
  scope: gpio_aon_mailbox
  total: 3632
  covered: 218
  target: 100
  report: build/cov/full_42/urgReport_retry/mod4.html
- metric: branch
  scope: gpio_aon_mailbox
  total: 32
  covered: 27
  target: 100
  report: build/cov/full_42/urgReport_retry/mod4.html
- metric: line
  scope: gpio_event_fifo
  total: 28
  covered: 27
  target: 100
  report: build/cov/full_42/urgReport_retry/mod5.html
- metric: condition
  scope: gpio_event_fifo
  total: 321
  covered: 106
  target: 100
  report: build/cov/full_42/urgReport_retry/mod5.html
- metric: toggle
  scope: gpio_event_fifo
  total: 1048
  covered: 159
  target: 100
  report: build/cov/full_42/urgReport_retry/mod5.html
- metric: branch
  scope: gpio_event_fifo
  total: 80
  covered: 51
  target: 100
  report: build/cov/full_42/urgReport_retry/mod5.html
- metric: line
  scope: gpio_output
  total: 30
  covered: 28
  target: 100
  report: build/cov/full_42/urgReport_retry/mod7.html
- metric: condition
  scope: gpio_output
  total: 9
  covered: 7
  target: 100
  report: build/cov/full_42/urgReport_retry/mod7.html
- metric: toggle
  scope: gpio_output
  total: 848
  covered: 408
  target: 100
  report: build/cov/full_42/urgReport_retry/mod7.html
- metric: branch
  scope: gpio_output
  total: 7
  covered: 7
  target: 100
  report: build/cov/full_42/urgReport_retry/mod7.html
- metric: line
  scope: gpio_diag
  total: 544
  covered: 420
  target: 100
  report: build/cov/full_42/urgReport_retry/mod9.html
- metric: condition
  scope: gpio_diag
  total: 800
  covered: 365
  target: 100
  report: build/cov/full_42/urgReport_retry/mod9.html
- metric: toggle
  scope: gpio_diag
  total: 4814
  covered: 1248
  target: 100
  report: build/cov/full_42/urgReport_retry/mod9.html
- metric: branch
  scope: gpio_diag
  total: 192
  covered: 98
  target: 100
  report: build/cov/full_42/urgReport_retry/mod9.html
exclusions: []
waivers: []
threshold_changes: []
END_REPORT_META -->
