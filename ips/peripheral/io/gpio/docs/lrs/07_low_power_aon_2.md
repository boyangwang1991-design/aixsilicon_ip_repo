# GPIO LRS：AON唤醒（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.LP.GPIO.WAK007.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK007.001
category: LP
feature: wak007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-007
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-007 定义的场景下，staging 可在 BUSY=0 时写，BUSY=1 时所有 staging/命令写入报错。

#### Acceptance Criteria

- staging 可在 BUSY=0 时写，BUSY=1 时所有 staging/命令写入报错。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK007.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK007.002
category: LP
feature: wak007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-007
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-007 定义的场景下，COMMIT 对包含已锁引脚的配置不得改变锁定字段；锁定位的值与当前 AON 活动配置不一致则整个 Bank COMMIT 失败。

#### Acceptance Criteria

- COMMIT 对包含已锁引脚的配置不得改变锁定字段；锁定位的值与当前 AON 活动配置不一致则整个 Bank COMMIT 失败。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK007.003

<!-- LRS_META
id: LRS.LP.GPIO.WAK007.003
category: LP
feature: wak007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-007
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-007 定义的场景下，WAKE_DIV/COUNT 在该 Bank 任一 WAKE_LOCK=1 时不得改变。

#### Acceptance Criteria

- WAKE_DIV/COUNT 在该 Bank 任一 WAKE_LOCK=1 时不得改变。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK008.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK008.001
category: LP
feature: wak008
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-008
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-008 定义的场景下，main_rst_ni 不影响 AON 活动配置、WAKE_LOCK、Pending。

#### Acceptance Criteria

- main_rst_ni 不影响 AON 活动配置、WAKE_LOCK、Pending。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK008.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK008.002
category: LP
feature: wak008
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-008
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-008 定义的场景下，主域 staging 复位为 0；暖复位后要修改含锁引脚 Bank，先执行 SNAPSHOT，返回的活动配置填充 AON_READBACK 窗口，软件据此重建 staging。未完成同步前不得自动重放旧请求。

#### Acceptance Criteria

- 主域 staging 复位为 0；暖复位后要修改含锁引脚 Bank，先执行 SNAPSHOT，返回的活动配置填充 AON_READBACK 窗口，软件据此重建 staging。未完成同步前不得自动重放旧请求。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK009.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK009.001
category: LP
feature: wak009
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-009
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-009 定义的场景下，AON 命令应通过跨域请求/应答机制传递，传输数据在请求到应答期间保持稳定且一致。

#### Acceptance Criteria

- AON 命令通过跨域请求/答机制传递，传输数据在请求到答期间保持稳定且一致。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK009.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK009.002
category: LP
feature: wak009
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-009
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-009 定义的场景下，主复位后应先恢复通道空闲一致性，完成后 READY=1；READY=0 时命令返回错误。

#### Acceptance Criteria

- 主复位后先恢复通道空闲一致性，完成后 READY=1；READY=0 时命令返回错误。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK010.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK010.001
category: LP
feature: wak010
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-010
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-010 定义的场景下，AON_TIMEOUT 为 24-bit 主时钟周期数，默认 65535，最小 16。

#### Acceptance Criteria

- AON_TIMEOUT 为 24-bit 主时钟周期数，默认 65535，最小 16。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK010.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK010.002
category: LP
feature: wak010
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-010
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-010 定义的场景下，到期设置 TIMEOUT 和全局故障，但 BUSY 保持，禁止复用 mailbox；迟到 ACK 仍完成原操作。超时不保证操作未生效，也不提供命令撤销。软件应查询/恢复 AON 后确认实际状态，不能直接重发。

#### Acceptance Criteria

- 到期设置 TIMEOUT 和全局故障，但 BUSY 保持，禁止复用 mailbox；迟到 ACK 仍完成原操作。超时不保证操作未生效，也不提供命令撤销。软件查询/恢复 AON 后确认实际状态，不能直接重发。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK010A.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK010A.001
category: LP
feature: wak010a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-010A
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-010A 定义的场景下，AON_STATUS.TIMEOUT 为命令局部状态，下一合法命令接受时清除；FAULT_STATUS.AON_TIMEOUT 为独立 sticky 诊断，仅 FAULT_CLEAR 或主复位清除。ERROR 与 AON_ERROR 同理。超时之后 BUSY 未解除时，下一命令不可能被接受。

#### Acceptance Criteria

- AON_STATUS.TIMEOUT 为命令局部状态，下一合法命令接受时清除；FAULT_STATUS.AON_TIMEOUT 为独立 sticky 诊断，仅 FAULT_CLEAR 或主复位清除。ERROR 与 AON_ERROR 同理。超时之后 BUSY 未解除时，下一命令不可能被接受。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK010A.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK010A.002
category: LP
feature: wak010a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-010A
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-010A 定义的场景下，AON硬件运行错误不能仅以APB错误代替，必须通过应答ERROR和FAULT_STATUS报告。

#### Acceptance Criteria

- AON硬件运行错误不能仅以APB错误代替，通过答ERROR和FAULT_STATUS报告。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK011.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK011.001
category: LP
feature: wak011
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-011
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-011 定义的场景下，暖复位中断已发送命令时，IP 应保证旧命令不重复执行，即使 AON 已执行。主域 READY 返回前应排空旧应答。冷复位应清除两域初始状态；应交付满足这些语义的 CDC/RDC 分析。

#### Acceptance Criteria

- 暖复位中断已发送命令时，IP 保证旧命令不重复执行，即使 AON 已执行。主域 READY 返回前排空旧答。冷复位清除两域初始状态；交付满足这些语义的 CDC/RDC 分析。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

