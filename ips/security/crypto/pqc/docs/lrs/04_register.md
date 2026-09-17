# PQC LRS：寄存器与软件可见能力

> 分层约束：本册只表达**软件可见能力需求**——软件需要看到和控制什么。
> **不定义 offset / bit 位 / access / reset**；寄存器结构由 SystemRDL 承接。

## 寄存器接口

| Item | Requirement |
|---|---|
| Protocol | APB4 |
| Access Width | 32 bit |
| Endian | little |
| Illegal Address | PSLVERR，无副作用 |
| Reserved Read | 返回 0 |
| Reserved Write | 忽略 |

### LRS.REG.PQC.ID.001 标识与版本能力

<!-- LRS_META
id: LRS.REG.PQC.ID.001
category: REG
feature: reg_id
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取 IP 版本、ABI 版本与微码版本标识，并独立读取算法、参数集、lane、
SCA 等级、SRAM 容量、DMA 能力与 key-slot 数量的能力位。

#### Acceptance Criteria

- 标识寄存器为只读且在复位后返回确定值；
- CAPABILITY 反映实际综合配置（含裁剪位图）；
- 能力查询与实际命令可用性一致。

---

### LRS.REG.PQC.CTRL.001 控制能力

<!-- LRS_META
id: LRS.REG.PQC.CTRL.001
category: REG
feature: reg_ctrl
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能启用/禁用 IP、发起 abort、发起 zeroize 与发起 self-test。

#### Acceptance Criteria

- 每项控制均产生可观察效果；
- 禁用状态拒绝密码命令；
- abort/zeroize/self-test 优先级按定义处理。

---

### LRS.REG.PQC.STATUS.001 状态能力

<!-- LRS_META
id: LRS.REG.PQC.STATUS.001
category: REG
feature: reg_status
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取 idle/busy/done/error/locked 状态。状态转换应对软件可观察且无歧义。

#### Acceptance Criteria

- 五种状态可独立观察；
- locked 状态在 self-test 失败或致命故障后置位；
- 状态不因轮询产生副作用。

---

### LRS.REG.PQC.RESULT.001 结果与完成 tag

<!-- LRS_META
id: LRS.REG.PQC.RESULT.001
category: REG
feature: reg_result
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取 verify result 与 completion tag；tag 应与提交的 command_id 一致。

#### Acceptance Criteria

- DSA_VERIFY 可通过结果寄存器获得 valid；
- tag 原样回写；
- 其他 opcode 的结果字段无未定义行为。

---

### LRS.REG.PQC.ERRCODE.001 非敏感错误类别

<!-- LRS_META
id: LRS.REG.PQC.ERRCODE.001
category: REG
feature: reg_error
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
- pqc_contract.md#§20.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取非敏感错误类别。错误类别不得编码秘密相关信息，也不得形成 KEM 有效性
oracle 或 ML-DSA 拒绝原因泄露。

#### Acceptance Criteria

- 所有错误类别为公开诊断分类；
- 不存在 KEM 有效性区分字段；
- 不存在每次拒绝原因字段。

---

### LRS.REG.PQC.INTR.001 中断能力

<!-- LRS_META
id: LRS.REG.PQC.INTR.001
category: REG
feature: reg_intr
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能对 DONE、ERROR、RNG_FAULT、TAMPER、SELF_TEST_FAIL 五类中断分别进行
state 读取、enable 配置、test 触发与 W1C 清除。

#### Acceptance Criteria

- 五类中断独立可控；
- W1C 只清除对应位；
- test 触发不产生真实密码副作用。

---

### LRS.REG.PQC.ALERT.001 告警能力

<!-- LRS_META
id: LRS.REG.PQC.ALERT.001
category: REG
feature: reg_alert
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取 recoverable 与 fatal 告警状态。fatal 告警应导致锁定并需要显式恢复流程。

#### Acceptance Criteria

- recoverable/fatal 可独立观察；
- fatal 后密码命令被拒绝；
- 告警状态在 zeroize/recover 后按定义更新。

---

### LRS.REG.PQC.PERF.001 性能计数器能力

<!-- LRS_META
id: LRS.REG.PQC.PERF.001
category: REG
feature: reg_perf
priority: P1
status: active
source_ref:
- pqc_contract.md#§6
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取总 cycles、Keccak cycles、NTT cycles、DMA stall 与公开命令类型计数。
生产模式应禁止暴露签名尝试次数及秘密相关的细粒度事件。

#### Acceptance Criteria

- 计数器可读且可清零；
- 生产策略下秘密相关事件不可读；
- 计数器不影响算法结果。

---

### LRS.REG.PQC.SLOT.001 Key slot 管理窗口

<!-- LRS_META
id: LRS.REG.PQC.SLOT.001
category: REG
feature: reg_slot
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
- pqc_contract.md#§20.5
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能通过 secure-only 管理窗口分配/销毁 key slot、查询 slot 元数据（owner/domain、
algorithm、parameter set、usage mask、exportable、valid、version）。

#### Acceptance Criteria

- slot 元数据可查询且与实际状态一致；
- 私钥 slot 默认不可读；
- 普通主体访问管理窗口被拒绝并记录。

---

### LRS.REG.PQC.COMPLETION.001 Completion record 能力

<!-- LRS_META
id: LRS.REG.PQC.COMPLETION.001
category: REG
feature: reg_completion
priority: P0
status: active
source_ref:
- pqc_contract.md#§20.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能读取 completion record，包含 command_id、status、output 长度、verify_valid、
非秘密 error_info 与 cycles 字段。cycles 可被安全策略屏蔽或量化。

#### Acceptance Criteria

- 字段齐全且与命令结果一致；
- KEM_DECAPS 全部长度正确密文返回 SUCCESS；
- 策略屏蔽时字段返回定义值而非随机值。