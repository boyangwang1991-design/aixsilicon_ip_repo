# Watchdog 完整流程恢复与交付计划

执行模式：**full-flow**。用户要求完整过程交付件并跑通全流程，且明确 HLD、LLD、VPLAN
也须按各自规则重整。本任务不能以补齐 LRS 或重跑旧 UT 作为完成条件。

## 输入与初始状态

- 工作区：`aixsilicon_workflow`；repo id：`ip`；profile：`all`。
- 开工 `aix wf status` / `aix repo status ip`：main，HEAD `2fd687b61943`，clean。
- 输入：`watchdog_contract.md`，1.0.0-draft，SHA-256
  `9bbb88115193928f73fe13e899f4713a677bc4a6be1c78a5153299619769f302`。
- 旧 `reports/validation_report.md` 明确使用 direct-contract partial-task；当时没有完整
  LRS/canonical/Gate 链。因此旧 RTL/UT 保留为待核对工程资产，旧报告保留为历史证据。
- 初始 suite audit：9 个 canonical model 缺失；生成 CSR 内断言触发早期审计错误。
  断言实际位于 `ifndef SYNTHESIS` 条件内，需在 G3 核对预处理与真实工具结果；不能直接
  修改生成文件或将审计结果清零。它不是已经确认的不可综合 RTL 缺陷。

## 请求到交付件的映射

| 请求/契约交付项 | Owner | 目标路径 | 本次范围 | 当前证据/缺口 |
|---|---|---|---|---|
| requirement.md / 规范 LRS | 01 / G0 | `docs/lrs/*.md`, `model/requirements.yaml` | required | 139 条需求，G0 已按用户交接冻结；原 109 编号全覆盖，见 g0_review.md |
| 参数合同/支持矩阵 | 19-PC | `model/parameter_space.yaml`, `reports/quality/param_check.md`, `param_matrix.md` | required | 16 项完整输入含位图/结构化 DEFAULT_CFG；188 项输入检查符合预期；PV 仍待真实执行 |
| architecture.md / HLD | 03 / G1 | `docs/hld/index.md`, `00_overview.md` 至 `08_risk_checklist.md` 及主题扩展分册；5 个架构/接口/域模型 | required | 24 文件完成重整，139 条全承接，已获用户 G1 批准冻结 |
| 周期级 LLD | 05 / G2 | `docs/lld/index.md`, `00_doc_control.md`, `01_overview.md`, `02_global_constraints.md`, 每 HLD 一级模块分册, `07_delivery_mapping.md`, `99_quality_gate.md`; `model/micro_design.yaml` | required | 全文完成重整，6 模块/22 接口/97 字段/6 FSM/6 CDC，作者检查通过；待 LLD/Register Freeze |
| register.yaml / 寄存器 | 02 / G2 | `regs/watchdog.rdl`, CSR、C header、RAL、IP-XACT、`docs/generated/`、`reports/quality/register_check.md` | required/existing | 契约中的 YAML 名称映射为 SystemRDL 结构源；行为先在 LLD 冻结，派生视图重新生成核对 |
| 验证方案 VPLAN | 06 / VP0 | `docs/verification/` 六个内容卷 + index + 99_quality_gate；`model/verification.yaml` | required | 旧 verification_plan.md 不满足完整六卷及逐需求链；等待 G2 |
| RTL 与模块 UT | 07 / UT / G3 | `rtl/*.sv`, `verification/unit_test/`, `reports/quality/module_ut_summary.md` | required/existing | 冻结模型后核对实现，按当前输入重编译执行，不能补签旧证据 |
| FuseSoC / 复用依赖 | 08 | 根 `.core`, `docs/reuse_plan.md` | required/existing | 重新核对当前 CBB/VIP registry 与 depend；构建入口统一 |
| 静态/CDC/RDC/性质检查 | 09 / G3 | `reports/quality/rtl_check_summary.md`, 原始商业 EDA 报告 | required | 旧 lint 2418 warnings，CDC/RDC 未闭合；早期 audit 问题待处理 |
| dv/ 完整 UVM 1.2 | 10–13 | `verification/env`, `tc`, `th`, `coverage`, `sim`, filelists | required | 待按 VPLAN 建立真实 Agent/RM/checker/coverage/testcases；模块 UT 不替代 |
| Smoke / Full Regression | 14 | `reports/smoke/smoke_junit.xml`, `reports/regression/junit.xml`, `regression_summary.md` | required | 两层真实日志、源码/二进制/配置哈希和全 testcase 集合对账 |
| 多配置执行 | 19-PV | `reports/quality/param_execution.md` | required | STANDARD/SAFETY/SUPERVISOR + mandatory/boundary/risk/negative 实际执行 |
| 覆盖率与质量 | 15 / G4 | `reports/coverage/coverage_summary.md`, `reports/quality/review_findings.yaml` | required | 功能/代码/断言分别闭合；禁止降低门槛代替验证 |
| 追踪 RTM | 16 | 4 类 `trace/*.yaml`, `reports/quality/trace_matrix.md` | required | 先 static precheck，再按 regression → coverage → RTM closure 链重建 |
| user_guide / 集成与用户手册 | 17 | `docs/integration/`, `docs/user_manual/` | required | 分别整理接口/tie-off/CDC/约束及配置/服务/错误流程，旧短指南只保留入口 |
| safety_manual / constraints | 17 / 09 / 20 | `docs/safety_manual.md`, `constraints/`, 安全原始证据 | required/existing | 故障模型、检测时限、共因、注入、网表冗余检查和系统假设 |
| 软件驱动及演示 | 07 / 13 / 17 | `sw/`, 可执行软件 proof | required/existing | 核对新冻结行为并实测契约 §19.3 演示场景 |
| PPA 表征 | 20 / G5 | `scripts/ppa/`, `model/pdk.yaml`, `evidence/ppa/` | required | 三产品配置实际工艺/库/时钟/活动假设，禁止用 generic elaborate 代替 |
| 最终验证报告 / 发布打包 | 15 / 18 / G5 | `model/quality.yaml`, `reports/quality/gate_report.md`, `release/` | required | 真实 G0–G5 与源码身份满足后打包；当前不能发布 |
| 可选行为探索模型 | 04 | 按 HLD 需要定义 | optional | 不作为验证/发布证据 |
| 独立拓扑生成器 | gen-adapter | 不适用 | out-of-scope | 本 IP 为普通参数化 SV；仍完整执行 19-PC/PV 与寄存器生成 |

## 文档重整验收

- **HLD**：L1 模块责任、外部/内部接口、控制/数据流、域与 CDC/RDC 策略、寄存器组及
  激活/保护模型、时限预算、参数影响、安全独立性、DFX、决策/风险与 LLD 工作包。
  不在 HLD 固化 RTL 文件、procedural 结构、FSM 编码或 bit/offset 表。
- **LLD**：每 HLD 一级模块按实际对象分册；完整状态/转移/非法态、候选年龄及优先级、
  位宽/饱和/反压、复位交错、邮箱取消/最多一次、暂停/恢复、寄存器 SW/HW collision、
  PPA 取舍和 RTL_MAP。不得以“遵循契约”替代设计。
- **VPLAN**：六卷为 verification_plan、feature_list、test_matrix、checker_plan、
  coverage_plan、agent_plan。主方案覆盖完整必需章节；需求逐条映射 TC→FL→LRS；
  每个 TC 有独立 oracle、激励、预期、timeout/seed/tier/config/implementation。
  分清 Module UT、UVM Smoke、全量回归；闭合功能交叉、代码、断言及参数空间。
- 三阶段均采用中文正文、顶层平铺语义分册、独立 index、唯一文档头与阶段 Gate META；
  每写一册运行 owner extractor，全目录核对 ID/引用/来源。超过 450 行或 20 META
  必须拆分；达到 300 行或 12 META 先评估。Gate/freeze 记录真实评审状态。

## 当前交接条件

G0/PC 已完成；G1 已据用户明确批准冻结。LLD 和寄存器行为已完成可审阅正文及作者
检查，原生APB4 CSR候选已生成并通过VCS编译。05/02要求真实LLD/Register Freeze
后进行正式再生；当前G2仍open。其后按VPLAN/VP0→实现与G3→完整验证/G4→
文档/PPA/G5→打包推进，后续交付仍全部required，不能以本阶段文档检查代替。

## 运行环境说明

根 uv Python 3.11.13，预检所有寄存器 exporter/FuseSoC/pytest/matplotlib 可用；
VCS、URG、SpyGlass、DC 路径可用，vcformal 不在 PATH。路径存在不等同于许可证与
全部能力可用，真正 EDA 阶段仍须实跑取证。
沙箱中 uv 子进程已退出但未被回收，导致无法取得退出码；同一根环境在沙箱外的
只读 probe 正常退出，后续 uv 检查按该方式执行。未使用系统 Python 或新增虚拟环境。
