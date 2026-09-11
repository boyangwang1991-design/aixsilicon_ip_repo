# GPIO LRS：配置规则（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.CFG.GPIO.CFG001.001

<!-- LRS_META
id: LRS.CFG.GPIO.CFG001.001
category: CFG
feature: cfg001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CFG-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CFG-001 定义的场景下，RESET_OE/HW_SAFE_OE 不得对无输出能力引脚置 1；RESET_IN_EN 不得对无输入能力引脚置 1。参数非法必须 elaboration 或配置检查失败。

#### Acceptance Criteria

- RESET_OE/HW_SAFE_OE 不得对无输出能力引脚置 1；RESET_IN_EN 不得对无输入能力引脚置 1。参数非法 elaboration 或配置检查失败。
- 检查默认、最小/最大合法配置及越界配置；裁剪实例的能力/地址读写行为符合要求。

### LRS.CFG.GPIO.CFG002.001

<!-- LRS_META
id: LRS.CFG.GPIO.CFG002.001
category: CFG
feature: cfg002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CFG-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CFG-002 定义的场景下，裁剪后寄存器地址不移动；声明的可选寄存器读 0、写忽略。参数范围外 Bank/引脚地址为非法地址。未实现引脚位读 0、写忽略。

#### Acceptance Criteria

- 裁剪后寄存器地址不移动；声明的可选寄存器读 0、写忽略。参数范围外 Bank/引脚地址为非法地址。未实现引脚位读 0、写忽略。
- 检查默认、最小/最大合法配置及越界配置；裁剪实例的能力/地址读写行为符合要求。

### LRS.CFG.GPIO.CFG003.001

<!-- LRS_META
id: LRS.CFG.GPIO.CFG003.001
category: CFG
feature: cfg003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CFG-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CFG-003 定义的场景下，FEATURE 寄存器如实反映裁剪；能力位为静态只读，不可由软件修改。默认配置用于功能覆盖，不作为最小面积推荐配置。

#### Acceptance Criteria

- FEATURE 寄存器如实反映裁剪；能力位为静态只读，不可由软件修改。默认配置用于功能覆盖，不作为最小面积推荐配置。
- 检查默认、最小/最大合法配置及越界配置；裁剪实例的能力/地址读写行为符合要求。

