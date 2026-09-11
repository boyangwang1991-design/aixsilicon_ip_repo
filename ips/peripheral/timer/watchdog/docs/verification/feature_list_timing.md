# 计时窗口与周期优先级：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.TIMING
name: 计时窗口与周期优先级
description: 计时窗口与周期优先级的可执行正确性证明
priority: must
req_ref:
- LRS.CFG.WATCHDOG.PAR.003
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.PERF.WATCHDOG.TIME.001
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.VER.001
- LRS.CONS.WATCHDOG.VER.002
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

选择P=0/1/最大代表，短TIMEOUT；服务落WIN_MIN-1/WIN_MIN/TIMEOUT-1/TIMEOUT；PRETIMEOUT同拍服务；C/D饱和与多通道并行。

独立判据：oracle以周期起点绝对时间推算floor(elapsed/(P+1))，不读取RTL计数作为期望；timeout精确TIMEOUT*(P+1)；成功服务抑制当拍新预警。

风险与边界：tick×窗口边界×预警×服务；宽度与分频端点。

### LRS.CFG.WATCHDOG.PAR.003

每通道计数、分频相位、服务状态、故障和升级期限独立。允许共享 APB/CDC 和诊断汇总，但不得因其他通道等待或故障而停止本通道计时。

验收：制造其他通道忙、故障与恢复，本通道的到期边沿和升级期限均不变化。

### LRS.FUNC.WATCHDOG.TIM.001

通道包含 W-bit 饱和向上计数 `C` 和分频相位 `D`。启动/成功刷新边沿设 `C=0,D=0`。此后每个 wdt_clk 边沿：若 `D=P`，产生 tick 并置 `D=0`；否则 `D=D+1`。因此每 `P+1` 个边沿产生一次 tick。

验收：P=0、P 最大值及代表中间值时，连续 tick 间隔精确为 P+1；成功刷新重建周期相位。

### LRS.FUNC.WATCHDOG.TIM.002

每个运行边沿先计算候选年龄 `A = tick ? sat(C+1) : C`，所有窗口、预警、超时及服务合法性均用 A。无成功刷新时 `C=A`；成功刷新则 `C=0,D=0`。启动边沿本身不执行年龄递增。

验收：tick 和非 tick 边沿均以候选年龄决定服务结果；启动边沿年龄为零。

### LRS.FUNC.WATCHDOG.TIM.003

正常周期：`A >= TIMEOUT` 必须判超时；窗口开启时，完整服务仅在 `WIN_MIN <= A < TIMEOUT` 合法；普通模式等效 `WIN_MIN=0`。TIMEOUT 边沿的服务必须失败。允许在 WIN_MIN 边沿成功。

验收：WIN_MIN-1 拒绝、WIN_MIN 接受、TIMEOUT-1 接受、TIMEOUT 拒绝；覆盖分频相位。

### LRS.FUNC.WATCHDOG.TIM.004

PRETIMEOUT 使能且 `A >= PRETIMEOUT`、本周期尚未预警时，产生一次预警事件。该边沿若有成功刷新则不产生新的预警；已存在的历史预警不自动清除。计数饱和不能导致超时消失。

验收：阈值触发每周期一次；同拍成功服务抑制新预警，历史预警保持，饱和不丢失故障。

### LRS.FUNC.WATCHDOG.TIM.005

未暂停时，从刷新/启动边沿到超时故障边沿恰为 `TIMEOUT*(P+1)` 个 wdt_clk 周期。启动周期改用 BOOT_TIMEOUT。软件应按最坏时钟偏差、总线/CDC 延迟预留服务裕量。

验收：无暂停时故障边沿与 TIMEOUT*(P+1) 完全一致；BOOT 使用 BOOT_TIMEOUT。

### LRS.FUNC.WATCHDOG.TIM.006

从高到低按以下顺序处理，互斥状态更新只能执行最高有效项： 1. POR 初始化。 2. 自身致命完整性/冗余故障；最终升级到期。 3. 当前监督超时、服务违规、检查点 Deadline 违规；同拍发生的各原因全部置位。 4. 可信恢复事件；不得覆盖第 2/3 项本拍新故障。 5. 完整合法服务/刷新；含已批准待提交配置的边界切换。 6. 合法 START/STOP；STOP 不得覆盖本拍超时。 7. 授权暂停进入/退出。 8. 普通计数、预警、诊断清除。 进入暂停的该边沿仍执行到期判断；退出暂停的边沿只恢复状态，下一边沿恢复递增。暂停前已锁存故障不得暂停升级。硬件置位与 W1C 同拍时硬件置位优先。

验收：对每对竞争动作验证优先序；到期与暂停同拍仍故障，恢复边沿不递增，清置同拍保留新事件。

### LRS.PERF.WATCHDOG.TIME.001

连续 wdt_clk 且无暂停/恢复时，普通/窗口监督精确在 TIMEOUT*(P+1) 周期到期；ALIVE 以同一期限评价完整周期健康条件。

验收：从周期开始逐拍比较精确边界，最后合法服务边沿与到期边沿严格区分。

### LRS.CONS.WATCHDOG.NFR.004

通道计时和升级不得受 APB backpressure、长读操作、客户端数或诊断访问影响。配置及客户端存储可按参数裁剪；不以共享轮询计数方案牺牲检测时限。

验收：改变通道/客户端规模及 APB 背压时，独立计时和升级到期边沿保持规定期限。

### LRS.CONS.WATCHDOG.VER.001

RUN普通/窗口模式、wdt_clk持续、无授权暂停/恢复条件下，从周期开始 TIMEOUT*(P+1) 个周期内若无合法刷新，必须进入对应故障响应。

验收：在持续时钟且无暂停恢复假设下，用断言或等强证据验证规定期限故障。

### LRS.CONS.WATCHDOG.VER.002

不合法服务、IRQ清除、配置写、第一次密钥、其他通道服务不能重置本通道 C/D。ALIVE 固定周期刷新为明确列出的例外。

验收：逐个非法/无关操作验证不会改变本通道周期；ALIVE 成功边界例外显式覆盖。
