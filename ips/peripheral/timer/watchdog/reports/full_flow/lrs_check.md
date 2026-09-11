# Watchdog LRS 作者检查报告

基线：`watchdog-contract-1.0.0-full-flow-r1`。共 139 条规范需求、35 个 Markdown 分册（含索引/Gate），覆盖全部 109 个原编号。

这是作者与确定性检查结果，**不是独立需求评审或 G0 冻结**。当前 G0 open / requirement_freeze=false。

| 检查 | 结果 |
|---|---|
| source_unchanged | PASS |
| single_document_head | PASS |
| single_open_gate | PASS |
| draft_status | PASS |
| unique_canonical_ids | PASS |
| nonempty_verifiable_requirements | PASS |
| no_meta_in_prose | PASS |
| all_109_source_ids_mapped | PASS |
| no_unknown_source_ids | PASS |
| all_applicable_categories | PASS |
| generator_explicit_na | PASS |
| required_ppa_and_registers | PASS |
| within_hard_split_limits | PASS |
| index_navigation_only | PASS |
| local_links_resolve | PASS |

## 语义整理与审查边界

- 原 109 项需求逐项保留来源和可判断验收边界；补入未编号参数、配置档、端口、寄存器能力、性能、权限和交付约束。
- TIM/PAR/STA/SRV/SUP/CFG/FLT/ESC/REC/PWR/BUS/CDC/SNP/RST/SAF/TST/DIA/REG/NFR/VER 逐族审读；独立评审仍须核对描述与验收是否足够原子、无歧义及完整继承所有表格细节。
- LRS 保留可观察的年龄/状态/事务语义；SAF 保护实现、CDC 电路组织、时钟具体实现交 HLD/LLD；寄存器位表仍以原来源与后续 RDL 核对。
- 参数默认/合法域来自原 §3.2；三个代表产品配置来自现有 configs 输入。位图与结构化 DEFAULT_CFG 已有独立需求，19-PC 必须承接类型/依赖，不能只抽 12 个标量后声称参数合同完整。
- 新 LRS 正文为中文，源 ID/协议/标识符原样保留；不存在虚构评审人、PASS 或签名。
- 机器检查不判断自然语言语义、需求原子性、参数复杂表达可执行性或电路正确性；这些不能由结构检查 PASS 替代。

## 分册评估

| 文件 | 行数 | META 数 |
|---|---:|---:|
| docs/lrs/00_overview.md | 51 | 1 |
| docs/lrs/01_configuration_parameters_1.md | 234 | 12 |
| docs/lrs/01_configuration_parameters_2.md | 232 | 12 |
| docs/lrs/01_configuration_profiles.md | 257 | 10 |
| docs/lrs/01_configuration_rules.md | 76 | 3 |
| docs/lrs/02_interface_apb.md | 76 | 3 |
| docs/lrs/02_interface_contract.md | 49 | 1 |
| docs/lrs/02_interface_rules.md | 100 | 4 |
| docs/lrs/02_interface_transactions.md | 134 | 5 |
| docs/lrs/03_functional_escalation.md | 76 | 3 |
| docs/lrs/03_functional_fault_policy.md | 52 | 2 |
| docs/lrs/03_functional_recovery.md | 124 | 5 |
| docs/lrs/03_functional_service_1.md | 124 | 5 |
| docs/lrs/03_functional_service_2.md | 148 | 6 |
| docs/lrs/03_functional_start.md | 124 | 5 |
| docs/lrs/03_functional_supervision_1.md | 124 | 5 |
| docs/lrs/03_functional_supervision_2.md | 124 | 5 |
| docs/lrs/03_functional_timing.md | 159 | 6 |
| docs/lrs/04_register_capabilities.md | 80 | 3 |
| docs/lrs/04_register_configuration.md | 172 | 7 |
| docs/lrs/04_register_snapshot.md | 76 | 3 |
| docs/lrs/04_register_validation.md | 111 | 4 |
| docs/lrs/05_performance.md | 77 | 3 |
| docs/lrs/06_clock_reset.md | 108 | 4 |
| docs/lrs/07_low_power.md | 124 | 5 |
| docs/lrs/08_safety.md | 160 | 6 |
| docs/lrs/09_security.md | 53 | 2 |
| docs/lrs/10_dfx.md | 124 | 5 |
| docs/lrs/10_dfx_diagnostics.md | 148 | 6 |
| docs/lrs/11_generator.md | 6 | 0 |
| docs/lrs/12_constraints.md | 160 | 6 |
| docs/lrs/12_constraints_acceptance.md | 160 | 6 |
| docs/lrs/12_constraints_delivery.md | 53 | 2 |
| docs/lrs/99_quality_gate.md | 14 | 1 |
| docs/lrs/index.md | 41 | 0 |

参数分册每册 6 个参数（LRS+PARAM 共 12 META），按基础尺寸/增强能力两个语义组分开；未达硬上限，保留一组以便对照。其余分册按服务/监督语义进一步拆分。

## 可复核证据

owner extractor 每次分册修改后的原始输出见 `lrs_extraction.log`；本次文件集合、SHA-256 和大小见 `lrs_check.json`。任一文件变化后须重跑检查，旧基线不能用于冻结新内容。
