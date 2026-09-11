# Watchdog 既有 HLD / LLD / VPLAN 内容审查

本报告为 review-only 现状审查与重整输入；它不是新的架构、微架构或验证模型。
完整重整仍属于 full-flow required 交付，按 G0/PC → G1 → G2 顺序进入对应 owner。

## HLD：`docs/hld/architecture.md`

现有文档描述 APB staging、单在途邮箱、通道责任、复位保留、仲裁、快照和安全思路，
可作为旧实现笔记保留。其中执行模式仍写 partial-task，正文为英文，仅一个短文件，
没有 HLD_DOC/MODULE/INTERFACE/DOMAIN/CDC/PERF/GATE META 或规范模型。

| 缺口 | 重整位置与验收 |
|---|---|
| 无 LRS baseline、参数合同与复杂度依据 | 00_overview 绑定新 LRS/PC 哈希，明确适用配置和架构目标 |
| 模块边界仅以段落概述 | 01_architecture 定义 L1 架构对象、责任/非责任、上下游、复用和 req_ref |
| 服务/故障/恢复数据与控制流不完整 | 02_functional 按命令、计时、服务、配置、故障升级与恢复分别说明 |
| 没有独立内外接口合同 | 03_interface 定义接口 ID、owner、域、协议/负载、请求/完成/取消语义 |
| 寄存器架构只有 external register 技术描述 | 单独寄存器主题分册定义组、访问路径、staging/active/snapshot、锁、W1C、提交激活 |
| CDC/RDC、reset、power 缺机读域和逐路径清单 | 04_clock_power 分开命令、应答、合并错误、IRQ/状态同步及暖复位取消路径 |
| 服务可见/执行/返回上界未绑定需求及竞争条件 | PERF 对象给出分段时限、仲裁假设、停钟边界与各配置预算 |
| 安全独立性仅结论性描述 | 05_safety 为每个故障模型列保护对象、检测/反应/盲区与综合网表检查交接 |
| 缺 DFX、决策、分解和风险清单 | 06_dfx、07_decomposition、08_risk_checklist 完整落地；禁止把 RTL 文件映射提前写入 HLD |

## LLD：`docs/lld/implementation.md`

现有文档已有 `LLD.MOD.WDT.CHANNEL/TOP` 标题和一些实现要点，但没有 META、
有效 HLD 引用、唯一文档头/Gate、对象级设计定义及可抽取 RTL_MAP。文本没有给出
足够细节独立审查每个周期和复位交错，也没有正式 `LLD_REG_META`。

| 缺口 | 重整位置与验收 |
|---|---|
| baseline 和全局约束缺失 | 文档控制/overview/global_constraints 绑定 HLD、接口、参数与时限输入 |
| channel 内部行为过于集中 | 按计时/服务/客户端/升级恢复/诊断安全拆主题，均归有效 HLD module |
| FSM 只有状态值描述 | 定义全部状态、条件、转移、复位状态、非法编码与同拍仲裁优先级 |
| 计时与饱和规则缺完整公式和位宽 | 冻结 C/D/A/E、序列年龄、Deadline、ALIVE 统计、token 的边界与更新规则 |
| 邮箱与错误路径缺逐拍/复位细节 | 定义接收、可见、执行、取消、应答、payload 保持、preset/warm/POR 交错与最多一次保证 |
| 参数提交与锁缺逐字段 SW/HW 行为 | 每类寄存器定义 register_ref、SW/HW 行为、collision、update_timing、reset_semantics；位表只在 RDL |
| 独立性及 PPA 取舍缺实现决策 | 定义保护路径/注入对象/反应保持、dont_touch 范围、关键组合路径/共享资源代价 |
| RTL 映射只有散落路径 | 07_delivery_mapping 用 RTL_MAP_META 明确实体映射，重建 HLD→LLD→RTL trace |

## VPLAN：`docs/verification/verification_plan.md`

现有表格按需求族列 UT 入口，明确没有完整 UVM、交叉覆盖或参数空间闭合。
这份记录可用于盘点已有 UT，但不能替代逐需求验证计划，也不能转写成全回归 PASS。

| 分册 | 重整内容 |
|---|---|
| verification_plan.md | 完整主方案章节、上游 baseline、边界/风险、验证层次、策略、工具、regression/signoff |
| feature_list.md | 139 条当前 LRS 的逐项 feature 引用和可裁剪配置条件；先审查重复/依赖后分组 |
| test_matrix.md | 每个 TC 恰好一个 feature_ref，真实实现入口、oracle、激励、预期、seed、timeout、tier、param_config |
| checker_plan.md | APB 协议、命令序号/最多一次、独立计时/服务模型、复位/快照/升级/安全 checker 和 assertion |
| coverage_plan.md | functional/code/assertion 分开；阈值/相位/模式/来源/复位/故障交叉；参数配置与不可达论证；原始报告采集/闭合 |
| agent_plan.md | 核对 APB VIP 当前质量/依赖，WDT 事件、时钟/复位、授权/恢复 Agent；active/passive 分工 |
| index.md / 99_quality_gate.md | 完整导航与唯一 VP0 open；不能以 VP0 冒充 G3/G4 |

回归顺序必须保持 Module UT → UVM Smoke → 全部可达 TC → 19-PV → coverage →
final RTM → quality review。完整环境需要真实 APB 与独立 WDT 域观察，不得把 UT 的
3752 次检查直接转成 UVM testcase/coverage 达成证据。

## 静态审计误报候选

`rtl/generated/watchdog_csr.sv` 的两条 immediate assertion 位于 `ifndef SYNTHESIS`
内。suite audit 是源文本筛查，没有预处理该宏，因此当前将其列为 forbidden construct。
此处只记录可复核事实：不得手改 PeakRDL 派生源码，也不能直接豁免全部断言。
后续 G3 应核对实际仿真/综合宏配置与真实工具输出，再确定生成选项或 owner 工具修复。
