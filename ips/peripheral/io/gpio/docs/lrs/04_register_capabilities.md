# GPIO LRS：寄存器软件兼容与状态能力

### LRS.REG.GPIO.MAP.001

<!-- LRS_META
id: LRS.REG.GPIO.MAP.001
category: REG
feature: map
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/MAP
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应在固定 16 KiB APB 空间访问全局、Bank、逐引脚及 AON 窗口，地址与字段编码须兼容输入合同 §15；没有列出的字地址均非法。

#### Acceptance Criteria

- 逐项比对后续 SystemRDL 与来源 §15；所有地址空间空洞、范围外 Bank/引脚以及 RO 写返回错误。

### LRS.REG.GPIO.IDENTITY.002

<!-- LRS_META
id: LRS.REG.GPIO.IDENTITY.002
category: REG
feature: identity
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/IDENTITY
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应可读取 IP_ID=0x4750494F、VERSION=0x00010000 和 FEATURE/GEOMETRY，用于识别产品、功能裁剪、引脚数、Bank 数、中断组数和同步级数。

#### Acceptance Criteria

- 在最小、默认、最大及功能裁剪配置读回身份/能力，且软件写不能改变常量。

### LRS.REG.GPIO.FAULT.003

<!-- LRS_META
id: LRS.REG.GPIO.FAULT.003
category: REG
feature: fault
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/FAULT
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT_STATUS 应区分访问错误、FIFO 溢出、水位、AON 超时/错误、Strap 过早、parity 和诊断实时汇总；FAULT_IRQ_ENABLE 默认关闭报警输出。

#### Acceptance Criteria

- 逐一置故障并检查状态、使能前后的 fault_irq_o，互不混淆实时源与 sticky 源。

### LRS.REG.GPIO.FIRST.004

<!-- LRS_META
id: LRS.REG.GPIO.FIRST.004
category: REG
feature: first
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/FIRST
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT_CLEAR.ACCESS 应同时释放 ACCESS_FIRST 首故障槽；与新错误同拍时应记录新错误并保持故障置位。

#### Acceptance Criteria

- 先产生错误占槽，再同拍清除和新错误；检查新地址、PPROT、读写属性与有效标志。

### LRS.REG.GPIO.LOST.005

<!-- LRS_META
id: LRS.REG.GPIO.LOST.005
category: REG
feature: lost
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/LOST
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT_CLEAR 的 FIFO_OVERFLOW 只应清溢出标志，不能清 LOST；FIFO_CMD.CLEAR_LOST 应清丢失计数和溢出标志，并服从新丢失置位优先。

#### Acceptance Criteria

- 预置非零 LOST/OVERFLOW，分别执行两种清除并与新丢失竞争，检查各自效果。

### LRS.REG.GPIO.AONRESULT.006

<!-- LRS_META
id: LRS.REG.GPIO.AONRESULT.006
category: REG
feature: aonresult
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/AONRESULT
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每个成功 AON 应答应更新整组 Pending、有效输入、锁、活动配置的主域读回窗口；DONE 保持至下一合法命令接受。

#### Acceptance Criteria

- 对每个 Bank 依次执行四种合法命令并核对完整读回；拒绝命令不得伪造成功读回或清 DONE。

### LRS.REG.GPIO.DEFAULT.007

<!-- LRS_META
id: LRS.REG.GPIO.DEFAULT.007
category: REG
feature: default
priority: P0
status: active
source_ref:
- gpio_contract.md#§15/DEFAULT
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

RW/W1S 默认零，来源 §15 所列例外必须按各自默认值实现；RO 动态状态随硬件、RO 常量在暖复位保持。

#### Acceptance Criteria

- 由 SystemRDL 生成 RAL reset 检查，并单独验证动态状态、POR 保持寄存器及 BOOT 参数。

