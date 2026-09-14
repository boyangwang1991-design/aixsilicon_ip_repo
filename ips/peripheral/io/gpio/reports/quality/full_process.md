# GPIO 全流程动作与技术条件

用户授权本次无需额外人工审核，并允许 CDC/RDC 缺失许可证时继续；G3 标记 PASS WITH CONDITION。此次已实际执行 G4/G5 后续动作，不以改 Gate 标签替代执行。

| 动作 | 本次结果 | 证据 |
|---|---|---|
| G0/G1/G2 规格、架构、LLD/RDL | PASS，258 需求、12 模块、753 寄存器实例 | gate_report.md |
| RTL 修复 | 实际修复 APB 长 Setup 下 CSR 提前完成导致的字节写入错误；原生 passthrough CSR，Access 阶段发请求 | ../../docs/lld/03_gpio_apb_if.md |
| Module UT | 13/13 PASS | module_ut_summary.md |
| RTL lint/elab/synth | elab 与真实 DC synth 通过；lint 0 error、2 warning 保留 | rtl_check_summary.md |
| CDC/RDC | 用户授权 SKIPPED，许可证恢复后重跑 | ../signoff/cdc.yaml、rdc.yaml |
| 低功耗/AON 专项 | 实际仿真 PASS | ../signoff/low_power.yaml |
| UVM/Agent/Env/RM/RAL | 已实现并编译、运行；全 RAL race/副作用闭环待补 | ral_handoff.yaml |
| 全量 testcase 执行 | 14 动态 TC × 3 seeds = 42/42 PASS；1 静态 TC PASS | ../regression/campaign.json |
| 参数硬件验证 | 7 配置/8 执行 PASS，剩余参数组合未闭合 | param_execution.md |
| 覆盖率合并与分析 | URG 完成，原 100% 目标未降低；代码和全 feature 覆盖未闭合 | ../coverage/coverage_summary.md |
| 最终 RTM | 15 TC 全有通过证据，需求/设计链接零缺口 | trace_matrix.md |
| Formal | 实际启动并构建模型，FPV 许可证等待，证明 0 完成 | ../signoff/formal.yaml |
| 集成与用户文档 | 指南、32 端口检查表、编程手册及委托评审完成 | integration_review.md、user_guide_review.md |
| PPA | 8/32/128 位三点实际综合、分析及图完成，E1 | ../ppa-report.md |
| 交付打包 | 条件 candidate 包；逐成员哈希验证见 gpio_0.1.0_candidate_package_report.md | ../../release/ |

G4 的执行覆盖和技术签核分别记录：15/15 TC 有通过结果并不等于 258 条需求全部完成覆盖证明。严格 Gate 的 fail/blocked 保留，条件交付不冒充无条件量产签核。已知条件统一列入 review_findings.yaml 和交付 release_note.md。

实际实现的 UVM 组件以根 Core 的 uvm fileset 与 verification/sim/Makefile 为运行入口；仓内保留但未纳入编译的原始模板不作为已实现或已验证证据。未发布 Catalog、未推送远端。
