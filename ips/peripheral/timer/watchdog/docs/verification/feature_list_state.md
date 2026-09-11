# 启动停止与启动期：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.STATE
name: 启动停止与启动期
description: 启动停止与启动期的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.STA.001
- LRS.FUNC.WATCHDOG.STA.002
- LRS.FUNC.WATCHDOG.STA.003
- LRS.FUNC.WATCHDOG.STA.004
- LRS.FUNC.WATCHDOG.STA.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

AUTO_START与手动START；BOOT开启/关闭；BOOT首次完整服务；重复START；STOP在各状态、NO_STOP/ENABLE_LOCK开关；pclk停止自动启动。

独立判据：启动边沿年龄/相位置零；BOOT只有一次宽限；非法START/STOP不重置监督；STOP仅授权解锁且允许状态成功；保留历史与锁。

风险与边界：控制状态×命令×锁；POR与首个可用WDT边沿。

### LRS.FUNC.WATCHDOG.STA.001

START 仅在 DISABLED 有效，必须使用已生效合法配置。BOOT_EN=1 则进入 BOOT，否则 RUN；重复 START 返回 BAD_STATE，不重置时间。

验收：禁用态合法 START 启动；其他状态重复 START 返回 BAD_STATE 且原期限不推迟。

### LRS.FUNC.WATCHDOG.STA.002

BOOT 使用 BOOT_TIMEOUT、普通服务时间区间 `[0,BOOT_TIMEOUT)`；服务算法、来源、客户端完成要求仍适用。BOOT 不发普通 PRETIMEOUT 预警。第一次完整成功服务切入 RUN，并清零计数、分频、客户端本轮状态；不能反复 START 获取 BOOT 宽限。

验收：BOOT 首次完整服务进入 RUN 并开始新周期；BOOT 不产生普通预警，重复 START 无新宽限。

### LRS.FUNC.WATCHDOG.STA.003

AUTO_START 通道在 POR 同步释放后的第一个可用 wdt_clk 边沿自动启动，不依赖 pclk 或软件。该时点即服务周期起点。

验收：pclk 停止时自动启动仍在 POR 同步释放后首个可用 WDT 边沿发生。

### LRS.FUNC.WATCHDOG.STA.004

NO_STOP_MASK=1 或 ENABLE_LOCK=1 的通道一旦启动不可由软件停止。其他通道 STOP 要求配置授权和有效解锁；仅 RUN/BOOT 可停止，清除未完成服务序列，不清历史故障，不解除锁。

验收：锁定通道 STOP 拒绝；可停止通道仅在 BOOT/RUN 接受，历史故障和锁保持。

### LRS.FUNC.WATCHDOG.STA.005

START、STOP、配置提交不直接清除 IRQ 或 FIRST_FAULT。冷启动默认 BOOT_EN=1；各通道默认时间通过 DEFAULT_CFG 明确，不将任意固定时长假设为适用于所有时钟。

验收：START/STOP/COMMIT 前后历史 IRQ/FIRST_FAULT 保持；默认启动时间来自指定 DEFAULT_CFG。
