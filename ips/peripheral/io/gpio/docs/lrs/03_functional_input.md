# GPIO LRS：输入处理（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.IN001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IN001.001
category: FUNC
feature: in001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-001 定义的场景下，软件可见 IN_SYNC 应表示经过 SYNC_STAGES 输入同步后的物理值；IN_DATA 应依次应用毛刺滤波、去抖和输入反相。运行时配置不得绕过输入同步。

#### Acceptance Criteria

- 软件可见 IN_SYNC 表示经过 SYNC_STAGES 输入同步后的物理值；IN_DATA 依次用毛刺滤波、去抖和输入反相。运行时配置不得绕过输入同步。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

### LRS.FUNC.GPIO.IN002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IN002.001
category: FUNC
feature: in002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-002 定义的场景下，输入有效前提为 INPUT_CAP_MASK && IN_ENABLE && input_available_i。

#### Acceptance Criteria

- 输入有效前提为 INPUT_CAP_MASK && IN_ENABLE && input_available_i。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

### LRS.FUNC.GPIO.IN002.002

<!-- LRS_META
id: LRS.FUNC.GPIO.IN002.002
category: FUNC
feature: in002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-002 定义的场景下，前提失效当拍清 IN_VALID、IN_DATA=0、清处理历史和计数、抑制新检测；IN_SYNC 在前提失效时软件读 0。已记录 Pending/FIFO/快照不隐式清除。

#### Acceptance Criteria

- 前提失效当拍清 IN_VALID、IN_DATA=0、清处理历史和计数、抑制新检测；IN_SYNC 在前提失效时软件读 0。已记录 Pending/FIFO/快照不隐式清除。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

### LRS.FUNC.GPIO.IN003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IN003.001
category: FUNC
feature: in003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-003 定义的场景下，前提重新成立后等待 SYNC_STAGES 个完整主域边沿填充同步路径，然后按启用的滤波/去抖阶段建立初值。最后一级首次给出有效值时设置 IN_VALID 并建立边沿基线，不产生边沿事件；有效电平模式可以立即置 Pending。

#### Acceptance Criteria

- 前提重新成立后等待 SYNC_STAGES 个完整主域边沿填充同步路径，然后按启用的滤波/去抖阶段建立初值。最后一级首次给出有效值时设置 IN_VALID 并建立边沿基线，不产生边沿事件；有效电平模式可以立即置 Pending。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

### LRS.FUNC.GPIO.IN004.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IN004.001
category: FUNC
feature: in004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-004 定义的场景下，输入反相只影响 IN_DATA、中断和主域事件；不影响 IN_SYNC、Strap、诊断物理比较以及 AON 唤醒定义。

#### Acceptance Criteria

- 输入反相只影响 IN_DATA、中断和主域事件；不影响 IN_SYNC、Strap、诊断物理比较以及 AON 唤醒定义。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

### LRS.FUNC.GPIO.IN005.001

<!-- LRS_META
id: LRS.FUNC.GPIO.IN005.001
category: FUNC
feature: in005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IN-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IN-005 定义的场景下，输出模式可同时采样输入。关闭 GPIO 输入处理不等同关闭 PAD 接收器；PAD 接收器由 Pad Controller 控制。

#### Acceptance Criteria

- 输出模式可同时采样输入。关闭 GPIO 输入处理不等同关闭 PAD 接收器；PAD 接收器由 Pad Controller 控制。
- 施加初始高低、available/enable 撤销恢复及首次有效，逐拍比较 IN_SYNC、IN_DATA、IN_VALID 与事件。

