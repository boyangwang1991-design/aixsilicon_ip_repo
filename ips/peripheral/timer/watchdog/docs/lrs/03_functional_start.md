# Watchdog：启动、停止与启动宽限

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.STA.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.STA.001
category: FUNC
feature: sta
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-STA-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

START 仅在 DISABLED 有效，必须使用已生效合法配置。BOOT_EN=1 则进入 BOOT，否则 RUN；重复 START 返回 BAD_STATE，不重置时间。

#### Acceptance Criteria

- 禁用态合法 START 启动；其他状态重复 START 返回 BAD_STATE 且原期限不推迟。

## LRS.FUNC.WATCHDOG.STA.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.STA.002
category: FUNC
feature: sta
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-STA-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

BOOT 使用 BOOT_TIMEOUT、普通服务时间区间 `[0,BOOT_TIMEOUT)`；服务算法、来源、客户端完成要求仍适用。BOOT 不发普通 PRETIMEOUT 预警。第一次完整成功服务切入 RUN，并清零计数、分频、客户端本轮状态；不能反复 START 获取 BOOT 宽限。

#### Acceptance Criteria

- BOOT 首次完整服务进入 RUN 并开始新周期；BOOT 不产生普通预警，重复 START 无新宽限。

## LRS.FUNC.WATCHDOG.STA.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.STA.003
category: FUNC
feature: sta
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-STA-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

AUTO_START 通道在 POR 同步释放后的第一个可用 wdt_clk 边沿自动启动，不依赖 pclk 或软件。该时点即服务周期起点。

#### Acceptance Criteria

- pclk 停止时自动启动仍在 POR 同步释放后首个可用 WDT 边沿发生。

## LRS.FUNC.WATCHDOG.STA.004

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.STA.004
category: FUNC
feature: sta
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-STA-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

NO_STOP_MASK=1 或 ENABLE_LOCK=1 的通道一旦启动不可由软件停止。其他通道 STOP 要求配置授权和有效解锁；仅 RUN/BOOT 可停止，清除未完成服务序列，不清历史故障，不解除锁。

#### Acceptance Criteria

- 锁定通道 STOP 拒绝；可停止通道仅在 BOOT/RUN 接受，历史故障和锁保持。

## LRS.FUNC.WATCHDOG.STA.005

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.STA.005
category: FUNC
feature: sta
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-STA-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

START、STOP、配置提交不直接清除 IRQ 或 FIRST_FAULT。冷启动默认 BOOT_EN=1；各通道默认时间通过 DEFAULT_CFG 明确，不将任意固定时长假设为适用于所有时钟。

#### Acceptance Criteria

- START/STOP/COMMIT 前后历史 IRQ/FIRST_FAULT 保持；默认启动时间来自指定 DEFAULT_CFG。

