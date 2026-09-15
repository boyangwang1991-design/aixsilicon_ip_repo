# Watchdog 1.0.0 集成指南

适用 `aixsilicon:ip:watchdog:1.0.0` 候选工程，顶层 `watchdog_top`。
本文由受用户委托的 AI 编写，不代表独立人工签核。实际设计、验证与发布状态见
[统一报告](../../reports/report.md)。依据：[LRS](../lrs/index.md)、[HLD](../hld/index.md)、[LLD](../lld/index.md)。

## 配置和构建

STANDARD 为单通道32-bit，SAFETY 增加数字冗余诊断，SUPERVISOR 为双通道、双客户端、
64-bit 功能代表配置。准确值取 LRS 抽取的 `model/parameter_space.yaml`。
支持矩阵是验证计划，不等于配置已实测通过。DEFAULT_CFG 逐通道结构必须与规模和能力
一致；AUTO_START_MASK/NO_STOP_MASK/HARD_CFG_LOCK_MASK 不得引用未实现通道。
生产默认关闭 DIAG_INJECT_EN，诊断授权来自可信生命周期控制。

根唯一 Core 管理本地 RTL、生成 CSR 与外部 CBB，编译顺序见 `rtl/filelist.f`。
复用[资产接入计划](../reuse_plan.md)，不复制资产仓源码。固定 UV_PROJECT 为 workflow
根并使用根 uv 环境。prepare_dependencies.py 只生成 build 下的依赖元数据适配。
RTL 检查入口为 scripts/run_rtl_checks.py；仿真入口为 verification/sim/Makefile。
机器结果和编译数据库全部在 build 中，接收方重验必须重新执行。

## 接口连接与 tie-off

域表示 IP 边界时序要求。异步来源由系统先同步或握手；输出进入其他域由接收方同步。

| 端口 | 域/方向 | 连接或未使用处理 |
|---|---|---|
| pclk | APB 输入 | APB 时钟，停钟不等于复位 |
| wdt_clk | WDT 输入 | 独立常开监督时基，系统另用独立时基监测其停振 |
| por_n、preset_n | 异步输入 | 低有效全局/接口复位，按各域同步释放；运行时为高 |
| PSEL、PENABLE、PWRITE | pclk 输入 | APB 控制，空闲 PSEL=0 |
| PADDR[14:0] | pclk 输入 | 字节地址，4字节对齐；先完整译码再缩窄，禁止地址别名 |
| PWDATA[31:0]、PSTRB[3:0]、PPROT[2:0] | pclk 输入 | 写数据/字节使能/保护属性；PPROT 不等于可信身份 |
| PRDATA[31:0]、PREADY、PSLVERR | pclk 输出 | 主机必须处理返回的总线错误 |
| access_source_i[SOURCE_WIDTH-1:0] | pclk 输入 | 可信身份映射；单主体可按配置绑定身份常数 |
| cfg_auth_i、service_auth_i、diag_auth_i | pclk 输入 | 配置、服务、诊断授权；不用的权限绑0 |
| sleep_req_i、debug_req_i、debug_auth_i | wdt_clk 输入 | 电源/调试控制，不用绑0 |
| pause_ack_o[NUM_CHANNELS-1:0] | wdt_clk 输出 | 等实际暂停确认后再执行系统低功耗步骤 |
| warm_reset_evt_i | wdt_clk 输入 | 可信暖复位事件，不用绑0，不可输入毛刺 |
| recovery_done_i、recovery_ack_o[NUM_CHANNELS-1:0] | wdt_clk 输入/输出 | done 保持至 ack、双方回零后再启动；不用 done=0 |
| irq_o[NUM_CHANNELS-1:0] | pclk 输出 | 接中断控制器，不替代硬复位请求 |
| nmi_req_o、local_reset_req_o[NUM_CHANNELS-1:0] | wdt_clk 输出 | 逐通道保持请求，接 NMI/局部复位管理器 |
| system_reset_req_o、safety_alert_o、safe_state_req_o | wdt_clk 输出 | 接系统复位/安全管理器，安全用途不可悬空 |
| wake_req_o | wdt_clk 输出 | 接常开唤醒逻辑，未使用时审查低功耗策略 |
| test_auth_i | wdt_clk 输入 | 可信测试授权，正常生产绑0，不屏蔽真实最终请求 |
| hw_evt_valid、hw_evt_ready | wdt_clk 输入/输出 | ready/valid 服务接口，不用 valid=0 |
| hw_evt_channel[3:0]、hw_evt_client[4:0]、hw_evt_type[2:0] | wdt_clk 输入 | 有效通道/客户端/事件编码，等待 ready 时保持，不用绑0 |
| hw_evt_data[31:0]、hw_evt_source[SOURCE_WIDTH-1:0] | wdt_clk 输入 | 负载/可信来源，等待 ready 时保持，不用绑0 |

## 时钟、复位和跨域

por_n 异步置位并在各域同步释放；preset_n 仅复位接口，不应清除持续监督故障。
释放后等待同步链生效再访问 APB。POR 会丢失 FIRST_FAULT，需要掉电保留时外部持久化。
APB 停钟不应阻断 WDT 最终请求；WDT 停钟则不能继续声明监督有效。
APB/WDT 单在途邮箱的负载在握手完成前保持，返回镜像保持到后续命令；禁止逐位同步
宽负载。请求/确认、取消、错误、输出和复位同步链须分别检查。
set_clock_groups 不等于 CDC 签核；按实际时钟补充 bundled-data max-delay/skew。
异步复位 false-path 不代替 recovery/removal、脉宽或复位树 RDC 检查。

## 中断、低功耗和安全

清 IRQ 不喂狗、不撤销有效复位请求。最终期限与恢复同时发生时最终请求优先。
恢复四相握手回零后才能重发，旧 done 高电平不产生新的恢复额度。
系统预算须含复位管理器和执行器延迟。暂停可能无限延长未监督时间，必须有系统策略。
共享振荡器、电源、模拟共因和物理冗余独立性不由 RTL 仿真证明，见[安全说明](../safety_manual.md)。

## 寄存器、约束与限制

原生窗口32 KiB，通道窗口仅访问实际实例；寄存器结构来自 regs/watchdog.rdl。
最大规模 RAL 不表示所有通道已实例化，非默认 DEFAULT_CFG 需调整软件/RAL 复位期望。
见[编程指南](../user_manual/watchdog_register_programming_guide.md)。
constraints/watchdog.sdc 当前表征 pclk 100 MHz、wdt_clk 50 MHz，不是芯片额定 Fmax。
uncertainty/transition=0.1 ns；APB/WDT I/O max delay=1/2 ns；输出负载0.01使用库单位。
实际库/角从 model/pdk.yaml 生成 build/rtl/pdk_setup.tcl；不得用目标周期推算虚构 PPA。
SAFETY 的互补计数、配置、锁、状态、升级年龄和请求保护锥需映射后审查扇入和独立性。
keep/dont_touch 和副本命名不能证明物理实现正确。签核缺项仍以统一报告为准。
[集成检查表](watchdog_integration_checklist.xlsx) 不含虚构接收方批准。
