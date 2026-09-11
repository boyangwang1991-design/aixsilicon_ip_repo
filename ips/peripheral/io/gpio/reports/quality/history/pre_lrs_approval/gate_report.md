# Quality Gate Report - gpio

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | fail | g1.architecture_trace |
| G2 | blocked | g2.microdesign_and_register_freeze |
| G3 | blocked | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency |
| G4 | blocked | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space, g4.parameter_execution |
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
  checks:
  - id: g0.required_lrs_docs
    status: pass
    detail: LRS markdown files=40 (single-file docs/lrs/lrs.md or category-split layout,
      must contain LRS_DOC_META)
    evidence:
    - path: docs/lrs/00_document_control.md
      status: present
      sha256: 2f1300718e2d154c6b37888ac24a580e623400aae6d71001ca770c7d38d3c57d
    - path: docs/lrs/01_configuration_parameters_1.md
      status: present
      sha256: 15d38e44e87e6f4494aa686da31a540af26913e0325768cb07a73fa136fb017a
    - path: docs/lrs/01_configuration_parameters_2.md
      status: present
      sha256: c596462930974c00370b3c2b47eb51091c583cd191b52bb1d8bab8608803a91b
    - path: docs/lrs/01_configuration_rules.md
      status: present
      sha256: 39fbe1f8f865a031aaafa43ebc5d1429d09f68da9d65acd6f574c142838560ae
    - path: docs/lrs/01_scope.md
      status: present
      sha256: abf2033a48c503bf72a230646f5b9020c85359dd81bbe06e686253ea21d96267
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
      sha256: ffba959b1ec596eee1a5b4e506efe46b202105cb008904792b37b631f910a870
    - path: docs/lrs/03_functional_capture.md
      status: present
      sha256: 214e65522910e6a8a5e7bba211c6e514c58624e543f63a000a6b020917e32b33
    - path: docs/lrs/03_functional_event_1.md
      status: present
      sha256: ad0b23020a5e69c24e0ed4f0405855c64d88af54fdcbebec5181c1482b7a8804
    - path: docs/lrs/03_functional_event_2.md
      status: present
      sha256: 8ab34e1c7e2c7fe0bcc16c08efbd3a644c9fd5a39c8df2801fa5782813c0312b
    - path: docs/lrs/03_functional_filter.md
      status: present
      sha256: 1fcc09f529e53a36d973b94b32ff6e7ef315ef778ab85e94a1f3c4b6fc870691
    - path: docs/lrs/03_functional_input.md
      status: present
      sha256: 871cb213365d28fac1536dce49764a991dda86c16cfb6e3b8ca984ea2e9cd9b8
    - path: docs/lrs/03_functional_irq_1.md
      status: present
      sha256: ee5e95e200b83e1bca6e9ca3d63bed20b7be684e4ebcd31230f4dae0ee946f12
    - path: docs/lrs/03_functional_irq_2.md
      status: present
      sha256: bf7808d96b8c21f014fca7c9cb66060a8607d39bcabcc568be92e513707d6c25
    - path: docs/lrs/03_functional_output_1.md
      status: present
      sha256: 40de18ecf363efb581cb74fe164eeaf8f9b204779353eef15b5c533790a79589
    - path: docs/lrs/03_functional_output_2.md
      status: present
      sha256: cfcefa694d0cf58ccb0d59adfa4787eeb60c53c88cb3e26a63f9ef925aed5953
    - path: docs/lrs/03_functional_priorities.md
      status: present
      sha256: 435371bf1c90c91e1923d173893dfb034c3c8f7a94cbbf21a8e28b4396cf54ac
    - path: docs/lrs/04_register_access_1.md
      status: present
      sha256: 8793402f0ade5b4c5e2891d4b08b836e64c4bf1898f8607fc130609ea3cc82ed
    - path: docs/lrs/04_register_access_2.md
      status: present
      sha256: cada8ec66a5f98fde06d094d2b241c74f87b7ceb6b2f28a1818ee1820904a0d7
    - path: docs/lrs/04_register_capabilities.md
      status: present
      sha256: 77fd78147f356637c331602134deb7f66dec3c617ba4e20ceb0b02c3b76d86dc
    - path: docs/lrs/05_performance.md
      status: present
      sha256: 7baddf1ba04a010eda436c10d287d88cd0a4afed82b64a8495107019138c01d5
    - path: docs/lrs/06_clock_reset.md
      status: present
      sha256: 7cdd0e9b004e0757eb8980c024c09548febdd02432837015af7e437caaff6d4a
    - path: docs/lrs/07_low_power_1.md
      status: present
      sha256: 6d96a7eff9ab6185579b0e99608d9301e932f89c3fa3c4c4f99a5b13af3f4e25
    - path: docs/lrs/07_low_power_2.md
      status: present
      sha256: 65831b07f796a124f6658b35686f074d854379ddcbc8be81e010a461101163ae
    - path: docs/lrs/07_low_power_aon_1.md
      status: present
      sha256: 0a66a8a34db9029eaa9661784352ba4d31e3392cd0ad019240c7b26174a89b37
    - path: docs/lrs/07_low_power_aon_2.md
      status: present
      sha256: 2533d7d5f34fcd1ada37cf1e5951b8e6756d50aa0cdf56d7ba5f0aef6c05db43
    - path: docs/lrs/07_low_power_aon_3.md
      status: present
      sha256: cbd8d029778d424cf480806694e0e088e09fdb8915e767d313e6696dfc0d4ffb
    - path: docs/lrs/08_functional_safety_1.md
      status: present
      sha256: 07ac6720ae6031fba71d658693056014dbe6c984dfd07869b81f76725b182f23
    - path: docs/lrs/08_functional_safety_2.md
      status: present
      sha256: e908c3a243bf9516897ca971cf809e4f0e2c4b2e5a96944a97f09390bb92693e
    - path: docs/lrs/09_security_1.md
      status: present
      sha256: 3c64b62616c306aafafe1ab7c930d3ff8c89282fb5c1f9fe3e5f503dd671ca0c
    - path: docs/lrs/09_security_2.md
      status: present
      sha256: 801689c365fa125a08aeced9de7a7caec5ea855364c9174ff600b194c70d5226
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
      sha256: 46ef29a4f065d0adf55c02451640a52789c95c5c8aad31bb8e5fd6d364d3cb57
    - path: docs/lrs/99_quality_gate.md
      status: present
      sha256: d75b519fe65ab678f56d7872e2a9346083651db1529c5f956f6375e51b830bdd
    - path: docs/lrs/index.md
      status: present
      sha256: a34fdd1100aed8ef089890c012c2ed7b104f73cad5aafe4c98e47270add2fa2e
  - id: g0.requirements_model
    status: pass
    detail: 258 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=parameterized;
      ppa_signoff=required; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 7de8c8c11b8b88fbe2e7ade5008e430df2a2da5ed5474142fab93ba76abffa3d
  findings: []
- id: G1
  status: fail
  required_checks:
  - g1.architecture_trace
  checks:
  - id: g1.architecture_trace
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/model/architecture.yaml'''
    evidence:
    - path: model/architecture.yaml
      status: missing
    - path: model/external_interface.yaml
      status: missing
    - path: model/internal_interface.yaml
      status: missing
    - path: model/clock_domains.yaml
      status: missing
    - path: model/cdc_paths.yaml
      status: missing
  findings: []
- id: G2
  status: blocked
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/model/micro_design.yaml'''
    evidence:
    - path: model/micro_design.yaml
      status: missing
    - path: model/requirements.yaml
      status: present
      sha256: 7de8c8c11b8b88fbe2e7ade5008e430df2a2da5ed5474142fab93ba76abffa3d
    - path: reports/quality/register_check.md
      status: missing
  findings: []
- id: G3
  status: blocked
  required_checks:
  - g3.rtl_and_core
  - g3.rtl_check_report
  - g3.module_ut
  - g3.csr_consistency
  checks:
  - id: g3.rtl_and_core
    status: fail
    detail: rtl=0; root cores=0
    evidence:
    - path: ip-package.yaml
      status: present
      sha256: ecb74b1b95edc53203809f6312756e87ef680e5f300827ed3a8cd78d37f93d5c
  - id: g3.rtl_check_report
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/rtl_check_summary.md'
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: missing
  - id: g3.module_ut
    status: fail
    detail: 'module UT sources=0; missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/module_ut_summary.md'
    evidence:
    - path: reports/quality/module_ut_summary.md
      status: missing
  - id: g3.csr_consistency
    status: pass
    detail: no SystemRDL source; CSR provenance not required
    evidence: []
  findings: []
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
  checks:
  - id: g4.verification_assets
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/model/verification.yaml'';
      distinct testcase implementations=0; valid lifecycle traces=0/4; testplans=0;
      UVM testcases=0'
    evidence:
    - path: model/verification.yaml
      status: missing
    - path: trace/req_to_hld.yaml
      status: missing
    - path: trace/hld_to_lld.yaml
      status: missing
    - path: trace/lld_to_rtl.yaml
      status: missing
    - path: trace/req_to_test.yaml
      status: missing
    - path: verification/sim/regression_list.yaml
      status: missing
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
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/trace_matrix.md;
      valid lifecycle traces=0/4'
    evidence:
    - path: reports/quality/trace_matrix.md
      status: missing
    - path: trace/req_to_hld.yaml
      status: missing
    - path: trace/hld_to_lld.yaml
      status: missing
    - path: trace/lld_to_rtl.yaml
      status: missing
    - path: trace/req_to_test.yaml
      status: missing
  - id: g.param_space
    status: fail
    detail: missing model/parameter_space.yaml for parameterized IP
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 7de8c8c11b8b88fbe2e7ade5008e430df2a2da5ed5474142fab93ba76abffa3d
  - id: g4.parameter_execution
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/reports/quality/param_execution.md'
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 7de8c8c11b8b88fbe2e7ade5008e430df2a2da5ed5474142fab93ba76abffa3d
    - path: reports/quality/param_execution.md
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
    detail: release inputs present=0/3
    evidence:
    - path: docs/integration
      status: present
    - path: docs/user_manual
      status: present
    - path: reports/quality/review_findings.yaml
      status: missing
  - id: g5.ppa_signoff
    status: fail
    detail: policy=required; required PPA evidence is missing
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 7de8c8c11b8b88fbe2e7ade5008e430df2a2da5ed5474142fab93ba76abffa3d
    - path: model/pdk.yaml
      status: missing
    - path: reports/ppa-report.md
      status: missing
    - path: reports/ppa/sweep_analysis.yaml
      status: missing
  findings: []
END_QUALITY_META -->
