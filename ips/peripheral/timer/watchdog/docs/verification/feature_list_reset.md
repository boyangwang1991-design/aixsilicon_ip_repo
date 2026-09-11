# 复位分域与外部假设：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.RESET
name: 复位分域与外部假设
description: 复位分域与外部假设的可执行正确性证明
priority: must
req_ref:
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

POR异步断言不同相位释放；preset在各APB/mailbox阶段；pclk停止后故障/唤醒；同步释放2/3/4；初始化期注入及释放后注入。

独立判据：POR才清留痕；preset仅接口镜像复位并重同步IRQ；安全输出不依赖pclk；初始化诊断屏蔽不超过SYNC_STAGES+2；裸异步输入由集成规则拒绝。

风险与边界：复位域×握手阶段×安全状态×时钟停止；外部停钟/失电责任单独审阅。

### LRS.INTF.WATCHDOG.IF.002

IRQ 依赖 pclk 同步；pclk 停止时，安全告警、唤醒和复位请求仍必须工作。复位请求不得依赖 IRQ 被软件处理。

验收：停止 pclk 后触发预警/故障，WDT 域唤醒及复位请求照常产生并保持。

### LRS.INTF.WATCHDOG.IF.004

IP 不检测自身时钟整体停振；系统必须用独立参考时基或外部看门狗覆盖。若 IP 失电，输出也不能保证有效，系统安全分析必须覆盖电源故障。

验收：集成假设明确独立停钟和电源故障检测者；不把本 IP 标成可自检整体停振。

### LRS.RESET.WATCHDOG.RST.001

warm_reset_evt 必须由复位管理器转换为 wdt_clk 单周期事件，或在外部使用完整握手形成一次事件；不得在系统复位电平持续期间每拍重启 WDT。por_n 释放同步链为 SYNC_STAGES 级；AUTO_START 在同步释放后首边沿启动。

验收：保持系统复位电平不造成重复 warm；SYNC_STAGES 各值下 AUTO_START 均满足释放边界。

### LRS.RESET.WATCHDOG.RST.002

冗余检查仅在主/影子状态均初始化后的第一个正常边沿起有效；允许的初始屏蔽不得超过 SYNC_STAGES+2 个 wdt_clk 周期。禁止使用可由软件无限保持的“初始化屏蔽”关闭安全诊断。

验收：初始化诊断屏蔽不超过 SYNC_STAGES+2；之后故障必检测，软件不能延长屏蔽。

### LRS.RESET.WATCHDOG.RST.003

preset_n 期间 IRQ 输出可复位为低，但释放后必须由保留原始状态重新同步产生；WDT 域复位/唤醒请求不受影响。

验收：preset 中 IRQ 可低；释放后由保留事件重新产生，WDT 请求全过程保持。

### LRS.RESET.WATCHDOG.RST.004

POR 后留痕丢失属于设计行为。若整机要求断电保持，必须由外部 retention/NVM 记录；本 IP 不隐含非易失存储。

验收：POR 清历史；文档明确断电保持由外部 retention/NVM 提供。
