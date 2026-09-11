# GPIO LRS：外部接口 2

### LRS.INTF.GPIO.PORT.011

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.011
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/irq_summary_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 irq_summary_o（输出），其外部合同为：全部引脚 IRQ 的 OR。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 irq_summary_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.012

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.012
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/event_o[N_GPIO]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 event_o[N_GPIO]（输出），其外部合同为：主域单周期合格边沿事件，与 IRQ_ENABLE 无关。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 event_o[N_GPIO] 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.013

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.013
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/sleep_req_i / sleep_ack_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 sleep_req_i / sleep_ack_o（输入/输出），其外部合同为：主域同步休眠覆盖握手。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 sleep_req_i / sleep_ack_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.014

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.014
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/safe_req_i
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 safe_req_i（输入），其外部合同为：主域同步安全覆盖请求。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 safe_req_i 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.015

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.015
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/safe_active_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 safe_active_o（输出），其外部合同为：主域安全覆盖已生效。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 safe_active_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.016

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.016
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/snapshot_req_i
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 snapshot_req_i（输入），其外部合同为：主域单周期快照触发。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 snapshot_req_i 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.017

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.017
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/strap_sample_i
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 strap_sample_i（输入），其外部合同为：主域同步 Strap 捕获请求。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 strap_sample_i 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.018

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.018
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/fault_irq_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 fault_irq_o（输出），其外部合同为：主域诊断/访问/FIFO 故障汇总。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 fault_irq_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.019

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.019
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/dma_req_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 dma_req_o（输出），其外部合同为：主域事件 FIFO 数据可用请求。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 dma_req_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.020

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.020
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/aon_clk_i / aon_rst_ni
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 aon_clk_i / aon_rst_ni（输入），其外部合同为：可选常开时钟/复位，aon_rst_ni 仅由冷复位树控制。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 aon_clk_i / aon_rst_ni 的驱动/接收方及未用时绑定值已声明。

