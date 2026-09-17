# PQC LRS：ML-KEM 功能需求

ML-KEM 共同参数：`n=256`，`q=3329`，共享秘密 32 B。三个参数集 ML-KEM-512/768/1024
的公钥/私钥/密文长度分别为 800/1632/768、1184/2400/1088、1568/3168/1568 字节。
本册定义外部可观察的算法结果与隐式拒绝性质。

### LRS.FUNC.PQC.KEM_KEYGEN.001 ML-KEM KeyGen

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_KEYGEN.001
category: FUNC
feature: kem_keygen
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.2
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

KEM_KEYGEN 应对 ML-KEM-512/768/1024 全部参数集，从 64 B seed `d || z`（生产模式由
DRBG 生成，KAT 模式可注入）产生符合 FIPS 203 字节级定义的封装公钥 `ek` 与解封装私钥
`dk`；公钥可作为普通输出，私钥仅按 LRS.SEC.PQC.SLOT.008 托管给外部 Key Manager，
完成结果只返回不透明 handle，不输出明文私钥到主机。

#### Acceptance Criteria

- 三个参数集的 KAT 向量全部通过；
- 公钥输出与私钥专用托管长度均与参数集定义一致；
- 同一 seed 产生确定性相同结果。

---

### LRS.FUNC.PQC.KEM_ENCAPS.001 ML-KEM Encaps

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_ENCAPS.001
category: FUNC
feature: kem_encaps
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.3
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

KEM_ENCAPS 应对三个参数集，从 `ek` 与 32 B randomness `m` 产生密文 `c` 与 32 B
共享秘密 `K`，字节级符合 FIPS 203。Encaps 不应允许主机提供内部 `r`、噪声向量或矩阵。

#### Acceptance Criteria

- 三个参数集 KAT 通过；
- 使用 KAT 注入 randomness 时结果确定；
- 输出长度与参数集一致且 `K` 为 32 B。

---

### LRS.FUNC.PQC.KEM_DECAPS.001 ML-KEM Decaps 隐式拒绝

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_DECAPS.001
category: FUNC
feature: kem_decaps
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.4
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

KEM_DECAPS 应对三个参数集，从 `dk` slot 与密文 `c` 产生 32 B 共享秘密。硬件应在内部
完成解密、`K' || r'` 重派生、完整重加密、全长度常数时间比较与常数时间 select。
对长度正确的任意密文（含非法密文）应返回 SUCCESS；无效密文应产生伪随机 rejection
secret `K_bar = J(z || c)`。

#### Acceptance Criteria

- 三个参数集 KAT 通过；
- 长度正确的单比特翻转/随机密文不产生有效性 oracle；
- 长度正确且无系统故障时输出为 32 B，completion 为 SUCCESS；
- 错误长度属于公开 API 格式错误，按 KEM_LEN.001 拒绝且不输出共享秘密。

---

### LRS.FUNC.PQC.KEM_DECAPS.002 Decaps 常数时间性质

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_DECAPS.002
category: FUNC
feature: kem_decaps_ct
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.1
- pqc_contract.md#§17.4
applicability:
  expr: 'true'
verification_method:
- formal
- simulation
END_LRS_META -->

#### Requirement

`KEM_DECAPS` 的密文是否合法不得影响外部可观察的分支、DMA 地址、错误码或总完成时间。
禁止首个不等字节即退出、失配时跳过 Keccak、由失配控制 clock gating。

#### Acceptance Criteria

- 合法/非法密文的公开 trace 形状与完成周期分布一致；
- 比较与 select 遍历全长度；
- 不存在 secret-dependent 的地址或门控。

---

### LRS.FUNC.PQC.KEM_LEN.001 密文与密钥长度边界

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_LEN.001
category: FUNC
feature: kem_length
priority: P0
status: active
source_ref:
- pqc_contract.md#§17.4
- pqc_contract.md#§11.2
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

Decaps 应固定长度读取完整密文；长度错误应在 API 层统一映射为失败结果，不进入越界解析。
truncated/oversized 密文不应导致越界访存或未定义行为。

#### Acceptance Criteria

- 过长/过短密文返回定义错误且不越界；
- 不产生有效性区分；
- 错误长度清理不留部分结果。

---

### LRS.FUNC.PQC.KEM_DATAFLOW.001 流式矩阵与工作集约束

<!-- LRS_META
id: LRS.FUNC.PQC.KEM_DATAFLOW.001
category: FUNC
feature: kem_dataflow
priority: P1
status: active
source_ref:
- pqc_contract.md#§17.2
- pqc_contract.md#§19.1
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

矩阵 `A_hat`/`A^T_hat` 应逐 polynomial 生成、使用、释放，不应为最大参数集常驻 16 个
polynomial。Encaps 中 `u` 与 `v` 的计算应产生与 FIPS 203 一致的压缩编码密文。

#### Acceptance Criteria

- 峰值 SRAM 占用不随 k 线性增长到常驻整矩阵；
- Compress/Decompress 使用参数集对应 du/dv；
- 结果与参考模型字节一致。