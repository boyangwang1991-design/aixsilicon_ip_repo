# GPIO LRS：外部接口 1

### LRS.INTF.GPIO.PORT.001

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.001
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/pclk_i
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 pclk_i（输入），其外部合同为：主域及 APB 时钟。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 pclk_i 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.002

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.002
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/por_ni
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 por_ni（输入），其外部合同为：芯片冷复位；各域异步置位、同步释放。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 por_ni 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.003

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.003
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/main_rst_ni
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 main_rst_ni（输入），其外部合同为：主功能暖复位；与 POR 组合生成主域复位。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 main_rst_ni 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.004

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.004
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/APB4
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 APB4（双向），其外部合同为：PADDR[13:0]、PWDATA/PRDATA[31:0]、PSTRB[3:0]、PPROT[2:0]、PSEL/PENABLE/PWRITE/PREADY/PSLVERR。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 APB4 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.005

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.005
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/gpio_in_i[N_GPIO]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 gpio_in_i[N_GPIO]（输入），其外部合同为：来自 PAD/输入路由的数字信号，可异步。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 gpio_in_i[N_GPIO] 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.006

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.006
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/input_available_i[N_GPIO]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 input_available_i[N_GPIO]（输入），其外部合同为：主域同步状态；输入路由和接收器有效。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 input_available_i[N_GPIO] 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.007

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.007
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/output_owned_i[N_GPIO]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 output_owned_i[N_GPIO]（输入），其外部合同为：主域同步状态；GPIO 当前拥有输出路径。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 output_owned_i[N_GPIO] 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.008

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.008
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/gpio_out_o / gpio_oe_o
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 gpio_out_o / gpio_oe_o（输出），其外部合同为：主域数字输出/OE，高有效。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 gpio_out_o / gpio_oe_o 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.009

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.009
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/irq_pin_o[N_GPIO]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 irq_pin_o[N_GPIO]（输出），其外部合同为：逐引脚电平中断。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 irq_pin_o[N_GPIO] 的驱动/接收方及未用时绑定值已声明。

### LRS.INTF.GPIO.PORT.010

<!-- LRS_META
id: LRS.INTF.GPIO.PORT.010
category: INTF
feature: port
priority: P0
status: active
source_ref:
- gpio_contract.md#§3/irq_group_o[N_IRQ_GROUPS]
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应提供 irq_group_o[N_IRQ_GROUPS]（输出），其外部合同为：路由后分组电平中断。

#### Acceptance Criteria

- 检查端口方向、位宽及域归属符合定义；配置变化时宽度随参数一致变化。
- 集成检查确认 irq_group_o[N_IRQ_GROUPS] 的驱动/接收方及未用时绑定值已声明。

