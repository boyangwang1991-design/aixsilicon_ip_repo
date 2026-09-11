# GPIO LRS：集成约束与交付

### LRS.CONS.GPIO.INSTANCEPAD.001

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEPAD.001
category: CONS
feature: instancepad
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/PAD
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供 GPIO 编号/PAD/Pinmux 映射、输入/输出能力以及可用性与拥有权来源。

#### Acceptance Criteria

- 逐引脚检查不存在多驱动、无能力 OE 和错误绑常量。

### LRS.CONS.GPIO.INSTANCEDEFAULTS.002

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEDEFAULTS.002
category: CONS
feature: instancedefaults
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/DEFAULTS
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应确定 RESET_OUT/OE、HW_SAFE_OUT/OE 以及相应板级影响。

#### Acceptance Criteria

- 核对默认和安全输出均为系统允许状态，不能以全零默认替代板级签核。

### LRS.CONS.GPIO.INSTANCECLOCK.003

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCECLOCK.003
category: CONS
feature: instanceclock
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/CLOCK
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供 pclk/aon_clk 范围、停钟条件、同步器 MTBF 目标。

#### Acceptance Criteria

- 目标频率与停止条件完整，CDC 约束能追踪到实际实例。

### LRS.CONS.GPIO.INSTANCERESET.004

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCERESET.004
category: CONS
feature: instancereset
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/RESET
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供 POR/main/AON 复位树及释放顺序。

#### Acceptance Criteria

- 确认主暖复位不清除 AON、锁、策略和 parity 安全请求。

### LRS.CONS.GPIO.INSTANCEPOWER.005

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEPOWER.005
category: CONS
feature: instancepower
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/POWER
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应明确 PAD/AON/主域电源、隔离保持位置与 PMU 握手。

#### Acceptance Criteria

- 入睡边界事件可阻止关电或触发恢复，断电前完成 PAD 接管。

### LRS.CONS.GPIO.INSTANCEELECTRIC.006

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEELECTRIC.006
category: CONS
feature: instanceelectric
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/ELECTRIC
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供开漏上拉、负载、驱动能力和诊断消隐所需外部延迟上界。

#### Acceptance Criteria

- BLANK 时间覆盖输入同步及外部传播，未满足时不得宣称诊断可靠。

### LRS.CONS.GPIO.INSTANCEBUS.007

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEBUS.007
category: CONS
feature: instancebus
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/BUS
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供基地址、APB HWIF 和可信 PPROT 来源。

#### Acceptance Criteria

- 检查地址窗口不重叠，安全属性不能由非可信软件伪造。

### LRS.CONS.GPIO.INSTANCEIRQDMA.008

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCEIRQDMA.008
category: CONS
feature: instanceirqdma
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/IRQDMA
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应提供 IRQ 路由，并确认 DMA 支持四字 HEAD 读取后显式 POP。

#### Acceptance Criteria

- DMA 实测完整事务序列；不支持该序列的 DMA 不得声称兼容。

### LRS.CONS.GPIO.INSTANCESAFETY.009

<!-- LRS_META
id: LRS.CONS.GPIO.INSTANCESAFETY.009
category: CONS
feature: instancesafety
priority: P0
status: active
source_ref:
- gpio_contract.md#§20.2/SAFETY
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

SoC 应指定故障输出接收者、系统安全态和诊断覆盖评估责任。

#### Acceptance Criteria

- 交付假设与 FMEDA/故障模型有明确责任，未经评估不声明 ASIL/DC。

