# PQC LRS：命令集合与命令语义

本册定义外部可观察的命令能力与状态语义；具体 descriptor 位域布局由 HLD/Lld 承接，
LRS 只规定软件可见能力。

## 命令能力概览

| Opcode | 输入 | 输出 | 关键可观察行为 |
|---|---|---|---|
| KEM_KEYGEN | seed/RNG、parameter set | ek、dk 或 slot handle | 支持确定性 KAT 与生产 RNG |
| KEM_ENCAPS | ek、randomness | ciphertext、shared secret | 随机数只来自批准熵路径 |
| KEM_DECAPS | dk slot、ciphertext | shared secret | 隐式拒绝；只返回命令完成 |
| DSA_KEYGEN | seed/RNG、parameter set | pk、sk 或 slot handle | 私钥默认写入 slot |
| DSA_SIGN | sk slot、message、context | signature | 支持 deterministic 与 hedged |
| DSA_VERIFY | pk、message、context、signature | valid bit | 无秘密数据 |
| ZEROIZE | slot/all | completion | 高优先级安全清零 |
| SELF_TEST | test selector | pass/fail | 上电 KAT、按需自检 |

### LRS.FUNC.PQC.CMD.001 命令集合完整性

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.001
category: FUNC
feature: command_set
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.1
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IP 应实现全部八个 opcode：KEM_KEYGEN、KEM_ENCAPS、KEM_DECAPS、DSA_KEYGEN、DSA_SIGN、
DSA_VERIFY、ZEROIZE、SELF_TEST，且每个 opcode 在 CAPABILITY 中可被软件查询。

#### Acceptance Criteria

- 每个 opcode 均可被 doorbell 提交并产生 completion；
- 未实现 opcode 返回配置错误；
- CAPABILITY 与实现的 opcode 集合一致。

---

### LRS.FUNC.PQC.CMD.002 命令描述符字段语义

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.002
category: FUNC
feature: command_descriptor
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
- pqc_contract.md#§20.1
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每个命令应包含 opcode、parameter set、flags、输入/输出地址与长度、key handle、
context 地址/长度与 completion tag。描述符应自然对齐并在启动前被原子抓取；
抓取后软件修改内存不得影响当前命令。

#### Acceptance Criteria

- 描述符全字段被抓取且校验（对齐、ABI、reserved、CRC、长度、capability）；
- 抓取后修改内存不改变执行结果；
- 非法字段在访问秘密前被终止。

---

### LRS.FUNC.PQC.CMD.003 参数校验与提前终止

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.003
category: FUNC
feature: command_validate
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

非法参数、地址未对齐、输出 buffer 过小、权限失败应在访问任何秘密数据之前终止命令，
并返回对应错误类别。

#### Acceptance Criteria

- 每类非法输入均在任何秘密读取前终止；
- 错误类别可区分配置/权限/长度/对齐；
- 终止后不留下部分结果。

---

### LRS.FUNC.PQC.CMD.004 运行中配置锁定

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.004
category: FUNC
feature: command_lock
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

BUSY 期间应锁定命令相关配置，软件修改不得影响正在执行的命令参数。

#### Acceptance Criteria

- BUSY 中写入被忽略或返回错误，当前命令结果不变；
- 锁定在 COMPLETE 后释放；
- 锁定覆盖 opcode/parameter set/地址/长度/key handle。

---

### LRS.FUNC.PQC.CMD.005 完成状态与错误分类

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.005
category: FUNC
feature: command_status
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
- pqc_contract.md#§20.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

完成状态应区分配置错误、DMA 错误、熵错误、自检错误与内部故障；不得区分 ML-KEM
密文有效/无效，也不得暴露 ML-DSA 每次拒绝原因。`KEM_DECAPS` 对所有长度正确的密文
应返回 SUCCESS。

#### Acceptance Criteria

- 五类错误可独立观察；
- 不存在 `KEM_INVALID` 状态或等效 oracle；
- `DSA_VERIFY` 的 invalid 作为公开 API 输出返回。

---

### LRS.FUNC.PQC.CMD.006 完成写序与门铃协议

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.006
category: FUNC
feature: doorbell
priority: P0
status: active
source_ref:
- pqc_contract.md#§20.3
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

门铃提交应按固定顺序完成：结果 staging → DMA 输出 → 写 completion record → 置
DONE 并中断。descriptor 可复用，completion 写入前 DONE 不得置位。

#### Acceptance Criteria

- 任意时刻观察到的顺序符合定义；
- DONE 置位时 completion record 已可见；
- 中断清除后可提交下一命令。

---

### LRS.FUNC.PQC.CMD.007 中止与安全收尾

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.007
category: FUNC
feature: abort
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

软件 abort 应仅在安全边界点生效，随后清零临时状态，不得留下可恢复的部分结果。

#### Acceptance Criteria

- abort 后无部分输出被提交；
- 所有临时秘密被清零；
- abort 后 IP 可接受新命令。

---

### LRS.FUNC.PQC.CMD.008 命令中断支持

<!-- LRS_META
id: LRS.FUNC.PQC.CMD.008
category: FUNC
feature: command_irq
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IP 应同时支持中断与轮询两种完成通知；两种方式观察到同一 completion record。

#### Acceptance Criteria

- 中断与轮询得到一致的 status/tag/长度；
- 中断在轮询模式可被屏蔽；
- 不产生丢失或重复的完成通知。