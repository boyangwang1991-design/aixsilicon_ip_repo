# Quality Gate Report - apb_demux

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | pass | g1.architecture_trace |
| G2 | pass | g2.microdesign_and_register_freeze |
| G3 | pass | g3.rtl_and_core, g3.rtl_check_report, g3.module_ut, g3.csr_consistency |
| G4 | pass | g4.verification_assets, g4.smoke_evidence, g4.full_regression_evidence, g4.coverage_closure, g4.rtm_closure, g.param_space |
| G5 | pass | g5.release_inputs, g5.ppa_signoff |

<!-- QUALITY_META
schema_version: '2.0'
ip_name: apb_demux
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
    detail: LRS markdown files=13 (single-file docs/lrs/lrs.md or category-split layout,
      must contain LRS_DOC_META)
    evidence:
    - path: docs/lrs/00_overview.md
      status: present
      sha256: ab7b8fc4b9809a94d445fa43f5fb9877506374a894e2f931b4ca8d01b617833d
    - path: docs/lrs/01_configuration.md
      status: present
      sha256: 620f9357cc86e3bc379a0c3bfc4f8303309ef361299713192c841e6be68e34db
    - path: docs/lrs/02_interface.md
      status: present
      sha256: df081f6552435a9f085260bd8dafd38e6bfed7ab3613d0c1cf798ff95cda176a
    - path: docs/lrs/03_functional.md
      status: present
      sha256: a5a6f9accf23ad0a855a5019918e19fe61b13a941bbd974727f3955c88418cd9
    - path: docs/lrs/04_performance.md
      status: present
      sha256: 6d1e5778905d080870bcd174c9a5a201c937989d8544e2cb5fae87564ea9a34e
    - path: docs/lrs/05_clock_reset.md
      status: present
      sha256: aa51fa945f7a0ba1497bc01beadb1bea6318b9b016e7db01a6bf892d817b0d75
    - path: docs/lrs/06_low_power.md
      status: present
      sha256: d67ceed81e0cfd799140d70f9e9b572dfcbdc596a4ac703800d2802e323d2e18
    - path: docs/lrs/07_safety.md
      status: present
      sha256: 8f00f05e99eda8f1554529915e74b67e82cc30e21013f527a22a0b43400263c2
    - path: docs/lrs/08_security.md
      status: present
      sha256: 0d3cc24fe475b2b0c3c72c55c883738a7ec306f5cc1008b575d4521fdd3cfe94
    - path: docs/lrs/09_dfx.md
      status: present
      sha256: d128be4eb7b344e52f05154f082101c8194900d47187f50a623ac7ad7142b360
    - path: docs/lrs/10_constraints.md
      status: present
      sha256: ef36e75a5285b65d22c5a72d34f0fa709189b016cf4e35f4bb3da00069f316b4
    - path: docs/lrs/11_quality_gate.md
      status: present
      sha256: 977590928642dad6d4fdc00235996c93a7db02b9f066784cd0a73af8dbfb5194
    - path: docs/lrs/index.md
      status: present
      sha256: cc1941aad509c3c0cbeae8448ad06592113c761b058053350c6f80e12a222d7e
  - id: g0.requirements_model
    status: pass
    detail: 55 requirements; duplicate IDs=0; must without verify_method=0; delivery_model=parameterized;
      ppa_signoff=none; ppa override reason valid=True
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 9f24927e5d6e3f8d2fc027d7a357dbbb6e45fa65c370aab759193960bafa9eb5
  findings: []
- id: G1
  status: pass
  required_checks:
  - g1.architecture_trace
  checks:
  - id: g1.architecture_trace
    status: pass
    detail: modules=4; uncovered must requirements=0; invalid requirement refs=0;
      invalid modules=0
    evidence:
    - path: model/architecture.yaml
      status: present
      sha256: f9e01f628b6b5759bd5886033d80f810853c67bb0d71dc62303612ed9e896f20
    - path: model/external_interface.yaml
      status: present
      sha256: 271716618bd15a849f6694b9797ee899a7c0da96e8ecf6149e75940739bf4145
    - path: model/internal_interface.yaml
      status: present
      sha256: a8d9d2bdf5dbebd400bd3e86c52ee052e8a1478e46d03a436ac1594bf6c1992c
    - path: model/clock_domains.yaml
      status: present
      sha256: 892e10ecd83e203626851a3942b03cb4f8f071daae17ea29f2ffe7db6bbb685c
    - path: model/cdc_paths.yaml
      status: present
      sha256: b062087a5a5f4bd380822cf0fb891255ecb8a3954379b0ca992621baa1d7e4db
  findings: []
- id: G2
  status: pass
  required_checks:
  - g2.microdesign_and_register_freeze
  checks:
  - id: g2.microdesign_and_register_freeze
    status: pass
    detail: modules=1; missing HLD coverage=0; unknown HLD refs=0; invalid modules=0;
      invalid child refs=0; invalid datapaths=0; invalid FSMs=0; modules without design
      objects=0; register_model=none; invalid register behaviors=0; RDL files=0; register
      report=n/a; CSR evidence=no SystemRDL source; CSR provenance not required
    evidence:
    - path: model/micro_design.yaml
      status: present
      sha256: bc58793960730053b6ea642536f60acda21423eba70686d6737c8b38666400a6
    - path: model/requirements.yaml
      status: present
      sha256: 9f24927e5d6e3f8d2fc027d7a357dbbb6e45fa65c370aab759193960bafa9eb5
    - path: reports/quality/register_check.md
      status: missing
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
    detail: rtl=1; cores=1
    evidence:
    - path: rtl/apb_demux_top.sv
      status: present
      sha256: f0a96f4e86cb03611425802aa615fe22cc7387ff75b680067b20988881c53e05
    - path: aixsilicon_ip_apb_demux.core
      status: present
      sha256: 40467d545c3040eab5e770a8234845e8f56a5590f1bd230b924dae6b0be9ca47
  - id: g3.rtl_check_report
    status: pass
    detail: validated REPORT_META
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: present
      sha256: 1c5cf79293da59b6f43de9a7257481427ad3451cada867ea7e5b39085947c821
  - id: g3.module_ut
    status: pass
    detail: module UT sources=1; module UT executions=1; compile/run evidence complete
    evidence:
    - path: verification/unit_test/ut_apb_demux.sv
      status: present
      sha256: f78db32b7da3f4076cd6ec1a4d9db805b144317c578c36560540af6d13606101
    - path: reports/quality/module_ut_summary.md
      status: present
      sha256: 05cfb06940a41946984fb7fb005aafd8881c081aa0346f683e9b7a2ec38b6938
  - id: g3.csr_consistency
    status: pass
    detail: no SystemRDL source; CSR provenance not required
    evidence: []
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
  checks:
  - id: g4.verification_assets
    status: pass
    detail: verification features=12; smoke testcase IDs=2; all-tier testcase IDs=13;
      implementation mappings=13; invalid mappings=0; regression list match=True;
      distinct testcase implementations=13; valid lifecycle traces=4/4; testplans=7;
      UVM testcases=14
    evidence:
    - path: model/verification.yaml
      status: present
      sha256: c648f3b0276b5153da83c73ef022149c10c2fd0aaa6fa42ddba4cbdbe2120524
    - path: trace/req_to_hld.yaml
      status: present
      sha256: 8bcadcb517e90b11fb77db9b2c0aef73cdac26f084a258016d0523514f00fea1
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: 38907acfadf2540b25acb12c0f3bebd952cdb1b16b0c330771624b023b2e0f01
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: 2e005f7e4513dead215d85666f5dfac052839564d6f84dbf4ca9bc29cba1e7d3
    - path: trace/req_to_test.yaml
      status: present
      sha256: ad05b045057737026041c3eb5cbbdce1e362c87a707b0e03a9a807c3d73d8737
    - path: verification/sim/regression_list.yaml
      status: present
      sha256: f78adeab575a7060a28b80cab5da5a639838de5f400ab44c7204100980d1e8e7
    - path: docs/verification/agent_plan.md
      status: present
      sha256: f93330d3372ec3e94abda995bcf859a96ae123b05fa0a04f7c8c20038e40e9b1
    - path: docs/verification/checker_plan.md
      status: present
      sha256: b0a69d2156a92d547759313874596adc1fcb1e2188984356c0f2140d5d258be6
    - path: docs/verification/coverage_plan.md
      status: present
      sha256: 4422cca33b3b64f4759c761d40a0d5ef35908e00dde9ef3ce1ea6fdc3b7e3ad6
    - path: docs/verification/feature_list.md
      status: present
      sha256: fcd8a66457c70602f7ff283443897ea0cf8d4d45908dc5ac7fbaea8ff030afe5
    - path: docs/verification/index.md
      status: present
      sha256: 46b337a97354176af59b84df92df36e7c084007c05077bb2a373f80296fe6988
    - path: docs/verification/test_matrix.md
      status: present
      sha256: 5d2352290d01205b4777f7601988221173ebf58dc5ade55fac4d6f4d2bac937f
    - path: docs/verification/verification_plan.md
      status: present
      sha256: 71263cf33b4190cbc76d71f9a9dae56e86057c7dacba3b4307699031b5c53561
    - path: verification/tc/tc_address_decode.sv
      status: present
      sha256: c0b4e76cd46d24638629426133264873821af52849f88227000e67b0ac3bd41d
    - path: verification/tc/tc_apb4.sv
      status: present
      sha256: 4b6de295a66450d676468135367af75cc8de9d1a3344c5914429edd939234410
    - path: verification/tc/tc_assertions.sv
      status: present
      sha256: 9c0c817cf1b3f375097e3a45d615aa371223b592bdfd467cb8212cc8440455f8
    - path: verification/tc/tc_base.sv
      status: present
      sha256: 0186a3785997a55ba68ca1e4045b4d18c8154269c503458b7c1b60af014e5323
    - path: verification/tc/tc_decode_miss.sv
      status: present
      sha256: b397188df306cfc513083b1543c98c8befc56e3f767be8bad6e4ce462a944858
    - path: verification/tc/tc_num_slaves_sweep.sv
      status: present
      sha256: f8f70dafb4b83c771a7070e0bd6cebb62b5860e858315adabd078a6340821d45
    - path: verification/tc/tc_output_register.sv
      status: present
      sha256: 62715545823419f706772cc82923baba353c1a19daaab594372a4bf4845e2f91
    - path: verification/tc/tc_psel_onehot.sv
      status: present
      sha256: 717a7e9e3ec0e18cf143e8ae9933c6bcdf9c58803bed975a25f0d43fa4c7bf96
    - path: verification/tc/tc_pslverr.sv
      status: present
      sha256: 0ac90dd279649f91bc8ffec7dfd55da15ff0bf5916aa5e8c23cfae491e464a2a
    - path: verification/tc/tc_remap.sv
      status: present
      sha256: 22a35fbaeb3a36f37411dff694ee4548acb1166127bc473ac6420cee43f2319d
    - path: verification/tc/tc_reset.sv
      status: present
      sha256: ed55d3c9c69403a5745e69d3ec2890430ab0cd511314e084d7ab12e6d522433a
    - path: verification/tc/tc_sanity.sv
      status: present
      sha256: e6c25a96f1c5c705c685f8512ac8e7c032997f328cd583ecc397a28090460832
    - path: verification/tc/tc_timeout.sv
      status: present
      sha256: c9e27c3b5ecd3378c3b4077f219c48f8355b4b66e38ee801a4205e549ac43bb2
    - path: verification/tc/tc_wait_states.sv
      status: present
      sha256: a5549b2497bce3bb9ad81376bee69f330ae17e4ae431daf765378686d93b2583
    - path: verification/tc/tc_sanity.sv
      status: present
      sha256: e6c25a96f1c5c705c685f8512ac8e7c032997f328cd583ecc397a28090460832
    - path: verification/tc/tc_apb4.sv
      status: present
      sha256: 4b6de295a66450d676468135367af75cc8de9d1a3344c5914429edd939234410
    - path: verification/tc/tc_num_slaves_sweep.sv
      status: present
      sha256: f8f70dafb4b83c771a7070e0bd6cebb62b5860e858315adabd078a6340821d45
    - path: verification/tc/tc_address_decode.sv
      status: present
      sha256: c0b4e76cd46d24638629426133264873821af52849f88227000e67b0ac3bd41d
    - path: verification/tc/tc_psel_onehot.sv
      status: present
      sha256: 717a7e9e3ec0e18cf143e8ae9933c6bcdf9c58803bed975a25f0d43fa4c7bf96
    - path: verification/tc/tc_wait_states.sv
      status: present
      sha256: a5549b2497bce3bb9ad81376bee69f330ae17e4ae431daf765378686d93b2583
    - path: verification/tc/tc_pslverr.sv
      status: present
      sha256: 0ac90dd279649f91bc8ffec7dfd55da15ff0bf5916aa5e8c23cfae491e464a2a
    - path: verification/tc/tc_decode_miss.sv
      status: present
      sha256: b397188df306cfc513083b1543c98c8befc56e3f767be8bad6e4ce462a944858
    - path: verification/tc/tc_remap.sv
      status: present
      sha256: 22a35fbaeb3a36f37411dff694ee4548acb1166127bc473ac6420cee43f2319d
    - path: verification/tc/tc_timeout.sv
      status: present
      sha256: c9e27c3b5ecd3378c3b4077f219c48f8355b4b66e38ee801a4205e549ac43bb2
    - path: verification/tc/tc_output_register.sv
      status: present
      sha256: 62715545823419f706772cc82923baba353c1a19daaab594372a4bf4845e2f91
    - path: verification/tc/tc_reset.sv
      status: present
      sha256: ed55d3c9c69403a5745e69d3ec2890430ab0cd511314e084d7ab12e6d522433a
    - path: verification/tc/tc_assertions.sv
      status: present
      sha256: 9c0c817cf1b3f375097e3a45d615aa371223b592bdfd467cb8212cc8440455f8
  - id: g4.smoke_evidence
    status: pass
    detail: 'smoke: tests=2; failures=0; errors=0; skipped=0; missing/non-passing
      testcase IDs=0; smoke_executions=2; every testcase is bound to a passing raw
      log'
    evidence:
    - path: reports/regression/regression_summary.md
      status: present
      sha256: 5e316a77c4106c9a215fb60438a47ebdd424c371b626782f891295e593381569
    - path: reports/smoke/smoke_junit.xml
      status: present
      sha256: d7131562f13364cd2ff31c3d48722a549a91191d60ce65e165adf0e06a558254
  - id: g4.full_regression_evidence
    status: pass
    detail: 'regression: validated REPORT_META; tests=13; failures=0; errors=0; skipped=0;
      missing/non-passing testcase IDs=0; executions=13; every testcase is bound to
      a passing raw log'
    evidence:
    - path: reports/regression/regression_summary.md
      status: present
      sha256: 5e316a77c4106c9a215fb60438a47ebdd424c371b626782f891295e593381569
    - path: reports/regression/junit.xml
      status: present
      sha256: e851e02e91398735008d09bf0867a323937cb4ab233a09120179d5a1d28df8d0
  - id: g4.coverage_closure
    status: pass
    detail: functional=100.0/90.0; code=90.0/90.0; assertion=100.0/100.0
    evidence:
    - path: reports/coverage/coverage_summary.md
      status: present
      sha256: 33dc181ac2e0b37c4eb5aadc0d78972177937512fe3c27c10ed0b09cad3b3421
  - id: g4.rtm_closure
    status: pass
    detail: validated REPORT_META; valid lifecycle traces=4/4
    evidence:
    - path: reports/quality/trace_matrix.md
      status: present
      sha256: fc0f4b3464d803984a54e48906278eb6f635ef218cd13f51114105ab53d760da
    - path: trace/req_to_hld.yaml
      status: present
      sha256: 8bcadcb517e90b11fb77db9b2c0aef73cdac26f084a258016d0523514f00fea1
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: 38907acfadf2540b25acb12c0f3bebd952cdb1b16b0c330771624b023b2e0f01
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: 2e005f7e4513dead215d85666f5dfac052839564d6f84dbf4ca9bc29cba1e7d3
    - path: trace/req_to_test.yaml
      status: present
      sha256: ad05b045057737026041c3eb5cbbdce1e362c87a707b0e03a9a807c3d73d8737
  - id: g.param_space
    status: pass
    detail: parameters=8; configs=17; missing evidence=0
    evidence:
    - path: reports/quality/param_check.md
      status: present
      sha256: c6fe9123fd8e2f8daae1de45795980eb506007339842dccf137a96a25e42cfec
    - path: reports/quality/param_matrix.md
      status: present
      sha256: 3c0aa9445fb83db6a72721f04f1948ed479899df7f4d3aae2b48dc58ec50c0f0
  findings: []
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
      sha256: 518f97cd11d58281ce8b1e38f82377bbd7fa56b35ae8dd06899f02e10a75873b
  - id: g5.ppa_signoff
    status: pass
    detail: policy=none; PPA signoff not applicable
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 9f24927e5d6e3f8d2fc027d7a357dbbb6e45fa65c370aab759193960bafa9eb5
    - path: model/pdk.yaml
      status: present
      sha256: e7b6c4ce9629f6ac946c5c0dfd61d029aab4ac8a528fbe0349a499028710f2e2
    - path: reports/ppa-report.md
      status: present
      sha256: 2934185a2312d9a6c5dd03c7a79d6b1d1d55695628ca59d33765aed299286282
    - path: reports/ppa/summary_CFG_BASE.yaml
      status: present
      sha256: 946b2d9742c20687523a6f55bf4d9a46289739a6db36193455168853ff7c9cc8
    - path: reports/ppa/pareto_area_power.png
      status: present
      sha256: 04e4aad1a2f79f450f8eb61676571426feb5b4f3f3ad54446f94310fc444b288
  findings: []
END_QUALITY_META -->
