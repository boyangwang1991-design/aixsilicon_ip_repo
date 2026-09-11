# Watchdog 周期级设计：文档控制

<!-- LLD_DOC_META
schema_version: '2.0'
ip_name: watchdog
delivery_model: parameterized
lrs_baseline: watchdog-contract-1.0.0-full-flow-r1
hld_baseline: watchdog-hld-1.0.0-full-flow-r1
document_version: 1.0.0
status: reviewed
microarchitecture_baseline: watchdog-lld-1.0.0-full-flow-r1
END_LLD_DOC_META -->

本次将原 partial 实现笔记重整为可抽取、可评审的周期级设计。G0/G1 已获用户交接，
本阶段设计基线按用户持续授权冻结；技术门禁另以实际生成和检查证据判断。
本文定义 HOW，不把既有 RTL 当作上游事实源，不包含 testcase/coverage 实现。
结构输入为 regs/watchdog.rdl；地址/位段/access/reset 数值只以 RDL 为源。
基线输入身份见 reports/full_flow/g1_approved_snapshot.json 与 g1_approval.md。
