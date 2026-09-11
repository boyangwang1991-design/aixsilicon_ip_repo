# 中断与安全告警（1）

来源：输入契约的 IRQ 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.001

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.001
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

`irq_o = |(INTR_RAW & INTR_ENABLE)`；`security_alert_o = |(INTR_RAW & ALERT_ENABLE)`。

#### Acceptance Criteria

- 应满足：`irq_o = |(INTR_RAW & INTR_ENABLE)`；`security_alert_o = |(INTR_RAW & ALERT_ENABLE)`。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.002

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.002
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

INTR_RAW 为 W1C 粘滞状态，新事件优先于同周期清除；bits31:9 RAZ/WI。

#### Acceptance Criteria

- 应满足：INTR_RAW 为 W1C 粘滞状态，新事件优先于同周期清除；bits31:9 RAZ/WI。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.003

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.003
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

屏蔽只控制输出，不影响事件捕获、拒绝、计数和日志。

#### Acceptance Criteria

- 应满足：屏蔽只控制输出，不影响事件捕获、拒绝、计数和日志。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.004

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.004
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

完整性故障未复位时 bit4 清除后仍保持置位；其他事件清除后需新事件才重置。

#### Acceptance Criteria

- 应满足：完整性故障未复位时 bit4 清除后仍保持置位；其他事件清除后需新事件才重置。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.00501

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.00501
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

INTR_TEST 仅产生 bit8，不设置真实错误位、不改变权限、不增加真实拒绝计数、不写日志。

#### Acceptance Criteria

- 应满足：INTR_TEST 仅产生 bit8，不设置真实错误位、不改变权限、不增加真实拒绝计数、不写日志。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.00502

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.00502
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

合成日志使用 INJECT_CMD。

#### Acceptance Criteria

- 应满足：合成日志使用 INJECT_CMD。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.00601

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.00601
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

ALERT_ENABLE 的修改仅限管理授权，不受策略锁影响。

#### Acceptance Criteria

- 应满足：ALERT_ENABLE 的修改仅限管理授权，不受策略锁影响。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.00602

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.00602
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FATAL 本身即使告警被屏蔽仍阻断外设。

#### Acceptance Criteria

- 应满足：FATAL 本身即使告警被屏蔽仍阻断外设。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

### LRS.FUNC.APB_SECURE_DEMUX.IRQ.007

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQ.007
category: FUNC
feature: irq
priority: P0
status: active
source_ref:
- REQ-IRQ-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

irq/alert 为 pclk 域电平，跨域送往中断/安全控制器由系统负责同步；本 IP 不直接复位系统。

#### Acceptance Criteria

- 应满足：irq/alert 为 pclk 域电平，跨域送往中断/安全控制器由系统负责同步；本 IP 不直接复位系统。
- 分别检查 RAW、使能和两个输出；覆盖清除与新事件同周期，屏蔽不得丢弃事件。

