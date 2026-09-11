# AIXSILICON Watchdog

当前按 **ip-development-suite full-flow** 恢复完整过程交付。原
[输入契约](watchdog_contract.md) 保留；既有 RTL/UT 是待与冻结设计核对的候选工程。
本 IP 尚未完成全流程或正式发布。

- [规范 LRS 索引](docs/lrs/index.md)：139 条需求，reviewed / G0 pass；[用户交接记录](reports/full_flow/g0_review.md)。
- [参数支持矩阵](reports/quality/param_matrix.md)：16 项完整参数；[188 项输入检查](reports/quality/param_semantic_check.md)符合预期，尚非 RTL 多配置执行。
- [重整 HLD 索引](docs/hld/index.md)：24 个文件、6 个 L1 模块；G1 已获用户批准冻结，见[批准记录](reports/full_flow/g1_approval.md)。
- [完整 LLD 索引](docs/lld/index.md)：139 条需求、22 接口、97 寄存器字段均承接；G2 已按[持续授权](reports/full_flow/continuation_authorization.md)完成检查并冻结。
- [完整 VPLAN 索引](docs/verification/index.md)：74 份分册、20 项 feature、20 个 TC、12 项断言，覆盖全部 139 条需求并关联 188 个参数配置；VP0 已检查冻结。
- [全流程交付计划](reports/full_flow/plan.md)：包含 HLD、LLD、VPLAN 全面重整及验证/打包链。
- [LRS 来源映射](reports/full_flow/source_mapping.md) / [作者检查](reports/full_flow/lrs_check.md)。
- [既有 HLD/LLD/VPLAN 内容审查](reports/full_flow/document_review.md)：历史缺口记录；三阶段文档现已重整。
- [当前执行进度与证据](reports/full_flow/current_progress.md) / [早期执行记录](reports/full_flow/execution_results.md) / [LLD 与寄存器冻结评审包](reports/full_flow/g2_review_package.md)。
- [当前机器门禁报告](reports/quality/gate_report.md)：结构检查不代替真实需求/设计冻结。
- [RTL top](rtl/watchdog_top.sv) / [channel core](rtl/watchdog_channel.sv)。
- [SystemRDL](regs/watchdog.rdl) 及派生 CSR/Header/IP-XACT/RAL。
- [原使用说明](docs/user_guide.md) / [安全说明](docs/safety_manual.md)。
- [历史 partial-task 验证结果](reports/validation_report.md)：保留当时实际范围，不作为 full-flow 完成声明。

历史模块测试入口为 `bash verification/unit_test/run_ut.sh`，寄存器和封装再生成入口为
`bash scripts/regenerate.sh`。均需使用 workflow 根 uv 环境及商业 EDA；中间产物进入
`build/`。恢复执行前先检查阶段输入、模型和技术冻结，重新编译并绑定当前源码证据。
真实 UVM 入口为 `verification/sim/Makefile`：设置 `UV_PROJECT` 为 workflow 根后执行
`make TEST=tc_bus SEED=1`。运行器检查源码、依赖、参数和二进制身份，证据写入
`reports/uvm/<run>/manifest.json`；失败和超时返回非零，不以仿真进程退出零替代通过。
模块测试通过不能替代 CDC/RDC、UVM 集成、功能交叉覆盖、物理冗余、PPA 或发布门禁。
