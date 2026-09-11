# Watchdog full-flow 当前执行结果

**G0/G1 已获用户批准；PC、HLD、LLD 重整及作者检查完成，G2 等待 LLD/Register Freeze。**
用户要求的全流程尚未完成，六卷 VPLAN、RTL 修复、UVM/CDC/RDC/覆盖率/参数执行、
真实 PPA 及最终发布仍全部 required，没有缩减成 partial-task。

| 实际执行 | 结果 | 证据 |
|---|---|---|
| G1批准对象哈希核验及登记 | 用户明确回复 approve, complete the rest；逐项核对批准前源哈希后登记，未改变架构语义 | g1_approved_snapshot.json、g1_approval.md、g1_handoff.log、g2_hld_status_*.log |
| PC完整参数输入 | 16项输入，188/188合法/非法配置检查符合预期；未冒充PV执行 | ../quality/param_semantic_check.json |
| 已冻结HLD当前检查 | 引用/模型一致性通过，批准证据存在 | g2_hld_check.log、../quality/hld_check.json |
| LLD逐册owner抽取 | 全目录形成micro_design.yaml；旧implementation笔记保留历史 | lld_extraction.log、../../docs/lld/index.md |
| LLD作者检查 | 139需求/6模块/22接口/97字段/6 FSM/6 CDC，167对象及RTL映射闭合；分册均低于阈值 | g2_lld_check.log、../quality/lld_check.json |
| APB4 CSR候选生成 | PeakRDL apb4-flat成功，原生地址15位/数据32位；产物仅在build/g2_csr_candidate | ../quality/register_candidate_check.md、build内manifest |
| 候选CSR商业编译 | VCS vlogan exit0；工具身份、源/输出/日志SHA由owner工具记录 | g2_csr_candidate_compile.log、g2_csr_candidate_lint.log、g2_csr_candidate_publish.log |
| 全套件回归 | 165 passed，1默认skip；该商业测试随后单独1 passed | g2_suite_tests.log、g2_suite_vcs_test.log |
| suite结构校验 | 24 skills，0 errors / 0 warnings | g2_suite_validation.log |
| 检查器反例 | 错RDL字段/过期投影、上游未冻结、未知HLD引用全部正确拒绝 | g2_lld_checker_negative_tests.json |
| 工作区检查 | make check exit0，125测试通过；pre-commit全通过 | g2_workflow_check.log、g2_workflow_precommit.log |
| 机器质量门禁 | exit2：G0/G1 pass，G2 fail，G3–G5 blocked | g2_machine_gates.log、../quality/gate_report.md |

G2机器检查确认模块承接、子对象、FSM、寄存器行为均无缺口；失败项是正式路径下的
CSR manifest和register_check尚未形成。build候选的编译pass不能替代正式发布证据，
更不能代填真实LLD冻结。冻结后必须同时更新正式package/module/adapter，再生成
Header/HTML/IP-XACT/RAL并核对同源身份；不可混用原passthrough与新APB4接口产物。

## 必须修复的旧实现差异

- 完整服务资格/refresh缺少独立复核，现有保护只复制KEY1比较。
- 最终请求直接来自普通q.final_req，需按LLD增加独立final_hold及综合网表证明。
- 取消抢占需屏蔽CBB请求，组合轮询模式不会按grant_ack停住指针。
- 运行COMMIT结果优先级和正式APB4适配须按新LLD对齐。

差异已在LLD规定实现方案，不将旧RTL/UT结果签到新设计。当前未重跑完整IP RTL回归。
商业寄存器测试验证W1C/字节写/碰撞/非零复位语义，属于工具回归，不是watchdog全IP验证。

## 当前交接

[LLD／寄存器冻结评审包](g2_review_package.md)已提供正文、作者检查和实际编译证据。
05/02要求真实冻结后正式生成；本次等待该结论，后续G2技术检查失败仍须修复。
之后按VPLAN/VP0→RTL与UT/G3→UVM/回归/PV/覆盖率/RTM/G4→文档/PPA/G5继续。

完整命令和退出码见g2_execution.json与原始日志；项目检查脚本在scripts/check_hld.py、
check_lld.py、check_parameter_plan.py，可使用根uv环境复现，不依赖私有skill运行时。
根工作区仍clean；IP与skills保留已授权修改，未提交、推送或发布。
