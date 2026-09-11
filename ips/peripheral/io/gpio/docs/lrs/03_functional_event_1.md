# GPIO LRS：事件FIFO（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.EVT001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT001.001
category: FUNC
feature: evt001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-001
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-001 定义的场景下，FIFO 记录 IRQ 边沿检测事件，受每 Bank EVENT_ENABLE 进一步筛选。IRQ_TEST 和电平模式不写 FIFO。

#### Acceptance Criteria

- FIFO 记录 IRQ 边沿检测事件，受每 Bank EVENT_ENABLE 进一步筛选。IRQ_TEST 和电平模式不写 FIFO。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT001.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT001.002
category: FUNC
feature: evt001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-001
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-001 定义的场景下，每个记录 128-bit：WORD0[6:0]=pin_id、[8]=1 上升/0 下降，其余 0；WORD1=timestamp[31:0]；WORD2=timestamp[63:32]；WORD3=0（保留）。

#### Acceptance Criteria

- 每个记录 128-bit：WORD0[6:0]=pin_id、[8]=1 上升/0 下降，其余 0；WORD1=timestamp[31:0]；WORD2=timestamp[63:32]；WORD3=0（保留）。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT002.001
category: FUNC
feature: evt002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-002
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-002 定义的场景下，timestamp 为主域 64-bit 每周期加 1 自由运行计数器，主复位清零，停钟停止，不代表墙上时间。事件时间戳为生成 event_o 的主域周期计数值。读取当前时间 TS_LO 时锁存 TS_HI 快照，后续读 TS_HI 返回锁存高位；多执行者需要软件互斥。

#### Acceptance Criteria

- timestamp 为主域 64-bit 每周期加 1 自由运行计数器，主复位清零，停钟停止，不代表墙上时间。事件时间戳为生成 event_o 的主域周期计数值。读取当前时间 TS_LO 时锁存 TS_HI 快照，后续读 TS_HI 返回锁存高位；多执行者需要软件互斥。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT003.001
category: FUNC
feature: evt003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-003
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-003 定义的场景下，每周期最多写一条记录。同拍多个选中引脚事件按最小 pin_id 选择一个，其余按丢失计入 LOST_COUNT；FIFO 满时丢弃新事件，不覆盖旧记录。

#### Acceptance Criteria

- 每周期最多写一条记录。同拍多个选中引脚事件按最小 pin_id 选择一个，其余按丢失计入 LOST_COUNT；FIFO 满时丢弃新事件，不覆盖旧记录。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT003.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT003.002
category: FUNC
feature: evt003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-003
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-003 定义的场景下，LOST_COUNT 为 32-bit 饱和计数；任何丢失置 OVERFLOW。该产品不承诺多引脚事件无损记录。

#### Acceptance Criteria

- LOST_COUNT 为 32-bit 饱和计数；任何丢失置 OVERFLOW。该产品不承诺多引脚事件无损记录。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT004.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT004.001
category: FUNC
feature: evt004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-004
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-004 定义的场景下，EVENT_HEAD0～3 是不消费的队头读取。

#### Acceptance Criteria

- EVENT_HEAD0～3 是不消费的队头读取。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT004.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT004.002
category: FUNC
feature: evt004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-004
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-004 定义的场景下，EVENT_POP bit0=1 显式弹出一条，空 FIFO POP 成功无操作；空 FIFO HEAD 读 0。

#### Acceptance Criteria

- EVENT_POP bit0=1 显式弹出一条，空 FIFO POP 成功无操作；空 FIFO HEAD 读 0。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT004.003

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT004.003
category: FUNC
feature: evt004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-004
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-004 定义的场景下，非空期间新写入不改变队头，因此软件先读四字再 POP 可一致读取。多个消费者须软件互斥。

#### Acceptance Criteria

- 非空期间新写入不改变队头，因此软件先读四字再 POP 可一致读取。多个消费者须软件互斥。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT005.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT005.001
category: FUNC
feature: evt005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-005
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-005 定义的场景下，同拍 POP 与写入允许互换槽位；FIFO 满且成功 POP 时可接收一个新事件。

#### Acceptance Criteria

- 同拍 POP 与写入允许互换槽位；FIFO 满且成功 POP 时可接收一个新事件。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT005.002

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT005.002
category: FUNC
feature: evt005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-005
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-005 定义的场景下，FIFO 空且 POP 与新事件同拍，新事件留下，POP 不消费尚不存在的记录。

#### Acceptance Criteria

- FIFO 空且 POP 与新事件同拍，新事件留下，POP 不消费尚不存在的记录。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT005.003

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT005.003
category: FUNC
feature: evt005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-EVT-005
applicability:
  expr: EVENT_FIFO_DEPTH > 0
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-EVT-005 定义的场景下，FLUSH 清 FIFO/LEVEL，且当拍新事件丢弃计入 LOST_COUNT。CLEAR_LOST 与丢失同拍时从 0 加本拍丢失数，OVERFLOW 置位优先。

#### Acceptance Criteria

- FLUSH 清 FIFO/LEVEL，且当拍新事件丢弃计入 LOST_COUNT。CLEAR_LOST 与丢失同拍时从 0 加本拍丢失数，OVERFLOW 置位优先。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

### LRS.FUNC.GPIO.EVT006.001

<!-- LRS_META
id: LRS.FUNC.GPIO.EVT006.001
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

在 GPIO-EVT-006 定义的场景下，WATERMARK 合法范围 1～DEPTH，FIFO_CTRL.EN 控制记录，DMA_EN 控制 dma_req_o=DMA_EN && LEVEL!=0。

#### Acceptance Criteria

- WATERMARK 合法范围 1～DEPTH，FIFO_CTRL.EN 控制记录，DMA_EN 控制 dma_req_o=DMA_EN && LEVEL!=0。
- 检查多引脚同时事件、满/空 POP+PUSH、FLUSH 冲突、饱和丢失及四字读取后 POP；对照队列内容。

