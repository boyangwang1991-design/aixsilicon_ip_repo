# PQC LRS：ML-DSA 功能需求

ML-DSA 共同参数：`n=256`，`q=8380417`。三个参数集 ML-DSA-44/65/87 的
公钥/私钥/签名长度分别为 1312/2560/2420、1952/4032/3309、2592/4896/4627 字节。
`gamma2` 对 44 为 `(q-1)/88`，对 65/87 为 `(q-1)/32`。

### LRS.FUNC.PQC.DSA_KEYGEN.001 ML-DSA KeyGen

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_KEYGEN.001
category: FUNC
feature: dsa_keygen
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.5
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

DSA_KEYGEN 应对 ML-DSA-44/65/87 全部参数集，从 32 B seed `xi` 产生符合 FIPS 204 的
公钥 `pk = rho || t1` 与私钥 `rho,K,tr,s1,s2,t0`。公钥可作为普通输出；
私钥仅按 LRS.SEC.PQC.SLOT.008 托管给外部 Key Manager，完成结果返回不透明 handle。

#### Acceptance Criteria

- 三个参数集 KAT 通过；
- 公钥输出与私钥专用托管长度与参数集定义一致；
- 同一 seed 产生确定性相同结果。

---

### LRS.FUNC.PQC.DSA_SIGN.001 ML-DSA Sign 与拒绝采样循环

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_SIGN.001
category: FUNC
feature: dsa_sign
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.6
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

DSA_SIGN 应对三个参数集，从 sk slot、消息 `M`、context `ctx` 与可选新鲜随机量产生
签名 `c_tilde || z || h`，字节级符合 FIPS 204。签名应实现完整拒绝采样循环：
`z = y + c·s1` 范数检查、`r0 = LowBits(w - c·s2)` 范数检查、hint 权重检查，
全部通过后一次性 commit。每次尝试固定调度、总次数及总延迟可变；
具体可观察边界以 LRS.SEC.PQC.CT.001 为准，禁止在首个失败检查处提前结束尝试。

#### Acceptance Criteria

- 三个参数集 KAT 通过；
- 强制 0/1/多次拒绝路径均可覆盖；
- 仅全部条件通过后输出签名。

---

### LRS.FUNC.PQC.DSA_SIGN.002 Sign 原子性与重试上限

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_SIGN.002
category: FUNC
feature: dsa_sign_atomic
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.6
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

候选签名应写入不可见 staging buffer，全部检查通过后一次性 DMA commit。每次失败不得
输出部分 `z/h`。attempt counter 溢出或达到安全上限时应返回通用
`INTERNAL_RETRY_EXHAUSTED` 并清除所有候选值。

#### Acceptance Criteria

- 拒绝轮次无任何部分签名可见；
- 达到上限返回通用内部错误且无输出；
- 上限检测不因 RNG 退化而活锁。

---

### LRS.FUNC.PQC.DSA_SIGN.003 deterministic 与 hedged 策略

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_SIGN.003
category: FUNC
feature: dsa_sign_policy
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.3
- pqc_contract.md#§17.6
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DSA_SIGN 应支持 deterministic 与 hedged 两种策略。hedged 模式应将 32 B 新鲜随机量
混入标准规定位置；deterministic 模式使用标准规定的确定性取值。

#### Acceptance Criteria

- 两种策略均产生可验签的合法签名；
- deterministic 模式同一输入结果确定；
- 非法 policy/opcode 组合被拒绝。

---

### LRS.FUNC.PQC.DSA_VERIFY.001 ML-DSA Verify

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_VERIFY.001
category: FUNC
feature: dsa_verify
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.7
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

DSA_VERIFY 应对三个参数集，从 `pk`、消息、context 与签名产生公开 valid bit。
应严格解析并检查规范编码、`z` 范数、hint 数量/顺序与全部边界，最终 valid 判定应结合
constant-time 比较产生。

#### Acceptance Criteria

- 三个参数集 KAT 与验签通过/失败向量通过；
- 非规范编码/越界 signature 被拒绝且不越界；
- valid 判定不受单点故障把 invalid 变为 valid。

---

### LRS.FUNC.PQC.DSA_MU.001 消息代表值与域分离

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_MU.001
category: FUNC
feature: dsa_domain
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.6
- pqc_contract.md#§17.8
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

消息代表值 `mu` 应严格按 FIPS 204 域分离构造，包含 `tr`、pure/prehash 域字节、
`len(ctx)` 与 `ctx`。软件不得直接注入内部 `mu` 绕过域分离，除非处于单独受控测试模式。

#### Acceptance Criteria

- pure 与 prehash 变体使用正确域字节；
- context 长度 0/1/255 B 均正确编码；
- 普通路径无法注入 mu。

---

### LRS.FUNC.PQC.DSA_MESSAGE.001 消息与 context 长度

<!-- LRS_META
id: LRS.FUNC.PQC.DSA_MESSAGE.001
category: FUNC
feature: dsa_message
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.3
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IP 应支持任意长度消息流，长度以 64 bit 表示；ML-DSA context 长度应支持 0–255 B。
超过 255 B 的 context 应被拒绝。

#### Acceptance Criteria

- 空/短/长消息签名与验签通过；
- context 0/1/255 B 通过，256 B 被拒绝；
- 64 bit 长度不被截断。