# GPIO LRS：诊断与功能安全（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.SAFE.GPIO.DIAG006.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG006.001
category: SAFE
feature: diag006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-006
applicability:
  expr: CFG_PARITY_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-006 定义的场景下，parity 故障注入寄存器只在 CFG_PARITY_EN=1 且 secure/privileged 访问时支持：选择现有 Bank OUT_DATA parity bit 翻转一次，不更改数据；GLOBAL_LOCK=1 时禁止注入。用于验证检测和 HW_SAFE 输出。其余冗余/TMR/锁步不属于本 V1.0 实现承诺。

#### Acceptance Criteria

- parity 故障注入寄存器只在 CFG_PARITY_EN=1 且 secure/privileged 访问时支持：选择现有 Bank OUT_DATA parity bit 翻转一次，不更改数据；GLOBAL_LOCK=1 时禁止注入。用于验证检测和 HW_SAFE 输出。其余冗余/TMR/锁步不属于本 V1.0 实现承诺。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG007.001

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG007.001
category: SAFE
feature: diag007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-007 定义的场景下，安全交付不得以本功能列表声明 ASIL 或诊断覆盖率。

#### Acceptance Criteria

- 安全交付不得以本功能列表声明 ASIL 或诊断覆盖率。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

### LRS.SAFE.GPIO.DIAG007.002

<!-- LRS_META
id: LRS.SAFE.GPIO.DIAG007.002
category: SAFE
feature: diag007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-DIAG-007 定义的场景下，必须结合 FMEDA、故障模型、PAD 与外部电路、时钟和电源假设单独评估；输出回读不能保证覆盖所有开路/短路。

#### Acceptance Criteria

- 结合 FMEDA、故障模型、PAD 与外部电路、时钟和电源假设单独评估；输出回读不能保证覆盖所有开路/短路。
- 检查消隐/失配阈值前后、开漏释放、W1C 竞争和 parity 注入，核对故障与安全输出及复位保持。

