# Watchdog 完整验证方案

<!-- VPLAN_META
schema_version: '2.0'
ip_name: watchdog
ip_display_name: 多通道安全看门狗
delivery_model: parameterized
lrs_baseline: watchdog-contract-1.0.0-full-flow-r1
hld_baseline: watchdog-hld-1.0.0-full-flow-r1
lld_baseline: watchdog-lld-1.0.0-full-flow-r1
verification_level: full
document_version: 1.0.0
status: reviewed
verification_baseline: watchdog-vplan-1.0.0-full-flow-r1
END_VPLAN_META -->

目标是证明冻结LRS的139条需求，而非复用旧partial报告作为完成证据。此方案不改设计。
VCS/UVM 1.2为动态签核环境；Module UT单独作为前置证据；每次构建绑定源、参数、工具、二进制及日志哈希。
20个TC按独立oracle划分，18个UVM加2个可执行静态/软件聚合入口；参数和小边界作为同一TC的scenario，不复制TC。

## 执行顺序与验收

1. G2冻结后准备VP0；每项feature必须有TC或断言，coverage只表示触达。
2. RTL修正→SpyGlass lint→Module UT→三工具G3；任何失败保留日志并修复。
3. UVM smoke→所有可达TC full regression→PC配置实测→coverage/RTM闭合。
4. STANDARD/SAFETY/SUPERVISOR真实28nm PPA与集成/软件/安全交付→G5。

Smoke运行BUS的默认配置seed=1。regression运行所有动态TC，在适用的STANDARD、SAFETY、SUPERVISOR及功能开启代表配置运行seed=1,17,101。
extended加seed=1009,65537以及PC所有合法配置构建与必要功能场景，非法配置逐条期望失败。
每个动态TC最多1000000 WDT边沿或10 ms仿真时间；单APB最多2个ACCESS边沿。
命令完成的有界等待仅用于两时钟持续运行的场景，停钟场景用测试自己的恢复截止点退出。
进程编译1800秒、仿真600秒，超时FAIL；保存失败seed，不以仅重跑通过覆盖首个失败记录。
不适用场景须以编译配置谓词说明；不把根本未运行的TC写成PASS。

## 项目签核指标

所有must需求及必需TC/断言100%正确性闭合；功能mandatory bins和关键cross 100%。
本方案规划代码覆盖目标line/branch/condition/FSM/toggle均95%（项目目标，非原契约自带百分比）；不同结构实例分别报告，不能混淆分母。
未达目标必须补场景或提出有证据的不可达分析；目前没有批准的coverage waiver。
Lint/CDC/RDC不得留未处置Error、意外锁存或组合环。PPA不另编造工艺无关数值门限，按真实时钟/库/活动报告。
对独立参考时钟监控、断电输出和模拟共因只给系统集成责任，不宣称本IP动态覆盖。

## 输入引用

- [LRS](../lrs/index.md)、[HLD](../hld/index.md)、[LLD](../lld/index.md)。
- [复用决策](../reuse_plan.md)：APB VIP当前仍是developing，需本项目资格检查。
- [持续授权](../../reports/full_flow/continuation_authorization.md)：无需逐阶段许可，技术检查不豁免。
