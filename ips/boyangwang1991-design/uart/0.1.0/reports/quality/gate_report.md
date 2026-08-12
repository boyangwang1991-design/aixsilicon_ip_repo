# Quality Gate Report - uart

| Gate | Status | Required checks |
|---|---|---|
| G0 | pass | g0.required_lrs_docs, g0.requirements_model |
| G1 | pass | g1.architecture_trace |
| G2 | pass | g2.microdesign_trace |
| G3 | pass | g3.rtl_and_core, g3.rtl_check_report, g3.csr_consistency |
| G4 | pass | g4.verification_assets, g4.smoke_report |
| G5 | pass | g5.release_inputs |

<!-- QUALITY_META
schema_version: '1.0'
ip_name: uart
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
    detail: Required LRS documents exist
    evidence:
    - path: docs/lrs/01_interface.md
      status: present
      sha256: 5f23edcf5d420c78fa57550ebab12762853b8a2236e8ba3604d8e91be97a0006
    - path: docs/lrs/02_functional.md
      status: present
      sha256: 756e01ee411d7de9286ae64081bbbc9f29a83d262ab9586bc84603953ace01b4
    - path: docs/lrs/08_constraint.md
      status: present
      sha256: 6f13314294c244fc6ea3dd0041ec1320583d993fbc119cc4b6915440a9494d1f
  - id: g0.requirements_model
    status: pass
    detail: 42 requirements; duplicate IDs=0; must without verify_method=0
    evidence:
    - path: model/requirements.yaml
      status: present
      sha256: 24c30808ac97c49aa02c73cc6500a739b5e1d9e18c49fd208c4bacb87a25b7b5
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
      sha256: 53b79c928c54013b5131fbb35268c52353fd916ccadcdef03921d7deebbe6881
    - path: model/external_interface.yaml
      status: present
      sha256: 1da2c6153f069cd87e1bd22ebfcee41de50f12a3c7f31a333440cd84b373b68f
    - path: model/internal_interface.yaml
      status: present
      sha256: b85e6e2d160d5b3c0538893c1ba09360feddcce788f3ab0cabeacd4dc6d3fae4
    - path: model/clock_domains.yaml
      status: present
      sha256: b780f5520527c5647a9290f102749b86ceb6ad59a9c1628d1b5f99364b2487cb
    - path: model/cdc_paths.yaml
      status: present
      sha256: 232b3487a5782afd0a49d504e70199e0cba1c160d15673e8755b1f718f33413a
  findings: []
- id: G2
  status: pass
  required_checks:
  - g2.microdesign_trace
  checks:
  - id: g2.microdesign_trace
    status: pass
    detail: modules=6; missing HLD coverage=0; unknown HLD refs=0; invalid modules=0;
      invalid FSMs=0
    evidence:
    - path: model/micro_design.yaml
      status: present
      sha256: 4b96ba8c207fb623e858070a2106905c38571786e42f0dc3e8708f9e497d2362
  findings: []
- id: G3
  status: pass
  required_checks:
  - g3.rtl_and_core
  - g3.rtl_check_report
  - g3.csr_consistency
  checks:
  - id: g3.rtl_and_core
    status: pass
    detail: rtl=10; cores=1
    evidence:
    - path: rtl/apb2tlul.sv
      status: present
      sha256: db891cd5caed4bd6832fbfdd7fea089d8ab399882f9455b6c30ffc21caea359c
    - path: rtl/generated/uart_csr.sv
      status: present
      sha256: c24d343d91e0ae9b8c60f510310344b849301a990cd050694a5f2fd8b920f8a8
    - path: rtl/generated/uart_csr_pkg.sv
      status: present
      sha256: 7603393306703b9d2531e2ba2c2623b8fcd326fed9563c3ce394826d34de184d
    - path: rtl/uart.sv
      status: present
      sha256: b2ea9b88abb25f8a7cdbe317dfc91e6b2b456647781d2bdc33ef384c526412a5
    - path: rtl/uart_apb_top.sv
      status: present
      sha256: 30459d105e8a5714417ab261e0b9efe102bfdaf7c5ae84af685115b5d458eb81
    - path: rtl/uart_core.sv
      status: present
      sha256: 4df7acad038cdb06f81e4b7681ddf3b0bc091eb38dae63c385812f980c47d0be
    - path: rtl/uart_reg_pkg.sv
      status: present
      sha256: 106f8da3d41f8cfe585a58e91c251e23e76c81d25956cb751f61644023dfa01b
    - path: rtl/uart_reg_top.sv
      status: present
      sha256: 8c40c957fbd7c1155f58d2c7696340b7ea6b82c2b0626ec684463f991538ae27
    - path: rtl/uart_rx.sv
      status: present
      sha256: 08a72a3f045562eee419f42fe2abb4f68f3282b90bb0a6e268872fd39748782b
    - path: rtl/uart_tx.sv
      status: present
      sha256: 1cd4f59b8a58bb8e99c2a24081aae093f6528ac1887abb7cb5f31b911f949241
    - path: fusesoc/rtl-team_ip_uart.core
      status: present
      sha256: 6f21d52c615a0d7de0529caf5e1f123e2bdd3e6f76a8c603930480be3a8c1dc3
  - id: g3.rtl_check_report
    status: pass
    detail: validated REPORT_META
    evidence:
    - path: reports/quality/rtl_check_summary.md
      status: present
      sha256: 741d1cf56b49abe1c39d379fbc15db48f0f839b065a46dadd89de3611ccc5924
  - id: g3.csr_consistency
    status: pass
    detail: CSR source and native SystemVerilog hashes match the manifest
    evidence:
    - path: regs/uart.rdl
      status: present
      sha256: baebd355395ea3200d7d8edda09022c87cff74cb721eb7de340064f980aeacdd
    - path: rtl/generated/uart_csr.sv
      status: present
      sha256: c24d343d91e0ae9b8c60f510310344b849301a990cd050694a5f2fd8b920f8a8
    - path: rtl/generated/uart_csr_pkg.sv
      status: present
      sha256: 7603393306703b9d2531e2ba2c2623b8fcd326fed9563c3ce394826d34de184d
    - path: rtl/generated/uart_csr.manifest.yaml
      status: present
      sha256: e561d93b76936173373fdca7b191901b9fb44a6fbfde84820f097f9dc244daff
  findings: []
- id: G4
  status: pass
  required_checks:
  - g4.verification_assets
  - g4.smoke_report
  checks:
  - id: g4.verification_assets
    status: pass
    detail: verification features=6; smoke testcase IDs=1; req_to_test links=120;
      no source gaps; testplans=6; testbenches=1
    evidence:
    - path: model/verification.yaml
      status: present
      sha256: cd58140448b2cd62e0da014b943ae65d74ce63a7091521754059c589d081be68
    - path: trace/req_to_test.yaml
      status: present
      sha256: cc179242813ae22db587efad72305bfea902da92c597630419cde46bd9d3af56
    - path: docs/verification/agent_plan.md
      status: present
      sha256: 9bab81aa318aac9f39acfe21a34d56391342b74be4811ac44543c427a74690df
    - path: docs/verification/checker_plan.md
      status: present
      sha256: 3cccbcfa24c8a14ae7d922c7e01c846c5db4a645a2760c7d8320763471d3c37b
    - path: docs/verification/coverage_plan.md
      status: present
      sha256: 0295c444126522803c021bba6bb3dc05999852b05ea76dd23364ece1b1864473
    - path: docs/verification/feature_list.md
      status: present
      sha256: 257697acda944772aa3dcb2bb55e8a23d68b92d53297623e14543edd6a2a1c39
    - path: docs/verification/test_matrix.md
      status: present
      sha256: 5896c8ff74a0adc327b60889646d3abae2b5b7177761d9c3e068eecf7f8c1bd2
    - path: docs/verification/verification_plan.md
      status: present
      sha256: 3d6774caef802c82448fe2cbb5807b65ebdc1a9522b9cc936629ce1d10be54f3
    - path: verification/tests/smoke_tb.sv
      status: present
      sha256: 51561f8cb6a3d4d851edca26b9cfdd001add08e12e3c7c4fa4c5dfede7ee1b3f
  - id: g4.smoke_report
    status: pass
    detail: validated REPORT_META; tests=7; failures=0; errors=0; skipped=0; missing
      testcase IDs=0
    evidence:
    - path: reports/smoke/smoke_summary.md
      status: present
      sha256: 0fd103f3efe0ee7b201c03185cfad2dfb5d38572896c6b24faeba7b61b0dfee8
    - path: reports/smoke/junit.xml
      status: present
      sha256: 760549ef2e857fff6d650ff93ecb21aa2ce9490fe26763302abdb9e2caf31bc3
  findings:
  - FINDING-002
- id: G5
  status: pass
  required_checks:
  - g5.release_inputs
  checks:
  - id: g5.release_inputs
    status: pass
    detail: release inputs present=8/8; valid trace models=4/4
    evidence:
    - path: docs/integration
      status: present
    - path: docs/user_manual
      status: present
    - path: reports/quality/trace_matrix.md
      status: present
      sha256: 049bc2304ff3a35c5468ac86a24b961e6c8184658c9e3511c007bf7191c168b4
    - path: reports/quality/review_findings.yaml
      status: present
      sha256: 63ce2d0148c8e6cf91e35221574dbd15988cb13931df39f4cfccccb0ccd6d2c2
    - path: trace/req_to_hld.yaml
      status: present
      sha256: e2708e81bd9143e1860204b4789cdcf0ddd8da9da1624b5727f49530da01ec95
    - path: trace/hld_to_lld.yaml
      status: present
      sha256: 3baaaf9298e3846579d1ea60d5faaf0f39db9109cc4db20899ea112d5bb6790c
    - path: trace/lld_to_rtl.yaml
      status: present
      sha256: 6bcf7198fe53a61e664b2a074c72d88803db4db2ced21454eb5340f47c34644e
    - path: trace/req_to_test.yaml
      status: present
      sha256: cc179242813ae22db587efad72305bfea902da92c597630419cde46bd9d3af56
  findings:
  - FINDING-003
END_QUALITY_META -->
