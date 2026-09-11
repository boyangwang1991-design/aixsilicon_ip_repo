# Watchdog：诊断注入与自检

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.DFX.WATCHDOG.TST.001

<!-- LRS_META
id: LRS.DFX.WATCHDOG.TST.001
category: DFX
feature: tst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TST-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DIAG_INJECT_EN=1 且 test_auth、配置诊断授权、未 DIAG_LOCK、解锁额度有效时，允许注入：主计数位翻转、分频位翻转、阈值副本翻转、状态非法编码、单比较路径翻转、服务判定完整性错误。注入选择由 FAULT_INJECT 命令数据定义，单次消费，不能持续压制真实故障。

#### Acceptance Criteria

- 六类真实注入分别经过全部授权条件，逐一撤销条件时禁止；单次命令仅注入一次。

## LRS.DFX.WATCHDOG.TST.002

<!-- LRS_META
id: LRS.DFX.WATCHDOG.TST.002
category: DFX
feature: tst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TST-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

注入后必须经过真实故障检测和真实告警锁存路径；默认不屏蔽最终复位请求。若测试平台需防止实际复位，旁路由外部测试环境实现，并记录这不等于已测试真实系统执行链。

#### Acceptance Criteria

- 注入经过真实检测/告警路径且默认最终请求不屏蔽；外部旁路须在结果中披露。

## LRS.DFX.WATCHDOG.TST.003

<!-- LRS_META
id: LRS.DFX.WATCHDOG.TST.003
category: DFX
feature: tst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TST-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IRQ_TEST 仅测试中断通路，置单独测试状态，不推进监督计数、不证明超时比较器覆盖。超时自检通过专用未承担生产监督的通道配置短期限并停止服务完成，不提供运行中任意写 C 的后门。

#### Acceptance Criteria

- IRQ_TEST 仅产生测试事件；短期限不服务可触发真实超时；无运行计数写后门。

## LRS.DFX.WATCHDOG.TST.004

<!-- LRS_META
id: LRS.DFX.WATCHDOG.TST.004
category: DFX
feature: tst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TST-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

诊断测试事件标记 TEST_CONTEXT；真实故障位仍置位，FIRST_FAULT 应记录当时测试上下文。生产配置可彻底裁剪注入入口；scan/test 模式及生命周期要求须在集成文档列出。

#### Acceptance Criteria

- 测试事件有 TEST_CONTEXT 且真实故障位照常置位；生产裁剪实例无法访问注入功能。

## LRS.DFX.WATCHDOG.TST.005

<!-- LRS_META
id: LRS.DFX.WATCHDOG.TST.005
category: DFX
feature: tst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TST-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

交付安全说明应列出故障模型、检测路径、最大检测延迟、未覆盖故障、时钟/电源/复位共因、周期测试建议及系统假设。不得在没有分析和验证证据时标注 ASIL 达成或固定诊断覆盖百分比。

#### Acceptance Criteria

- 安全说明逐项覆盖故障模型、检测路径/延迟、盲区、共因和周期测试，不虚构 ASIL 或诊断比例。

