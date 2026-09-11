# GPIO LRS：AON唤醒（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.LP.GPIO.WAK001.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK001.001
category: LP
feature: wak001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-001
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-001 定义的场景下，AON_WAKE_EN=1 时，IP 应提供独立于主功能时钟运行的常开唤醒能力。

#### Acceptance Criteria

- AON_WAKE_EN=1 时，IP 提供独立于主功能时钟运行的常开唤醒能力。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK001.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK001.002
category: LP
feature: wak001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-001
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-001 定义的场景下，AON 应采样独立输入，不依赖主域 IN_ENABLE、IRQ_ENABLE、反相和滤波。

#### Acceptance Criteria

- AON 采样独立输入，不依赖主域 IN_ENABLE、IRQ_ENABLE、反相和滤波。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK001.003

<!-- LRS_META
id: LRS.LP.GPIO.WAK001.003
category: LP
feature: wak001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-001
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-001 定义的场景下，WAKE_MODE 编码同 IRQ_MODE，以物理同步输入为依据。

#### Acceptance Criteria

- WAKE_MODE 编码同 IRQ_MODE，以物理同步输入为依据。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK002.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK002.001
category: LP
feature: wak002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-002
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-002 定义的场景下，AON 每引脚固定 2 级同步器；Bank 共享 WAKE_DIV+1 周期采样节拍；连续 WAKE_COUNT+1 次一致样本后更新检测值，WAKE_COUNT 为 8-bit。

#### Acceptance Criteria

- AON 每引脚固定 2 级同步器；Bank 共享 WAKE_DIV+1 周期采样节拍；连续 WAKE_COUNT+1 次一致样本后更新检测值，WAKE_COUNT 为 8-bit。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK002.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK002.002
category: LP
feature: wak002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-002
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-002 定义的场景下，WAKE_MODE=0 或 WAKE_ENABLE=0 停止新增事件。首次有效值只建立边沿基线，电平可立即触发。

#### Acceptance Criteria

- WAKE_MODE=0 或 WAKE_ENABLE=0 停止新增事件。首次有效值只建立边沿基线，电平可立即触发。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK003.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK003.001
category: LP
feature: wak003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-003
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-003 定义的场景下，WAKE_PENDING 为 AON W1C，事件置位优先，wake_req_o=OR(WAKE_PENDING)，不因关闭 WAKE_ENABLE 自动撤销已记录请求。软件必须显式清除；持续电平仍可立即重置位。

#### Acceptance Criteria

- WAKE_PENDING 为 AON W1C，事件置位优先，wake_req_o=OR(WAKE_PENDING)，不因关闭 WAKE_ENABLE 自动撤销已记录请求。软件显式清除；持续电平仍可立即重置位。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK004.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK004.001
category: LP
feature: wak004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-004
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-004 定义的场景下，每 Bank 主域窗口维护 staging：ENABLE、MODE_LO/MID/HI（三个位平面）、DIV、COUNT、CLEAR_MASK。模式由三个平面组成 3-bit 编码。

#### Acceptance Criteria

- 每 Bank 主域窗口维护 staging：ENABLE、MODE_LO/MID/HI（三个位平面）、DIV、COUNT、CLEAR_MASK。模式由三个平面组成 3-bit 编码。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK004.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK004.002
category: LP
feature: wak004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-004
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-004 定义的场景下，提交前检查存在且启用引脚的模式、输入能力和 WAKE_LOCK。

#### Acceptance Criteria

- 提交前检查存在且启用引脚的模式、输入能力和 WAKE_LOCK。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK005.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK005.001
category: LP
feature: wak005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-005
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-005 定义的场景下，AON_CMD 一次只接受一个 Bank 的一个命令：bit0 COMMIT、bit1 SNAPSHOT、bit2 CLEAR、bit3 LOCK；必须 one-hot。

#### Acceptance Criteria

- AON_CMD 一次只接受一个 Bank 的一个命令：bit0 COMMIT、bit1 SNAPSHOT、bit2 CLEAR、bit3 LOCK； one-hot。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK005.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK005.002
category: LP
feature: wak005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-005
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-005 定义的场景下，全 IP 仅一个 outstanding AON 命令。

#### Acceptance Criteria

- 全 IP 仅一个 outstanding AON 命令。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK005.003

<!-- LRS_META
id: LRS.LP.GPIO.WAK005.003
category: LP
feature: wak005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-005
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-005 定义的场景下，COMMIT 原子传输该 Bank 整组配置，AON 生效后返回 ACK；重建该 Bank 唤醒历史但不清 Pending。

#### Acceptance Criteria

- COMMIT 原子传输该 Bank 整组配置，AON 生效后返回 ACK；重建该 Bank 唤醒历史但不清 Pending。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK006.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK006.001
category: LP
feature: wak006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-006
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-006 定义的场景下，SNAPSHOT 在 AON 单个边沿捕获 Pending 和有效位，经 mailbox 返回主域缓存。CLEAR 在 AON 按 CLEAR_MASK 清除 Pending，然后返回清除后（含同拍新事件）状态。LOCK 使用 CLEAR_MASK 作为置锁 mask，在 AON 域置 WAKE_LOCK，软件 SNAPSHOT 同时返回锁状态。

#### Acceptance Criteria

- SNAPSHOT 在 AON 单个边沿捕获 Pending 和有效位，经 mailbox 返回主域缓存。CLEAR 在 AON 按 CLEAR_MASK 清除 Pending，然后返回清除后（含同拍新事件）状态。LOCK 使用 CLEAR_MASK 作为置锁 mask，在 AON 域置 WAKE_LOCK，软件 SNAPSHOT 同时返回锁状态。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

