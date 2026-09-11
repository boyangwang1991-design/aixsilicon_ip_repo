# GPIO LRS：中断检测（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.IRQ001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ001.001
category: FUNC
feature: irq001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-001 定义的场景下，每引脚 IRQ_MODE：0=禁用、1=上升沿、2=下降沿、3=双边沿、4=高电平、5=低电平；6/7 非法。检测基于有效 IN_DATA。

#### Acceptance Criteria

- 每引脚 IRQ_MODE：0=禁用、1=上升沿、2=下降沿、3=双边沿、4=高电平、5=低电平；6/7 非法。检测基于有效 IN_DATA。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ002.001
category: FUNC
feature: irq002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-002 定义的场景下，IRQ_DETECT_EN 控制新事件检测；IRQ_ENABLE 只控制 Pending 输出。关闭 DETECT 不清 Pending，关闭 ENABLE 不停止检测。

#### Acceptance Criteria

- IRQ_DETECT_EN 控制新事件检测；IRQ_ENABLE 只控制 Pending 输出。关闭 DETECT 不清 Pending，关闭 ENABLE 不停止检测。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ002.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ002.002
category: FUNC
feature: irq002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-002 定义的场景下，DETECT 从 0→1 时，用当前有效输入建立边沿基线，无历史边沿补发；电平模式可立即触发。

#### Acceptance Criteria

- DETECT 从 0→1 时，用当前有效输入建立边沿基线，无历史边沿补发；电平模式可立即触发。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ003.001
category: FUNC
feature: irq003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-003 定义的场景下，IRQ_PENDING 为 W1C 粘滞状态：next=(old & ~sw_clear)|hw_event|sw_test，置位优先。

#### Acceptance Criteria

- IRQ_PENDING 为 W1C 粘滞状态：next=(old & ~sw_clear)|hw_event|sw_test，置位优先。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ003.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ003.002
category: FUNC
feature: irq003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-003 定义的场景下，IRQ_STATUS=PENDING & ENABLE；irq_pin_o 等于 IRQ_STATUS；irq_summary_o 为 OR。

#### Acceptance Criteria

- IRQ_STATUS=PENDING & ENABLE；irq_pin_o 等于 IRQ_STATUS；irq_summary_o 为 OR。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ004.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ004.001
category: FUNC
feature: irq004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-004 定义的场景下，电平模式条件持续成立时 hw_event 持续为 1，清除不能压过有效电平；输入解除后由软件清 Pending。边沿模式未清期间新边沿可能合并，不表示计数。

#### Acceptance Criteria

- 电平模式条件持续成立时 hw_event 持续为 1，清除不能压过有效电平；输入解除后由软件清 Pending。边沿模式未清期间新边沿可能合并，不表示计数。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ005.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ005.001
category: FUNC
feature: irq005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-005 定义的场景下，IRQ_TEST 写 1 设置 Pending，不依赖输入有效、MODE、DETECT_EN；仍受访问权限约束；不产生 EVENT_FIFO 数据、RISING/FALLING_PENDING 或 event_o。

#### Acceptance Criteria

- IRQ_TEST 写 1 设置 Pending，不依赖输入有效、MODE、DETECT_EN；仍受访问权限约束；不产生 EVENT_FIFO 数据、RISING/FALLING_PENDING 或 event_o。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ006.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ006.001
category: FUNC
feature: irq006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-006 定义的场景下，RISING_PENDING/FALLING_PENDING 分别记录被当前边沿模式选中且 DETECT_EN 有效的上升/下降事件，独立 W1C，硬件置位优先。清 IRQ_PENDING 不清方向状态，反之亦然。

#### Acceptance Criteria

- RISING_PENDING/FALLING_PENDING 分别记录被当前边沿模式选中且 DETECT_EN 有效的上升/下降事件，独立 W1C，硬件置位优先。清 IRQ_PENDING 不清方向状态，反之亦然。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ007.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ007.001
category: FUNC
feature: irq007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-007 定义的场景下，改写 IRQ_MODE 后重建边沿基线，保留 Pending。IN_VALID 首次有效的边沿不作为事件。

#### Acceptance Criteria

- 改写 IRQ_MODE 后重建边沿基线，保留 Pending。IN_VALID 首次有效的边沿不作为事件。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ007.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ007.002
category: FUNC
feature: irq007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IRQ-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IRQ-007 定义的场景下，改写 IRQ_GROUP 仅改变现存 IRQ 的路由，不清状态。

#### Acceptance Criteria

- 改写 IRQ_GROUP 仅改变现存 IRQ 的路由，不清状态。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ008.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ008.001
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

在 GPIO-IRQ-008 定义的场景下，每引脚只选择一个 IRQ_GROUP，编码小于 N_IRQ_GROUPS。

#### Acceptance Criteria

- 每引脚只选择一个 IRQ_GROUP，编码小于 N_IRQ_GROUPS。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

### LRS.FUNC.GPIO.IRQ008.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IRQ008.002
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

在 GPIO-IRQ-008 定义的场景下，group[g]=OR(IRQ_STATUS[i] && route[i]==g)。

#### Acceptance Criteria

- group[g]=OR(IRQ_STATUS[i] && route[i]==g)。
- 覆盖各模式、DETECT/ENABLE 组合、有效性恢复、清除与事件同拍；比较 Pending、方向、分组和 event_o。

