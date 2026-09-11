# Watchdog：GROUP、ALIVE 与 FLOW

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.SUP.006

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.006
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

ALIVE 周期中 PRETIMEOUT 到期只在当时尚有客户端未达 MIN 时产生预警。BOOT 周期使用 BOOT_TIMEOUT 作为首个固定观测周期，成功后转 RUN。固定时间检查能够发现软件过快报到，不能被高频服务无限推迟检查。

#### Acceptance Criteria

- ALIVE 仅缺少 MIN 时预警；BOOT 首周期成功转 RUN；持续高频服务不能推迟周期评价。

## LRS.FUNC.WATCHDOG.SUP.007

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.007
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FLOW 为每客户端定义线性检查点 `0..LAST_STEP`，LAST_STEP 为 1～255。START(data=0) 开启该客户端本轮流程；之后 STEP 必须严格递增至 LAST_STEP-1；END(data=LAST_STEP) 结束。LAST_STEP=1 时 START 后直接 END。该模式不使用密钥服务，SERVICE_MODE 必须设 0，采用来源授权和检查点检查。

#### Acceptance Criteria

- LAST_STEP=1 和 255 均符合 START/STEP/END 定义；FLOW 禁止非 SINGLE_KEY 编码配置。

## LRS.FUNC.WATCHDOG.SUP.008

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.008
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-008
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每客户端 START 在本轮只允许一次；重复、跳步、倒序、未 START 的 END 均为 FLOW_SEQUENCE。START/STEP 可在主窗口前发生，但 END 必须满足主窗口，否则 EARLY_SERVICE。所有必需客户端 END 后刷新通道。

#### Acceptance Criteria

- 重复/跳步/倒序/未 START 的 END 触发 FLOW_SEQUENCE；早 END 失败；最后完成才刷新。

## LRS.FUNC.WATCHDOG.SUP.009

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.009
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-009
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

独立未分频 W-bit deadline 计数从 START 边沿置零，下一个边沿起递增。END 必须满足 `DEADLINE_MIN <= elapsed < DEADLINE_MAX`，MAX>MIN；到达 MAX 边沿时，Deadline 超时优先于 END。PAUSED 冻结；其他客户端服务不延后该期限。

#### Acceptance Criteria

- END 在 MIN 接受、MAX 拒绝；暂停冻结 Deadline；其他客户端活动不能延期。

## LRS.FUNC.WATCHDOG.SUP.010

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SUP.010
category: FUNC
feature: sup
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SUP-010
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

完整完成前主 TIMEOUT 仍有约束；两类期限先到先故障。FLOW 仅覆盖配置的线性检查点顺序及时间，不声称完整控制流或数据正确性验证。

#### Acceptance Criteria

- 主超时与 Deadline 任一先到均故障；声明 FLOW 只保证指定线性检查点与时间条件。

