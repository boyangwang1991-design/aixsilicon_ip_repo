# GPIO LRS：产品范围（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.CONS.GPIO.SCP001.001

<!-- LRS_META
id: LRS.CONS.GPIO.SCP001.001
category: CONS
feature: scp001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SCP-001
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-SCP-001 定义的场景下，IP 应提供 1～128 路 GPIO，支持 32-bit APB4 配置、输入同步、滤波去抖、推挽/开漏输出、原子位操作、完整中断、配置锁、低功耗控制，以及可裁剪的 AON 唤醒、事件记录、快照、Strap 和诊断。

#### Acceptance Criteria

- IP 提供 1～128 路 GPIO，支持 32-bit APB4 配置、输入同步、滤波去抖、推挽/开漏输出、原子位操作、完整中断、配置锁、低功耗控制，以及可裁剪的 AON 唤醒、事件记录、快照、Strap 和诊断。
- 核对产品功能、交付语言和系统边界，逐项确认均有后续设计/交付 owner。

### LRS.CONS.GPIO.SCP002.001

<!-- LRS_META
id: LRS.CONS.GPIO.SCP002.001
category: CONS
feature: scp002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SCP-002
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-SCP-002 定义的场景下，实现应以参数化 SystemVerilog 交付。软件应按每 Bank 最多 32 路组织寄存器；Bank 不表示独立电源或时钟域。主功能仅使用一个外部时钟。

#### Acceptance Criteria

- 实现以参数化 SystemVerilog 交付。软件按每 Bank 最多 32 路组织寄存器；Bank 不表示独立电源或时钟域。主功能仅使用一个外部时钟。
- 核对产品功能、交付语言和系统边界，逐项确认均有后续设计/交付 owner。

### LRS.CONS.GPIO.SCP003.001

<!-- LRS_META
id: LRS.CONS.GPIO.SCP003.001
category: CONS
feature: scp003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SCP-003
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-SCP-003 定义的场景下，GPIO 不承担全芯片 Pinmux、模拟模式、上下拉电阻、驱动强度、Slew Rate、Schmitt、耐压和工艺 IO Cell 的实现。上述能力由 Pinmux/Pad Controller/Pad Adapter 提供。

#### Acceptance Criteria

- GPIO 不承担全芯片 Pinmux、模拟模式、上下拉电阻、驱动强度、Slew Rate、Schmitt、耐压和工艺 IO Cell 的实现。上述能力由 Pinmux/Pad Controller/Pad Adapter 提供。
- 核对产品功能、交付语言和系统边界，逐项确认均有后续设计/交付 owner。

### LRS.CONS.GPIO.SCP003.002

<!-- LRS_META
id: LRS.CONS.GPIO.SCP003.002
category: CONS
feature: scp003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SCP-003
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-SCP-003 定义的场景下，GPIO 应提供明确的数字数据、OE、输入有效性和所有权接口。

#### Acceptance Criteria

- GPIO 提供明确的数字数据、OE、输入有效性和所有权接口。
- 核对产品功能、交付语言和系统边界，逐项确认均有后续设计/交付 owner。

