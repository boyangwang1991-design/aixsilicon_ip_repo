# GPIO LRS：滤波与去抖（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.FLT001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT001.001
category: FUNC
feature: flt001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-001 定义的场景下，每引脚 PIN_CFG.FILTER_EN 独立开启滤波；K=FILTER_CFG+1，范围 1～256。滤波每主时钟采样一次同步输入。

#### Acceptance Criteria

- 每引脚 PIN_CFG.FILTER_EN 独立开启滤波；K=FILTER_CFG+1，范围 1～256。滤波每主时钟采样一次同步输入。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT001.002

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT001.002
category: FUNC
feature: flt001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-001 定义的场景下，连续 K 次同一候选值后更新输出；遇到另一值时该值成为候选、计数从 1 开始。输入与当前输出相等时不输出变化事件。初始化也要求 K 次一致样本。

#### Acceptance Criteria

- 连续 K 次同一候选值后更新输出；遇到另一值时该值成为候选、计数从 1 开始。输入与当前输出相等时不输出变化事件。初始化也要求 K 次一致样本。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT002.001
category: FUNC
feature: flt002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-002 定义的场景下，DEBOUNCE_EN 独立控制去抖；D=DEBOUNCE_CFG+1，范围 1～256。

#### Acceptance Criteria

- DEBOUNCE_EN 独立控制去抖；D=DEBOUNCE_CFG+1，范围 1～256。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT002.002

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT002.002
category: FUNC
feature: flt002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-002 定义的场景下，每 Bank 共享 DIV+1 主周期一个采样使能，DIV 为 16-bit。

#### Acceptance Criteria

- 每 Bank 共享 DIV+1 主周期一个采样使能，DIV 为 16-bit。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT002.003

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT002.003
category: FUNC
feature: flt002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-002 定义的场景下，去抖仅在采样使能时观察滤波输出，连续 D 次一致才更新。

#### Acceptance Criteria

- 去抖仅在采样使能时观察滤波输出，连续 D 次一致才更新。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT003.001
category: FUNC
feature: flt003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-003 定义的场景下，已启用滤波阶段尚无有效输出时，去抖不能计数。各引脚候选/计数独立；共享的只有采样节拍。

#### Acceptance Criteria

- 已启用滤波阶段尚无有效输出时，去抖不能计数。各引脚候选/计数独立；共享的只有采样节拍。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT004.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT004.001
category: FUNC
feature: flt004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-004 定义的场景下，关闭滤波时应采用已有效同步值；关闭去抖时应采用有效滤波值。

#### Acceptance Criteria

- 关闭滤波时采用已有效同步值；关闭去抖时采用有效滤波值。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT004.002

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT004.002
category: FUNC
feature: flt004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-004 定义的场景下，启用阶段的下游采样应使用前一主边沿后的上游状态，不得使用同沿刚更新的值。

#### Acceptance Criteria

- 启用阶段的下游采样使用前一主边沿后的上游状态，不得使用同沿刚更新的值。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT005.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT005.001
category: FUNC
feature: flt005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-005 定义的场景下，写入 FILTER_CFG、DEBOUNCE_CFG、PIN_CFG 的 FILTER_EN/DEBOUNCE_EN/IN_INV，重新初始化该引脚输入处理和边沿历史。写 BANK_DEBOUNCE_DIV 重新初始化该 Bank 的所有已开启去抖引脚，并重启共享分频计数。重新初始化不清已有 Pending。

#### Acceptance Criteria

- 写入 FILTER_CFG、DEBOUNCE_CFG、PIN_CFG 的 FILTER_EN/DEBOUNCE_EN/IN_INV，重新初始化该引脚输入处理和边沿历史。写 BANK_DEBOUNCE_DIV 重新初始化该 Bank 的所有已开启去抖引脚，并重启共享分频计数。重新初始化不清已有 Pending。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT006.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT006.001
category: FUNC
feature: flt006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-006 定义的场景下，在时钟正常且输入保持稳定的前提下，主输入更新延迟的保守设计上界为 (SYNC_STAGES+4+K_eff+D_eff×(DIV+1))×Tclk，其中关闭滤波取 K_eff=0，关闭去抖取 D_eff=0。具体 RTL 周期模型必须满足该上界并在架构文档给出精确拍数。用于保证边沿识别时，高低两种稳定时间均须满足处理链的稳定要求。

#### Acceptance Criteria

- 在时钟正常且输入保持稳定的前提下，主输入更新延迟的保守设计上界为 (SYNC_STAGES+4+K_eff+D_eff×(DIV+1))×Tclk，其中关闭滤波取 K_eff=0，关闭去抖取 D_eff=0。具体 RTL 周期模型满足该上界并在架构文档给出精确拍数。用于保证边沿识别时，高低两种稳定时间均须满足处理链的稳定要求。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

### LRS.FUNC.GPIO.FLT007.001

<!-- LRS_META
id: LRS.FUNC.GPIO.FLT007.001
category: FUNC
feature: flt007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-FLT-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-FLT-007 定义的场景下，GPIO 不保证捕获任意窄异步脉冲，也不提供异步脉冲捕获锁存器。软件时钟分频变化会改变实际去抖时间，驱动应按频率重算。

#### Acceptance Criteria

- GPIO 不保证捕获任意窄异步脉冲，也不提供异步脉冲捕获锁存器。软件时钟分频变化会改变实际去抖时间，驱动按频率重算。
- 扫描 K/D=1、256、DIV=0、65535 及阈值前后跳变，检查初始化、重配置和稳定输入延迟。

