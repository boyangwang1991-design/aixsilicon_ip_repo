# GPIO LRS：中断检测（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.IRQ008.003

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ008.003
category: FUNC
feature: irq008
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-008
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-008 定义的场景下，IRQ 路由无独立消费者 Pending；共享消费者须由驱动协调清除。

#### Acceptance Criteria

- IRQ 路由无独立消费者 Pending；共享消费者须由驱动协调清除。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ009.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ009.001
category: FUNC
feature: irq009
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-009
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-009 定义的场景下，event_o 仅对合格物理输入处理后的边沿事件输出 1 拍，受 IRQ_MODE 和 DETECT_EN 约束，不受 IRQ_ENABLE 约束；电平中断不每拍写事件 FIFO。

#### Acceptance Criteria

- event_o 仅对合格物理输入处理后的边沿事件输出 1 拍，受 IRQ_MODE 和 DETECT_EN 约束，不受 IRQ_ENABLE 约束；电平中断不每拍写事件 FIFO。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ009.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ009.002
category: FUNC
feature: irq009
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-009
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-009 定义的场景下，跨域消费者必须采用额外握手/计数/FIFO，不能直接同步短脉冲。

#### Acceptance Criteria

- 跨域消费者采用额外握手/计数/FIFO，不能直接同步短脉冲。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

