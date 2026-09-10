# AXI Memory Protection Unit — Feature List

> 本文档是验证方案的一部分。Feature 通过 `req_ref` 追踪到 LRS 需求；Testcase 通过
> `feature_ref` 引用 Feature（一对一）。

---

### FL.AXI_MPU.DEFAULT_DENY — Default Deny 策略

<!-- FEATURE_META
id: FL.AXI_MPU.DEFAULT_DENY
name: Default_Deny
description: 未匹配任何有效 Region 的访问默认拒绝；Reset 后所有可编程 Region 默认 disabled；Default Deny 与 Explicit Allow 组合
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.DEFAULT_DENY.001
  - LRS.FUNC.AXI_MPU.DEFAULT_DENY.002
design_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
proof_methods:
  - simulation
  - assertion
END_FEATURE_META -->

### Verification Intent

证明未匹配 Region 的访问被拒绝、Reset 后默认 deny、Explicit Allow 才放行。

### Verification Objects

* `axi_mpu_permission`（region_match / priority / checker）；
* `regs/axi_mpu.rdl`（REGION_CONTROL.enable reset）。

### Key Risk

* 误 allow（组合逻辑遗漏）；
* reset 后 enable 残留。

---

### FL.AXI_MPU.REQ_CONTEXT — Request Context 构建

<!-- FEATURE_META
id: FL.AXI_MPU.REQ_CONTEXT
name: Request_Context
description: 每个 AXI transaction 转换为基础 Request Context（address/read_write/axi_id/master_id/secure/privileged/instruction/burst 属性）
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.REQ_CONTEXT.001
design_ref:
  - HLD.IF.INT.AXI_MPU.REQ_CTX
  - LLD.DATAPATH.AXI_MPU.REQ_CTX
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 read/write 两侧均能正确构建 context（AR/AW 通道信号正确映射）。

---

### FL.AXI_MPU.MASTER — Master Identity 与权限

<!-- FEATURE_META
id: FL.AXI_MPU.MASTER
name: Master_Identity
description: MASTER_MASK 按 master_id 判定；非法 Master ID（>=MASTER_NUM）必须拒绝；AxID 不作为 Master Identity
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.MASTER_ID.001
  - LRS.FUNC.AXI_MPU.PERM_MASTER.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
  - LLD.MOD.AXI_MPU.MASTER_ATTR
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 master_allowed 判定正确、非法 ID 被拒绝。

---

### FL.AXI_MPU.MASTER_SEC — Master Security Attribution

<!-- FEATURE_META
id: FL.AXI_MPU.MASTER_SEC
name: Master_Security_Attribution
description: MASTER_ATTR（SECURE_CAPABLE/NONSECURE_CAPABLE）校验声明的 Security 状态；Master Security 与 Region Security 独立检查
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001
  - LRS.SEC.AXI_MPU.ATTACK.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
  - LLD.MOD.AXI_MPU.MASTER_ATTR
applicability:
  expr: "true"
proof_methods:
  - simulation
  - formal
END_FEATURE_META -->

### Verification Intent

证明 master_security_valid 判定、forged Secure 被拒绝。

---

### FL.AXI_MPU.REGION — Region 匹配与优先级

<!-- FEATURE_META
id: FL.AXI_MPU.REGION
name: Region_Match
description: BASE+LIMIT 模式；region_match（enable && addr>=base && addr<=limit）；Lowest Region Index Wins；非法 BASE>LIMIT 视为 disabled
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.REGION.001
  - LRS.FUNC.AXI_MPU.REGION.002
  - LRS.FUNC.AXI_MPU.REGION.003
  - LRS.FUNC.AXI_MPU.REGION.004
design_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
proof_methods:
  - simulation
  - formal
END_FEATURE_META -->

### Verification Intent

证明 region match、BASE/LIMIT 边界、优先级、非法配置处理。

---

### FL.AXI_MPU.BURST — Burst Boundary Protection

<!-- FEATURE_META
id: FL.AXI_MPU.BURST
name: Burst_Boundary
description: INCR/FIXED/WRAP burst 计算完整地址范围；跨 Region 边界整事务拒绝；不能部分 beat 合法部分非法
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.BURST.001
  - LRS.FUNC.AXI_MPU.BURST.002
design_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
proof_methods:
  - simulation
  - formal
END_FEATURE_META -->

### Verification Intent

证明 burst_start/end 计算、跨边界 DENY whole transaction。

---

### FL.AXI_MPU.PERM_DIM — Security/Privilege/Operation 权限维度

<!-- FEATURE_META
id: FL.AXI_MPU.PERM_DIM
name: Permission_Dimensions
description: Secure/Non-secure、Privileged/Unprivileged、Read/Write/Execute 独立判定并 AND 组合；deny_reason 可观测
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.PERM_SECURITY.001
  - LRS.FUNC.AXI_MPU.PERM_PRIVILEGE.001
  - LRS.FUNC.AXI_MPU.PERM_OP.001
  - LRS.FUNC.AXI_MPU.PERM_DECISION.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - LLD.MOD.AXI_MPU.PERM
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明各权限维度独立判定、AND 组合、deny_reason 正确。

---

### FL.AXI_MPU.READ_PATH — Read Path

<!-- FEATURE_META
id: FL.AXI_MPU.READ_PATH
name: Read_Path
description: AR 捕获、合法性判断、合法转发、非法本地 R DECERR（RID/RVALID/RRESP/RLAST 完整）、read outstanding 跟踪
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.READ.001
  - LRS.FUNC.AXI_MPU.READ.002
  - LRS.FUNC.AXI_MPU.OUTSTANDING.001
  - LRS.INTF.AXI_MPU.AXI_SLAVE.001
  - LRS.INTF.AXI_MPU.AXI_MASTER.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - LLD.MOD.AXI_MPU.READ
  - LLD.FSM.AXI_MPU.READ
applicability:
  expr: "true"
proof_methods:
  - simulation
  - assertion
END_FEATURE_META -->

### Verification Intent

证明 read 合法/非法路径的完整行为、本地 DECERR、outstanding 跟踪。

---

### FL.AXI_MPU.WRITE_PATH — Write Path 与 Write Decision Queue

<!-- FEATURE_META
id: FL.AXI_MPU.WRITE_PATH
name: Write_Path
description: AW/W 解耦、Write Decision Queue 关联 AW 与 W、非法 W consume+本地 B DECERR、无 deadlock/串扰/部分写入
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.WRITE.001
  - LRS.FUNC.AXI_MPU.WRITE.002
  - LRS.FUNC.AXI_MPU.WRITE_QUEUE.001
  - LRS.INTF.AXI_MPU.AXI_SLAVE.001
  - LRS.INTF.AXI_MPU.AXI_MASTER.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
  - LLD.MOD.AXI_MPU.WRITE
  - LLD.FSM.AXI_MPU.WRITE
applicability:
  expr: "true"
proof_methods:
  - simulation
  - assertion
END_FEATURE_META -->

### Verification Intent

证明 write 合法/非法路径、WQ 关联、本地 DECERR、无 hang/串扰。

---

### FL.AXI_MPU.ERR_RESP — Local DECERR 与 Ordering

<!-- FEATURE_META
id: FL.AXI_MPU.ERR_RESP
name: Error_Response
description: 非法访问本地 DECERR（RRESP/BRESP=DECERR）；满足 AXI ordering；不拉低 READY、不 hang
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
  - LRS.FUNC.AXI_MPU.ORDERING.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
  - LLD.MOD.AXI_MPU.ERR_RESP
applicability:
  expr: "true"
proof_methods:
  - simulation
  - assertion
END_FEATURE_META -->

### Verification Intent

证明 DECERR 响应、ordering 保持、无 hang。

---

### FL.AXI_MPU.VIOLATION — Violation Logging 与 IRQ

<!-- FEATURE_META
id: FL.AXI_MPU.VIOLATION
name: Violation_Logging
description: VIOL_* 寄存器捕获（FIRST_ERROR_STICKY）、VIOL_COUNT（saturating）、IRQ（sticky+W1C）
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.VIOLATION.001
  - LRS.FUNC.AXI_MPU.VIOLATION.002
  - LRS.FUNC.AXI_MPU.IRQ.001
  - LRS.REG.AXI_MPU.VIOLATION.001
  - LRS.INTF.AXI_MPU.IRQ.001
  - LRS.DFX.AXI_MPU.OBSERVABILITY.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.VIOLATION
  - LLD.MOD.AXI_MPU.VIOLATION
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 violation 捕获、sticky、W1C、计数、IRQ 行为。

---

### FL.AXI_MPU.LOCK — Region/Global Lock

<!-- FEATURE_META
id: FL.AXI_MPU.LOCK
name: Configuration_Lock
description: REGION_LOCK（置位后配置冻结、仅 reset 清除）；GLOBAL_LOCK（0->1 allowed、1->0 仅 reset）；Violation 状态清除仍可访问
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.REGION_LOCK.001
  - LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001
  - LRS.REG.AXI_MPU.REGION.001
  - LRS.REG.AXI_MPU.GLOBAL.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.REG_FILE
  - LLD.MOD.AXI_MPU.REGS
applicability:
  expr: "true"
proof_methods:
  - simulation
  - assertion
END_FEATURE_META -->

### Verification Intent

证明 lock 语义、锁后改写拒绝、reset 解锁。

---

### FL.AXI_MPU.RESET — Reset 行为

<!-- FEATURE_META
id: FL.AXI_MPU.RESET
name: Reset_Behavior
description: Reset 后所有 Region disabled、Default Deny、locks/violation/IRQ 清除；异步复位
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.RESET.001
  - LRS.RESET.AXI_MPU.CLOCK.001
  - LRS.RESET.AXI_MPU.RESET.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.TOP
  - LLD.MOD.AXI_MPU.TOP
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 reset 后默认状态正确、traffic 中 reset 可恢复。

---

### FL.AXI_MPU.OUTSTANDING — 多 Outstanding 与 Ordering

<!-- FEATURE_META
id: FL.AXI_MPU.OUTSTANDING
name: Multiple_Outstanding
description: 多 outstanding read/write 支持；permission check 不降级；ordering 保持
priority: must
req_ref:
  - LRS.FUNC.AXI_MPU.OUTSTANDING.001
  - LRS.PERF.AXI_MPU.THROUGHPUT.001
  - LRS.PERF.AXI_MPU.OUTSTANDING.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
  - LLD.MOD.AXI_MPU.READ
  - LLD.MOD.AXI_MPU.WRITE
applicability:
  expr: "true"
proof_methods:
  - simulation
  - performance
END_FEATURE_META -->

### Verification Intent

证明多 outstanding 不降级、ordering 保持、吞吐达标。

---

### FL.AXI_MPU.CONFIG — 配置接口与配置安全

<!-- FEATURE_META
id: FL.AXI_MPU.CONFIG
name: Configuration
description: APB4 配置接口正确性（reset/RW/RO/W1C/illegal addr）；配置安全（Region/Global Lock、reset unlock）
priority: must
req_ref:
  - LRS.INTF.AXI_MPU.APB_CFG.001
  - LRS.REG.AXI_MPU.IRQ.001
  - LRS.REG.AXI_MPU.MASTER_ATTR.001
  - LRS.SEC.AXI_MPU.CONFIG_SEC.001
  - LRS.CONS.AXI_MPU.CONFIG_BUS.001
design_ref:
  - HLD.MOD.L1.AXI_MPU.REG_FILE
  - LLD.MOD.AXI_MPU.REGS
applicability:
  expr: "true"
proof_methods:
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 APB4 访问行为、寄存器属性、illegal address、配置安全。

---

### FL.AXI_MPU.GEN_PARAM — Generator 参数与结构裁剪

<!-- FEATURE_META
id: FL.AXI_MPU.GEN_PARAM
name: Generator_Parameters
description: Generator 参数（ADDR/DATA/ID_WIDTH、MASTER_NUM、REGION_NUM、OUTSTANDING、HAS_*、PIPELINE、WRAP_SUPPORT）结构裁剪与配置契约
priority: must
req_ref:
  - LRS.CFG.AXI_MPU.ADDR_WIDTH.001
  - LRS.CFG.AXI_MPU.MASTER_NUM.001
  - LRS.CFG.AXI_MPU.REGION_NUM.001
  - LRS.CFG.AXI_MPU.OUTSTANDING.001
  - LRS.CFG.AXI_MPU.FEATURE.001
  - LRS.GEN.AXI_MPU.INPUT.001
  - LRS.GEN.AXI_MPU.OUTPUT.001
  - LRS.GEN.AXI_MPU.DETERMINISM.001
  - LRS.CONS.AXI_MPU.DEPLOY.001
design_ref:
  - HLD.GEN.AXI_MPU.GENERATOR
  - LLD.MOD.AXI_MPU.TOP
applicability:
  expr: "true"
proof_methods:
  - static
  - equivalence
  - simulation
END_FEATURE_META -->

### Verification Intent

证明 Generator 参数契约、结构裁剪、确定性输出。
