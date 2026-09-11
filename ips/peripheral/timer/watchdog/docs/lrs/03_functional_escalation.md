# Watchdog：故障升级

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.ESC.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.ESC.001
category: FUNC
feature: esc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-ESC-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

升级年龄 E 从故障边沿置零，以未分频 wdt_clk 计，每个后续边沿递增且不可暂停。要求 `0 <= LOCAL_DELAY < FINAL_DELAY`；LOCAL_DELAY=0 同故障边沿请求局部复位。到 FINAL_DELAY 同拍必最终升级，恢复事件不能覆盖。

#### Acceptance Criteria

- LOCAL_DELAY=0 同拍请求，FINAL_DELAY 精确到期升级；暂停和恢复边界不能推迟期限。

## LRS.FUNC.WATCHDOG.ESC.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.ESC.002
category: FUNC
feature: esc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-ESC-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT 状态服务、清 IRQ、重复错误、配置访问不能重新起算 E。致命自身故障不等待 LOCAL_DELAY/FINAL_DELAY，立即最终升级。最终输出为保持型请求，不用计数器回卷清除。

#### Acceptance Criteria

- FAULT 中反复访问/服务/故障不重算升级年龄；致命异常立即升级，最终请求持续保持。

## LRS.FUNC.WATCHDOG.ESC.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.ESC.003
category: FUNC
feature: esc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-ESC-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

wake_req 为各通道 `(PREWARN_raw && WAKE_EN) || active_fault` 汇总。RAW PREWARN 由 W1C 清除；active_fault 仅由可信恢复流程清除。NMI/safety_alert 对活动故障保持，不由 W1C 解除。

#### Acceptance Criteria

- 预警 wake 受 WAKE_EN 控制；活动故障始终 wake，W1C 不能解除活动 NMI/safety_alert。

