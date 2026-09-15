# Watchdog 统一设计与验证结论

G0–G2 已通过，G3 已获带条件继续授权；G4/G5 尚未闭合，当前不能正式发布。

本轮按 ip-development-suite full-flow 恢复并执行现有 APB 看门狗工程，候选包身份为
`aixsilicon:ip:watchdog:1.0.0`。本报告只以本轮实测作为完成依据；保留原契约和审批，
未改变本轮起点的 RTL 外部接口与行为，未提升 registry 的规划状态。

## 交付范围与实测结果

| 内容 | 入口 | 本轮结果 |
|---|---|---|
| 需求、架构、微架构 | [LRS](../docs/lrs/index.md)、[HLD](../docs/hld/index.md)、[LLD](../docs/lld/index.md) | 139 条需求、16 参数、6 模块、22 接口、167 微设计对象和97寄存器字段完成重新抽取及当前输入评审 |
| 寄存器与 RTL | [SystemRDL](../regs/watchdog.rdl)、[顶层](../rtl/watchdog_top.sv)、根 FuseSoC Core | 原生 CSR 实际编译通过，RDL/生成输出来源一致；最终源码 elaboration 通过 |
| 模块测试 | verification/unit_test/run_ut.sh | 32/48/64-bit channel 与两组 APB/WDT 时钟配置全部通过；5配置、3800次检查；2个UT覆盖4个本地RTL模块 |
| UVM | [VPLAN](../docs/verification/index.md)、verification/sim/Makefile | 225/225项执行通过、0失败；运行前后输入哈希与编译产物身份一致 |
| 参数矩阵 | scripts/run_parameter_verification.py | 188/188项已执行：178合法配置编译及能力/复位默认值读回通过，10非法配置按预期在Schema层拒绝 |
| 追踪与静态验收 | build/reports/quality/trace_matrix.md | 四类静态链接为253/6/6/221，无静态链接缺口；20个规范TC均有执行记录，18通过、CONFIG/DELIVERY两项失败 |
| 软件和文档 | [集成指南](../docs/integration/watchdog_integration_guide.md)、[用户指南](../docs/user_manual/watchdog_user_guide.md)、[寄存器编程指南](../docs/user_manual/watchdog_register_programming_guide.md)、[集成检查表](../docs/integration/watchdog_integration_checklist.xlsx) | C11驱动测试通过；中文文档及实际评审通过，接收方检查表未代填签字 |
| PPA | [PPA专报](ppa/ppa_report.md) | 真实28nm库可用；两次综合内存失败、一次超时，本轮无合格测量点 |

178项参数读回不是178项完整功能回归。原始矩阵中25项计划sim的实际检查同样限于
能力与复位值；**178项lint、25项formal、4项synth仍未执行**，其余运行时行为与产品
功能闭合也不能由读回替代。因此参数总签核与 CONFIG 静态TC仍为 fail。
DELIVERY 静态TC中的驱动、生成视图和文档存在性检查通过，但技术签核和 PPA 条件失败。

工具版本：VCS W-2024.09-SP1_Full64、SpyGlass X-2025.06、DC V-2023.12-SP3、
URG W-2024.09-SP1、GCC 8.5.0。C驱动检查使用 -Wall -Wextra -Werror。
CBB/APB VIP 仍由资产仓依赖提供；APB VIP 的 developing 状态未被本IP回归提升为全局资格通过。

## 门禁

| Gate | 状态 | 当前依据 |
|---|---|---|
| G0 | pass | LRS当前投影、输入绑定评审和需求结构有效 |
| G1 | pass | HLD当前投影、需求承接和评审有效 |
| G2 | pass | LLD/寄存器冻结、CSR真实编译及来源一致性有效 |
| G3 | pass_with_condition | Module UT与CSR通过；lint/综合/formal未签核，CDC/RDC为许可证原因skipped |
| G4 | fail | smoke子检查通过；全量规范TC含两项静态失败，覆盖率、参数签核和RAL交接未闭合，最终RTM失败 |
| G5 | blocked | 依赖G4；集成/用户文档评审通过，PPA未通过 |

用户对G3带条件继续问题回复原文 `continue`，记录见
[授权原文](../docs/reviews/g3_conditional_continuation.md)。该授权允许继续流程，
不降低覆盖率目标，不关闭技术缺口，也不授权正式发布；technical_signoff_complete仍为false。

## UVM 与覆盖率

四种配置为 STANDARD、SAFETY、SUPERVISOR、CFG_RISK_DIAG，共18个动态UVM用例。
每配置运行seed 1/17/101，CDC扩展增加1009/65537，加上先行smoke，共225项。
单独的smoke及其原始日志通过；这与CONFIG/DELIVERY两项静态验收失败分别记录。

下表是各配置 **watchdog_harness.dut** 的URG实测百分比，各项VPLAN目标均为95%。
不同结构分别统计，没有混合分母，没有新增排除项、豁免或降低门槛。

| 配置 | line | condition | toggle | FSM | branch |
|---|---:|---:|---:|---:|---:|
| STANDARD | 27.79 | 54.82 | 40.53 | 10.98 | 62.10 |
| SAFETY | 27.97 | 55.04 | 40.53 | 10.98 | 62.37 |
| SUPERVISOR | 30.00 | 53.82 | 31.82 | 6.06 | 60.76 |
| RISK_DIAG | 28.37 | 55.36 | 41.93 | 11.74 | 62.67 |

现有watchdog_fcov三类通用coverpoint均为23/26（88.46%）；包含环境/VIP的全部
covergroup汇总为72/111（64.86%）。两者都不代表VPLAN mandatory bins/关键cross
已实现或闭合，计划到实现的完整映射仍缺失。
URG四组初次运行均因libsnpsmalloc崩溃；仅对重试进程设置VCS_USE_MALLOC=1后成功。
初次失败、重试、设计数据库与运行数据库的身份及原始分子/分母全部本地保留。

## 统一问题追踪

| ID | 问题与影响 | owner | 状态 | 下一步 |
|---|---|---|---|---|
| WDT-LINT-001 | 0 Fatal/0 Error但2412 Warning；FuseSoC返回失败，不能签核 | RTL/09 | open | 依据原始规则、实例和信号逐项修复或审查，禁止整体屏蔽 |
| WDT-CDC-001 | cdc_adv_checker缺失，高级CDC未执行 | 环境/09 | open | 许可证可用后重跑届时源码；当前仅为授权skipped |
| WDT-RDC-001 | cdc_adv_checker/rdc_adv_checker缺失，复位跨域未签核 | 环境/09 | open | 恢复许可证并重跑，不以仿真替代 |
| WDT-FORMAL-001 | 证明引擎退出4，无properties.rpt与性质结果 | 形式验证/环境 | open | 恢复证明引擎及所需能力后重跑12项性质；不把退出失败解释为反例或证明通过 |
| WDT-SYNTH-001 | 两次compile_ultra报OPT-1603，classic运行1800秒超时，无有效综合网表 | 综合/PPA | open | 解决资源与优化问题，保留安全冗余约束，重跑三产品真实工艺表征 |
| WDT-COV-001 | 各项DUT代码覆盖率低于95%；必需功能bins/cross和断言闭合不足 | 验证/15 | open | 按未命中路径补充测试和覆盖实现，再检查完整VPLAN映射 |
| WDT-PV-001 | 编译/读回通过，仍缺独立lint/formal/synth与完整参数功能验收 | 参数验证/19 | open | 为计划方法取得逐配置真实证据，不将读回等同于功能签核 |
| WDT-RAL-001 | 现有RAL已编译并接入UVM，缺规范生成来源manifest与访问场景交接证明 | 寄存器/验证 | open | 补齐owner provenance及access/reset/mirror/byte-enable/side-effect/race证明 |
| WDT-FLOW-001 | G4/G5与CONFIG/DELIVERY静态验收仍未闭合 | 流程维护 | open | 关闭上述责任项后重跑规范TC、覆盖率、RTM和门禁，满足条件后才正式发布 |
| WDT-LOG-001 | 原FuseSoC静默输出不能形成完整执行记录 | 工具维护 | closed | 已启用完整输出，并以当前elaboration、UT和UVM实际复验 |
| WDT-SMOKE-001 | 原工具将全量摘要失败联动成smoke失败 | suite/质量工具 | closed | 已独立判定smoke；全量失败与证据篡改反例测试通过 |

lint明细为W415a 851、W528 1548、W240 5、两类STARC合计4、SYNTH_5064 4；未制作全局waiver。
套件最终回归294项：292通过、2跳过；本地执行身份与覆盖率解析测试7/7通过。
工作区审计及24个Skill结构校验均为0 error/0 warning。

## 复现与候选交付

从workflow根的唯一uv环境执行，先将UV_PROJECT设为workflow根，并在IP工作区运行。
主要入口如下；保留工具的失败退出码，AI读取结果后维护本报告及METADATA。

| 阶段 | 复现入口 |
|---|---|
| 设计模型 | uv run --no-sync python scripts/refresh_design.py --stage lrs（同样适用hld/lld/vplan） |
| RTL检查 | uv run --no-sync python scripts/run_rtl_checks.py lint（同样适用elab/synth/cdc/rdc/formal） |
| 模块测试 | bash verification/unit_test/run_ut.sh |
| UVM全量 | make -C verification/sim regress |
| 参数执行 | make -C verification/sim parameters |
| 参数机读汇总 | scripts/summarize_parameters.py --manifest 后接本轮build/reports/parameters中的manifest.json，使用uv run python执行 |
| 覆盖率 | scripts/collect_coverage.py --regression-manifest 后接本轮完整回归manifest；scripts/summarize_coverage.py --coverage-manifest 后接本轮coverage manifest |
| 软件/静态交付 | make -C verification/sim delivery |
| 规范证据、RTM、门禁 | suite的build_verification_evidence.py → build_trace.py --phase closure → evaluate_quality.py；均消费本次原始结果 |
| AI结论抽取 | suite的extract_report.py --workspace . --ip-name watchdog；PPA加--report-type ppa |

本轮关键run-id：UVM `20260914T103319502494`，覆盖率 `20260914T113827687991`，
参数矩阵 `20260914T113901205256`，CONFIG/DELIVERY静态证明 `20260914T113900`。
原始结果只在build中；新clone必须重跑，报告抽取verified=true不等于技术门禁通过。
已完成的参数编译缓存按本地恢复索引备份清理，原始日志、配置和执行清单仍留在build/reports。

候选交付路径为 `release/watchdog_1.0.0_candidate.zip`，仅供未签核版本审查与后续验证。
归档逐成员校验记录位于 `build/reports/release/watchdog_1.0.0_candidate_package_report.md`，
不进入交付包。包中保留.gitignore；build/与release/均被忽略。
报告白名单只有本报告和PPA专报，本轮没有PPA最终图。

380份旧过程材料（含旧model/quality.yaml）已归档到build/legacy_reports/20260914T071652，
取消跟踪其中70个遗留机器文件；已存在的其他IP清理改动保留。审批原文仍在docs/reviews。
未提交、推送Git或发布到GitHub；未变更资产登记成熟度，也未生成正式签核声明。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ip_summary
ip_name: watchdog
status: blocked
conclusion: G0–G2 已通过，G3 已获带条件继续授权；G4/G5 尚未闭合，当前不能正式发布。
gates:
  G0: pass
  G1: pass
  G2: pass
  G3: pass_with_condition
  G4: fail
  G5: blocked
findings:
- id: WDT-LINT-001
  status: open
  summary: 2412 条 lint warning 尚未关闭
  next_action: 按原始规则与路径逐项处置
- id: WDT-CDC-001
  status: open
  summary: CDC 高级许可证缺失
  next_action: 恢复 cdc_adv_checker 后重跑
- id: WDT-RDC-001
  status: open
  summary: RDC 高级许可证缺失
  next_action: 恢复 cdc_adv_checker/rdc_adv_checker 后重跑
- id: WDT-FORMAL-001
  status: open
  summary: 证明引擎退出4且没有性质结果
  next_action: 恢复 FPV 能力并重跑
- id: WDT-LOG-001
  status: closed
  summary: 完整日志采集已修复，elaboration 重跑通过
  next_action: 已复验，后续保持真实工具输出
- id: WDT-FLOW-001
  status: open
  summary: G4/G5 未闭合
  next_action: 关闭责任项后重跑规范TC、覆盖率、RTM和门禁
- id: WDT-SYNTH-001
  status: open
  summary: 两次综合内存失败及一次超时，无有效综合网表
  next_action: 解决资源与优化问题后重跑真实工艺综合
- id: WDT-COV-001
  status: open
  summary: DUT代码覆盖率低于95%，VPLAN必需功能覆盖和断言闭合不足
  next_action: 补充未命中路径测试与必需bins/cross，按配置重新测量
- id: WDT-PV-001
  status: open
  summary: 参数矩阵需要逐配置工具签核；能力/复位值读回不能代替计划的lint/formal/synth及产品功能回归
  next_action: 按报告中的逐项处置执行
- id: WDT-RAL-001
  status: open
  summary: RAL 来源清单与交接证明未闭合
  next_action: 补齐 owning RAL provenance 与访问场景证明
- id: WDT-SMOKE-001
  status: closed
  summary: smoke被全量回归失败联动误判的问题已修复
  next_action: 已通过独立状态判定与哈希篡改反例回归
evidence:
- path: build/reports/quality/quality.yaml
  sha256: 13383f24e296f023036938ac371ca0968bca12359d451ef2a6cd4fb0d987f327
- path: build/reports/quality/module_ut_summary.md
  sha256: 4da4b1a37d87b9ee6d8d991b9e62ce8b94d9461b70e73df78f8f28e3cd8ae494
- path: build/reports/rtl/20260914T124004848366/execution.json
  sha256: 2f512d7e19469857f5f16dbca935eb480ba174cf29a0fa109f0f8e131b83b963
- path: build/reports/regression/20260914T103319502494/manifest.json
  sha256: b1f888445708ffe9354aa57ce075c3dc7c8fcb654a7972d297ca128c4d917fa6
- path: build/reports/regression/regression_summary.md
  sha256: 2626da6f046ced62c0e8798a587d536ce10e9b6beb82627ea98059cca36cc170
- path: build/reports/regression/junit.xml
  sha256: eced9fb6d1338315b287a47bdf7ecb90ae994af6d698fc41708a45320453977f
- path: build/reports/smoke/smoke_junit.xml
  sha256: 388dd0421cf57d90973b5694514f20b591f10b2b96bfe11837e94f2cf7be6527
- path: build/reports/coverage/20260914T113827687991/manifest.json
  sha256: afc636b83f8011bb5481dee85a9d719d8bf1f29abcba708e6d08486ddf4e109e
- path: build/reports/coverage/coverage_summary.md
  sha256: ad5cb0c287ae068fc779df4f5ea0f5bf7715fc0341b1926b56c88af74f337d39
- path: build/reports/parameters/20260914T113901205256/manifest.json
  sha256: 9fa6f83dfada1a66f5e4999c409942c4f9fc58d9422ebf92c36853b27019af7d
- path: build/reports/quality/param_execution.md
  sha256: 79bc6b541aea5bb637f397fb63f1d17029ea91407f6288f79930c50c5b4cf082
- path: build/reports/quality/param_check.md
  sha256: 1dd2f7d4b939b99c47c810eacdf92977c3ea23fb47f45d248bfa0f1565e4277c
- path: build/reports/static/20260914T113900/config.json
  sha256: dc9e05a1ff403c44374f32c3151108deb62f1b52fd75ea57d06ea4b498e5783c
- path: build/reports/static/20260914T113900/delivery.json
  sha256: 85cdc6a2013fcef627e7c5a875a81814fbfe94ce7088abc65e5a4251cb8081ea
- path: build/reports/delivery/20260914T125557415882/manifest.json
  sha256: 250915f73ca7cf4671f7c6a46da60d8f13d2d52c1e4f72c870f19e5aad31cb6f
- path: build/reports/quality/trace_matrix.md
  sha256: e7afe6f48ca3089ea59b12565c8b54fd036538f87dc845d1a3f2e69a5525169c
- path: build/reports/recovery/lint_diagnostics.json
  sha256: 3d12da8ddd63e103e6885eff3b1951ed85d276efc582d98bf30eedf6c4a227b8
- path: build/reports/signoff/cdc.yaml
  sha256: 968ab92538bef620c4f6f408959ab156bc857de08a08d53a5544404b8273643c
- path: build/reports/signoff/rdc.yaml
  sha256: 92ee3b32e4441f2529496af589e2aa52a05e26ab3d835aae45dbc834df576c1c
- path: build/reports/formal/20260914_043257/manifest.json
  sha256: 4462d013ce8b5517b444a7ccff3b37be64ee5f3373dc7206e9bd2b59f4d537ed
- path: build/reports/rtl/20260914T083556079972/execution.json
  sha256: 5cd1a41c4861610992d2ba9208393f9bd8f6c825279630bff3a61669683945eb
- path: build/reports/rtl/20260914T084927285403/execution.json
  sha256: 095266f67a04fc5064e02bc4aa2e96ee4e93edcb196ede38bbbd1348f8b98eac
- path: build/reports/rtl/20260914T085940523110/execution.json
  sha256: 17d48c1327aec361e93ac0a2997a87bc3af24df73e3e26cf237a5b1ec1cc2208
- path: build/reports/ppa/attempt_context.json
  sha256: 0ade2ae4ffd9e65842814044f3eb61018299eed8d1b56d7f8d85843c2729d107
- path: build/reports/quality/g3_continuation.yaml
  sha256: 8c2e47ae603e64cd293e678372cd17587cc191d828fb62ebfc1589ac0627d808
- path: build/reports/quality/review_findings.yaml
  sha256: 6d15eb93b9c5f56863156ff8fc644dc5d358e4986751670ce183ea61c73bd13c
- path: build/reports/quality/integration_review.md
  sha256: c4066024c9fbbfab945acab2ef1f837c6bb6b197f4cafb0cf9153f1529479d77
- path: build/reports/quality/user_guide_review.md
  sha256: 5a297baa011336bd063d877b5962585fad1815d89a2cc900bc5201ccb18a9806
- path: build/legacy_reports/20260914T071652/archive_index.json
  sha256: 0e02d8bed3df0d6b516f5c4563cbc755f1de8dd262d0ce057db1eb7adab098a6
- path: build/reports/recovery/parameter_cache_archives.json
  sha256: 976227ceb7eb9e9f4e5f2a1811b1ce7b50a440bbc7d3017ab1badff5fa0b7b9f
- path: build/reports/recovery/suite_final_all.xml
  sha256: 73bb73211e13008b86c7479483abda4682ffa0264d0b2366446b49a8fb4bfe47
- path: build/reports/recovery/local_script_tests.xml
  sha256: 8f8bc093fa3725ac12fbf5735048299bffd41bdfe0dd19e740c61ba6372a62b5
- path: build/reports/recovery/final_checks.json
  sha256: 929ab985b08ff4937ed401c08518b70c24a7642efb158b439f3d2957cd215eac
END_IP_REPORT_METADATA -->
