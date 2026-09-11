# GPIO LRS：性能与资源（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.PERF.GPIO.ARC002.001

<!-- LRS_META
id: LRS.PERF.GPIO.ARC002.001
category: PERF
feature: arc002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-002
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-002 定义的场景下，未使用通道和裁剪功能应允许综合移除。

#### Acceptance Criteria

- 未使用通道和裁剪功能允许综合移除。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

### LRS.PERF.GPIO.ARC002.002

<!-- LRS_META
id: LRS.PERF.GPIO.ARC002.002
category: PERF
feature: arc002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-002
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-002 定义的场景下，输入可靠同步要求不可被运行时配置绕过；资源实现选择在 HLD/LLD 说明。

#### Acceptance Criteria

- 输入可靠同步要求不可被运行时配置绕过；资源实现选择在 HLD/LLD 说明。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

### LRS.PERF.GPIO.ARC004.001

<!-- LRS_META
id: LRS.PERF.GPIO.ARC004.001
category: PERF
feature: arc004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-004
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-004 定义的场景下，V1.0 无 AXI/AHB 接口、无自动波形发生器、PWM、协议引擎或专用高速脉冲计数器。

#### Acceptance Criteria

- V1.0 无 AXI/AHB 接口、无自动波形发生器、PWM、协议引擎或专用高速脉冲计数器。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

### LRS.PERF.GPIO.ARC004.002

<!-- LRS_META
id: LRS.PERF.GPIO.ARC004.002
category: PERF
feature: arc004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-004
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-004 定义的场景下，APB 持续零等待访问最短每两主时钟完成一次写；通过 TOGGLE 连续写实现完整输出方波最快每四主周期一周期，实际受上游限制。

#### Acceptance Criteria

- APB 持续零等待访问最短每两主时钟完成一次写；通过 TOGGLE 连续写实现完整输出方波最快每四主周期一周期，实际受上游限制。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

### LRS.PERF.GPIO.ARC005.001

<!-- LRS_META
id: LRS.PERF.GPIO.ARC005.001
category: PERF
feature: arc005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-005
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-005 定义的场景下，综合报告至少覆盖 N_GPIO=8/32/128、最小裁剪和完整配置，分别报告面积、关键路径、动态功耗估计和 AON 成本。

#### Acceptance Criteria

- 综合报告至少覆盖 N_GPIO=8/32/128、最小裁剪和完整配置，分别报告面积、关键路径、动态功耗估计和 AON 成本。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

### LRS.PERF.GPIO.ARC005.002

<!-- LRS_META
id: LRS.PERF.GPIO.ARC005.002
category: PERF
feature: arc005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-ARC-005
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-ARC-005 定义的场景下，频率目标由目标库/工艺集成约束给出，本文不虚构 MHz/PPA 指标。

#### Acceptance Criteria

- 频率目标由目标库/工艺集成约束给出，本文不虚构 MHz/PPA 指标。
- 审查对应实现或综合/时序/功耗报告，保留配置和目标库约束，未测项目不得宣称通过。

