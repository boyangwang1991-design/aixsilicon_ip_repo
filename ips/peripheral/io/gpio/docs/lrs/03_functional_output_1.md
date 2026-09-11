# GPIO LRS：输出控制（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.OUT001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT001.001
category: FUNC
feature: out001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-001 定义的场景下，OUT_DATA 与 OUT_OE 应能独立配置。软件应可在 OE=0 时预装载输出数据，再使能 OE。

#### Acceptance Criteria

- OUT_DATA 与 OUT_OE 能独立配置。软件可在 OE=0 时预装载输出数据，再使能 OE。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT001.002

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT001.002
category: FUNC
feature: out001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-001 定义的场景下，OUT_DATA 应读回软件输出值，IN_SYNC/IN_DATA 应读回输入通路值。

#### Acceptance Criteria

- OUT_DATA 读回软件输出值，IN_SYNC/IN_DATA 读回输入通路值。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT002.001
category: FUNC
feature: out002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-002 定义的场景下，正常模式先令 D=OUT_DATA XOR OUT_INV，再执行开漏转换。

#### Acceptance Criteria

- 正常模式先令 D=OUT_DATA XOR OUT_INV，再执行开漏转换。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT002.002

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT002.002
category: FUNC
feature: out002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-002 定义的场景下，推挽：physical_out=D，physical_oe=OUT_OE；开漏：physical_out=0，physical_oe=OUT_OE && !D。

#### Acceptance Criteria

- 推挽：physical_out=D，physical_oe=OUT_OE；开漏：physical_out=0，physical_oe=OUT_OE && !D。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT002.003

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT002.003
category: FUNC
feature: out002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-002 定义的场景下，最终 OE 再与 OUTPUT_CAP_MASK、output_owned_i 相与。

#### Acceptance Criteria

- 最终 OE 再与 OUTPUT_CAP_MASK、output_owned_i 相与。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT003.001
category: FUNC
feature: out003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-003 定义的场景下，OUT_SET/CLR/TOGGLE 分别对写 1 且 PSTRB 有效位执行置位/清除/翻转。OE_SET/CLR 语义相同。每事务原子更新，不进行软件读改写。

#### Acceptance Criteria

- OUT_SET/CLR/TOGGLE 分别对写 1 且 PSTRB 有效位执行置位/清除/翻转。OE_SET/CLR 语义相同。每事务原子更新，不进行软件读改写。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT004.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT004.001
category: FUNC
feature: out004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-004 定义的场景下，MASKED_LO 操作引脚 [15:0]、MASKED_HI 操作 [31:16]；PWDATA[31:16] 为位 mask，PWDATA[15:0] 为新值。仅 mask=1 的存在位改变。

#### Acceptance Criteria

- MASKED_LO 操作引脚 [15:0]、MASKED_HI 操作 [31:16]；PWDATA[31:16] 为位 mask，PWDATA[15:0] 为新值。仅 mask=1 的存在位改变。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT004.002

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT004.002
category: FUNC
feature: out004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-004 定义的场景下，mask/value 必须同一完整 32-bit 事务提交；读这些 WO 别名返回 0。

#### Acceptance Criteria

- mask/value 同一完整 32-bit 事务提交；读这些 WO 别名返回 0。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT005.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT005.001
category: FUNC
feature: out005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-005 定义的场景下，单次事务原子性不扩展到多个 Bank。

#### Acceptance Criteria

- 单次事务原子性不扩展到多个 Bank。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT005.002

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT005.002
category: FUNC
feature: out005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-005 定义的场景下，V1.0 不提供 OUT/OE Shadow Commit；跨寄存器输出配置应按“关 OE→配置数据/模式→开 OE”执行。

#### Acceptance Criteria

- V1.0 不提供 OUT/OE Shadow Commit；跨寄存器输出配置按“关 OE→配置数据/模式→开 OE”执行。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT005.003

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT005.003
category: FUNC
feature: out005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-005 定义的场景下，需要多引脚相同周期数据切换可使用单 Bank OUT_DATA 写。

#### Acceptance Criteria

- 需要多引脚相同周期数据切换可使用单 Bank OUT_DATA 写。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT006.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT006.001
category: FUNC
feature: out006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-006 定义的场景下，修改 PIN_CFG.OUT_OD 或 OUT_INV 时，对应 OUT_OE 必须为 0，否则整笔写报错。

#### Acceptance Criteria

- 修改 PIN_CFG.OUT_OD 或 OUT_INV 时，对 OUT_OE 为 0，否则整笔写报错。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

