# Watchdog：GROUP、ALIVE 与 FLOW

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.SUP.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.001
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

客户端 ID 只是选择索引，身份保护由 OWNER_SOURCE 与可信来源比较实现。同一个 OWNER_SOURCE 管理多个客户端时，不宣称这些任务彼此隔离。

#### Acceptance Criteria

- 匹配 OWNER_SOURCE 才接受；相同来源管理多个客户端的实例不宣称任务隔离。

## LRS.FUNC.WATCHDOG.SUP.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.002
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

SINGLE 的完整服务在合法窗口直接刷新通道。GROUP 的各客户端完整服务在合法窗口置 SEEN_MASK 位；最后一个必需客户端服务使 mask 完整时，才刷新通道。同拍刷新后 SEEN_MASK 清零开始新轮。

#### Acceptance Criteria

- GROUP 非最后客户端服务不刷新；最后必需客户端完成后刷新并清 SEEN_MASK。

## LRS.FUNC.WATCHDOG.SUP.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.003
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

GROUP 在窗口开启前的完整客户端服务属于 EARLY_SERVICE；重复报到属于 DUPLICATE_CLIENT，默认记录且不贡献第二次报到。重复报到不更新 token。主超时记录 `REQUIRE_MASK & ~SEEN_MASK`。第一笔双密钥允许在窗口前开始，但完整服务仍需在窗口内完成。

#### Acceptance Criteria

- 过早、重复、缺失分别得到规定事件和位图；重复报到不更新 token；第一密钥可提前。

## LRS.FUNC.WATCHDOG.SUP.004

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.004
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

ALIVE 使用固定观测周期 TIMEOUT，不接受由窗口大小决定的提前刷新；WIN_EN 必须为 0。每客户端每次完整服务增加 16-bit 饱和事件数，MIN_ALIVE/MAX_ALIVE 满足 `1 <= MIN <= MAX <= 65535`。超过 MAX 当拍产生 ALIVE_OVERFLOW。

#### Acceptance Criteria

- ALIVE 配置禁止窗口；MIN/MAX 取 1 和 65535 边界，超过 MAX 当拍告警。

## LRS.FUNC.WATCHDOG.SUP.005

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.005
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

`A=TIMEOUT` 边沿先对刚结束的周期统计进行评估：全部必需客户端计数满足范围则自动刷新周期、清零统计；否则 ALIVE_MISSING 故障并记录不足客户端。该边沿新到来的服务拒绝为 EPOCH_BOUNDARY，不归前后任一周期、不形成额外故障，调用方需下一拍重试。该规则是 ALIVE 对普通“TIMEOUT 必故障”的唯一例外。

#### Acceptance Criteria

- 周期边界先评价旧计数；健康时刷新、缺失时故障；边界新服务返回 EPOCH_BOUNDARY 且不计入任一周期。

