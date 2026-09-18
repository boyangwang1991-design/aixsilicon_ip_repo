# PQC 验证方案索引

## 主方案与实施

- [范围、环境、回归与验收](verification_plan.md)
- [UVM加冻结KAT的落地顺序](implementation_plan.md)
- [参数与配置执行计划](configuration_plan.md)

## 六类内容卷

- 功能：[配置/命令/接口](feature_list.md)、[算法/性能](feature_list_algorithm.md)、[安全/生命周期](feature_list_security.md)
- 测试：[控制/配置](test_matrix.md)、[完整算法](test_matrix_algorithm.md)、[安全/生命周期](test_matrix_security.md)
- [比对器、冻结向量与独立期望](checker_plan.md)
- 覆盖：[接口/结构](coverage_plan.md)、[算法/安全集成](coverage_plan_algorithm.md)
- [Agent复用与TLM连接](agent_plan.md)
- 主方案见上；断言补充：[协议/复位](assertion_plan.md)、[安全](assertion_plan_security.md)、[数据通路](assertion_plan_datapath.md)

## 门禁与结论

- [唯一VP0计划门禁](99_quality_gate.md)
- [唯一执行总报告](../../reports/report.md)

本索引仅导航。Markdown为编辑入口，model/verification.yaml与trace由工具生成。

- [首条Encaps测试](test_matrix_encaps.md)
- [Decaps正常/拒绝与背压集成测试](test_matrix_decaps.md)

- [KeyGen和托管增量](test_matrix_keygen.md)

- [ML-DSA Verify 集成增量](test_matrix_dsa_verify.md)

- [DSA KeyGen 集成增量](test_matrix_dsa_keygen.md)

- [DSA Sign 集成增量](test_matrix_dsa_sign.md)
