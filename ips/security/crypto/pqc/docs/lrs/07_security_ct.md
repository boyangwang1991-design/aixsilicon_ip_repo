# PQC LRS：常数时间与访问模式安全需求

### LRS.SEC.PQC.CT.001 秘密不控制可观察行为

<!-- LRS_META
id: LRS.SEC.PQC.CT.001
category: SEC
feature: constant_time
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.1
applicability:
  expr: 'true'
verification_method:
- formal
- simulation
END_LRS_META -->

#### Requirement

私钥与解封装比较结果不得影响未经授权的外部状态、错误分类或 DMA 地址。
KEM Decaps 对相同公开输入长度和相同外部服务条件，合法/非法密文保持相同完成调度。

ML-DSA Sign 采用每次尝试固定调度、总尝试次数与总延迟可变的明确例外。每次尝试
应完成预定计算和全部检查后统一决定重试；失败原因、检查失败位置及部分签名不可见。
不得把不同失败位置的提前退出或 sampler 的可变耗时当作固定调度。
固定尝试预算必须包含原语和采样完成/填充；预算耗尽进入统一错误和清除路径，
不得通过秘密相关错误码暴露细节。总时延分布仍须分析/验证与私钥的独立性；
允许可变总延迟不等于已证明无侧信道。

#### Acceptance Criteria

- 对同一公开配置和同样外部等待，各拒绝原因/位置的单次 Sign 尝试具有相同调度长度与外部访问形状；
- 单次尝试的采样/原语等待、填充和终止边界全部计量，不能只检查 FSM 状态序列；
- 成功前不输出候选签名；超限仅返回统一错误并清除所有临时秘密；
- KEM Decaps 的密文有效性不影响完成周期、DMA 形状或错误码；
- 形式检查覆盖禁止的控制依赖，统计检查比较 Sign 总时延/尝试次数分布；
- P50/P95/P99 描述性能，不作为侧信道安全证明。

---

### LRS.SEC.PQC.CT.002 禁止秘密相关门控

<!-- LRS_META
id: LRS.SEC.PQC.CT.002
category: SEC
feature: no_secret_gating
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.1
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

禁止在 secret-dependent 条件下 clock gate 单个运算单元；时钟门控只能依据公开调度状态。

#### Acceptance Criteria

- 时钟门控使能仅来自公开状态；
- 静态检查覆盖所有门控点；
- 无数据相关 gating。

---

### LRS.SEC.PQC.CT.003 确定性本地存储

<!-- LRS_META
id: LRS.SEC.PQC.CT.003
category: SEC
feature: no_cache
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.1
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

cache 不参与秘密工作集；所有秘密计算应使用确定性本地 SRAM，访存模式可静态分析。

#### Acceptance Criteria

- IP 不发起带 cache 属性的秘密访问；
- 秘密工作集完全位于本地 SRAM；
- 访存地址生成不依赖秘密值。

---

### LRS.SEC.PQC.ZEROIZE.001 零化与最大周期

<!-- LRS_META
id: LRS.SEC.PQC.ZEROIZE.001
category: SEC
feature: zeroize
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.4
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

IP 应提供同步 `zeroize_req`，在规定的最大周期数内完成工作 SRAM、Keccak 状态与秘密
寄存器的清零。zeroize 不应依赖主时序状态机正常运行。

#### Acceptance Criteria

- 从任意状态均可在最大周期内完成零化；
- 零化不依赖主 FSM 正确运行；
- 零化后可验证无秘密残留。

---

### LRS.SEC.PQC.LOCK.001 立即停止与锁定

<!-- LRS_META
id: LRS.SEC.PQC.LOCK.001
category: SEC
feature: fault_lock
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.4
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

tamper、fatal ECC、self-test fail 与生命周期变化应触发立即停止、清零工作状态并锁定。

#### Acceptance Criteria

- 四类事件均可触发同一锁定序列；
- 锁定后拒绝密码命令；
- 事件类别可观察且不泄露秘密。

---

### LRS.SEC.PQC.INTEGRITY.001 控制与计数器完整性保护

<!-- LRS_META
id: LRS.SEC.PQC.INTEGRITY.001
category: SEC
feature: control_integrity
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.4
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

控制 FSM 应使用稀疏编码或冗余校验；opcode、参数集、key type 与权限字段应带完整性保护。
关键循环计数器、NTT stage、DMA 长度与 micro-PC 应提供冗余或奇偶校验。

#### Acceptance Criteria

- 单点翻转可被检测；
- 检测后进入锁定或安全收尾；
- 完整性保护不引入秘密相关分支。

---

### LRS.SEC.PQC.VERIFY.001 Verify 判定双轨保护

<!-- LRS_META
id: LRS.SEC.PQC.VERIFY.001
category: SEC
feature: verify_hardening
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.4
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

ML-DSA Verify 的最终 valid 判定应采用双轨或重复比较，避免单点故障把 invalid 变为 valid。
KEM 重加密比较与 shared-secret select 应提供结果完整性保护。

#### Acceptance Criteria

- 单点故障不能翻转 valid 结果；
- select 逻辑有结果完整性检查；
- 保护不改变正确结果。