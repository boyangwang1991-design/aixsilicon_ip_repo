# GPIO LRS：接口规则（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.INTF.GPIO.IF001.001

<!-- LRS_META
id: LRS.INTF.GPIO.IF001.001
category: INTF
feature: if001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-001 定义的场景下，未使用的 available/owned 接口应按实际集成情况绑常量，不能默认以读到 0 代替有效性说明。

#### Acceptance Criteria

- 未使用的 available/owned 接口按实际集成情况绑常量，不能默认以读到 0 代替有效性说明。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF001.002

<!-- LRS_META
id: LRS.INTF.GPIO.IF001.002
category: INTF
feature: if001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-001 定义的场景下，改变输入路由时，集成层应先撤销 available，切换并稳定后再拉高。

#### Acceptance Criteria

- 改变输入路由时，集成层先撤销 available，切换并稳定后再拉高。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF002.001

<!-- LRS_META
id: LRS.INTF.GPIO.IF002.001
category: INTF
feature: if002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-002 定义的场景下，内部 RTL 不产生 Z；OE=0 表示释放 PAD。

#### Acceptance Criteria

- 内部 RTL 不产生 Z；OE=0 表示释放 PAD。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF002.002

<!-- LRS_META
id: LRS.INTF.GPIO.IF002.002
category: INTF
feature: if002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-002 定义的场景下，GPIO 输出拥有权不能直接替代 Pinmux 的最终物理选择逻辑。

#### Acceptance Criteria

- GPIO 输出拥有权不能直接替代 Pinmux 的最终物理选择逻辑。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF003.001

<!-- LRS_META
id: LRS.INTF.GPIO.IF003.001
category: INTF
feature: if003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-003 定义的场景下，safe_req_i 仅提供主域有时钟时的同步响应。

#### Acceptance Criteria

- safe_req_i 仅提供主域有时钟时的同步响。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF003.002

<!-- LRS_META
id: LRS.INTF.GPIO.IF003.002
category: INTF
feature: if003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-003 定义的场景下，断钟/掉电下必须生效的安全覆盖，由常开 PAD/安全控制器实施，可复用 HW_SAFE_OUT/OE 参数；不得宣称主域同步逻辑提供异步紧急切断。

#### Acceptance Criteria

- 断钟/掉电下生效的安全覆盖，由常开 PAD/安全控制器实施，可复用 HW_SAFE_OUT/OE 参数；不得宣称主域同步逻辑提供异步紧急切断。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF004.001

<!-- LRS_META
id: LRS.INTF.GPIO.IF004.001
category: INTF
feature: if004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-004 定义的场景下，AON 输入应在 AON 时钟域可靠采样；aon_input_available_i 由常开路由逻辑同步提供。

#### Acceptance Criteria

- AON 输入在 AON 时钟域可靠采样；aon_input_available_i 由常开路由逻辑同步提供。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

### LRS.INTF.GPIO.IF004.002

<!-- LRS_META
id: LRS.INTF.GPIO.IF004.002
category: INTF
feature: if004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-IF-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-IF-004 定义的场景下，交付应包含输入同步的 CDC 约束与实现要求；同步结构细节在 HLD/LLD 冻结。

#### Acceptance Criteria

- 交付包含输入同步的 CDC 约束与实现要求；同步结构细节在 HLD/LLD 冻结。
- 检查正常连接及未用端口绑定、时钟有效/无效条件，满足所述接口限制。

