# GPIO LRS：访问安全（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.SEC.GPIO.SEC001.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC001.001
category: SEC
feature: sec001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-001 定义的场景下，CFG_LOCK、DATA_LOCK、WAKE_LOCK 均为每引脚 W1S；GLOBAL_LOCK 为全局 W1S。锁仅冷复位清除，main_rst_ni 不清锁。暖复位仍可将被锁寄存器恢复默认值，锁阻止后续软件写，非防复位机制。

#### Acceptance Criteria

- CFG_LOCK、DATA_LOCK、WAKE_LOCK 均为每引脚 W1S；GLOBAL_LOCK 为全局 W1S。锁仅冷复位清除，main_rst_ni 不清锁。暖复位仍可将被锁寄存器恢复默认值，锁阻止后续软件写，非防复位机制。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC002.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC002.001
category: SEC
feature: sec002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-002 定义的场景下，CFG_LOCK 保护 PIN_CFG、FILTER_CFG、DEBOUNCE_CFG、DIAG_CFG、IRQ_DETECT_EN、IRQ_ENABLE；DATA_LOCK 保护 OUT/OE 所有写入口。

#### Acceptance Criteria

- CFG_LOCK 保护 PIN_CFG、FILTER_CFG、DEBOUNCE_CFG、DIAG_CFG、IRQ_DETECT_EN、IRQ_ENABLE；DATA_LOCK 保护 OUT/OE 所有写入口。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC002.002

<!-- LRS_META
id: LRS.SEC.GPIO.SEC002.002
category: SEC
feature: sec002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-002 定义的场景下，GLOBAL_LOCK 阻止新增配置、共享分频/FIFO 控制/访问策略修改和清故障命令以外的诊断配置；不阻止正常 OUT/OE、Pending 清除、FIFO POP、快照触发。DATA_LOCK 才锁正常数据通路。

#### Acceptance Criteria

- GLOBAL_LOCK 阻止新增配置、共享分频/FIFO 控制/访问策略修改和清故障命令以外的诊断配置；不阻止正常 OUT/OE、Pending 清除、FIFO POP、快照触发。DATA_LOCK 才锁正常数据通路。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC002A.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC002A.001
category: SEC
feature: sec002a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-002A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-002A 定义的场景下，GLOBAL_LOCK 同时禁止 IN_ENABLE、IRQ_DETECT_EN、IRQ_ENABLE、EVENT_ENABLE、DIAG_ENABLE、所有逐引脚配置，以及 FAULT_IRQ_ENABLE 的写入；允许设置更多 CFG_LOCK/DATA_LOCK。

#### Acceptance Criteria

- GLOBAL_LOCK 同时禁止 IN_ENABLE、IRQ_DETECT_EN、IRQ_ENABLE、EVENT_ENABLE、DIAG_ENABLE、所有逐引脚配置，以及 FAULT_IRQ_ENABLE 的写入；允许设置更多 CFG_LOCK/DATA_LOCK。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC002A.002

<!-- LRS_META
id: LRS.SEC.GPIO.SEC002A.002
category: SEC
feature: sec002a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-002A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-002A 定义的场景下，WAKE_LOCK 只能通过 AON LOCK 命令更新，该命令固定要求 secure/privileged（ACCESS_CTRL_EN=1 时），且受 GLOBAL_LOCK 限制。

#### Acceptance Criteria

- WAKE_LOCK 只能通过 AON LOCK 命令更新，该命令固定要求 secure/privileged（ACCESS_CTRL_EN=1 时），且受 GLOBAL_LOCK 限制。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC002A.003

<!-- LRS_META
id: LRS.SEC.GPIO.SEC002A.003
category: SEC
feature: sec002a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-002A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-002A 定义的场景下，IRQ_TEST/DIAG_TEST 在 GLOBAL_LOCK=1 时禁止。

#### Acceptance Criteria

- IRQ_TEST/DIAG_TEST 在 GLOBAL_LOCK=1 时禁止。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC003.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC003.001
category: SEC
feature: sec003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-003 定义的场景下，写一个锁定的 RW 字段，即使新值相同也报错；位操作 mask=0 不视为尝试修改。

#### Acceptance Criteria

- 写一个锁定的 RW 字段，即使新值相同也报错；位操作 mask=0 不视为尝试修改。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC003.002

<!-- LRS_META
id: LRS.SEC.GPIO.SEC003.002
category: SEC
feature: sec003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-003 定义的场景下，共享 Bank 分频在该 Bank 任一 CFG_LOCK=1 时禁止修改。锁定同样覆盖可用引脚的所有别名入口。

#### Acceptance Criteria

- 共享 Bank 分频在该 Bank 任一 CFG_LOCK=1 时禁止修改。锁定同样覆盖可用引脚的所有别名入口。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC004.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC004.001
category: SEC
feature: sec004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-004 定义的场景下，ACCESS_CTRL_EN=1 时，ACCESS_CFG.SECURE_ONLY 和 PRIV_ONLY 对所有业务访问生效；ACCESS_CFG 与所有锁寄存器的写入固定要求 secure 且 privileged，不能通过放宽 ACCESS_CFG 绕过。安全属性来自可信 APB 上游。

#### Acceptance Criteria

- ACCESS_CTRL_EN=1 时，ACCESS_CFG.SECURE_ONLY 和 PRIV_ONLY 对所有业务访问生效；ACCESS_CFG 与所有锁寄存器的写入固定要求 secure 且 privileged，不能通过放宽 ACCESS_CFG 绕过。安全属性来自可信 APB 上游。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC005.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC005.001
category: SEC
feature: sec005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-005 定义的场景下，ACCESS_CFG 为全局 Bank 以外策略，不实现 per-pin Master ID ACL。

#### Acceptance Criteria

- ACCESS_CFG 为全局 Bank 以外策略，不实现 per-pin Master ID ACL。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC005.002

<!-- LRS_META
id: LRS.SEC.GPIO.SEC005.002
category: SEC
feature: sec005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-005 定义的场景下，PPROT 不包含 Master ID；多核身份隔离应由上游防火墙负责。关闭访问控制参数时忽略 PPROT[1:0]，PPROT[2] 的数据访问限制仍有效。

#### Acceptance Criteria

- PPROT 不包含 Master ID；多核身份隔离由上游防火墙负责。关闭访问控制参数时忽略 PPROT[1:0]，PPROT[2] 的数据访问限制仍有效。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

### LRS.SEC.GPIO.SEC006.001

<!-- LRS_META
id: LRS.SEC.GPIO.SEC006.001
category: SEC
feature: sec006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-006 定义的场景下，同笔事务只要存在一个有效写目标被锁/无能力/无权限，整个事务不更新业务寄存器。

#### Acceptance Criteria

- 同笔事务只要存在一个有效写目标被锁/无能力/无权限，整个事务不更新业务寄存器。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

