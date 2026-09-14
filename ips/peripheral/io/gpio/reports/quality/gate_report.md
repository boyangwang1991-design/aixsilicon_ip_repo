# Quality Gate Report - gpio

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model, g0.design_freshness |
| G1 | pass | g1.architecture_trace, g1.design_freshness |
| G2 | pass | g2.microdesign_and_register_freeze |
| G3 | fail | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency, g3.special_signoff |
| G4 | blocked | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space, g4.parameter_execution, g4.special_signoff, g4.ral_handoff |
| G5 | blocked | g5.release_inputs, g5.ppa_signoff |

<!-- QUALITY_META
schema_version: '2.0'
ip_name: gpio
generated_by: 15-regression-quality-review/evaluate_quality.py
gates:
- id: G0
  status: pass
  required_checks:
  - g0.required_lrs_docs
  - g0.requirements_model
  - g0.design_freshness
  checks:
  - id: g0.required_lrs_docs
    status: pass
    detail: LRS markdown files=45 (single-file docs/lrs/lrs.md or category-split layout,
      must contain LRS_DOC_META)
    evidence:
    - path: docs/lrs/00_document_control.md
      status: present
      sha256: 9d400a2fac2ea6a83cc56fccce2a24c300e743d48b4b43c4dd48879216f81273
    - path: docs/lrs/01_configuration_cases_1.md
      status: present
      sha256: adfb23740eef1ae55eb864821c03fd334f147137434d99a33c9c139bc5b9c4df
    - path: docs/lrs/01_configuration_cases_2.md
      status: present
      sha256: 928d4978f89f701dca0a56b598c467c2af8679bf2d2995c0748971590ac37753
    - path: docs/lrs/01_configuration_meta_1.md
      status: present
      sha256: 1f7dc58c1e62843e4be9df45c3b2ebda1eb1ad37208270a7aa22a6af836470bd
    - path: docs/lrs/01_configuration_meta_2.md
      status: present
      sha256: 8a8c61e7def3631b34eca7a53e51412adebb30aedd9c8ac580f146e78890ad05
    - path: docs/lrs/01_configuration_parameters_1.md
      status: present
      sha256: 15d38e44e87e6f4494aa686da31a540af26913e0325768cb07a73fa136fb017a
    - path: docs/lrs/01_configuration_parameters_2.md
      status: present
      sha256: c596462930974c00370b3c2b47eb51091c583cd191b52bb1d8bab8608803a91b
    - path: docs/lrs/01_configuration_products.md
      status: present
      sha256: 2b6e01a1197e8555f5639054b517e77f9f4954b822c80175ede48e4a3784ef7b
    - path: docs/lrs/01_configuration_rules.md
      status: present
      sha256: 87d9935c60ba4e7a5f6d3ca382966a599cbc25b0c0be3203001c219cddbbe43c
    - path: docs/lrs/01_scope.md
      status: present
      sha256: e825cb49aba8cda355bf9b82c23369bfc6a3eababb2a79ec4eef179727299bc0
    - path: docs/lrs/02_interface_ports_1.md
      status: present
      sha256: 9ca274de13f629e15cd1e571e8388ac8304838385df875f99f4bf2984b37d521
    - path: docs/lrs/02_interface_ports_2.md
      status: present
      sha256: a8eee8b068fdcba21d71edaf0864550b654eaf4a124d34eeac207f5f382ecc6d
    - path: docs/lrs/02_interface_ports_3.md
      status: present
      sha256: a36476eaad3a6a4f8453d0c76f0f17db493e7cfd8aa6fad1113c3a374b0b292e
    - path: docs/lrs/02_interface_rules.md
      status: present
      sha256: 94a59d54f9b7d742a8bf354177a00ff68d51c2e976e86e306aa93ec738b7437e
    - path: docs/lrs/03_functional_capture.md
      status: present
      sha256: f39a0dba1026827c07fc6ae353e9854b2faf2a0c55791d99c3b92adb12669037
    - path: docs/lrs/03_functional_event_1.md
      status: present
      sha256: 662b3fd80b6ea7f4cd0fc72f37a8e5a18f7c75dba16520d4069fb71972db73ef
    - path: docs/lrs/03_functional_event_2.md
      status: present
      sha256: 8dbbb80e4ca6a4113525f464737059b0ad2a287c55d799916b9e46d11af1c993
    - path: docs/lrs/03_functional_filter.md
      status: present
      sha256: 48f36eac83a799d5868ec61c500631184cc01096ebf03b4d1f02299494bb80d3
    - path: docs/lrs/03_functional_input.md
      status: present
      sha256: 926f28cc81eec46f4861f1f067a425914cd6d47a3a80ca14deb488e03712f393
    - path: docs/lrs/03_functional_irq_1.md
      status: present
      sha256: 0b953a904d5a36588adb88b192580c8c46bed2a6ebd6841cca58fb9b2fe2c638
    - path: docs/lrs/03_functional_irq_2.md
      status: present
      sha256: fe2546d18993e908f0d84c5da89d15eea05328f9d5ea01a9fa53f66b404b68ef
    - path: docs/lrs/03_functional_output_1.md
      status: present
      sha256: 2f18fb7a8cf9854fd4e6674abe3571f05d87df7cf1c8a010c381beb79fec64b4
    - path: docs/lrs/03_functional_output_2.md
      status: present
      sha256: e539a0370f101a8e39defbb2098f3b6b8f8b5de7a77ed873afbfca63a9a7e219
    - path: docs/lrs/03_functional_priorities.md
      status: present
      sha256: 435371bf1c90c91e1923d173893dfb034c3c8f7a94cbbf21a8e28b4396cf54ac
    - path: docs/lrs/04_register_access_1.md
      status: present
      sha256: a51a05c7f453206462199b0340dd5f271c71c1fdacc278965e771a54aef4691c
    - path: docs/lrs/04_register_access_2.md
      status: present
      sha256: 61f27f5be3cb71f6b8d9c325bb83a80fb552b71a5fb711696e717acec4c9287e
    - path: docs/lrs/04_register_capabilities.md
      status: present
      sha256: 77fd78147f356637c331602134deb7f66dec3c617ba4e20ceb0b02c3b76d86dc
    - path: docs/lrs/05_performance.md
      status: present
      sha256: 8eb3ecb1099b0075e788d4c2bca5a756e3a6ebb134680037d505a9f32473d104
    - path: docs/lrs/06_clock_reset.md
      status: present
      sha256: 7cdd0e9b004e0757eb8980c024c09548febdd02432837015af7e437caaff6d4a
    - path: docs/lrs/07_low_power_1.md
      status: present
      sha256: 6ab923ef3173c14422ed0890b2669d476536e5dec9c63ca1e7f9538fa39e41f5
    - path: docs/lrs/07_low_power_2.md
      status: present
      sha256: 5761d9b9c3fdcd2099b27267696818819f15cb3e317dbf150f091651f11715f2
    - path: docs/lrs/07_low_power_aon_1.md
      status: present
      sha256: 5e0a69262a912a91265ad3b22b579211930aeb5d3e71bc82b009514beb3d507d
    - path: docs/lrs/07_low_power_aon_2.md
      status: present
      sha256: 1d7ffaaa98ed589044adc2f2f89797832f82f95a086b520e2c6d17f98804003f
    - path: docs/lrs/07_low_power_aon_3.md
      status: present
      sha256: 08b0865993180a7f49d3702a10da8670598a1ae325a8fd161e027dc1cf49b74e
    - path: docs/lrs/08_functional_safety_1.md
      status: present
      sha256: ca767f00729aadc05da3a44227cdbb84063ee221ebc550e7b5d0936e8f0b8e0b
    - path: docs/lrs/08_functional_safety_2.md
      status: present
      sha256: 150d393258142a44df8774ff4d8356974dd010ac91d0010303db7bf61957f04a
    - path: docs/lrs/09_security_1.md
      status: present
      sha256: f031ce2aa050cdb7fa8b1021e50180951af8da943efcb09fc0faf866d16a4ddc
    - path: docs/lrs/09_security_2.md
      status: present
      sha256: 529388ddb9d24a062b2f74d8a6ccd745f949bd334603d9b5813f59a58dcf60ec
    - path: docs/lrs/10_dfx.md
      status: present
      sha256: acb4c299b272f444b0ac5e288d4ff5091eee5589fc6ec8722a924ee5bbd49309
    - path: docs/lrs/11_generator.md
      status: present
      sha256: 94365a3d289e397c6fe043e1e6241298f5daa175afc8f0fc9abb94fa8e525b37
    - path: docs/lrs/12_constraints_delivery.md
      status: present
      sha256: 2f8029385164dd7bdb10fdf1bd5146a34c53e2e4c6f71e1710a734a5b51df748
    - path: docs/lrs/12_constraints_integration.md
      status: present
      sha256: 37f5dc981f8dd2f7b84f861b1d13c0ddd556f800efdd4e927b98ab806277b49d
    - path: docs/lrs/12_constraints_verification.md
      status: present
      sha256: e8fe71dd38c002b66ea0baea2dd760e9094ec984d7db36959a309cafcee64edf
    - path: docs/lrs/99_quality_gate.md
      status: present
      sha256: 3eee5dec476f289a54bd541034fae2430df4ee88dc825b6730ae274abdfb8990
    - path: docs/lrs/index.md
      status: present
      sha256: a16bd46b842a01afc6c8caa3fcbe1a091495b880b544a8ff5569ed2a1ed9a7c3
  - id: g0.requirements_model
    status: pass
    detail: 258 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=parameterized;
      ppa_signoff=required; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
  - id: g0.design_freshness
    status: pass
    detail: 'lrs: current projection and input-bound technical review verified'
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
  findings: []
- id: G1
  status: pass
  required_checks:
  - g1.architecture_trace
  - g1.design_freshness
  checks:
  - id: g1.architecture_trace
    status: pass
    detail: modules=12; uncovered must requirements=0; invalid requirement refs=0;
      invalid modules=0
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: 1d30ad2c87caed88fe88f96de3512b4a3a405f3101cce27c948c1a84c5821011
    - path: model/external_interface.yaml
      status: present
      sha256: 2cdbb78ec40e57fbd649645227dc9277ca82b321bd56821b93d3c83d43a641cc
    - path: model/internal_interface.yaml
      status: present
      sha256: 6a39f880700203fd440932095122138fe57c30dbb0106a46619c9398f370260e
    - path: model/clock_domains.yaml
      status: present
      sha256: 763dd0df82216fe3475a3b340610e90ab8c5ba5ae9411fb8d078426c40ca6dda
    - path: model/cdc_paths.yaml
      status: present
      sha256: b3a915c4c09a21e66dd2d63ef41dc6d40e66dcc52717dd1f8487f81de935eb40
  - id: g1.design_freshness
    status: pass
    detail: 'hld: current projection and input-bound technical review verified'
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: 1d30ad2c87caed88fe88f96de3512b4a3a405f3101cce27c948c1a84c5821011
    - path: model/external_interface.yaml
      status: present
      sha256: 2cdbb78ec40e57fbd649645227dc9277ca82b321bd56821b93d3c83d43a641cc
    - path: model/internal_interface.yaml
      status: present
      sha256: 6a39f880700203fd440932095122138fe57c30dbb0106a46619c9398f370260e
    - path: model/clock_domains.yaml
      status: present
      sha256: 763dd0df82216fe3475a3b340610e90ab8c5ba5ae9411fb8d078426c40ca6dda
    - path: model/cdc_paths.yaml
      status: present
      sha256: b3a915c4c09a21e66dd2d63ef41dc6d40e66dcc52717dd1f8487f81de935eb40
  findings: []
- id: G2
  status: pass
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: pass
    detail: modules=12; missing HLD coverage=0; unknown HLD refs=0; invalid modules=0;
      invalid child refs=0; invalid datapaths=0; invalid FSMs=0; modules without design
      objects=0; register_model=required; invalid register behaviors=0; RDL files=1;
      register report=validated REPORT_META; CSR evidence=CSR source and native SystemVerilog
      hashes match the manifest
    evidence:
    - path: model/micro_design.yaml
      status: present
      sha256: 5f13e20cbad30ce75e9e32ffe7648c8529b3b54045192655a33bef0e1e29831e
    - path: model/requirements.yaml
      status: present
      sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
    - path: reports/quality/register_check.md
      status: present
      sha256: 846b1e1de907156a19c4995e70288d071a9c5f100aa51b4aa720de4c88ba77e1
    - path: regs/gpio.rdl
      status: present
      sha256: 46bd1bab2da0f44f9bdff6c5bba6f4c7f7a93a9d09d7f6e6849cc3ea40571984
    - path: rtl/generated/gpio_csr.sv
      status: present
      sha256: 7fbf9fde2865aaa4810108bb5612c656e29995651b94c1bb494e3309799b3bab
    - path: rtl/generated/gpio_csr_adapter.sv
      status: present
      sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
    - path: rtl/generated/gpio_csr_pkg.sv
      status: present
      sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
    - path: rtl/generated/gpio_csr.manifest.yaml
      status: present
      sha256: 9139333d4a667d48c213aa74ce2377def134413097b95fdafa691b826b685ecc
  findings: []
- id: G3
  status: fail
  required_checks:
  - g3.rtl_and_core
  - g3.rtl_check_report
  - g3.module_ut
  - g3.csr_consistency
  - g3.special_signoff
  checks:
  - id: g3.rtl_and_core
    status: pass
    detail: rtl=17; root cores=1; expected=aixsilicon_ip_gpio.core; actual=aixsilicon_ip_gpio.core
    evidence:
    - path: rtl/generated/gpio_csr.sv
      status: present
      sha256: 7fbf9fde2865aaa4810108bb5612c656e29995651b94c1bb494e3309799b3bab
    - path: rtl/generated/gpio_csr_adapter.sv
      status: present
      sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
    - path: rtl/generated/gpio_csr_pkg.sv
      status: present
      sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
    - path: rtl/generated/gpio_reg_desc_pkg.sv
      status: present
      sha256: f709bb8faecdf59f6206e77564f5e51c6599770c62b0c69797b39e65a304f507
    - path: rtl/gpio.sv
      status: present
      sha256: 8995b0b9ab0850be86797585e841839fea4baad07dde2a91da08736019ded346
    - path: rtl/gpio_aon_mailbox.sv
      status: present
      sha256: cca9516e4ecf017b548c059407036feb71dc9ebfa46b655d440cd4bc02fd50b9
    - path: rtl/gpio_aon_wake.sv
      status: present
      sha256: f55c78309a898b23c4e9530a49c010d44c188128150808df8d88d5bbe145dbad
    - path: rtl/gpio_apb_if.sv
      status: present
      sha256: eed67322dfdd2143237c4f93ea8af350f036a87c9ee52cddd689da84869616be
    - path: rtl/gpio_capture.sv
      status: present
      sha256: 71e3b2a6ffb272f05c99390addead35f5709d8292596ee84bb2010e4bc5e8af5
    - path: rtl/gpio_diag.sv
      status: present
      sha256: 03c792f38def1bffc2fd1726b0e88ec2b36aa151a1377a0f660df2aae5641061
    - path: rtl/gpio_event_fifo.sv
      status: present
      sha256: 791832b98dc7e7675bae96a53c01fa114562660fe536ec315f4e40f554b9cd7c
    - path: rtl/gpio_input.sv
      status: present
      sha256: 16ba407e14681dbb68154f9a290e7e351ac07afb395325a918d8d4dbc3e99d6b
    - path: rtl/gpio_irq.sv
      status: present
      sha256: 01d96f140262d58b530348830274a0789d1cbe9016977d48f403609f611f2556
    - path: rtl/gpio_output.sv
      status: present
      sha256: 6010ecb13e88eb779dc16a84e60b9ef9e48cf8b8763d38fb3746e52772a727f5
    - path: rtl/gpio_pkg.sv
      status: present
      sha256: 48f5ffdc5cf46b697dd625c23c45697f46d68c92e1aee6438347428e31026894
    - path: rtl/gpio_regfile.sv
      status: present
      sha256: 24e665d030fb606492fa95e06cdf40219974ea72ac39e1baaceb228559306cb4
    - path: rtl/gpio_security.sv
      status: present
      sha256: 26b65cbfdb2ad13bb7acaf133e3005c27688c86ba819e4bc6bd47cf494f0e079
    - path: aixsilicon_ip_gpio.core
      status: present
      sha256: 36d5048d5738b8539c5d41c1c849a8c9c64aebc1aaabda39ea06eb61003c590f
    - path: ip-package.yaml
      status: present
      sha256: 03376fc562afd1839961be7ba6d6e4bdf60a4bc62585fe6895b223a0ea3c0a9f
  - id: g3.rtl_check_report
    status: pass
    detail: validated REPORT_META
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: present
      sha256: c1510739015af00c548f778757614271ee2e0392dc16d5bce8236feafd373cda
  - id: g3.module_ut
    status: pass
    detail: module UT sources=13; module UT executions=13; compile/run evidence complete
    evidence:
    - path: verification/unit_test/ut_gpio.sv
      status: present
      sha256: 3c606a8dd8f35780d6279413856e78eddae041bbde8d83b4881d633b21277260
    - path: verification/unit_test/ut_gpio_aon_mailbox.sv
      status: present
      sha256: 3cbd623a25a55c3a73502be3bf3783dde5dfd408cd70a4de36a6adaa403b8532
    - path: verification/unit_test/ut_gpio_aon_wake.sv
      status: present
      sha256: 4e8a2dae4051c6758f30ce13cf8ca2508cfd75df9078657ecae1c0611842c23e
    - path: verification/unit_test/ut_gpio_apb_if.sv
      status: present
      sha256: b1c9187943d67446559bd41b8d34feddd78d8654cc734e5e4b30e217a7572836
    - path: verification/unit_test/ut_gpio_capture.sv
      status: present
      sha256: 89ce60a9f22bad65d4ff2f2af77ceb19b036f34d764a21f53261415ee069cbcc
    - path: verification/unit_test/ut_gpio_diag.sv
      status: present
      sha256: 5a0d487d1a075770f00962698d5a1933ebb0b6e791dd2b993220c43db8f7794e
    - path: verification/unit_test/ut_gpio_event_fifo.sv
      status: present
      sha256: 6acf8a800a88a6c3dd27852ffa8f5341027b9dc27f9a3426a511086548454f59
    - path: verification/unit_test/ut_gpio_input.sv
      status: present
      sha256: e546254adf2f38c2a773b73f70df98881894eb7e6313a04107922184a06ce6b0
    - path: verification/unit_test/ut_gpio_irq.sv
      status: present
      sha256: de6822208e678caee8fe2196267dc67679fdd97f0f35cf0368cfdde8c384dde1
    - path: verification/unit_test/ut_gpio_output.sv
      status: present
      sha256: 82a169acb69717f59b6d2c15af8f04ac5ba0872168ee84ba229225d4c773430c
    - path: verification/unit_test/ut_gpio_read_path.sv
      status: present
      sha256: bb089c87b3b7f116830eb760f4c35d25f830b656f2a6a52029380bd7037fd2d6
    - path: verification/unit_test/ut_gpio_regfile.sv
      status: present
      sha256: d9d15b37f3b08d6a324effb671b3912dfa7af9b229bcf4fc5db3bed29a72a728
    - path: verification/unit_test/ut_gpio_security.sv
      status: present
      sha256: 141bd8e42356a78923bbd2cdf47ccc991433b5e9a14da7943297b3f75487bdb7
    - path: reports/quality/module_ut_summary.md
      status: present
      sha256: ad5de9e2f9afda22e5565eb0ace02e4560c6d331b6ab42dbfab8aff4c45caae4
  - id: g3.csr_consistency
    status: pass
    detail: CSR source and native SystemVerilog hashes match the manifest
    evidence:
    - path: regs/gpio.rdl
      status: present
      sha256: 46bd1bab2da0f44f9bdff6c5bba6f4c7f7a93a9d09d7f6e6849cc3ea40571984
    - path: rtl/generated/gpio_csr.sv
      status: present
      sha256: 7fbf9fde2865aaa4810108bb5612c656e29995651b94c1bb494e3309799b3bab
    - path: rtl/generated/gpio_csr_adapter.sv
      status: present
      sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
    - path: rtl/generated/gpio_csr_pkg.sv
      status: present
      sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
    - path: rtl/generated/gpio_csr.manifest.yaml
      status: present
      sha256: 9139333d4a667d48c213aa74ce2377def134413097b95fdafa691b826b685ecc
  - id: g3.special_signoff
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/signoff/cdc.yaml'''
    evidence: []
  findings:
  - GPIO.CDC.LICENSE
  - GPIO.RDC.LICENSE
- id: G4
  status: blocked
  required_checks:
  - g4.verification_assets
  - g4.smoke_evidence
  - g4.full_regression_evidence
  - g4.coverage_closure
  - g4.rtm_closure
  - g.param_space
  - g4.parameter_execution
  - g4.special_signoff
  - g4.ral_handoff
  checks:
  - id: g4.verification_assets
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/verification/sim/regression_list.yaml'';
      distinct testcase implementations=0; valid lifecycle traces=4/4; testplans=25;
      UVM testcases=0'
    evidence:
    - path: model/verification.yaml
      status: present
      sha256: ca81f72500b907d9027e1cdd4d0f92ea80f85210624ac0ec236df3d7912690b0
    - path: trace/req_to_hld.yaml
      status: present
      sha256: a4908902d9a48048aceaba6274b7f57516e6ad5b081506fd2ade341b0c112baa
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: c76771be9a62a4d1af585051d6305d6b09af8c6f10bf03399d2ea47832581ecc
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: 875e1d30a363bae516825dc21b6b5a50f998a24ce449186e46dbc015ae04ecff
    - path: trace/req_to_test.yaml
      status: present
      sha256: 05d11c861c8759bddc32de3769b1ebb43b0fe39a93920cad57a5154b31a866e7
    - path: verification/sim/regression_list.yaml
      status: missing
    - path: docs/verification/99_quality_gate.md
      status: present
      sha256: 22f3a84dbaca5c3769d428c2c810851450b0f3a4d515f97db3fcd46d8b4d3cf7
    - path: docs/verification/agent_plan.md
      status: present
      sha256: 33f2b46b6533ccc52064a41c8e516aad7a29000ea6b3f96215606bade1ac7271
    - path: docs/verification/checker_plan.md
      status: present
      sha256: b87580c391b8fa4fe6e53f083fed581234ec83ff4f9774f7aee0aac8d8f4c1c6
    - path: docs/verification/coverage_plan.md
      status: present
      sha256: ec40e8ab0550c49d283a057658550e01d4293df0a89bee4b723c1bcd445e8c72
    - path: docs/verification/coverage_plan_1.md
      status: present
      sha256: 3514e380fa43532593a11c139005ca9fae16ca40e42fbacda1c945bfefe408a8
    - path: docs/verification/coverage_plan_2.md
      status: present
      sha256: 7acf0fd2eff24f8b5e4f36c1afc73243a179615112d0242cd2fe99ec68741e9d
    - path: docs/verification/feature_list.md
      status: present
      sha256: a02035b4a3e0f4392689adffe1878ba8dc04500605c9d0cd165d7fad6c6a714a
    - path: docs/verification/index.md
      status: present
      sha256: 9171dabaab1426ed0469710ed4e4ed0dc80c8c212222f7f6ee9fb2e1ab1aeb11
    - path: docs/verification/test_matrix.md
      status: present
      sha256: 65d148612f37074606d325405925671b1d3864f19ff19db7a8c9c30d52210a42
    - path: docs/verification/test_matrix_aon.md
      status: present
      sha256: 5b5a1c2c397e23ba08800cef360ca803534710f6832aab4bdf66e29c0ff0fee4
    - path: docs/verification/test_matrix_apb.md
      status: present
      sha256: ddc25e05a9e1f23d34fb47119ae22636f71f41c9d4cc7421e168516069e2d938
    - path: docs/verification/test_matrix_capture.md
      status: present
      sha256: 852c59e5beb1f29e4c0aed9b44d6dae26b4974b22683bd02fd56f82eccfaa683
    - path: docs/verification/test_matrix_config.md
      status: present
      sha256: 68bfefb64cc02bb0dfb8c7f2227ac8b58e8fcf5e1f871c50d9520d1ed4d167ba
    - path: docs/verification/test_matrix_delivery.md
      status: present
      sha256: c8da34b66ae3b3949f9f2197f5907853a3b4712c2d300a19e9e159e15aaa676f
    - path: docs/verification/test_matrix_diag.md
      status: present
      sha256: 89956711d99b6daadbc9f487c8e846d0c63c80663bff60edf2995f97ffd2e392
    - path: docs/verification/test_matrix_fifo.md
      status: present
      sha256: a9002e3dc05341946c07926ae17608fccbe7ce15d507801f9a1c0695ffba9fad
    - path: docs/verification/test_matrix_filter.md
      status: present
      sha256: aba8690ff9d4242e86e88c3a5457ee988864b263530535945d5ba11e2ffae35b
    - path: docs/verification/test_matrix_input.md
      status: present
      sha256: 9e0996d103ac2494d9de82c5a9fc6d93734c9753d139bf6c73b0098dfdcef3d4
    - path: docs/verification/test_matrix_irq.md
      status: present
      sha256: 0c3ca24ef8b3772c234cc799f7864b16faa5928fc8f75815fc1fea78443f2c17
    - path: docs/verification/test_matrix_lowpower.md
      status: present
      sha256: 775689097f39e7b5e19d7de149557fc53f72786581ac26bb36c4c0abaa43c628
    - path: docs/verification/test_matrix_output.md
      status: present
      sha256: 79ee7be018638beeaada9b0fa06c06501257850eb7cda95ebe4af52910e38214
    - path: docs/verification/test_matrix_parity.md
      status: present
      sha256: e7d3de744643e2eb83343bda3fd72a39ce16d7a11c0686abb37da46419fd7bdc
    - path: docs/verification/test_matrix_reset.md
      status: present
      sha256: 6d60af38d03c304b9201c812f0ed595ae554b2fc1dad461fe3b0bf29f33e0943
    - path: docs/verification/test_matrix_security.md
      status: present
      sha256: 0eb32178ef99e02ad101ce7819ec824539fdfb5aeb09182f08bb8bfdc3c0d756
    - path: docs/verification/verification_plan.md
      status: present
      sha256: 327f8d71b63e39268235c60fc4fd1898283c82c5523646aa6028a17a0bd8c644
  - id: g4.smoke_evidence
    status: fail
    detail: 'smoke: missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/smoke/smoke_junit.xml;
      invalid smoke_executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/smoke/smoke_junit.xml
      status: missing
  - id: g4.full_regression_evidence
    status: fail
    detail: 'regression: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/regression/regression_summary.md;
      missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/regression/junit.xml;
      invalid executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/regression/junit.xml
      status: missing
  - id: g4.coverage_closure
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/coverage/coverage_summary.md'
    evidence:
    - path: reports/coverage/coverage_summary.md
      status: missing
  - id: g4.rtm_closure
    status: fail
    detail: REPORT_META dependencies must be a list; valid lifecycle traces=4/4
    evidence:
    - path: reports/quality/trace_matrix.md
      status: present
      sha256: b2815a2a0223b6902bdeacb520c1911cd83ab233e704ddf09ef890bb252e77a2
    - path: trace/req_to_hld.yaml
      status: present
      sha256: a4908902d9a48048aceaba6274b7f57516e6ad5b081506fd2ade341b0c112baa
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: c76771be9a62a4d1af585051d6305d6b09af8c6f10bf03399d2ea47832581ecc
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: 875e1d30a363bae516825dc21b6b5a50f998a24ce449186e46dbc015ae04ecff
    - path: trace/req_to_test.yaml
      status: present
      sha256: 05d11c861c8759bddc32de3769b1ebb43b0fe39a93920cad57a5154b31a866e7
  - id: g.param_space
    status: pass
    detail: parameters=20; configs=269; missing evidence=0
    evidence:
    - path: reports/quality/param_check.md
      status: present
      sha256: 7c0f078e42fdb2a6497023adeaa9498c62e07e19e72054399c031b4e591b73cc
    - path: reports/quality/param_matrix.md
      status: present
      sha256: f684cf6f06617d1303888c3699e00b4e88e5bb600b14aa067b36c417b5fc830f
  - id: g4.parameter_execution
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/param_execution.md'
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
    - path: reports/quality/param_execution.md
      status: missing
  - id: g4.special_signoff
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/signoff/formal.yaml'''
    evidence: []
  - id: g4.ral_handoff
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/ral_handoff.yaml'''
    evidence:
    - path: reports/quality/ral_handoff.yaml
      status: missing
  findings: []
- id: G5
  status: blocked
  required_checks:
  - g5.release_inputs
  - g5.ppa_signoff
  checks:
  - id: g5.release_inputs
    status: fail
    detail: release inputs valid=1/3; missing integration Markdown; missing user_manual
      Markdown
    evidence:
    - path: docs/integration
      status: present
    - path: docs/user_manual
      status: present
    - path: reports/quality/review_findings.yaml
      status: present
      sha256: cd443b874250af23a70117d5968592d02aadff0f30883c75de78420d528cac22
  - id: g5.ppa_signoff
    status: fail
    detail: policy=required; required PPA evidence is missing
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
    - path: model/pdk.yaml
      status: present
      sha256: d1456b0eeb98f2d31258ef240b87b024d255502c3606484dc3ad6b8a1dd6f7a6
    - path: reports/ppa-report.md
      status: missing
    - path: reports/ppa/sweep_analysis.yaml
      status: missing
  findings: []
END_QUALITY_META -->
