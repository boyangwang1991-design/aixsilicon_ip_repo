# AXI Memory Protection Unit — Checker & Assertion Plan

> 本文档是验证方案的一部分。定义 Checker/RM 分工与 `ASSERTION_META`。

---

## 7. Checker Architecture

```text
Input Transaction (AXI Master Agent / APB Agent)
     │
     ▼
Reference Model (axi_mpu_rm)
     │
Expected
     │
     ▼
Scoreboard (axi_mpu_scoreboard)
     ▲
Actual
     │
Output Monitor (AXI Slave Agent Monitor)
```

## 8. Reference Model 分工

| 对象 | 职责 |
|------|------|
| `axi_mpu_rm` | 从输入事务计算 Expected 判定（region/priority/permission/burst/DECERR/violation） |
| `axi_mpu_scoreboard` | 比较 RM 预期与 M_AXI/S 响应；检查 DECERR 语义与 ordering |
| `axi_mpu_violation_checker` | 校验 VIOL_* 寄存器 / IRQ 与 RM 预期一致 |

RM 为 transaction-level，独立于 RTL 实现。

---

## 9. Assertion Definitions

### ASSERT.AXI_MPU.READ_PATH.001 — Denied AR never reaches M_AXI_AR

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.READ_PATH.001
name: denied_ar_no_forward
feature_ref:
  - FL.AXI_MPU.READ_PATH
design_ref:
  - LLD.MOD.AXI_MPU.READ
property: 若某 AR 事务被判定为 DENY，则其不得出现在 M_AXI_AR 通道
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.WRITE_PATH.001 — Denied AW never reaches M_AXI_AW

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.WRITE_PATH.001
name: denied_aw_no_forward
feature_ref:
  - FL.AXI_MPU.WRITE_PATH
design_ref:
  - LLD.MOD.AXI_MPU.WRITE
property: 若某 AW 事务被判定为 DENY，则其不得出现在 M_AXI_AW 通道
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.WRITE_PATH.002 — Denied W data never modifies downstream state

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.WRITE_PATH.002
name: denied_w_no_downstream
feature_ref:
  - FL.AXI_MPU.WRITE_PATH
design_ref:
  - LLD.MOD.AXI_MPU.WRITE
property: 被拒绝的 write 事务的 W beats 不得驱动到 M_AXI_W，下游状态不被修改
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.ERR_RESP.001 — Denied transaction eventually receives local error response

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.ERR_RESP.001
name: denied_eventual_decerr
feature_ref:
  - FL.AXI_MPU.ERR_RESP
design_ref:
  - LLD.MOD.AXI_MPU.ERR_RESP
property: 每个被接受的 denied transaction 最终收到本地 DECERR 响应（read 全 beat / write B）
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.ERR_RESP.002 — No hang (response within bound)

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.ERR_RESP.002
name: no_hang
feature_ref:
  - FL.AXI_MPU.ERR_RESP
design_ref:
  - LLD.MOD.AXI_MPU.ERR_RESP
property: 被拒绝事务在有限周期内完成本地响应，READY 不被永久拉低
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.LOCK.001 — Locked region stable until reset

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.LOCK.001
name: locked_region_stable
feature_ref:
  - FL.AXI_MPU.LOCK
design_ref:
  - LLD.MOD.AXI_MPU.REGS
property: REGION_LOCK 置位后，该 Region 的 BASE/LIMIT/ATTR/MASTER_MASK 保持稳定直到 reset
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.LOCK.002 — GLOBAL_LOCK cannot 1->0 except reset

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.LOCK.002
name: global_lock_oneway
feature_ref:
  - FL.AXI_MPU.LOCK
design_ref:
  - LLD.MOD.AXI_MPU.REGS
property: GLOBAL_LOCK 不能从 1 转 0，除 reset 外
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.DEFAULT_DENY.001 — No unmatched access allowed

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.DEFAULT_DENY.001
name: default_deny_invariant
feature_ref:
  - FL.AXI_MPU.DEFAULT_DENY
design_ref:
  - LLD.MOD.AXI_MPU.PERM
property: DEFAULT_DENY 下，任何未匹配有效 Region 的访问不得被允许
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.BURST.001 — Burst crossing boundary denied whole

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.BURST.001
name: burst_cross_deny_whole
feature_ref:
  - FL.AXI_MPU.BURST
design_ref:
  - LLD.MOD.AXI_MPU.PERM
property: burst 若跨 Region 边界，整事务被拒绝，不得部分转发
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.MASTER_SEC.001 — Forged Secure rejected

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.MASTER_SEC.001
name: forged_secure_rejected
feature_ref:
  - FL.AXI_MPU.MASTER_SEC
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
property: Master 无 SECURE_CAPABLE 时声明 Secure 的访问必须被拒绝
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.MASTER.001 — Invalid master id rejected

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.MASTER.001
name: invalid_master_rejected
feature_ref:
  - FL.AXI_MPU.MASTER
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
property: master_id >= MASTER_NUM 的访问必须被拒绝
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.CONFIG.001 — APB illegal address rejected

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.CONFIG.001
name: apb_illegal_addr
feature_ref:
  - FL.AXI_MPU.CONFIG
design_ref:
  - LLD.MOD.AXI_MPU.REGS
property: APB 对未定义地址的访问必须被拒绝（PSLVERR 或忽略），不得破坏 DUT 状态
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.CONFIG.002 — Locked config write ignored

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.CONFIG.002
name: locked_cfg_write_ignored
feature_ref:
  - FL.AXI_MPU.CONFIG
design_ref:
  - LLD.MOD.AXI_MPU.REGS
property: Region/Global Lock 生效后，对受保护配置字段的写访问不得改变其值
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.REQ_CONTEXT.001 — Request context built from AXI signals

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.REQ_CONTEXT.001
name: req_ctx_mapping
feature_ref:
  - FL.AXI_MPU.REQ_CONTEXT
design_ref:
  - LLD.DATAPATH.AXI_MPU.REQ_CTX
property: Request Context 的 address/read_write/secure/privileged/instruction/master_id 字段必须与 AXI 通道信号一致映射
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->

### ASSERT.AXI_MPU.GEN_PARAM.001 — Region table width matches generator params

<!-- ASSERTION_META
id: ASSERT.AXI_MPU.GEN_PARAM.001
name: region_table_width
feature_ref:
  - FL.AXI_MPU.GEN_PARAM
design_ref:
  - LLD.MOD.AXI_MPU.TOP
property: REGION_BASE/LIMIT 与 VIOL_ADDR 寄存器位宽必须等于 ADDR_WIDTH；MASTER_MASK 位宽必须等于 MASTER_NUM
severity: error
verification_method: assertion
applicability:
  expr: "true"
END_ASSERTION_META -->
