# AXI Memory Protection Unit — Coverage Plan

> 本文档是验证方案的一部分。定义功能覆盖对象（`COVERAGE_META`）。

---

## 10. Functional Coverage Objects

### COV.AXI_MPU.REGION.001 — Region Match 类别覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.REGION.001
name: region_match_class
type: functional
description: Region 匹配类别覆盖：无匹配/单匹配/多匹配/优先级/BASE/LIMIT/boundary ±1/非法 BASE>LIMIT
feature_ref:
  - FL.AXI_MPU.REGION
design_ref:
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 Region 匹配的所有类别是否被触达。

### Coverpoints

* `region_match_class`: no_match / single / multi / priority_lowest / base_eq / limit_eq / base_minus1 / limit_plus1 / invalid_base_limit；
* `priority_index`: lowest-index matching region index。

### Cross Coverage

* `region_match_class x operation_type`（read/write）；
* `priority_index x region_match_class`。

---

### COV.AXI_MPU.MASTER.001 — Master 权限覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.MASTER.001
name: master_permission_cov
type: functional
description: MASTER_MASK allowed/denied、非法 Master ID 覆盖
feature_ref:
  - FL.AXI_MPU.MASTER
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 Master 权限判定各类别是否被触达。

### Coverpoints

* `master_allowed`: allowed / denied；
* `master_id_invalid`: valid / invalid(>=MASTER_NUM)。

---

### COV.AXI_MPU.SECURITY.001 — Security 权限覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.SECURITY.001
name: security_permission_cov
type: functional
description: Secure/Non-secure allow/deny、forged Secure、Master Attr violation 覆盖
feature_ref:
  - FL.AXI_MPU.MASTER_SEC
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 Security 权限维度各类别是否被触达。

### Coverpoints

* `security_state`: secure / non_secure；
* `security_allow`: allow / deny；
* `master_attr_violation`: valid / forged / no_capability。

---

### COV.AXI_MPU.PERM.001 — Privilege/Operation 覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.PERM.001
name: perm_dimension_cov
type: functional
description: Privileged/Unprivileged、Read/Write/Execute/NX 判定覆盖
feature_ref:
  - FL.AXI_MPU.PERM_DIM
design_ref:
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量权限维度各类别是否被触达。

### Coverpoints

* `privilege`: privileged / unprivileged；
* `operation`: read / write / instruction；
* `deny_reason`: NO_REGION/MASTER_DENY/MASTER_SECURITY_DENY/SECURITY_DENY/PRIVILEGE_DENY/READ_DENY/WRITE_DENY/EXECUTE_DENY/BURST_BOUNDARY_DENY/INVALID_CONTEXT。

### Cross Coverage

* `operation x deny_reason`；
* `privilege x deny_reason`。

---

### COV.AXI_MPU.BURST.001 — Burst 覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.BURST.001
name: burst_cov
type: functional
description: INCR/FIXED/WRAP、fully inside/cross BASE/cross LIMIT/cross Region 覆盖
feature_ref:
  - FL.AXI_MPU.BURST
design_ref:
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 burst 类型与边界类别是否被触达。

### Coverpoints

* `burst_type`: incr / fixed / wrap；
* `burst_boundary`: fully_inside / cross_base / cross_limit / cross_region。

### Cross Coverage

* `burst_type x burst_boundary`。

---

### COV.AXI_MPU.TXN.001 — AXI Transaction 覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.TXN.001
name: axi_txn_cov
type: functional
description: 多 ID、多 outstanding、backpressure、AW/W 解耦、local DECERR、reset during traffic 覆盖
feature_ref:
  - FL.AXI_MPU.OUTSTANDING
design_ref:
  - LLD.MOD.AXI_MPU.READ
  - LLD.MOD.AXI_MPU.WRITE
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 AXI 事务层面场景是否被触达。

### Coverpoints

* `outstanding_depth`: 1/2/4/8（读/写）；
* `backpressure`: none / ar_ready_stall / w_ready_stall / r_ready_stall / b_ready_stall；
* `response`: okay / decerr；
* `reset_during_traffic`: idle / active。

---

### COV.AXI_MPU.VIOLATION.001 — Violation 覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.VIOLATION.001
name: violation_cov
type: functional
description: FIRST_ERROR_STICKY、VIOL_COUNT saturation、IRQ sticky/W1C、simultaneous violations 覆盖
feature_ref:
  - FL.AXI_MPU.VIOLATION
design_ref:
  - LLD.MOD.AXI_MPU.VIOLATION
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 violation 捕获/清除/中断各类别是否被触达。

### Coverpoints

* `capture_policy`: first_error / subsequent_ignored；
* `count_saturation`: not_full / saturated；
* `irq_state`: set / cleared_w1c / irq_enable / irq_disable；
* `simultaneous`: single / multiple_same_cycle。

---

### COV.AXI_MPU.LOCK.001 — Lock 覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.LOCK.001
name: lock_cov
type: functional
description: Region Lock、Global Lock、reset unlock 覆盖
feature_ref:
  - FL.AXI_MPU.LOCK
design_ref:
  - LLD.MOD.AXI_MPU.REGS
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 lock 语义各类别是否被触达。

### Coverpoints

* `region_lock`: unlocked / locked / rewrite_attempt_after_lock / reset_unlock；
* `global_lock`: unlocked / locked / write_zero_attempt / reset_unlock。

---

### COV.AXI_MPU.CONFIG.001 — 配置接口覆盖

<!-- COVERAGE_META
id: COV.AXI_MPU.CONFIG.001
name: config_cov
type: functional
description: APB4 访问（RW/RO/W1C）、illegal address 覆盖
feature_ref:
  - FL.AXI_MPU.CONFIG
design_ref:
  - LLD.MOD.AXI_MPU.REGS
applicability:
  expr: "true"
END_COVERAGE_META -->

### Coverage Intent

衡量 APB4 配置访问类别是否被触达。

### Coverpoints

* `access_type`: rw / ro / w1c / illegal_addr；
* `register_group`: global / irq / violation / master_attr / region。
