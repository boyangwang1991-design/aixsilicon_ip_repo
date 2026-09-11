# Watchdog：参数合法性与通道独立性

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.CFG.WATCHDOG.PAR.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PAR.001
category: CFG
feature: par
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PAR-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

非法参数组合必须在生成/编译检查阶段报错。自动启动且默认配置非法时不得静默关闭 WDT。

#### Acceptance Criteria

- 非法参数和非法自动启动默认配置均在生成或编译阶段失败；不得退化成关闭监督。

## LRS.CFG.WATCHDOG.PAR.002

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PAR.002
category: CFG
feature: par
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PAR-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

能力寄存器必须反映实际 elaboration 结果；软件写入未实现模式返回 `UNSUPPORTED`，不改变运行状态。

#### Acceptance Criteria

- 逐配置读能力与编译参数一致；选择裁剪模式得到 UNSUPPORTED，运行状态及计时不变。

## LRS.CFG.WATCHDOG.PAR.003

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PAR.003
category: CFG
feature: par
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PAR-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每通道计数、分频相位、服务状态、故障和升级期限独立。允许共享 APB/CDC 和诊断汇总，但不得因其他通道等待或故障而停止本通道计时。

#### Acceptance Criteria

- 制造其他通道忙、故障与恢复，本通道的到期边沿和升级期限均不变化。

