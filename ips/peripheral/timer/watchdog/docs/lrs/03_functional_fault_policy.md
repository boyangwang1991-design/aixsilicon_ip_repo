# Watchdog：故障策略与记录型错误

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.FLT.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.FLT.001
category: FUNC
feature: flt
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-FLT-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT_POLICY 以与上述位同位置的位图指定哪些非致命违规进入 FAULT；TIMEOUT、ALIVE_MISSING、ALIVE_OVERFLOW、FLOW_SEQUENCE、DEADLINE 必须使能。安全配置另强制 EARLY/BAD_KEY/SEQ_TIMEOUT 使能。位11～14、16、17为固定致命，不可降级或屏蔽其最终请求。PREWARN 不能配置成监督故障。

#### Acceptance Criteria

- 强制监督故障不可关闭；致命事件不可屏蔽或降级；PREWARN 不成为 FAULT 策略。

## LRS.FUNC.WATCHDOG.FLT.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.FLT.002
category: FUNC
feature: flt
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-FLT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

记录型服务错误不能刷新计数、更新令牌或贡献客户端完成。重复错误不能覆盖 FIRST_FAULT。IRQ_ENABLE 只控制 IRQ，不能屏蔽原始记录、升级或安全请求。

#### Acceptance Criteria

- 记录型错误不刷新、不更新 token、不贡献完成；IRQ mask 不影响原始事件与复位请求。

