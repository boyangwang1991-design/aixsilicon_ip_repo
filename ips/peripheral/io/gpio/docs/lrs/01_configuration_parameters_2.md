# GPIO LRS：静态参数 2

### LRS.CFG.GPIO.PARAM.011

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.011
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/SNAPSHOT_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 SNAPSHOT_EN，合法值/默认值为 0/1 / 1，用于输入快照。

#### Acceptance Criteria

- 默认实例中 SNAPSHOT_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.012

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.012
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/STRAP_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 STRAP_EN，合法值/默认值为 0/1 / 1，用于主功能域一次性 Strap。

#### Acceptance Criteria

- 默认实例中 STRAP_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.013

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.013
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/EVENT_FIFO_DEPTH
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 EVENT_FIFO_DEPTH，合法值/默认值为 0、4、8、16、32、64 / 16，用于0 裁剪事件记录。

#### Acceptance Criteria

- 默认实例中 EVENT_FIFO_DEPTH 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.014

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.014
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/DIAG_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 DIAG_EN，合法值/默认值为 0/1 / 1，用于输出回读诊断。

#### Acceptance Criteria

- 默认实例中 DIAG_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.015

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.015
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/ACCESS_CTRL_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 ACCESS_CTRL_EN，合法值/默认值为 0/1 / 1，用于安全/特权访问控制。

#### Acceptance Criteria

- 默认实例中 ACCESS_CTRL_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.016

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.016
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/CFG_PARITY_EN
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 CFG_PARITY_EN，合法值/默认值为 0/1 / 0，用于关键寄存器 parity。

#### Acceptance Criteria

- 默认实例中 CFG_PARITY_EN 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.017

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.017
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/BOOT_SECURE_ONLY
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 BOOT_SECURE_ONLY，合法值/默认值为 0/1 / 1，用于上电业务访问安全限制。

#### Acceptance Criteria

- 默认实例中 BOOT_SECURE_ONLY 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.018

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.018
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/BOOT_PRIV_ONLY
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 BOOT_PRIV_ONLY，合法值/默认值为 0/1 / 1，用于上电业务访问特权限制。

#### Acceptance Criteria

- 默认实例中 BOOT_PRIV_ONLY 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

### LRS.CFG.GPIO.PARAM.019

<!-- LRS_META
id: LRS.CFG.GPIO.PARAM.019
category: CFG
feature: param
priority: P0
status: active
source_ref:
- gpio_contract.md#§2.1/HW_SAFE_OUT / HW_SAFE_OE
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应提供静态参数 HW_SAFE_OUT / HW_SAFE_OE，合法值/默认值为 N_GPIO 位 / 0，用于独立安全覆盖的物理值。

#### Acceptance Criteria

- 默认实例中 HW_SAFE_OUT / HW_SAFE_OE 符合所列默认值。
- 合法范围内可配置；超出范围或位宽不匹配时配置检查或 elaboration 失败。

