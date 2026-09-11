# GPIO 验证方案

<!-- VPLAN_META
schema_version: '2.0'
ip_name: gpio
delivery_model: parameterized
lrs_baseline: GPIO-CONTRACT-59597f3b2da6
hld_baseline: GPIO-HLD-001
lld_baseline: GPIO-LLD-001
verification_level: full
document_version: 1.0.0-draft
status: approved
verification_baseline: GPIO-VPLAN-001
END_VPLAN_META -->

验证对象为完整GPIO合同，包括所有启用增强功能。UVM 1.2为功能验证平台，独立RM是唯一功能oracle；结构/工程检查使用显式static proof，不替代仿真。

按Module UT→UVM Smoke→完整回归→参数PV→覆盖率→最终RTM执行。Smoke采用APB用例固定seed=1；全部功能用例运行seed=1/17/101，随机压力扩展seed=2026。任何用例失败均阻止G4。

默认CFG_BASE执行全部适用功能；CFG_MIN8、CFG_FULL128及参数合同mandatory配置分别编译/运行适用用例。参数负例必须在指定配置/elaboration阶段失败，不能将编译意外崩溃计为预期失败。

每个功能用例设主域周期watchdog=40000000，AON停钟由独立仿真时钟watchdog=120秒限制；测试在超时前必须显式恢复停钟并检查迟到应答。极限DIV/D通过事件驱动等待执行，不省略边界。

[功能](feature_list.md)、[测试矩阵](test_matrix.md)、[检查器](checker_plan.md)、[覆盖率](coverage_plan.md)、[Agent](agent_plan.md)。

## 1. 验证范围与边界

功能范围包括APB、输入处理、输出、IRQ、锁、休眠、安全、AON、捕获、FIFO、诊断及参数裁剪。外部PMU/Pad Controller/互联防火墙只验证接口假设和数字模型；不承诺本IP提供电气或掉电保持功能。

## 2. 需求与功能映射

[功能列表](feature_list.md)导航全部语义域。每个LRS ID通过唯一所属Feature关联测试，必要SVA提供补充不变量。最终RTM必须绑定当前RTL及实际通过记录，不能从规划映射推断验收。

## 3. Testcase与激励

[测试矩阵](test_matrix.md)及其分册规定每个测试的stimulus、oracle、预期、参数、seed和超时。极限计数边界采用可审计的初始化辅助，仅缩短前置状态建立，不跳过待测竞争沿。

## 4. 参数空间

参数合同为LRS PARAM/CONFIG/CASE META的派生投影。CFG_BASE为默认产品，CFG_MIN8为最小裁剪，CFG_FULL128包含parity；mandatory宽度和风险配置分别检查。静态配置检查仅负责合法性，不替代真实编译/仿真PV。

## 5. 环境与Agent

[Agent计划](agent_plan.md)定义APB master、两个域的输入driver/monitor及reset agent。使用UVM 1.2 analysis连接和统一config对象，每个时钟域独立采样；测试不直接写DUT业务状态来制造期望结果。

## 6. 参考模型与Scoreboard

RM由总线事务和域采样事件驱动。输入模型以连续样本段计算K/D，FIFO用软件队列，IRQ用事件集合，AON用命令序号和活动配置快照。scoreboard独立读取DUT输出和APB返回，报告首个周期差异，结束时不得遗留未核对事务。

## 7. Assertion

[检查器计划](checker_plan.md)定义8项合同强制不变量。仿真绑定SVA与UT共享命名，启用断言且保留触发/失败统计。商业formal若执行，应报告具体证明性质及假设；没有运行不能标为证明完成。

## 8. 覆盖率

[覆盖率计划](coverage_plan.md)给出功能、代码和断言目标及配置排除要求。URG合并保留输入数据库哈希、命令、版本和原始报告。配置不可达排除与设计缺陷未覆盖必须区分。

## 9. 错误与故障注入

APB非法事务覆盖地址、访问类、权限、锁、能力和字段编码。AON停止时钟验证超时后槽不复用；parity注入验证数据不变且安全请求按时锁存；回读诊断用外部PAD值失配，不能把DIAG_TEST视为完整诊断链路验证。

## 10. 复位和低功耗

RESET用例按合同复位矩阵逐类建立非默认状态。暖复位分别打在AON请求发送、同步、执行、应答返回阶段，检查不重放及排空；主域复位同步作用于APB master，避免非法上游事务混入结果。

## 11. CDC与RDC

SpyGlass静态分析覆盖两类PAD同步器与mailbox双向token/保持总线。同步器深度和级间无组合结构检查对应约束；RDC检查POR保持状态到暖复位逻辑的隔离。异步时钟仿真补充功能竞争证据，不能证明MTBF。

## 12. 性能与PPA

APB零等待与两周期最短连续写通过事务时间戳检查，TOGGLE方波周期为四主周期。滤波延迟检查合同上界。8/32/128及裁剪/完整配置的面积、时序、动态功耗估计和AON成本必须由真实综合报告提供；功耗报告说明活动率来源。

## 13. 回归与调试

先UT，再APB smoke，成功后执行全部可达testcase。失败保存配置、seed、首错日志及波形；修复后重跑受影响层级再全量回归。JUnit testcase ID与TESTCASE_META一致，静态工程用例单独保存command-proof，不能伪装UVM运行。

## 14. 签核与未决项

G4需要全部必需测试通过、覆盖率达标、最终RTM无gap、无未解决高风险项。G5另需文档、真实PPA和交付清单。当前尚未实现RTL和验证源码，所有执行证据待建立；PPA目标时钟等待集成输入。用户继续授权适用于经过校验后的计划批准，不代替工具证据。
