# Watchdog：全流程验收要求

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.CONS.WATCHDOG.VER.001

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.001
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

RUN普通/窗口模式、wdt_clk持续、无授权暂停/恢复条件下，从周期开始 TIMEOUT*(P+1) 个周期内若无合法刷新，必须进入对应故障响应。

#### Acceptance Criteria

- 在持续时钟且无暂停恢复假设下，用断言或等强证据验证规定期限故障。

## LRS.CONS.WATCHDOG.VER.002

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.002
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-002
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

不合法服务、IRQ清除、配置写、第一次密钥、其他通道服务不能重置本通道 C/D。ALIVE 固定周期刷新为明确列出的例外。

#### Acceptance Criteria

- 逐个非法/无关操作验证不会改变本通道周期；ALIVE 成功边界例外显式覆盖。

## LRS.CONS.WATCHDOG.VER.003

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.003
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

FAULT 后未发生合格恢复/POR，FINAL_DELAY 不能被服务、访问、暂停或重复故障延后。请求置位后，在指定恢复事件前必须保持。

#### Acceptance Criteria

- 故障后持续施加服务/访问/暂停/重复故障，最终升级不延期，请求保持至合格恢复。

## LRS.CONS.WATCHDOG.VER.004

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.004
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-004
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

一个被APB成功接收的邮箱命令最多执行一次；未接收/返回PSLVERR的写无对应状态副作用；执行、取消、错误结果与DONE_SEQ一一对应。

#### Acceptance Criteria

- 接收、执行、取消、拒绝与完成序号逐一对账，返回错误的请求没有对应操作副作用。

## LRS.CONS.WATCHDOG.VER.005

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.005
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-005
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

锁只能按规定复位清除；多字阈值更新只能旧配置或新配置整体生效，不能使用混合值。

#### Acceptance Criteria

- 全部复位类型验证锁保持/清除；多字参数观察结果只有完整旧值或完整新值。

## LRS.CONS.WATCHDOG.VER.006

<!-- LRS_META
id: LRS.CONS.WATCHDOG.VER.006
category: CONS
feature: ver
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-VER-006
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

对每种配置档必须建立需求→feature→test/checker/assertion→coverage追踪。功能覆盖需包含边界和关键交叉，不能仅用代码覆盖率替代。安全机制另外提供故障注入结果和未覆盖项说明。

#### Acceptance Criteria

- 每个配置适用需求有 feature/test/checker/assertion/coverage 追踪；单列故障注入与未覆盖项。

