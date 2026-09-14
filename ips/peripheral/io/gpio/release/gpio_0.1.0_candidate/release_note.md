> ⚠️ **CANDIDATE RELEASE — NOT QUALIFIED.** 本包为候选交付物，未经正式质量认证，不得表述为已发布产物。

# GPIO 0.1.0 Release Note

- IP: gpio
- 版本: 0.1.0
- 发布类别: candidate
- EDA profile: commercial-systemverilog
- 源码来源: commit 966bdeb83e5b (main)
- 交付文件数: 610
- G5 状态: blocked

## Gate 状态与交付条件

- G0: pass
- G1: pass
- G2: pass
- G3: pass_with_condition
- G4: fail
- G5: blocked

- G3 / g3.rtl_check_report [fail]: report status is fail
- G3 / g3.special_signoff [skipped]: cdc: skipped (user-authorized license skip; signoff remains unverified); rdc: skipped (user-authorized license skip; signoff remains unverified); low_power: pass (validated)
- G4 / g4.coverage_closure [fail]: report status is fail
- G4 / g4.parameter_execution [fail]: report status is fail
- G4 / g4.special_signoff [fail]: formal: fail (formal: invalid signoff identity)
- G4 / g4.ral_handoff [fail]: RAL handoff missing or not passed
- G5 / g5.ppa_signoff [fail]: policy=required; invalid PPA summary schema/level
- G3 / g3.rtl_check_report [fail]: report status is fail
- G3 / g3.special_signoff [skipped]: cdc: skipped (user-authorized license skip; signoff remains unverified); rdc: skipped (user-authorized license skip; signoff remains unverified); low_power: pass (validated)
- G3 / user_authorization [conditional]: G3也标记为PASS with condition，毕竟CDC LICENCE 缺失也不是现在能搞定的，先完成完整流程

全部技术子检查与已知发现见包内 reports/quality/gate_report.md、review_findings.yaml；带条件继续不等于无条件技术签核。
