# Quality Gate Report - axi_mpu

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | pass | g1.architecture_trace |
| G2 | pass | g2.microdesign_and_register_freeze |
| G3 | pass | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency |
| G4 | pass | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space, g4.parameter_execution |
| G5 | pass | g5.release_inputs, g5.ppa_signoff |

<!-- QUALITY_META
schema_version: '2.0'
ip_name: axi_mpu
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
    detail: LRS markdown files=16 (single-file docs/lrs/lrs.md or category-split layout,
      must contain LRS_DOC_META)
    evidence:
    - path: docs/lrs/00_overview.md
      status: present
      sha256: 309a907d4e2490e54f137d0c89a98b637d4f655bdaf9909d92599b48d30566ab
    - path: docs/lrs/01_configuration.md
      status: present
      sha256: 168493a41fe5fc0a0f44cd24c7bf1d924f34dbcab263b9405e53aeb833538df8
    - path: docs/lrs/02_interface.md
      status: present
      sha256: b5bd85a643562e089769193a396cc36e013e3637a9f4432615f2a2d373f98989
    - path: docs/lrs/03_functional.md
      status: present
      sha256: 6641b28890debd357808c84fa8af5ecb3d83d9bee17e8f6824cad98fefd851db
    - path: docs/lrs/03b_transaction.md
      status: present
      sha256: dcab3232011e9efb67f7bcb163ad6250d91c335cf8250099f2b0172713a380eb
    - path: docs/lrs/04_register.md
      status: present
      sha256: 2674ce08d221bc755d1689108fc8ce115cefbbf3c178ecfe80be49be9166b83c
    - path: docs/lrs/05_performance.md
      status: present
      sha256: d0e30b951115b22ae46f4e4d7513a5610104012afe35b1913a9e13428484b2a2
    - path: docs/lrs/06_clock_reset.md
      status: present
      sha256: 6816a6ebbe438d738cc84f528f4d65bfa6259d57c89b5114445f8e844d0bfaea
    - path: docs/lrs/07_low_power.md
      status: present
      sha256: 9e454d580f911081f8b126a6f7f1892dab070817960d8fb387c517c699be3b0f
    - path: docs/lrs/08_safety.md
      status: present
      sha256: 2bcdd8cf003a77ef0d4054928b2b5225e3a8d3342389abef9ff20ac01dce443f
    - path: docs/lrs/09_security.md
      status: present
      sha256: b6b2156eb9036b5a4bba7ce623b21674886b667c97987934e56efe6eefec6857
    - path: docs/lrs/10_dfx.md
      status: present
      sha256: 6ed861bed381299ccd38a7ebbe0dc3190b885811b1e7cc7d1055df3294fb9343
    - path: docs/lrs/11_generator.md
      status: present
      sha256: 8e4893daa993b19467d94e68a8b5b7bb7fe819bc4525fb7a1f9c81fe62044c2e
    - path: docs/lrs/12_constraints.md
      status: present
      sha256: 4fd88975e983a9a5bb60c68e1134e7ebd7ae4246341030dee68b40be14f17092
    - path: docs/lrs/99_quality_gate.md
      status: present
      sha256: 97721a167219d3781f715f7286b94c345fb30ef9164c931685a45674cc4dbb82
    - path: docs/lrs/index.md
      status: present
      sha256: 6b5189fc6e40a94405ad7689a050cb027d57afb7c9867d2c959843b5a4a7f408
  - id: g0.requirements_model
    status: pass
    detail: 71 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=generator;
      ppa_signoff=required; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 412accd5ceb619406692f7229c938efab515a718910de90ffe309b412e3e7d45
  findings: []
- id: G1
  status: pass
  required_checks:
  - g1.architecture_trace
  checks:
  - id: g1.architecture_trace
    status: pass
    detail: modules=7; uncovered must requirements=0; invalid requirement refs=0;
      invalid modules=0
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: 2a747dd62f00c774d6f28fcc9be8172ad0cf495eb86234f66ec3db78002868d8
    - path: model/external_interface.yaml
      status: present
      sha256: cc2c89c44c9854fd91045622c598e124968375ffbabc770eaafa7faab15a8140
    - path: model/internal_interface.yaml
      status: present
      sha256: 22bcc9739841a71924bb02f298d78fea2eb15778d3fc29df99af9bed4e981cf1
    - path: model/clock_domains.yaml
      status: present
      sha256: 596ae64ae11403f3056ba34b95500ba2d745c31da45b291ac2885e2cb5c8b79f
    - path: model/cdc_paths.yaml
      status: present
      sha256: 31f9203535fd0256f423e9572ea31198807ac65ce4707be6b5047afc2ece5ff0
  findings: []
- id: G2
  status: pass
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: pass
    detail: modules=8; missing HLD coverage=0; unknown HLD refs=0; invalid modules=0;
      invalid child refs=0; invalid datapaths=0; invalid FSMs=0; modules without design
      objects=0; register_model=required; invalid register behaviors=0; RDL files=1;
      register report=validated REPORT_META; CSR evidence=CSR source and native SystemVerilog
      hashes match the manifest
    evidence:
    - path: model/micro_design.yaml
      status: present
      sha256: e4d77148f2384271a0c83f3cd774c2357a2700b86d4ffe0b2411c20b08d04544
    - path: model/requirements.yaml
      status: present
      sha256: 412accd5ceb619406692f7229c938efab515a718910de90ffe309b412e3e7d45
    - path: reports/quality/register_check.md
      status: present
      sha256: 6146a34b7e3048aa6c5c8e8b1b3ab0ce49b12e12f0784681e0c685b463f59820
    - path: regs/axi_mpu.rdl
      status: present
      sha256: f7cac5296e922c4b5ffa87757e5106ab22167c6fe43188bccb5c7c2cbb286dde
    - path: rtl/generated/axi_mpu_csr.sv
      status: present
      sha256: cc108732db4d58525a950aa8c3f1dff991843b75f0c5b6b76bcc36cf476c1243
    - path: rtl/generated/axi_mpu_csr_pkg.sv
      status: present
      sha256: 160f1c94f02a030d0323b85c895c0f1bd92694e6b571e3367f54eacf223b155f
    - path: rtl/generated/axi_mpu_csr.manifest.yaml
      status: present
      sha256: 0f3634544bb03c8c2fb5486783d33377aa2162879fbc3ba238c92c1d3cf0d674
  findings: []
- id: G3
  status: pass
  required_checks:
  - g3.rtl_and_core
  - g3.rtl_check_report
  - g3.module_ut
  - g3.csr_consistency
  checks:
  - id: g3.rtl_and_core
    status: pass
    detail: rtl=6; root cores=1; expected=aixsilicon_ip_axi_mpu.core; actual=aixsilicon_ip_axi_mpu.core
    evidence:
    - path: rtl/axi_mpu.sv
      status: present
      sha256: 710921e65968a6139fb883b036dc04c38e2fd967645e95b37634a651c7fb0bb1
    - path: rtl/axi_mpu_permission.sv
      status: present
      sha256: 402821fb65ad90bc5f953a5682c04813af06f893f04920d9fa0947a9b34e4749
    - path: rtl/axi_mpu_read.sv
      status: present
      sha256: 98e44d9264d51524df99aaef7c6ba877db09e7846364b17edfecaef849b5fe11
    - path: rtl/axi_mpu_write.sv
      status: present
      sha256: 92b949deb2161132f23294fe9bb11d926ab523b64fb62aa70d05ad5f6a9c8cd4
    - path: rtl/generated/axi_mpu_csr.sv
      status: present
      sha256: cc108732db4d58525a950aa8c3f1dff991843b75f0c5b6b76bcc36cf476c1243
    - path: rtl/generated/axi_mpu_csr_pkg.sv
      status: present
      sha256: 160f1c94f02a030d0323b85c895c0f1bd92694e6b571e3367f54eacf223b155f
    - path: aixsilicon_ip_axi_mpu.core
      status: present
      sha256: 82a334560643b3097dab92680d4919846a70e17a4940217ee6a1149114856cbe
    - path: ip-package.yaml
      status: present
      sha256: 27e3b614710ee9c52750941545ca8fc148ffe5661b7c69d1cca52e82f149c43c
  - id: g3.rtl_check_report
    status: pass
    detail: validated REPORT_META
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: present
      sha256: d292f831732ebf97dacb807663c862492c4df02323289f7e4eb415bc93e96da1
  - id: g3.module_ut
    status: pass
    detail: module UT sources=1; module UT executions=1; compile/run evidence complete
    evidence:
    - path: verification/unit_test/ut_permission.sv
      status: present
      sha256: 7a67d4a52fa96236d692df093ed070d50e4815a128e3a8ddc56ff21aa128dea8
    - path: reports/quality/module_ut_summary.md
      status: present
      sha256: ff47c51f8778ee5180f5cb4118215f25940235f6f7b2d6e40a9b7f0907f8ce50
  - id: g3.csr_consistency
    status: pass
    detail: CSR source and native SystemVerilog hashes match the manifest
    evidence:
    - path: regs/axi_mpu.rdl
      status: present
      sha256: f7cac5296e922c4b5ffa87757e5106ab22167c6fe43188bccb5c7c2cbb286dde
    - path: rtl/generated/axi_mpu_csr.sv
      status: present
      sha256: cc108732db4d58525a950aa8c3f1dff991843b75f0c5b6b76bcc36cf476c1243
    - path: rtl/generated/axi_mpu_csr_pkg.sv
      status: present
      sha256: 160f1c94f02a030d0323b85c895c0f1bd92694e6b571e3367f54eacf223b155f
    - path: rtl/generated/axi_mpu_csr.manifest.yaml
      status: present
      sha256: 0f3634544bb03c8c2fb5486783d33377aa2162879fbc3ba238c92c1d3cf0d674
  findings: []
- id: G4
  status: pass
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
    status: pass
    detail: verification features=16; smoke testcase IDs=1; all-tier testcase IDs=14;
      implementation mappings=14; invalid mappings=0; regression list match=True;
      distinct testcase implementations=14; valid lifecycle traces=4/4; testplans=7;
      UVM testcases=15
    evidence:
    - path: model/verification.yaml
      status: present
      sha256: 4b7b4cbd5702a5d375b97fb8e6487df99e85d383a2ca0247949a9f617508ebee
    - path: trace/req_to_hld.yaml
      status: present
      sha256: 668d8d516c745feb77a1e3e252e37fed5a977db7d52b8b22c86465e6701eabe7
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: 2a29c4150f187c5abfefc43565bbdd6d058cca5c8e8e2e4a548aa9e99a0a66ce
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: cb7a701a09d5d6ac736345f0c230d20e6023d07e9066f3bcb5a1482d3ec7862c
    - path: trace/req_to_test.yaml
      status: present
      sha256: 37bf88d795305d9472a2ea023d192bf7dca4d4f1091038dbfe294ccdc0bca173
    - path: verification/sim/regression_list.yaml
      status: present
      sha256: cbe9733ec5ef483c4a942c1e098f2318dcff2e178c2391230e4f1d12566503e5
    - path: docs/verification/agent_plan.md
      status: present
      sha256: 46c6547ae772781f492499f434f90a5d2d295ba4c7509930a5ac0c4e1c13ed43
    - path: docs/verification/checker_plan.md
      status: present
      sha256: 588c101d3f0c4114806b4046f608c1988cbc2feb516960feb21d3f6e9154cea0
    - path: docs/verification/coverage_plan.md
      status: present
      sha256: 11a3a37051bc528a4e418b9e74145c3dd29ecaa6c9ba1ed061e2f2781b544545
    - path: docs/verification/feature_list.md
      status: present
      sha256: dbe7a1c562115c75e5863817beeb5a6d992c223ea2678404ca73a30c332f10e9
    - path: docs/verification/index.md
      status: present
      sha256: 1a7b0d924f861c00badb8962b752cdc9c41ed6fe321b4600ba4ed061c942a954
    - path: docs/verification/test_matrix.md
      status: present
      sha256: 581b3023a1cccb99891bdbfd2dcfb682bfac9678e6efd10a6a4459e49577baa5
    - path: docs/verification/verification_plan.md
      status: present
      sha256: c9ea534f003101b911c97ace05a17702f4ea9168c1b749e861a69d9613f1fc40
    - path: verification/tc/tc_base.sv
      status: present
      sha256: 6bb9d0d489073f0bef35df094b754f6eb50ad0465581c53700a49e005825f06a
    - path: verification/tc/tc_burst_boundary.sv
      status: present
      sha256: 5dc1f67d288f18d088ae3a0a86ab81304c7b40840f315279bfe3b377e12db5a0
    - path: verification/tc/tc_config_lock.sv
      status: present
      sha256: c006b56070c097828822693435f4ebdc4335d955c8ca21890b429103f128f509
    - path: verification/tc/tc_default_deny.sv
      status: present
      sha256: 96c382a4fd5430c8ca3feaa4471defa23011945d584f8ba0b38e19aeb512578c
    - path: verification/tc/tc_local_decerr.sv
      status: present
      sha256: 9e43b9239ee531c1b6357e7a9cd52fc04fdb8b26b29c27f7427bf67525ae3e5e
    - path: verification/tc/tc_master_permission.sv
      status: present
      sha256: 98ffc80494bed47042865e895ff62e5b13b60f0e54e0d566eeaebae4cee6a63f
    - path: verification/tc/tc_op_permission.sv
      status: present
      sha256: f3f054a1ff1b679de557691e60d1dd8de68e7075caccff7c5ed1668d44807ae9
    - path: verification/tc/tc_outstanding.sv
      status: present
      sha256: 1b4374e7f61d0c25534055f566b25b27a4a575798443bef01ede956af8838435
    - path: verification/tc/tc_privilege_permission.sv
      status: present
      sha256: f9058dfa9e29735e92a8706c44872e54e15e9a92cc2972915de6a5520dd2506e
    - path: verification/tc/tc_random_traffic.sv
      status: present
      sha256: 5a7aba63646a5bc5982a8d3db7e78caeff9ac498d01d3c467b46e75655a0e4ee
    - path: verification/tc/tc_region_boundary.sv
      status: present
      sha256: be10a7ea073ffe85be6521263a4bad56a8f0e5ac248e5feb6f74cfb0fee35a01
    - path: verification/tc/tc_reset_behavior.sv
      status: present
      sha256: 84cf424c4dc376b37d97394e086514bcd4ddfcd4869959e33eaeeea771d7b8ae
    - path: verification/tc/tc_security_permission.sv
      status: present
      sha256: debbef48dab094119d5f8169d7004fa0c4ac86340ef76496b0bb2812e17d2fce
    - path: verification/tc/tc_smoke_basic.sv
      status: present
      sha256: c21704f6511bcef372497b135ef645a7d52923f5e634c365dd842b6fc674a13d
    - path: verification/tc/tc_violation_capture.sv
      status: present
      sha256: c22c70a98506d997b911d2a165bb61272cb789346caf7a0d470a89d6d7e6f0c4
    - path: verification/tc/tc_default_deny.sv
      status: present
      sha256: 96c382a4fd5430c8ca3feaa4471defa23011945d584f8ba0b38e19aeb512578c
    - path: verification/tc/tc_master_permission.sv
      status: present
      sha256: 98ffc80494bed47042865e895ff62e5b13b60f0e54e0d566eeaebae4cee6a63f
    - path: verification/tc/tc_security_permission.sv
      status: present
      sha256: debbef48dab094119d5f8169d7004fa0c4ac86340ef76496b0bb2812e17d2fce
    - path: verification/tc/tc_region_boundary.sv
      status: present
      sha256: be10a7ea073ffe85be6521263a4bad56a8f0e5ac248e5feb6f74cfb0fee35a01
    - path: verification/tc/tc_burst_boundary.sv
      status: present
      sha256: 5dc1f67d288f18d088ae3a0a86ab81304c7b40840f315279bfe3b377e12db5a0
    - path: verification/tc/tc_privilege_permission.sv
      status: present
      sha256: f9058dfa9e29735e92a8706c44872e54e15e9a92cc2972915de6a5520dd2506e
    - path: verification/tc/tc_op_permission.sv
      status: present
      sha256: f3f054a1ff1b679de557691e60d1dd8de68e7075caccff7c5ed1668d44807ae9
    - path: verification/tc/tc_smoke_basic.sv
      status: present
      sha256: c21704f6511bcef372497b135ef645a7d52923f5e634c365dd842b6fc674a13d
    - path: verification/tc/tc_local_decerr.sv
      status: present
      sha256: 9e43b9239ee531c1b6357e7a9cd52fc04fdb8b26b29c27f7427bf67525ae3e5e
    - path: verification/tc/tc_violation_capture.sv
      status: present
      sha256: c22c70a98506d997b911d2a165bb61272cb789346caf7a0d470a89d6d7e6f0c4
    - path: verification/tc/tc_config_lock.sv
      status: present
      sha256: c006b56070c097828822693435f4ebdc4335d955c8ca21890b429103f128f509
    - path: verification/tc/tc_reset_behavior.sv
      status: present
      sha256: 84cf424c4dc376b37d97394e086514bcd4ddfcd4869959e33eaeeea771d7b8ae
    - path: verification/tc/tc_outstanding.sv
      status: present
      sha256: 1b4374e7f61d0c25534055f566b25b27a4a575798443bef01ede956af8838435
    - path: verification/tc/tc_random_traffic.sv
      status: present
      sha256: 5a7aba63646a5bc5982a8d3db7e78caeff9ac498d01d3c467b46e75655a0e4ee
  - id: g4.smoke_evidence
    status: pass
    detail: 'smoke: tests=1; failures=0; errors=0; skipped=0; missing/non-passing
      testcase IDs=0; smoke_executions=1; every testcase is bound to a passing raw
      log'
    evidence:
    - path: reports/regression/regression_summary.md
      status: present
      sha256: eceb47591a7784fd6cce373e2d9eb537ca7548b0a793b7997550e4abeacd4966
    - path: reports/smoke/smoke_junit.xml
      status: present
      sha256: eb9eb5e2b44889e242c8f21dc945758256be557020aa4ae6e8bd3d7c7a933f60
  - id: g4.full_regression_evidence
    status: pass
    detail: 'regression: validated REPORT_META; tests=14; failures=0; errors=0; skipped=0;
      missing/non-passing testcase IDs=0; executions=14; every testcase is bound to
      a passing raw log'
    evidence:
    - path: reports/regression/regression_summary.md
      status: present
      sha256: eceb47591a7784fd6cce373e2d9eb537ca7548b0a793b7997550e4abeacd4966
    - path: reports/regression/junit.xml
      status: present
      sha256: 2679f7e39621a72bef1f756c8c16aa5633ec61316f3814b93e48ef8fac6c7694
  - id: g4.coverage_closure
    status: pass
    detail: functional=100.0/100.0; code=100.0/90.0; assertion=100.0/100.0
    evidence:
    - path: reports/coverage/coverage_summary.md
      status: present
      sha256: d80bc0e667b4da4f5c5344c31433a4de69d153cfe2d7f235fff6447abbcb3a10
  - id: g4.rtm_closure
    status: pass
    detail: validated REPORT_META; valid lifecycle traces=4/4
    evidence:
    - path: reports/quality/trace_matrix.md
      status: present
      sha256: 700c2235ecf5a2272384bae8f3bcb10f5e1bd202a6c827673df9bb9a914662e0
    - path: trace/req_to_hld.yaml
      status: present
      sha256: 668d8d516c745feb77a1e3e252e37fed5a977db7d52b8b22c86465e6701eabe7
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: 2a29c4150f187c5abfefc43565bbdd6d058cca5c8e8e2e4a548aa9e99a0a66ce
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: cb7a701a09d5d6ac736345f0c230d20e6023d07e9066f3bcb5a1482d3ec7862c
    - path: trace/req_to_test.yaml
      status: present
      sha256: 37bf88d795305d9472a2ea023d192bf7dca4d4f1091038dbfe294ccdc0bca173
  - id: g.param_space
    status: pass
    detail: parameters=14; configs=29; missing evidence=0
    evidence:
    - path: reports/quality/param_check.md
      status: present
      sha256: 025994fdcf13dd91ef450260e4cb71f1fe1a5da5bac75a83bfaf9d522372d08b
    - path: reports/quality/param_matrix.md
      status: present
      sha256: 8a22c7b9ff9b59a033deaf69efb70e0374fcb0be9352a498d5ee9d4325f53deb
  - id: g4.parameter_execution
    status: pass
    detail: validated REPORT_META
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 412accd5ceb619406692f7229c938efab515a718910de90ffe309b412e3e7d45
    - path: reports/quality/param_execution.md
      status: present
      sha256: ace895b5c37363fc68aa1b24f83d588253a215b27b51fdfddab1908e1b1d3b07
  findings:
  - FIND.AXI_MPU.006
- id: G5
  status: pass
  required_checks:
  - g5.release_inputs
  - g5.ppa_signoff
  checks:
  - id: g5.release_inputs
    status: pass
    detail: release inputs present=3/3
    evidence:
    - path: docs/integration
      status: present
    - path: docs/user_manual
      status: present
    - path: reports/quality/review_findings.yaml
      status: present
      sha256: ffaf09809dba297b0f4b6336af31b1d893ec7de56a7d251234a52fb631b4e8b4
  - id: g5.ppa_signoff
    status: pass
    detail: policy=required; PDK_READY; valid E2/E3 summaries=7; unique_runs=7; comparable=True;
      analysis=True; plots=2
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 412accd5ceb619406692f7229c938efab515a718910de90ffe309b412e3e7d45
    - path: model/pdk.yaml
      status: present
      sha256: e5cc1bb47c2f781a83255d82cdac405606134e0c14ecda3eea539c52bcb9fc2b
    - path: reports/ppa-report.md
      status: present
      sha256: f4a97562cd8ca42225e6533a2362fd097dcd6206fca9d2550692a2299d67c78b
    - path: reports/ppa/sweep_analysis.yaml
      status: present
      sha256: f62add490bef9ab2c8fdcb2a431a46f90daf6ad71ab44a7414b8d8c639b51d60
    - path: reports/ppa/summary_CFG_R16_P0_200M_200MHz.yaml
      status: present
      sha256: 752b16467d49852c3a7537f663b80f9654870f87d23a3b831e140900f73af6af
    - path: reports/ppa/summary_CFG_R16_P0_400M_400MHz.yaml
      status: present
      sha256: b3e190909911c7aaac319f1eb8c0db82d240d3d44550b75ed7626f412480b18f
    - path: reports/ppa/summary_CFG_R16_P0_500M_500MHz.yaml
      status: present
      sha256: a240881b0dcc3ab65f7310d4d70c4fe72dccf68d7861401af1061b71bef3c5ce
    - path: reports/ppa/summary_CFG_R16_P1_200M_200MHz.yaml
      status: present
      sha256: a592864103bf3d9dce446e29029e4bff9fc04d2435616c95473e3d63e45a441d
    - path: reports/ppa/summary_CFG_R16_P1_400M_400MHz.yaml
      status: present
      sha256: 3c60c944ee1b2f87fc5d070e3e9bb15de5509e93b0e6210eec6882142fb1437e
    - path: reports/ppa/summary_CFG_R16_P1_500M_500MHz.yaml
      status: present
      sha256: c32bb5c337ce6808ee306de3601fdc83a03a7cffca29b7ddaa64bf92c2616f49
    - path: reports/ppa/summary_CFG_R4_P0_400M_400MHz.yaml
      status: present
      sha256: ddc58879b197b7fb100616157121bb0d5c2b0c6d9365086208052bdcf8223c60
    - path: reports/ppa/pareto_area_power.png
      status: present
      sha256: 4e70efd53aa67fe196c2aee76cee218494f312afd317d04fac17f588e27cd852
    - path: reports/ppa/pareto_area_slack.png
      status: present
      sha256: 3de328e5fa3b04c82d6f7844450f76201a936ebfeb47c002aeb3bb30c9bb2fd2
  findings: []
END_QUALITY_META -->
