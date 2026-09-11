# GPIO LRS：静态参数 1

### LRS.CFG.GPIO.PARAM.001

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.001
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/N_GPIO
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 N_GPIO，合法值/默认值为 1～128 / 32，用于引脚数；N_BANK=ceil(N_GPIO/32)。

#### Acceptance Criteria

- 默认实例中 N_GPIO 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.002

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.002
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/SYNC_STAGES
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 SYNC_STAGES，合法值/默认值为 2～4 / 2，用于主域输入同步级数。

#### Acceptance Criteria

- 默认实例中 SYNC_STAGES 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.003

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.003
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/INPUT_CAP_MASK
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 INPUT_CAP_MASK，合法值/默认值为 N_GPIO 位 / 全 1，用于输入能力。

#### Acceptance Criteria

- 默认实例中 INPUT_CAP_MASK 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.004

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.004
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/OUTPUT_CAP_MASK
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 OUTPUT_CAP_MASK，合法值/默认值为 N_GPIO 位 / 全 1，用于输出能力。

#### Acceptance Criteria

- 默认实例中 OUTPUT_CAP_MASK 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.005

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.005
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/RESET_OUT
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 RESET_OUT，合法值/默认值为 N_GPIO 位 / 0，用于输出锁存复位值。

#### Acceptance Criteria

- 默认实例中 RESET_OUT 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.006

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.006
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/RESET_OE
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 RESET_OE，合法值/默认值为 N_GPIO 位 / 0，用于输出使能复位值。

#### Acceptance Criteria

- 默认实例中 RESET_OE 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.007

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.007
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/RESET_IN_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 RESET_IN_EN，合法值/默认值为 N_GPIO 位 / INPUT_CAP_MASK，用于输入处理复位使能。

#### Acceptance Criteria

- 默认实例中 RESET_IN_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.008

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.008
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/N_IRQ_GROUPS
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 N_IRQ_GROUPS，合法值/默认值为 1～4 / 1，用于中断分组。

#### Acceptance Criteria

- 默认实例中 N_IRQ_GROUPS 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.009

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.009
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/OUT_INV_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 OUT_INV_EN，合法值/默认值为 0/1 / 1，用于输出反相。

#### Acceptance Criteria

- 默认实例中 OUT_INV_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.010

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.010
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/AON_WAKE_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 AON_WAKE_EN，合法值/默认值为 0/1 / 1，用于常开唤醒模块。

#### Acceptance Criteria

- 默认实例中 AON_WAKE_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

