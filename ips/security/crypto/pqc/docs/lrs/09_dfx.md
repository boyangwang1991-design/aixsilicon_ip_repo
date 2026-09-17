# PQC LRS：DFX / 可测性与可观测性需求

### LRS.DFX.PQC.SCAN.001 秘密扫描排除

<!-- LRS_META
id: LRS.DFX.PQC.SCAN.001
category: DFX
feature: scan_exclusion
priority: P0
status: active
source_ref:
- pqc_contract.md#§12
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

密钥与秘密中间态应使用 secure scan exclusion 或加密 scan；生产生命周期不可旁路。

#### Acceptance Criteria

- 秘密寄存器与 key RAM 不进入普通 scan chain；
- scan 模式在生产生命周期被禁止；
- 排除清单可审计。

---

### LRS.DFX.PQC.MBIST.001 SRAM MBIST 安全要求

<!-- LRS_META
id: LRS.DFX.PQC.MBIST.001
category: DFX
feature: mbist
priority: P0
status: active
source_ref:
- pqc_contract.md#§12
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

SRAM MBIST 不得泄露 retained key；测试前后应执行受控清零。

#### Acceptance Criteria

- MBIST 前后工作 SRAM 被清零；
- MBIST 不读取 key RAM 内容到可观察端口；
- 清零在 MBIST 使能序列中强制。

---

### LRS.DFX.PQC.DEBUG.001 受限 debug 可观测性

<!-- LRS_META
id: LRS.DFX.PQC.DEBUG.001
category: DFX
feature: debug_visibility
priority: P0
status: active
source_ref:
- pqc_contract.md#§12
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

debug 仅可观察公开 command state、粗粒度进度与错误类别。trace 不记录 seed、randomness、
secret coefficient、shared secret、签名 nonce 或 KEM validity。

#### Acceptance Criteria

- 可观察信号清单仅含公开对象；
- 不存在秘密对象进入 trace/debug 端口；
- 清单可审计。

---

### LRS.DFX.PQC.FI.001 故障注入能力

<!-- LRS_META
id: LRS.DFX.PQC.FI.001
category: DFX
feature: fault_injection
priority: P1
status: active
source_ref:
- pqc_contract.md#§12
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IP 应可注入公开数据路径 ECC、DMA 与控制完整性错误。秘密相关 fault injection 端口
仅应在测试生命周期存在。

#### Acceptance Criteria

- 公开路径注错可稳定触发对应检测；
- 秘密注错端口在生产生命周期不可用；
- 正常功能模式无法意外触发注错。

---

### LRS.DFX.PQC.PERFCNT.001 性能计数器可观测性

<!-- LRS_META
id: LRS.DFX.PQC.PERFCNT.001
category: DFX
feature: perf_counter
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

IP 应提供总 cycles、Keccak cycles、NTT cycles、DMA stall 与公开命令类型计数供性能分析
使用。

#### Acceptance Criteria

- 计数器与仿真测量一致；
- 计数器不因读取产生副作用；
- 生产策略下秘密相关细粒度事件不可读。