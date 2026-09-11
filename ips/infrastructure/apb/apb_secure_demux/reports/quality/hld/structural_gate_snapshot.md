# Quality Gate Report - apb_secure_demux

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | pass | g1.architecture_trace |
| G2 | fail | g2.microdesign_and_register_freeze |
| G3 | blocked | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency |
| G4 | blocked | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space, g4.parameter_execution |
| G5 | blocked | g5.release_inputs, g5.ppa_signoff |

<!-- QUALITY_META
schema_version: '2.0'
ip_name: apb_secure_demux
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
    detail: LRS markdown files=36 (single-file docs/lrs/lrs.md or category-split layout,
      must contain LRS_DOC_META)
    evidence:
    - path: docs/lrs/00_overview.md
      status: present
      sha256: 0422c3f34bb471bea42befed536ada520ffd3dd59e2101717b38328b636eeb42
    - path: docs/lrs/01_configuration_cases.md
      status: present
      sha256: 232eab64a54bd242d91c3d00b173c7f60988e9873c40ba56c29d8c87eaf4d23b
    - path: docs/lrs/01_configuration_meta_01.md
      status: present
      sha256: 74d86a7f0c28f55c3b1a8d489536cc04dad62534abb3833cb583b0893c7a9bbc
    - path: docs/lrs/01_configuration_meta_02.md
      status: present
      sha256: 4faa7cb0fcfbd07f1b10a4cbf96d29779139c7a8c00812b9cc41cd27c126744b
    - path: docs/lrs/01_configuration_meta_03.md
      status: present
      sha256: e020affaaea57bd6df3049b87949010f47e2222b7527f024c0a4cd4656023688
    - path: docs/lrs/01_configuration_negative.md
      status: present
      sha256: c89596f2a7be896d65e5d2dd68190dca90f71f0cf4ca4826e00f39c22f603f93
    - path: docs/lrs/01_configuration_rules_01.md
      status: present
      sha256: 79293b49477869ef546a521ca0c8257a6348be28c4a827c0f02af20da5b66cdc
    - path: docs/lrs/01_configuration_values.md
      status: present
      sha256: ae2e25443a58b806b43bde26c8617d06d8c2ec3ce1173586d6b2967bbfe9eb90
    - path: docs/lrs/02_interface_protocol_01.md
      status: present
      sha256: 0b053307353afa00a501821c6571c07783836af8c16a351b62db361ae9e1cea1
    - path: docs/lrs/02_interface_signals.md
      status: present
      sha256: 4d632328ae41fcd86c258cf4dd108c2952edb3aeee1d74135441de11f78e462f
    - path: docs/lrs/02_interface_transfer_01.md
      status: present
      sha256: f48e516424e4f5ee85615e1ac234537fee3f3e434a9ec5654475260b1d7015f1
    - path: docs/lrs/02_interface_transfer_02.md
      status: present
      sha256: 502bf4d976c0d742031817c611eae14e7ccc2afd86fb9adbbf29181d9acaac79
    - path: docs/lrs/03_functional_decode_01.md
      status: present
      sha256: 69d7005e4fd8f48abb1b0697b7404c3103d80651fda47c769b32ed7d52751680
    - path: docs/lrs/03_functional_interrupt_01.md
      status: present
      sha256: 1c1e6f4ccf843193f068c378846dbecb751e4ae23c20136cd1817ff6a5bea249
    - path: docs/lrs/03_functional_logging_01.md
      status: present
      sha256: b148191c1b55f07ecdc115a9cbe256384dd396a1ba7c967fce24d31625733f1b
    - path: docs/lrs/03_functional_logging_02.md
      status: present
      sha256: be460ea4b8817918b9dd597c7165a79c847965d73408ff286f4b115728ddf86a
    - path: docs/lrs/04_register_access_01.md
      status: present
      sha256: 3a38689f75c1cf78f063b38f9440886317d07b6c64d8568445f2d861463d9210
    - path: docs/lrs/04_register_access_02.md
      status: present
      sha256: 0ce1e418af8b728f6c3c54f56be5b466a9c0b98770e163ad2c1c45aa16d7f554
    - path: docs/lrs/04_register_update_01.md
      status: present
      sha256: ece77ece22b74a591b534bd9cc2933e6e4210aee4997340dad857e5f8659a334
    - path: docs/lrs/04_register_update_02.md
      status: present
      sha256: 3e6a81159e840505b115273726da961bcc8c89e555ef0fef0ac4ca097bc60bf9
    - path: docs/lrs/05_performance_timing_01.md
      status: present
      sha256: da578f2e1538d1d4165c7d7319d84eeed46fd164f46ea37b2ad6a64fdd4ca9d5
    - path: docs/lrs/06_clock_reset_01.md
      status: present
      sha256: c06f124575d0e79e3a32348a97f5b62939e53d237f2cc8654048bc91456788e8
    - path: docs/lrs/08_safety_integrity_01.md
      status: present
      sha256: 95ea9f8ce23ae63aebb21d3b53cf532383dd22469cd55a5339c28a04672d0dcc
    - path: docs/lrs/08_safety_integrity_02.md
      status: present
      sha256: 836e5b70d3d19284e27b4434c51f086d26c7b0839daa047d47773eb04c74d375
    - path: docs/lrs/09_security_permissions_01.md
      status: present
      sha256: 0960b1b87c378d01562e4c33e4012c35f0919e9531998950b548ba48cbb08547
    - path: docs/lrs/09_security_permissions_02.md
      status: present
      sha256: 9dad1aae88c2dc7aa1ca658fb3148475b9a67262a55cd42b4424ae9a7474a20a
    - path: docs/lrs/10_dfx_01.md
      status: present
      sha256: 7a462506e09f95597a3e9f727ceb9b1c4a6a7a8863e91a0b873de11a78581756
    - path: docs/lrs/10_dfx_02.md
      status: present
      sha256: 4badf7d5ff874741f8e49c8d88dae50ac07618f2e0424fac8149fdb8ed90bb47
    - path: docs/lrs/10_dfx_03.md
      status: present
      sha256: 34e45654bb4a9d54a5c9e2c00d32c955a91c7d3295bb288c8d14706fd81a3a5d
    - path: docs/lrs/12_constraints_system_01.md
      status: present
      sha256: 0337e2fb117b79f9fc8774c2d4215fd51723c4054350d26ffbffc6ecd00c6b36
    - path: docs/lrs/13_contract_clauses_01.md
      status: present
      sha256: ebb7c922aa491a5c2437691a83d7741a20a6fd4871716fe6b8bb3f74c99c5105
    - path: docs/lrs/13_contract_clauses_02.md
      status: present
      sha256: 4825c658e7d23c4aa5430fa0478c53b85bb93e3e07e918248851c936895db0aa
    - path: docs/lrs/13_contract_clauses_03.md
      status: present
      sha256: 4b6f7cb941f0bcb00a8fb0285bdfc1f02b9fa3f0c8522f4b1d528f61cc920492
    - path: docs/lrs/90_applicability_na.md
      status: present
      sha256: 140de566bfc3726101e20f1169efaafdfa4dcb128b0df11780fc860c2dd81ace
    - path: docs/lrs/99_quality_gate.md
      status: present
      sha256: 40137f132f54b4e1a7c5cce65e4ec5dc2dfe9feaaaa3957386531860de8b655c
    - path: docs/lrs/index.md
      status: present
      sha256: 3634fbc86b44fca990899f8e7ef5c4a6b64cd610a1025dfacc8cf15d01aa500c
  - id: g0.requirements_model
    status: pass
    detail: 169 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=parameterized;
      ppa_signoff=required; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 694f86536fc45126bcc0ea82bf642fbaac6def375fa41009c14d9918f5f75c16
  findings: []
- id: G1
  status: pass
  required_checks:
  - g1.architecture_trace
  checks:
  - id: g1.architecture_trace
    status: pass
    detail: modules=9; uncovered must requirements=0; invalid requirement refs=0;
      invalid modules=0
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: 9fa44754d10cfb53a5d05a14ca0bb5275c6c7834f883e1eac41c3cf67fb45b63
    - path: model/external_interface.yaml
      status: present
      sha256: 0445cab6b9866f52b7cccdaa92f49e849b497f8959b2ee9d25a0789b23ffa628
    - path: model/internal_interface.yaml
      status: present
      sha256: c769a7457b24f62cca05fe798b1d1fc05c0ace395d2a9be4df05a66a9f2bdb70
    - path: model/clock_domains.yaml
      status: present
      sha256: aea5456531bc51287dd98cabf6eb23881d6180eb257e9594367bf219700cce51
    - path: model/cdc_paths.yaml
      status: present
      sha256: 2f929d4fae15b15ddd91b50a6b4c4155674931bbb3d152c930b983e2acabfd6e
  findings: []
- id: G2
  status: fail
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: fail
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/model/micro_design.yaml'''
    evidence:
    - path: model/micro_design.yaml
      status: missing
    - path: model/requirements.yaml
      status: present
      sha256: 694f86536fc45126bcc0ea82bf642fbaac6def375fa41009c14d9918f5f75c16
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
      sha256: f32f955020a8f1eed5464f46f14095ef6006876422bcbfb078bb960b3607f3e4
  - id: g3.rtl_check_report
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/quality/rtl_check_summary.md'
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: missing
  - id: g3.module_ut
    status: fail
    detail: 'module UT sources=0; missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/quality/module_ut_summary.md'
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
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/model/verification.yaml'';
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
    detail: 'smoke: missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/smoke/smoke_junit.xml;
      invalid smoke_executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/smoke/smoke_junit.xml
      status: missing
  - id: g4.full_regression_evidence
    status: fail
    detail: 'regression: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/regression/regression_summary.md;
      missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/regression/junit.xml;
      invalid executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/regression/junit.xml
      status: missing
  - id: g4.coverage_closure
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/coverage/coverage_summary.md'
    evidence:
    - path: reports/coverage/coverage_summary.md
      status: missing
  - id: g4.rtm_closure
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/quality/trace_matrix.md;
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
    status: pass
    detail: parameters=17; configs=74; missing evidence=0
    evidence:
    - path: reports/quality/param_check.md
      status: present
      sha256: cd2c3ff256e1885853ab3386074be909e6a89a3ece08c59a9217d431bc740329
    - path: reports/quality/param_matrix.md
      status: present
      sha256: 2781b066aa7c8fba158b59b981c91c55be3dc0bc609511368d1b0e5231076bd9
  - id: g4.parameter_execution
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/reports/quality/param_execution.md'
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 694f86536fc45126bcc0ea82bf642fbaac6def375fa41009c14d9918f5f75c16
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
      sha256: 694f86536fc45126bcc0ea82bf642fbaac6def375fa41009c14d9918f5f75c16
    - path: model/pdk.yaml
      status: missing
    - path: reports/ppa-report.md
      status: missing
    - path: reports/ppa/sweep_analysis.yaml
      status: missing
  findings: []
END_QUALITY_META -->
