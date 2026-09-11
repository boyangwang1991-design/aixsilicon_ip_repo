# GPIO LRS：APB访问（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.REG.GPIO.BUS001.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS001.001
category: REG
feature: bus001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-001 定义的场景下，本地 CSR 支持零等待 APB 传输：PREADY=1；错误同样在合法 APB Access 阶段返回。写副作用仅在 PSEL && PENABLE && PREADY && !PSLVERR 的完成边沿发生，Setup 阶段无副作用。

#### Acceptance Criteria

- 本地 CSR 支持零等待 APB 传输：PREADY=1；错误同样在合法 APB Access 阶段返回。写副作用仅在 PSEL && PENABLE && PREADY && !PSLVERR 的完成边沿发生，Setup 阶段无副作用。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS002.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS002.001
category: REG
feature: bus002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-002 定义的场景下，所有地址按 4 字节对齐。

#### Acceptance Criteria

- 所有地址按 4 字节对齐。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS002.002

<!-- LRS_META
id: LRS.REG.GPIO.BUS002.002
category: REG
feature: bus002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-002 定义的场景下，PADDR[1:0]!=0、未定义字地址、向 RO 写入、非法字段编码、锁定目标写入、权限错误，均返回 PSLVERR=1，PRDATA=0，整个事务无业务副作用。错误记录寄存器更新属于允许的诊断副作用。

#### Acceptance Criteria

- PADDR[1:0]!=0、未定义字地址、向 RO 写入、非法字段编码、锁定目标写入、权限错误，均返回 PSLVERR=1，PRDATA=0，整个事务无业务副作用。错误记录寄存器更新属于允许的诊断副作用。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS003.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS003.001
category: REG
feature: bus003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-003 定义的场景下，RW/W1C/W1S/SET/CLR/TOGGLE 均按 PSTRB 展开的 byte mask 生效。RW 写 PSTRB=0 为无操作成功。

#### Acceptance Criteria

- RW/W1C/W1S/SET/CLR/TOGGLE 均按 PSTRB 展开的 byte mask 生效。RW 写 PSTRB=0 为无操作成功。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS003.002

<!-- LRS_META
id: LRS.REG.GPIO.BUS003.002
category: REG
feature: bus003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-003 定义的场景下，掩码组合写和命令寄存器只允许 PSTRB=1111；否则报错。WO 读取返回 0。

#### Acceptance Criteria

- 掩码组合写和命令寄存器只允许 PSTRB=1111；否则报错。WO 读取返回 0。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS004.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS004.001
category: REG
feature: bus004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-004 定义的场景下，保留位读 0、写忽略；字段非法编码仅检查真正被字节使能写到的字段。不存在引脚位写忽略，存在但不支持相关输入/输出能力的位尝试置 1 返回错误。

#### Acceptance Criteria

- 保留位读 0、写忽略；字段非法编码仅检查真正被字节使能写到的字段。不存在引脚位写忽略，存在但不支持相关输入/输出能力的位尝试置 1 返回错误。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS005.001
category: REG
feature: bus005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005 定义的场景下，读数据为事务完成边沿前的状态。读无隐含清除；仅显式 EVENT_POP 命令消费 FIFO。

#### Acceptance Criteria

- 读数据为事务完成边沿前的状态。读无隐含清除；仅显式 EVENT_POP 命令消费 FIFO。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005.002

<!-- LRS_META
id: LRS.REG.GPIO.BUS005.002
category: REG
feature: bus005
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005 定义的场景下，APB4 PPROT[0] 为 privileged，PPROT[1] 为 non-secure，PPROT[2] 为 instruction 属性。本 IP 拒绝 PPROT[2]=1 的访问。

#### Acceptance Criteria

- APB4 PPROT[0] 为 privileged，PPROT[1] 为 non-secure，PPROT[2] 为 instruction 属性。本 IP 拒绝 PPROT[2]=1 的访问。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005A.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS005A.001
category: REG
feature: bus005a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005A 定义的场景下，命令寄存器写 0 为成功无操作。

#### Acceptance Criteria

- 命令寄存器写 0 为成功无操作。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005A.002

<!-- LRS_META
id: LRS.REG.GPIO.BUS005A.002
category: REG
feature: bus005a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005A 定义的场景下，有效命令位与保留位同时写入时忽略保留位；AON_CMD 多个有效命令位置 1 报错。

#### Acceptance Criteria

- 有效命令位与保留位同时写入时忽略保留位；AON_CMD 多个有效命令位置 1 报错。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005A.003

<!-- LRS_META
id: LRS.REG.GPIO.BUS005A.003
category: REG
feature: bus005a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005A 定义的场景下，更新使能字段使其从 1→1 不重建边沿历史；IRQ_MODE 即使写相同值仍按重配置建立基线。

#### Acceptance Criteria

- 更新使能字段使其从 1→1 不重建边沿历史；IRQ_MODE 即使写相同值仍按重配置建立基线。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS005A.004

<!-- LRS_META
id: LRS.REG.GPIO.BUS005A.004
category: REG
feature: bus005a
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-005A
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-005A 定义的场景下，针对某个 PIN_CFG 的写入，若只改变 OUT/SLEEP/GROUP 字段，不重置输入滤波历史；仅 IRQ_MODE 写字段被有效字节覆盖时重建中断基线。

#### Acceptance Criteria

- 针对某个 PIN_CFG 的写入，若只改变 OUT/SLEEP/GROUP 字段，不重置输入滤波历史；仅 IRQ_MODE 写字段被有效字节覆盖时重建中断基线。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

