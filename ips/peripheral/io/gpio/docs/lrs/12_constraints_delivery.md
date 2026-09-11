# GPIO LRS：完整交付要求

### LRS.CONS.GPIO.DELIVERY.001

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.001
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/设计说明
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付规范需求、架构与微设计说明，以及寄存器机器可读定义及生成结果。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.002

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.002
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/RTL
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付参数化 RTL、FuseSoC core、编译/仿真/综合入口。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.003

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.003
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/验证
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付APB/GPIO 验证环境、RAL、独立参考模型、SVA、测试及覆盖报告。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.004

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.004
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/软件
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付C 寄存器头文件和输出、中断、AON 唤醒、事件 FIFO 示例驱动。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.005

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.005
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/约束
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付CDC/RDC/STA 约束、复位/电源域接口说明及低功耗集成例。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.006

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.006
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/配置
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付功能裁剪/能力查询说明、PPA 报告及已知限制。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

### LRS.CONS.GPIO.DELIVERY.007

<!-- LRS_META
id: LRS.CONS.GPIO.DELIVERY.007
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.1/安全
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

产品应交付启用安全增强时的故障模型、注入测试和使用假设。

#### Acceptance Criteria

- 检查实际文件及其输入/输出哈希、内容和可复现入口；未执行的测试或分析必须保持未完成状态。

