# GPIO LRS：休眠与安全覆盖（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.LP.GPIO.LP001.001

<!-- LRS_META
id: LRS.LP.GPIO.LP001.001
category: LP
feature: lp001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-001 定义的场景下，每引脚 SLEEP_MODE 为 0=保持、1=强制低、2=强制高、3=高阻。

#### Acceptance Criteria

- 每引脚 SLEEP_MODE 为 0=保持、1=强制低、2=强制高、3=高阻。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP001.002

<!-- LRS_META
id: LRS.LP.GPIO.LP001.002
category: LP
feature: lp001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-001 定义的场景下，强制低/高是物理推挽 OUT=0/1、OE=1；高阻 OE=0；均仍受输出能力/拥有权约束。

#### Acceptance Criteria

- 强制低/高是物理推挽 OUT=0/1、OE=1；高阻 OE=0；均仍受输出能力/拥有权约束。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP001.003

<!-- LRS_META
id: LRS.LP.GPIO.LP001.003
category: LP
feature: lp001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-001 定义的场景下，GPIO 对开漏线路通常应配置保持或高阻，由系统配置负责选择。

#### Acceptance Criteria

- GPIO 对开漏线路通常配置保持或高阻，由系统配置负责选择。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP002.001

<!-- LRS_META
id: LRS.LP.GPIO.LP002.001
category: LP
feature: lp002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-002 定义的场景下，sleep_req_i 拉高的下一主域边沿锁存当时正常模式有效 physical_out/oe 到 sleep_hold，应用休眠覆盖并拉高 sleep_ack_o。请求保持期间 ack 保持。请求拉低的下一边沿解除覆盖并拉低 ack。

#### Acceptance Criteria

- sleep_req_i 拉高的下一主域边沿锁存当时正常模式有效 physical_out/oe 到 sleep_hold，用休眠覆盖并拉高 sleep_ack_o。请求保持期间 ack 保持。请求拉低的下一边沿解除覆盖并拉低 ack。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP003.001

<!-- LRS_META
id: LRS.LP.GPIO.LP003.001
category: LP
feature: lp003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-003 定义的场景下，保持捕获使用进入边沿前的 OUT/OE。

#### Acceptance Criteria

- 保持捕获使用进入边沿前的 OUT/OE。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP003.002

<!-- LRS_META
id: LRS.LP.GPIO.LP003.002
category: LP
feature: lp003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-003 定义的场景下，若同拍完成 APB OUT 写，先前输出被保持，新数据进入正常锁存，在退出休眠后生效。

#### Acceptance Criteria

- 若同拍完成 APB OUT 写，先前输出被保持，新数据进入正常锁存，在退出休眠后生效。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP003.003

<!-- LRS_META
id: LRS.LP.GPIO.LP003.003
category: LP
feature: lp003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-003 定义的场景下，休眠有效期间允许写 OUT/OE，但 PIN_CFG.SLEEP_MODE 写入报错；CFG_LOCK 仍生效。

#### Acceptance Criteria

- 休眠有效期间允许写 OUT/OE，但 PIN_CFG.SLEEP_MODE 写入报错；CFG_LOCK 仍生效。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP004.001

<!-- LRS_META
id: LRS.LP.GPIO.LP004.001
category: LP
feature: lp004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-004 定义的场景下，主域内输出选择优先级：复位默认值 > safe_req_i 或内部 parity 安全请求 > 休眠覆盖 > 正常输出；最终始终应用 capability/ownership 门控。

#### Acceptance Criteria

- 主域内输出选择优先级：复位默认值 > safe_req_i 或内部 parity 安全请求 > 休眠覆盖 > 正常输出；最终始终用 capability/ownership 门控。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP004.002

<!-- LRS_META
id: LRS.LP.GPIO.LP004.002
category: LP
feature: lp004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-004 定义的场景下，safe 覆盖用 HW_SAFE_OUT/OE 物理值，旁路反相/开漏。safe_req 解除后回到仍有效的休眠或正常状态。

#### Acceptance Criteria

- safe 覆盖用 HW_SAFE_OUT/OE 物理值，旁路反相/开漏。safe_req 解除后回到仍有效的休眠或正常状态。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP005.001

<!-- LRS_META
id: LRS.LP.GPIO.LP005.001
category: LP
feature: lp005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-005 定义的场景下，主域断钟但不断电时已锁存输出继续保持。

#### Acceptance Criteria

- 主域断钟但不断电时已锁存输出继续保持。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP005.002

<!-- LRS_META
id: LRS.LP.GPIO.LP005.002
category: LP
feature: lp005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-005 定义的场景下，主域掉电时，本 IP 主域 RTL 不保证保持；SoC 必须在断电前通过 AON PAD 控制/retention/isolation 接管，且退出时先恢复值和路由再解除接管。

#### Acceptance Criteria

- 主域掉电时，本 IP 主域 RTL 不保证保持；SoC 在断电前通过 AON PAD 控制/retention/isolation 接管，且退出时先恢复值和路由再解除接管。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

### LRS.LP.GPIO.LP006.001

<!-- LRS_META
id: LRS.LP.GPIO.LP006.001
category: LP
feature: lp006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-006 定义的场景下，V1.0 休眠覆盖仅控制 GPIO 输出，不自动关闭输入/中断。

#### Acceptance Criteria

- V1.0 休眠覆盖仅控制 GPIO 输出，不自动关闭输入/中断。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

