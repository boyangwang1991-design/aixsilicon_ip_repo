# GPIO LRS：时钟与复位

### LRS.RESET.GPIO.STATE.001

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.001
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/主功能 CSR、事件 FIFO、主 Pending、快照与 Strap
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 主功能 CSR、事件 FIFO、主 Pending、快照与 Strap，冷复位应恢复默认值；main 暖复位应恢复默认值。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 主功能 CSR、事件 FIFO、主 Pending、快照与 Strap 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.STATE.002

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.002
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/CFG_LOCK、DATA_LOCK、GLOBAL_LOCK 与 ACCESS_CFG
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 CFG_LOCK、DATA_LOCK、GLOBAL_LOCK 与 ACCESS_CFG，冷复位应锁清零、策略恢复 BOOT 参数默认；main 暖复位应保持原值。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 CFG_LOCK、DATA_LOCK、GLOBAL_LOCK 与 ACCESS_CFG 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.STATE.003

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.003
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/主 parity 故障安全请求
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 主 parity 故障安全请求，冷复位应清除；main 暖复位应保持。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 主 parity 故障安全请求 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.STATE.004

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.004
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/AON 活动配置、WAKE_LOCK 与 Pending
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 AON 活动配置、WAKE_LOCK 与 Pending，冷复位应恢复默认值；main 暖复位应保持。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 AON 活动配置、WAKE_LOCK 与 Pending 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.STATE.005

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.005
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/主域 AON staging 与读回缓存
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 主域 AON staging 与读回缓存，冷复位应清零并等待通道恢复 READY；main 暖复位应清零并等待通道恢复 READY。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 主域 AON staging 与读回缓存 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.STATE.006

<!-- LRS_META
id: LRS.RESET.GPIO.STATE.006
category: RESET
feature: state
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/休眠覆盖保持值
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

对 休眠覆盖保持值，冷复位应清除并进入 RESET_OUT/OE 输出；main 暖复位应清除并进入 RESET_OUT/OE 输出。

#### Acceptance Criteria

- 分别在空闲、业务活动及已置锁/故障状态施加冷、暖复位，检查 休眠覆盖保持值 的结果。
- 复位期间业务事务不计完成，APB 上游应与主功能域同步复位。

### LRS.RESET.GPIO.CLOCK.001

<!-- LRS_META
id: LRS.RESET.GPIO.CLOCK.001
category: RESET
feature: clock
priority: P0
status: active
source_ref:
- gpio_contract.md#§3
applicability:
  expr: 'true'
verification_method:
- static
- review
- simulation
END_LRS_META -->

#### Requirement

POR 应在各域异步置位、同步释放；main_rst_ni 只复位主功能，aon_rst_ni 只能由冷复位树控制。

#### Acceptance Criteria

- 独立改变 pclk/aon_clk 相位、停止一个域时钟并施加复位，释放顺序及保持状态符合合同。
- 检查时钟/复位树、RDC 与恢复移除约束，不能以数字仿真代替物理复位签核。

