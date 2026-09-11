# GPIO LRS：外部接口 3

### LRS.INTF.GPIO.PORT.021

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.021
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/aon_gpio_in_i / aon_input_available_i
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 aon_gpio_in_i / aon_input_available_i（输入），其外部合同为：AON 电源域有效的 PAD 输入及路由有效性。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 aon_gpio_in_i / aon_input_available_i 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.022

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.022
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/wake_req_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 wake_req_o（输出），其外部合同为：AON 粘滞唤醒请求，供 PMU 同步。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 wake_req_o 的驱动/接收方及未用时绑定值已声明。

