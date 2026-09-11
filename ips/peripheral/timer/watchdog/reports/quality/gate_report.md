# Quality Gate Report - watchdog

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | pass | g1.architecture_trace |
| G2 | pass | g2.microdesign_and_register_freeze |
| G3 | fail | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency |
| G4 | blocked | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space, g4.parameter_execution |
| G5 | blocked | g5.release_inputs, g5.ppa_signoff |

<!-- QUALITY_META
schema_version: '2.0'
ip_name: watchdog
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
    - path: docs/lrs/00_overview.md
      status: present
      sha256: fc85a6c20b6ebeddbf2207fe65b7304b4a13852717eb6a893d3f7437e247c3ef
    - path: docs/lrs/01_configuration_cases_1.md
      status: present
      sha256: fa944a68ca4c1626b22c4a473d867af918fb2881f7b2fa750c7597bf8599a1fd
    - path: docs/lrs/01_configuration_cases_2.md
      status: present
      sha256: 7ecf33fbd1ba45593fbef874f8e2f9f5551b8ded37f87f86f2aac104a205d5cc
    - path: docs/lrs/01_configuration_cases_3.md
      status: present
      sha256: 1465f55e81c9701b661e965cf47e83ea0b63321202fa7ebf7f360f146b61421b
    - path: docs/lrs/01_configuration_default_cfg.md
      status: present
      sha256: d3d0c7d082d936ed8e9cdfd0730bda8b08866d2674f02f15a5a5e6a36931330e
    - path: docs/lrs/01_configuration_masks.md
      status: present
      sha256: f0928d6970b1ab9e2344bf823801a5361e10c70b6f1add45e5fcfee532c875bb
    - path: docs/lrs/01_configuration_parameters_1.md
      status: present
      sha256: c3a207e009b459b676f8d6234308cf2cf47ff66ae4742b3073ec3ba662d71058
    - path: docs/lrs/01_configuration_parameters_2.md
      status: present
      sha256: 5ee42f0c3215dbf8696a4b56597a5d238abc9bc6052d0a402af862c89bd43754
    - path: docs/lrs/01_configuration_profiles.md
      status: present
      sha256: 2a001f8725ab0f41a29eeb5c735a5652dec58c1addd0b830dd38753fbf45f15f
    - path: docs/lrs/01_configuration_rules.md
      status: present
      sha256: 2c50db248806409d7995e1f12019b2a520b1c0e84f462e65e2f2af18e0d022e0
    - path: docs/lrs/02_interface_apb.md
      status: present
      sha256: 32fe0fb8b8aa0f9a9e194e8a45d39b5f1d735da2c7ed997a6596945f74590a69
    - path: docs/lrs/02_interface_contract.md
      status: present
      sha256: d822e188d448256bf36fcd5fb84eace1af8bab4e488d252b559ffe96643e1b39
    - path: docs/lrs/02_interface_rules.md
      status: present
      sha256: 568cbc00a0c91aa846fb4cfda961bb07dc663bdcbeb20fba86087e82ede01bc7
    - path: docs/lrs/02_interface_transactions.md
      status: present
      sha256: 37cdb34d3ffa8c85fc06c916dfe3fab6f47dc51e5513c3337d9c9264423e7917
    - path: docs/lrs/03_functional_escalation.md
      status: present
      sha256: 997201505415ded2f01f6eb60f2b1ffe37d541efa8dccf7e391e0fb32887991c
    - path: docs/lrs/03_functional_fault_policy.md
      status: present
      sha256: 560626dbc52759a04daead265c15c2fa33f4f1b7e2f338cf7c28779e3dc3156a
    - path: docs/lrs/03_functional_recovery.md
      status: present
      sha256: 7b73fd3e0bbf327677e3478073b09ffdd98e5aab8b222eed01d47a07ef08fd0a
    - path: docs/lrs/03_functional_service_1.md
      status: present
      sha256: b785786b79281e953e85d1390697a9c6cd43c3a242cdbbdc585f1b34389b25e0
    - path: docs/lrs/03_functional_service_2.md
      status: present
      sha256: 447109f8289309ea389b8a08265718a4b4e2332403eee346260884eabba497bf
    - path: docs/lrs/03_functional_start.md
      status: present
      sha256: 34267ec20d9a2002a829bfbac438997597979f0f8cb97f20f7916530a3c0da3f
    - path: docs/lrs/03_functional_supervision_1.md
      status: present
      sha256: 09d8ab11a5f51233a987aa447e47019c26dcff67275e32655eb2137a38952cd6
    - path: docs/lrs/03_functional_supervision_2.md
      status: present
      sha256: 293365d8aa8c1a0ae9e18f302a19e5d8db0efcd7a29383ee23ff373e010a3079
    - path: docs/lrs/03_functional_timing.md
      status: present
      sha256: 92ec30f80ca7efaca80d7af2629b131436147410f9c00cb80b48e02d6730d67d
    - path: docs/lrs/04_register_capabilities.md
      status: present
      sha256: 928f59514d4a8cce23b895c624baaf3af08ec61fe26084234ff4fe19c8f5e41d
    - path: docs/lrs/04_register_configuration.md
      status: present
      sha256: ff63c6a8086a74b953e24e6b19da31435deb7978d76b42a2fd5d03c0316550b8
    - path: docs/lrs/04_register_snapshot.md
      status: present
      sha256: cff119a8c04547a9207f27685dd594e1fd3b8b851722b26e5640396ba11ad85b
    - path: docs/lrs/04_register_validation.md
      status: present
      sha256: 393bb6ad7b3c9127ab3a507dcd80a28094fae49e4061918a7523c7f348cacbc7
    - path: docs/lrs/05_performance.md
      status: present
      sha256: dd4b6ef8923231ba23b01d184621e0ce7a012f95c623075da0f1aed3780bb8f2
    - path: docs/lrs/06_clock_reset.md
      status: present
      sha256: c6d8ad3741f4bfb82da19abb4150c9a0c413c9a2322f7cb8c61355835aa73664
    - path: docs/lrs/07_low_power.md
      status: present
      sha256: 52daf018fa8119c59db20c759011f133dad9c0344c6e4d05b6b9162d037ee129
    - path: docs/lrs/08_safety.md
      status: present
      sha256: bb7599eb6c8afd8fa20f0548e724ebfd32422a4527145156b965a8a2f3e14da8
    - path: docs/lrs/09_security.md
      status: present
      sha256: 7c1762a33ef355b7bc50f88e834804c5b55e45f2731e1f097d9895bd2cb71949
    - path: docs/lrs/10_dfx.md
      status: present
      sha256: d830a2f0f38ff3f3ad273cbe433e23cb0d23bda853adebb39d89b3a1fa954f3e
    - path: docs/lrs/10_dfx_diagnostics.md
      status: present
      sha256: 18331c970db91d7f0cafc64fa3fc52db2795446f07f4f0c411a03be872003261
    - path: docs/lrs/11_generator.md
      status: present
      sha256: 2c6b9e645859d960ecdb5286b9bdc995ca4b9abb55321cd0016ebd7404bc2795
    - path: docs/lrs/12_constraints.md
      status: present
      sha256: 563eb12b067ffe23c574f1f02bf2057159ec81d77c370ebaaaeffc51fe73d7d1
    - path: docs/lrs/12_constraints_acceptance.md
      status: present
      sha256: f62af4e5e0d873bf2c983814230fd385ff1a6168b2369c14da3af831f0f7ac18
    - path: docs/lrs/12_constraints_delivery.md
      status: present
      sha256: ecbc10de7b7d3622eebecdfd3f61ebd0364a5c6398597770c16684ad93161fe6
    - path: docs/lrs/99_quality_gate.md
      status: present
      sha256: fd5ef685758479a481e3b81ea1dce5a6aaa37ccd93b0f2f5966dc8a3a92ab676
    - path: docs/lrs/index.md
      status: present
      sha256: 354e175a1e75600f8f1154d55860d6fb9ab5c88ae4ea566925889ce7218e04a3
  - id: g0.requirements_model
    status: pass
    detail: 139 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=parameterized;
      ppa_signoff=required; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a65e448c10140ca009ac320df2ce9e9be048967c55713853bf63f1ec43c13107
  findings: []
- id: G1
  status: pass
  required_checks:
  - g1.architecture_trace
  checks:
  - id: g1.architecture_trace
    status: pass
    detail: modules=6; uncovered must requirements=0; invalid requirement refs=0;
      invalid modules=0
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: bf17edbd072f26f72285bd1eb248b6387e1225dc5f1fbca9350791cee8699c64
    - path: model/external_interface.yaml
      status: present
      sha256: 073f982fdd08fc33ffe8823b711e3e463dcb2efb3fcbd70cabdcc0cd646ceffc
    - path: model/internal_interface.yaml
      status: present
      sha256: 1b23e9d701e6970c6f3f64bf9fce47d8b70698828cfc95180beb896b1679ef66
    - path: model/clock_domains.yaml
      status: present
      sha256: e51e3632e7d38e152eedd428504c75c2e0b4c69c4f933e4211e461a73054a3ce
    - path: model/cdc_paths.yaml
      status: present
      sha256: 7c908390e33dcbb89b8fbd5245caed1546ec157db1f7a560001351b83dafde53
  findings: []
- id: G2
  status: pass
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: pass
    detail: modules=6; missing HLD coverage=0; unknown HLD refs=0; invalid modules=0;
      invalid child refs=0; invalid datapaths=0; invalid FSMs=0; modules without design
      objects=0; register_model=required; invalid register behaviors=0; RDL files=1;
      register report=validated REPORT_META; CSR evidence=CSR source and native SystemVerilog
      hashes match the manifest
    evidence:
    - path: model/micro_design.yaml
      status: present
      sha256: f875e9c1e58e4d8451ac5fdf1ec5d4debaa2995ea05441736b16b61d790370b8
    - path: model/requirements.yaml
      status: present
      sha256: a65e448c10140ca009ac320df2ce9e9be048967c55713853bf63f1ec43c13107
    - path: reports/quality/register_check.md
      status: present
      sha256: 06e151fc3a6c3ac5d0489fc3b89dc2c6f516ffd47f45078442b0d2b17c14abdd
    - path: regs/watchdog.rdl
      status: present
      sha256: ef453feb551ecaa968feb76851094c6eb6e8458e2b5e857dcebd03b1f9cd751e
    - path: rtl/generated/watchdog_csr.sv
      status: present
      sha256: 277b9d5b34a1c03295dc1eb65a6ed9f1b18a122c96d67fe153df7cced39bce04
    - path: rtl/generated/watchdog_csr_pkg.sv
      status: present
      sha256: a20925d1227ed6701779f78a6c21d8746be91a4928b912dc64a3324d9e494650
    - path: rtl/generated/watchdog_csr.manifest.yaml
      status: present
      sha256: 781b76d51e1661205bf5f8df0a1c14a075accd238e94f609e7da6367d3a7d0fb
  findings: []
- id: G3
  status: fail
  required_checks:
  - g3.rtl_and_core
  - g3.rtl_check_report
  - g3.module_ut
  - g3.csr_consistency
  checks:
  - id: g3.rtl_and_core
    status: fail
    detail: 'rtl=6; root cores=1; invalid ip-package.yaml: ''vendor'''
    evidence:
    - path: rtl/generated/watchdog_csr.sv
      status: present
      sha256: 277b9d5b34a1c03295dc1eb65a6ed9f1b18a122c96d67fe153df7cced39bce04
    - path: rtl/generated/watchdog_csr_pkg.sv
      status: present
      sha256: a20925d1227ed6701779f78a6c21d8746be91a4928b912dc64a3324d9e494650
    - path: rtl/generated/watchdog_reg_adapter.sv
      status: present
      sha256: e9b3a3b93944f624b8256a8be5d45b7c878c2d00916da01477bc7becfb8b8718
    - path: rtl/watchdog_channel.sv
      status: present
      sha256: ec80bb1446a0cb4c7903c476b940a136d82377bea044d1421c4e7ac055637d7a
    - path: rtl/watchdog_pkg.sv
      status: present
      sha256: a319d6a2e447838c5e139eb066b1ef67175bd7940241cf2f484f76863dc93c6a
    - path: rtl/watchdog_top.sv
      status: present
      sha256: 1f708f7419c203d390512c175a5797c9089ed5188adac1cf85db8a9457ef592b
    - path: aixsilicon_ip_watchdog.core
      status: present
      sha256: b4d9d3dd1d6debbebb5aeefad47484ac4284f3aadb0f3a488990ddcf366dc9ce
    - path: ip-package.yaml
      status: present
      sha256: f2126c0747abc252a5f15ce09853a1253078f32e123de3cf93215ef3e92988e7
  - id: g3.rtl_check_report
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/quality/rtl_check_summary.md'
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: missing
  - id: g3.module_ut
    status: fail
    detail: 'module UT sources=2; missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/quality/module_ut_summary.md'
    evidence:
    - path: verification/unit_test/ut_watchdog_channel.sv
      status: present
      sha256: 5a8d651e87c770c73c1ae08093fa90430d113a3dd88c69faed545752165e6303
    - path: verification/unit_test/ut_watchdog_top.sv
      status: present
      sha256: 28e81eab9e0d51f206ebaa9d6713952f59c2409d43e0f18d3667c5a3de786337
    - path: reports/quality/module_ut_summary.md
      status: missing
  - id: g3.csr_consistency
    status: pass
    detail: CSR source and native SystemVerilog hashes match the manifest
    evidence:
    - path: regs/watchdog.rdl
      status: present
      sha256: ef453feb551ecaa968feb76851094c6eb6e8458e2b5e857dcebd03b1f9cd751e
    - path: rtl/generated/watchdog_csr.sv
      status: present
      sha256: 277b9d5b34a1c03295dc1eb65a6ed9f1b18a122c96d67fe153df7cced39bce04
    - path: rtl/generated/watchdog_csr_pkg.sv
      status: present
      sha256: a20925d1227ed6701779f78a6c21d8746be91a4928b912dc64a3324d9e494650
    - path: rtl/generated/watchdog_csr.manifest.yaml
      status: present
      sha256: 781b76d51e1661205bf5f8df0a1c14a075accd238e94f609e7da6367d3a7d0fb
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
    detail: '[Errno 2] No such file or directory: ''/home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/model/verification.yaml'';
      distinct testcase implementations=0; valid lifecycle traces=0/4; testplans=1;
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
    - path: docs/verification/verification_plan.md
      status: present
      sha256: 38a795937836235687e89677ac66d1dfa3d6aac4cf2b35e8d7be7bcdbc93580a
  - id: g4.smoke_evidence
    status: fail
    detail: 'smoke: missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/smoke/smoke_junit.xml;
      invalid smoke_executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/smoke/smoke_junit.xml
      status: missing
  - id: g4.full_regression_evidence
    status: fail
    detail: 'regression: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/regression/regression_summary.md;
      missing JUnit report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/regression/junit.xml;
      invalid executions contract: missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/regression/regression_summary.md'
    evidence:
    - path: reports/regression/regression_summary.md
      status: missing
    - path: reports/regression/junit.xml
      status: missing
  - id: g4.coverage_closure
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/coverage/coverage_summary.md'
    evidence:
    - path: reports/coverage/coverage_summary.md
      status: missing
  - id: g4.rtm_closure
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/quality/trace_matrix.md;
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
    detail: parameters=16; configs=188; missing evidence=0
    evidence:
    - path: reports/quality/param_check.md
      status: present
      sha256: 1dd2f7d4b939b99c47c810eacdf92977c3ea23fb47f45d248bfa0f1565e4277c
    - path: reports/quality/param_matrix.md
      status: present
      sha256: 8a84b749784467caa306951a0b0c61b114d6731f5a05b7be4e1c3fcaac967c7c
  - id: g4.parameter_execution
    status: fail
    detail: 'missing report: /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/reports/quality/param_execution.md'
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a65e448c10140ca009ac320df2ce9e9be048967c55713853bf63f1ec43c13107
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
      status: missing
    - path: docs/user_manual
      status: missing
    - path: reports/quality/review_findings.yaml
      status: missing
  - id: g5.ppa_signoff
    status: fail
    detail: policy=required; required PPA evidence is missing
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: a65e448c10140ca009ac320df2ce9e9be048967c55713853bf63f1ec43c13107
    - path: model/pdk.yaml
      status: missing
    - path: reports/ppa-report.md
      status: missing
    - path: reports/ppa/sweep_analysis.yaml
      status: missing
  findings: []
END_QUALITY_META -->
