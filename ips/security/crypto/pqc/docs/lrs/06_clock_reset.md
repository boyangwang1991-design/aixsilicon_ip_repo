# PQC LRS：时钟与复位需求

### LRS.RESET.PQC.CLK.001 主时钟

<!-- LRS_META
id: LRS.RESET.PQC.CLK.001
category: RESET
feature: clock
priority: P0
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

IP 应使用单一主功能时钟 `clk`，规划目标频率 400 MHz（Balanced 配置，28 nm 级工艺）。
APB、AXI 与密码数据路径应处于同一时钟域。

#### Acceptance Criteria

- 400 MHz 仅作为规划与周期换算基准，本轮不声称已完成物理时序闭合；
- 不存在未声明的内部时钟域；
- 时钟门控只依据公开调度状态。

---

### LRS.RESET.PQC.COLD.001 冷复位与上电自检

<!-- LRS_META
id: LRS.RESET.PQC.COLD.001
category: RESET
feature: cold_reset
priority: P0
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

冷复位后 IP 应先执行 KAT self-test；成功前应拒绝所有密码命令。self-test 失败应进入
Locked 状态并置位 SELF_TEST_FAIL 中断。

#### Acceptance Criteria

- 复位后初始状态为 Disabled/SelfTest；
- self-test 成功前密码命令被拒绝；
- 失败后锁定且无法执行密码命令。

---

### LRS.RESET.PQC.WARM.001 Warm reset 与 key slot 保持

<!-- LRS_META
id: LRS.RESET.PQC.WARM.001
category: RESET
feature: warm_reset
priority: P0
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

warm reset 应默认清除 ephemeral slot；persistent slot 的保持策略应由 key manager /
生命周期决定，不应由 IP 自行假定保留。

#### Acceptance Criteria

- ephemeral slot 在 warm reset 后被清除；
- persistent slot 保持策略可由外部策略控制；
- 保持与否可在 slot 元数据中观察。

---

### LRS.RESET.PQC.SAFE.001 故障统一安全收尾

<!-- LRS_META
id: LRS.RESET.PQC.SAFE.001
category: RESET
feature: safe_shutdown
priority: P0
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

DMA bus error、timeout、ECC UE 与 RNG health fail 应进入统一安全收尾流程：停止当前
计算、清零工作 SRAM/Keccak/寄存器、置位对应告警。

#### Acceptance Criteria

- 五类故障均触发同一收尾序列；
- 收尾后无秘密残留；
- 告警类别可区分且有界完成。

---

### LRS.RESET.PQC.POWERDOWN.001 掉电前收尾

<!-- LRS_META
id: LRS.RESET.PQC.POWERDOWN.001
category: RESET
feature: powerdown
priority: P1
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

power-down 前应完成或安全中止当前操作并清零工作状态；密钥保持域应独立说明
retention、tamper 与 ECC 策略。

#### Acceptance Criteria

- 掉电请求不产生部分输出；
- 工作状态被清零；
- 保持域的 retention 策略有文档记录。