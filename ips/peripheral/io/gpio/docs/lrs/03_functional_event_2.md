# GPIO LRS：事件FIFO（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.EVT006.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT006.002
category: FUNC
feature: evt006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-006
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-006 定义的场景下，FAULT_IRQ 的 FIFO 水位源采用 LEVEL>=WATERMARK，溢出源采用粘滞 OVERFLOW。关闭记录不清存量。

#### Acceptance Criteria

- FAULT_IRQ 的 FIFO 水位源采用 LEVEL>=WATERMARK，溢出源采用粘滞 OVERFLOW。关闭记录不清存量。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT007.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT007.001
category: FUNC
feature: evt007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-007
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-007 定义的场景下，DMA 是外部 APB Master，经系统互联读 HEAD0～3 并写 POP；GPIO 无内存 Master 端口、无独立 DMA ACK、无自动 pop-on-read。

#### Acceptance Criteria

- DMA 是外部 APB Master，经系统互联读 HEAD0～3 并写 POP；GPIO 无内存 Master 端口、无独立 DMA ACK、无自动 pop-on-read。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT007.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT007.002
category: FUNC
feature: evt007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-007
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-007 定义的场景下，驱动/DMA 描述符必须支持读四字后显式写 POP 的事务序列。

#### Acceptance Criteria

- 驱动/DMA 描述符支持读四字后显式写 POP 的事务序列。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT007.003

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT007.003
category: FUNC
feature: evt007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-007
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-007 定义的场景下，普通仅固定源地址搬运的 DMA 不自动兼容本 FIFO。

#### Acceptance Criteria

- 普通仅固定源地址搬运的 DMA 不自动兼容本 FIFO。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

