# GPIO LRS：诊断与功能安全（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.SAFE.GPIO.DIAG001.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG001.001
category: SAFE
feature: diag001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-001
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-001 定义的场景下，DIAG_EN 启用逐引脚物理回读比较，使用 IN_SYNC 而非 IN_DATA。

#### Acceptance Criteria

- DIAG_EN 启用逐引脚物理回读比较，使用 IN_SYNC 而非 IN_DATA。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG001.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG001.002
category: SAFE
feature: diag001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-001
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-001 定义的场景下，只有输入有效、输出拥有权成立，且当前最终 OE=1 时检查；高阻、开漏释放不检查。

#### Acceptance Criteria

- 只有输入有效、输出拥有权成立，且当前最终 OE=1 时检查；高阻、开漏释放不检查。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG002.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG002.001
category: SAFE
feature: diag002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-002
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-002 定义的场景下，最终 OUT/OE、输出拥有权、输入 available、休眠/安全状态变化时重启消隐计数；BLANK=DIAG_CFG.BLANK，合法值至少 SYNC_STAGES+2。

#### Acceptance Criteria

- 最终 OUT/OE、输出拥有权、输入 available、休眠/安全状态变化时重启消隐计数；BLANK=DIAG_CFG.BLANK，合法值至少 SYNC_STAGES+2。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG002.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG002.002
category: SAFE
feature: diag002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-002
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-002 定义的场景下，消隐 BLANK 个完整周期后比较物理回读与期望 OUT。

#### Acceptance Criteria

- 消隐 BLANK 个完整周期后比较物理回读与期望 OUT。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG002.003

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG002.003
category: SAFE
feature: diag002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-002
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-002 定义的场景下，持续 M=DIAG_CFG.M_MINUS_ONE+1 次失配后置 DIAG_PENDING[i]；匹配时失配计数清零。

#### Acceptance Criteria

- 持续 M=DIAG_CFG.M_MINUS_ONE+1 次失配后置 DIAG_PENDING[i]；匹配时失配计数清零。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG002.004

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG002.004
category: SAFE
feature: diag002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-002
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-002 定义的场景下，复位默认 BLANK=SYNC_STAGES+2，M=1。

#### Acceptance Criteria

- 复位默认 BLANK=SYNC_STAGES+2，M=1。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG003.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG003.001
category: SAFE
feature: diag003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-003
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-003 定义的场景下，DIAG_PENDING 为 W1C，持续故障到阈值后每拍保持置位优先，软件清除不能隐藏未恢复失配。

#### Acceptance Criteria

- DIAG_PENDING 为 W1C，持续故障到阈值后每拍保持置位优先，软件清除不能隐藏未恢复失配。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG003.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG003.002
category: SAFE
feature: diag003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-003
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-003 定义的场景下，DIAG_PENDING & DIAG_ENABLE 的 OR 进入 FAULT_STATUS 的实时汇总，不自动控制主安全覆盖。

#### Acceptance Criteria

- DIAG_PENDING & DIAG_ENABLE 的 OR 进入 FAULT_STATUS 的实时汇总，不自动控制主安全覆盖。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG004.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG004.001
category: SAFE
feature: diag004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-004
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-004 定义的场景下，DIAG_TEST 为 WO，写 1 对应引脚置 DIAG_PENDING，测试后应软件清除。它验证记录/报警路径，不验证 PAD、电气驱动或完整输入路径。

#### Acceptance Criteria

- DIAG_TEST 为 WO，写 1 对引脚置 DIAG_PENDING，测试后软件清除。它验证记录/报警路径，不验证 PAD、电气驱动或完整输入路径。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG004.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG004.002
category: SAFE
feature: diag004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-004
applicability:
  expr: DIAG_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-004 定义的场景下，V1.0 不提供输入软件强制回环，避免与正常输入有效性混淆。

#### Acceptance Criteria

- V1.0 不提供输入软件强制回环，避免与正常输入有效性混淆。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG005.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG005.001
category: SAFE
feature: diag005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-005
applicability:
  expr: CFG_PARITY_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-005 定义的场景下，CFG_PARITY_EN=1 时，对 OUT_DATA、OUT_OE、PIN_CFG、IRQ_ENABLE、IRQ_DETECT_EN、ACCESS_CFG 的存储值提供每 32-bit 字偶 parity。每拍检查；部分写根据合并后的完整字重算 parity。

#### Acceptance Criteria

- CFG_PARITY_EN=1 时，对 OUT_DATA、OUT_OE、PIN_CFG、IRQ_ENABLE、IRQ_DETECT_EN、ACCESS_CFG 的存储值提供每 32-bit 字偶 parity。每拍检查；部分写根据合并后的完整字重算 parity。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG005.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG005.002
category: SAFE
feature: diag005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-005
applicability:
  expr: CFG_PARITY_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-005 定义的场景下，故障置 FAULT_STATUS.PARITY，内部安全请求保持到冷复位；软件不能通过 W1C解除安全请求。暖复位不清该锁存故障。parity 检测延迟上界为 1 个运行的主时钟周期。

#### Acceptance Criteria

- 故障置 FAULT_STATUS.PARITY，内部安全请求保持到冷复位；软件不能通过 W1C解除安全请求。暖复位不清该锁存故障。parity 检测延迟上界为 1 个运行的主时钟周期。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

