# SPI Master 实施过程中的 SKILL 改进报告

日期：2026-09-10。对象：本地 ip-development-suite checkout `0172efd`。本次记录 **21 项**实际发现及优化建议，没有直接修改共享 SKILL 源码；IP 内包含有限、可审计的兼容脚本。

工具版本：PeakRDL 1.5.0、regblock 1.3.1、SystemRDL compiler 1.32.2、FuseSoC 2.4.7、Edalize 0.6.8、VCS/URG W-2024.09-SP1、SpyGlass X-2025.06、DC V-2023.12-SP3。完整环境与依赖哈希见 [environment-manifest.json](quality/environment-manifest.json)。

用户已授权自主执行工程工作；报告明确区分工具运行通过、候选实现验收和独立技术冻结，未填写虚构的人工审批。

## 问题清单

| ID | 严重度 | 位置 | 实际发现、处理和建议 |
|---|---|---|---|
| SK-001 | major | 00-ip-workspace §4.4 / workflow pyproject.toml | 根环境可运行 YAML，但缺少 PeakRDL/SystemRDL/FuseSoC 的声明及安装；02 无法执行；提供并测试根项目 ip-dev extra，检查 lock 中 exporter 集合；本次在根项目补充依赖 |
| SK-002 | major | 02-reg-model/references/templates.md §1/§2/§3 | 完整模板仍含 reg 级 onwrite、WO 的 sw=w/hw=w、无 reset 的 RW；与同文件 Common Gotchas 和入口硬规则冲突；将每个 fenced RDL 示例纳入编译测试，标 BAD 的片段反向断言失败；正确模板逐字段写 onwrite/reset |
| SK-003 | minor | 07-rtl-code-generator §5.3/§5.9/§6.1 | 同时要求 typedef enum 与避免 typedef enum，语法规则散落且不一致；以 profile + 实际版本探测统一裁决，保留兼容回退而非无条件禁用 |
| SK-004 | major | 总入口 / artifact-contract 的 freeze 规则 | 自动实现授权与技术审批易混淆；不能由作者填写虚构 approver 来满足下游；将执行授权、设计审查、工具验收分开，提供可自动运行的 candidate 流程；只有实际技术评审才冻结 |
| SK-005 | major | 19/extract_parameters.py:261 与 LRS 模板 §3.2 | 模板的 Parameter/Kind/Type/Default/Legal Values 表无法识别；输出 0 参数仍退出 0；feature 名必须包含参数名，与代码注释相反；改为统一结构化 PARAM_META；无参数的 parameterized IP 必须失败；消除 800 字符距离限制。本次采用工具识别的表格，仍从 Markdown 抽取 |
| SK-006 | major | 02/templates.md Runtime Access Protection | hwclr 被解释成恢复 reset 值，实际为清零；CLKDIV=1 等非零复位不等价；加非零 reset 回归，软复位使用明确的 functional reset 接口 |
| SK-007 | critical | 02-reg-model §2.9 / templates W1C | 推荐的 `onwrite=wclr` 实际是任意写清除。IRQ 测试写1清 SEG_DONE，同时错误清 XFER_DONE；生成代码无数据/byte mask 条件。W1C 应用 `woclr`，增加写0、逐位、PSTRB、同沿事件测试。本次修 RDL 后再生，未修改生成 RTL |
| SK-008 | major | 07 SpyGlass 脚本 | 仅 enableSV 不支持 elaboration $error；实际 8 Fatals。需要 enableSV09，与参数化 CBB 联合测试 |
| SK-009 | major | 08 FuseSoC 示例 / sync_fifo core | 示例顶层 depend 无效；资产缺少 paramtype，被 FuseSoC 2.4.7 拒绝。应使用 filesets.*.depend 和 vlogparam。本次仅在 build 内适配元数据，引用原源码 |
| SK-010 | major | 07 组合辅助操作建议 | VCS TBIFASL：无参 task 的读取不进入 always_comb 敏感列表。空 FIFO 补数恢复时发0，预填测试正常。改用 function/显式参数，并增加空转非空恢复用例 |
| SK-011 | critical | 09 ip_pdk_scan.py / CBB pdk.py | IP scanner 消费 CBB --json 的精确 corner_files，但新版 CBB 默认输出脱敏视图并扁平化 libraries，造成真实 .db 存在却报缺库。需版本化 public/local schema，并提供显式本机精确接口；不得把适配失败当 PDK_UNAVAILABLE |
| SK-012 | major | 06 extract_verification、15 gen_regression_list/evaluate_quality | 方案允许 static/review，但执行对象路径被硬编码为 verification/tc/*.sv。实际 C 驱动/静态交付脚本被拒绝。增加 proof_kind/executor 和对应文件/命令/哈希规则；不能把非仿真需求挂到无效 SV 文件。本次仅做 IP 局部 extractor adapter，精确允许真实的 scripts/check_delivery.py，其他校验不变；未修改共享 SKILL，原始 evaluator 的限制如实保留 |
| SK-013 | major | 14 构建复用与证据纪律 | 复用 simv 时仅记录当前源码哈希，会错误绑定旧二进制。建议将源文件、编译参数、工具版本和可执行文件哈希固化为构建身份，--no-build 必须校验；coverage DB 同样绑定身份。本次已校验 source/command manifest |
| SK-014 | major | 08/09 工具 backend 模板 | Edalize VCS 使用 vcs_options/run_options，不消费示例 flags/mode；DC 参数 elaborate 后顶层被重命名，current_design spi_master_top 会报 UID-109，即使后续网表成功也必须拒绝。本次真实日志触发失败后修脚本、重新综合通过；建议 backend schema 和参数化工具 smoke 纳入套件 CI |
| SK-015 | major | 14/15 URG 环境预检 | URG 默认分配器在许可证初始化栈的 libsnpsmalloc.so/mem_free 崩溃。安装版本支持 VCS_USE_MALLOC=1，重跑四配置报告成功。建议记录失败栈、环境差异和复跑命令，不能将工具崩溃当作覆盖率 0 或伪造通过 |
| SK-016 | major | CBB 复用与 reset 约束 | sync_fifo 没有功能 clear 端口，IP 必须加本域寄存的清除复位胶水；lint 提示 AsyncResetOtherUse。建议复用合同显式描述 clear/flush、同沿访问和 reset timing，增加功能同步 clear profile，并将 RDC/recovery-removal 作为集成责任，不用全量 RAM reset 规避 |
| SK-017 | major | 15 validate_coverage_contract | 单一 code achieved/target 无法表达 line/branch/toggle/FSM 的不同分母，且只允许固定报告路径，容易诱导用手写 RTL line=100 代替全设计覆盖。本次保留全部原始 URG、逐模块指标、未覆盖解释，不调整分母或伪造豁免；建议带 metric/scope/raw denominator 的结构化模型 |
| SK-018 | minor | 根统一 uv 环境 | 引入 SystemRDL 的 antlr 4.13.2 使 resolver 将 OmegaConf 从 2.3.1 调整为 2.0.6。uv pip check、Docling import、OmegaConf 插值 smoke 通过，但不等于完整文档转换回归。建议 ip-dev extra 给出经过验证的跨领域依赖组合和降级差异提示 |
| SK-019 | minor | 08 target 继承与验收 | FuseSoC 合并继承的 run_options 后出现两个 UVM_TESTNAME，smoke 实际跑了 modes；单看退出码会漏检。本次拆开目标并检查实际 RNTST/PASS 用例名；建议 suite smoke 同时断言目标身份、预期日志和零 UVM error/fatal |
| SK-020 | major | 09/15 VCS lint 示例 | 本机 VCS 的合法选项为 `+lint=all`。套件示例 `-lint=all` 被传给链接器，报 `cannot find -lint=all`；修正后 FuseSoC lint 编译通过。建议实际 smoke 测试精确参数拼写，不把字符串包含某个 flag 当工具成功证据 |
| SK-021 | major | 15 evaluate_quality.py main | 实际 G4=fail/G5=blocked 时仍退出 0，因为退出码只代表报告成功生成。CI 若只检查命令退出码会误判签核成功。建议增加 `--fail-on-gate` 或独立状态检查入口。本 IP 增加 `make signoff`，读取真实 Gate 状态并在未闭合时返回非零 |

## 可复现的优先修复顺序

1. **P0：寄存器语义。** 编译 RDL 示例后做写 0、写 1、单 bit、PSTRB 和同沿 hwset 测试。`onwrite=wclr` 是写任意值清零，W1C 需要 `woclr`。本 IP 的 `tc_spi_irq` 在修复前真实失败，修 RDL 并再生后通过；禁止手修 generated RTL。
2. **P0：派生数据真实性。** 参数化 IP 提取出 0 参数应失败；PDK public/local schema 必须版本化。检测真实库存在与解析失败，不得错误降级为“无库”。
3. **P1：工具端到端模板。** 每个示例用受支持工具版本实际执行；覆盖 SystemVerilog 2009、参数化顶层、source/order、backend 字段、test identity 和失败退出码。
4. **P1：统一 proof/evidence。** 支持仿真、模块 UT、C 测试、静态审查、综合和 formal unavailable 的独立证据。源文件、工具、命令、配置、seed、日志、二进制和覆盖库身份应可追溯。
5. **P1：候选实现与冻结分离。** 用户授权自动完成工程工作时，允许 candidate 流程持续前进；不能自动填写不存在的独立 approver。冻结仍需真实技术审查和板级边界。

## 本次处理状态与证据

本次没有直接改动共享 SKILL 源码。IP 内的兼容脚本、正确 RDL 和测试提供了可复现的修正样例，未来套件升级后应移除对应 adapter。

- [真实回归及源哈希](quality/regression-default-1.json)：四模式、位序、位宽、暂停、错误、IRQ 和竞争测试。
- [模块测试](quality/unit-tests.json)：FIFO 随机顺序、精确超时边界、原因切换、末沿中止保留 RX、状态复位、计数回绕。
- [寄存器生成证据](quality/register-generation.json)、[参数模型](../model/parameter_space.yaml)、[PDK adapter](../scripts/scan_pdk.py)。
- [URG 原始覆盖率](coverage/default/dashboard.html)、[静态告警评审](quality/static-review.md)、[真实综合](synth/default/summary.json)。
- [最终验收和已知限制](acceptance.md)、[原始套件 Gate 结果](quality/gate_report.md)。

已有本地绕行不代表上游问题已修复；特别是混合 proof 支持和自动候选状态，需要 suite 整体一致更新，不能只放宽某一个 validator。


另外，原始质量审查会将仅构造参数不同的 testcase 归一化为相同源码。当前实现已将每组的独立场景调用放入对应 testcase，以便源码审查能直接定位；仍建议 checker 分析真实调用链，避免把有意使用公共 BFM 的不同场景误判为空壳。


## 本次 G5 收尾补充

按用户明确指示，将暂定代码行覆盖门槛 95% 调整为 90%，实测仍为 91.62%；没有修改原始 URG 数据或排除未覆盖逻辑，功能和必需断言仍要求 100%。建议 SKILL 将项目阈值、调整授权、实测指标和残余风险分别建模，避免把“降低门槛”误报成“新增覆盖”。

SK-12 的本地修复由 scripts/evaluate_quality_compat.py 实现：仅允许精确匹配的 static delivery TC 使用 Python 入口，校验 C 编译/执行返回码、真实 PASS 日志和当前源文件/证据哈希，正常 SV/UVM 检查保持不变。保存 upstream-gate-report.md 和 quality-evaluator-adapter.json；共享 SKILL 未由本次修改，建议上游增加通用 proof executor 协议。G5 范围明确为 IP 交付与已执行的工艺表征，板级签核不是本次完成项。

适配器反例验证：一份有效证据被接受，八种失败/缺失/过期/类型误配情况被拒绝。普通 UVM 校验器仍拒绝仅有 C PASS 的日志；详见 quality/adapter-tests.log。
