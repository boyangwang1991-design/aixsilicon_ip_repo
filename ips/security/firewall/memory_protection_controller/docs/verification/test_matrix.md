# AXI Memory Protection Unit — Test Matrix

> 本文档是验证方案的一部分。每个 `TESTCASE_META` 通过 `feature_ref` 恰好引用一个
> `FL.*` Feature（extractor 强制一对一）；`implementation` 是
> `verification/tc/*.sv` 路径，class 名必须等于文件 stem。

---

## 5. Testcase Definitions

### TC.AXI_MPU.SMOKE.001 — Smoke: reset + APB + 基本读写

<!-- TESTCASE_META
id: TC.AXI_MPU.SMOKE.001
name: smoke_basic
type: directed
description: Reset 后通过 APB 配置一个 Region 并完成一条合法读与一条合法写；验证 DUT 可编译、reset、基本访问与基本事务响应
priority: must
tier: smoke
implementation: verification/tc/tc_smoke_basic.sv
feature_ref:
  - FL.AXI_MPU.READ_PATH
design_ref:
  - LLD.MOD.AXI_MPU.TOP
preconditions:
  - DUT 处于 reset 释放状态
  - 通过 APB 配置 REGION0 覆盖测试地址，允许当前 Master
stimulus:
  - APB 写 GLOBAL_CTRL/REGION0_* 配置
  - AXI 发一条合法 read burst（len=0）
  - AXI 发一条合法 write burst（len=0）
expected_result:
  - read 返回 OKAY 且数据正确
  - write 返回 BOKAY 且下游收到
timeout_policy: 1000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.DEFAULT_DENY.001 — 未匹配访问拒绝

<!-- TESTCASE_META
id: TC.AXI_MPU.DEFAULT_DENY.001
name: default_deny
type: negative
description: 未配置任何 Region 或访问地址未命中任何 Region 时，read/write 均返回 DECERR
priority: must
tier: regression
implementation: verification/tc/tc_default_deny.sv
feature_ref:
  - FL.AXI_MPU.DEFAULT_DENY
design_ref:
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - reset 后未配置 Region（或仅配置不覆盖测试地址的 Region）
stimulus:
  - AXI 发 read 到未匹配地址
  - AXI 发 write 到未匹配地址
expected_result:
  - RRESP=DECERR、BRESP=DECERR
  - M_AXI 上无对应事务
  - VIOL_STATUS.valid 置位
timeout_policy: 1000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.REGION.001 — Region 边界与优先级

<!-- TESTCASE_META
id: TC.AXI_MPU.REGION.001
name: region_boundary
type: boundary
description: 验证 REGION_BASE/LIMIT 边界（等于 BASE、等于 LIMIT、BASE±1、LIMIT±1）、Region overlap 与 lowest-index-wins 优先级、非法 BASE>LIMIT 视为 disabled
priority: must
tier: regression
implementation: verification/tc/tc_region_boundary.sv
feature_ref:
  - FL.AXI_MPU.REGION
design_ref:
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - 通过 APB 配置多个 overlap Region 与边界 Region
stimulus:
  - 对 BASE、LIMIT、BASE-1、LIMIT+1 地址发 read/write
  - 配置 Region0/Region1 overlap 并访问
  - 配置非法 BASE>LIMIT 并访问
expected_result:
  - 边界地址按 BASE<=addr<=LIMIT 规则判定
  - overlap 时按最低索引 Region 权限判定
  - 非法 Region 视为 disabled（访问走其他 Region 或 deny）
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.MASTER.001 — Master 权限与非法 ID

<!-- TESTCASE_META
id: TC.AXI_MPU.MASTER.001
name: master_permission
type: negative
description: MASTER_MASK 判定 allowed/denied Master；非法 Master ID（>=MASTER_NUM）拒绝
priority: must
tier: regression
implementation: verification/tc/tc_master_permission.sv
feature_ref:
  - FL.AXI_MPU.MASTER
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
preconditions:
  - 配置 Region 仅允许 Master0/2；Master1 访问同地址
stimulus:
  - Master0/2 访问（应允许）
  - Master1 访问（应拒绝）
  - 非法 master_id（越界）访问（应拒绝）
expected_result:
  - Master0/2 事务正常完成
  - Master1 与非法 ID 事务返回 DECERR
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.SECURITY.001 — Security 权限与 Master Attr

<!-- TESTCASE_META
id: TC.AXI_MPU.SECURITY.001
name: security_permission
type: negative
description: Secure/Non-secure Region 权限；Master Security Attribution 拒绝 forged Secure；Master 无 Secure capability 时 Secure 访问拒绝
priority: must
tier: regression
implementation: verification/tc/tc_security_permission.sv
feature_ref:
  - FL.AXI_MPU.MASTER_SEC
design_ref:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - Region 仅允许 Secure；Master Attr 配置 Master 无 SECURE_CAPABLE
stimulus:
  - Non-secure 访问 secure-only Region（拒绝）
  - 无 capability Master 发 Secure 访问（forged，拒绝）
  - 有 capability Master 发 Secure 访问（允许）
expected_result:
  - forged/无 capability Secure 访问返回 DECERR 且 reason=MASTER_SECURITY_DENY
  - 合法 Secure 访问正常完成
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.PRIVILEGE.001 — Privilege 权限

<!-- TESTCASE_META
id: TC.AXI_MPU.PRIVILEGE.001
name: privilege_permission
type: directed
description: PRIVILEGED_ALLOW/UNPRIVILEGED_ALLOW 判定
priority: must
tier: regression
implementation: verification/tc/tc_privilege_permission.sv
feature_ref:
  - FL.AXI_MPU.PERM_DIM
design_ref:
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - Region 仅允许 Privileged
stimulus:
  - Privileged 访问（允许）
  - Unprivileged 访问（拒绝）
expected_result:
  - Unprivileged 访问返回 DECERR
  - Privileged 访问正常完成
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.OP.001 — R/W/X 权限

<!-- TESTCASE_META
id: TC.AXI_MPU.OP.001
name: op_permission
type: directed
description: READ_ALLOW/WRITE_ALLOW/EXECUTE_ALLOW 判定；instruction access 需 READ_ALLOW && EXECUTE_ALLOW
priority: must
tier: regression
implementation: verification/tc/tc_op_permission.sv
feature_ref:
  - FL.AXI_MPU.PERM_DIM
design_ref:
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - Region 配置 READ=1, WRITE=0, EXEC=0
stimulus:
  - Read 访问（允许）
  - Write 访问（拒绝）
  - Instruction (PROT[2]=1) 访问（拒绝，NX）
expected_result:
  - Write/Instruction 返回 DECERR 且 reason=WRITE_DENY/EXECUTE_DENY
  - Read 正常完成
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.BURST.001 — Burst 边界保护

<!-- TESTCASE_META
id: TC.AXI_MPU.BURST.001
name: burst_boundary
type: boundary
description: INCR/FIXED/WRAP burst 完整地址范围计算；跨 Region 边界整事务拒绝
priority: must
tier: regression
implementation: verification/tc/tc_burst_boundary.sv
feature_ref:
  - FL.AXI_MPU.BURST
design_ref:
  - LLD.MOD.AXI_MPU.PERM
preconditions:
  - Region 覆盖固定地址段
stimulus:
  - burst 完全在 Region 内（INCR/FIXED/WRAP）
  - burst 跨 LIMIT（INCR 上跨）
  - burst 跨 BASE（INCR 下跨）
  - WRAP burst 跨边界
expected_result:
  - 完全在内：正常完成
  - 跨边界：整事务 DENY（DECERR），M_AXI 无部分事务
timeout_policy: 3000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.ERR_RESP.001 — 本地 DECERR 响应

<!-- TESTCASE_META
id: TC.AXI_MPU.ERR_RESP.001
name: local_decerr
type: error_injection
description: 非法 read/write 本地 DECERR；RID/RVALID/RRESP/RLAST 完整；W beat 被 consume；无 hang、无部分写入
priority: must
tier: regression
implementation: verification/tc/tc_local_decerr.sv
feature_ref:
  - FL.AXI_MPU.ERR_RESP
design_ref:
  - LLD.MOD.AXI_MPU.ERR_RESP
preconditions:
  - 配置 Region 拒绝某地址段
stimulus:
  - 非法 read burst（len=3）→ 期望 4 个 DECERR beat + RLAST
  - 非法 write burst（len=3）→ 期望 W 被 consume、1 个 B DECERR
expected_result:
  - read: RRESP=DECERR 全部 beat、RDATA=0、RLAST 正确
  - write: 无 M_AXI 写、B 返回 DECERR
  - 后续合法事务不受影响
timeout_policy: 3000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.VIOLATION.001 — Violation 捕获与 IRQ

<!-- TESTCASE_META
id: TC.AXI_MPU.VIOLATION.001
name: violation_capture
type: directed
description: FIRST_ERROR_STICKY 捕获、VIOL_COUNT 计数（saturating）、IRQ sticky+W1C
priority: must
tier: regression
implementation: verification/tc/tc_violation_capture.sv
feature_ref:
  - FL.AXI_MPU.VIOLATION
design_ref:
  - LLD.MOD.AXI_MPU.VIOLATION
preconditions:
  - 使能 IRQ_ENABLE
stimulus:
  - 连续触发多个 violation
  - 读 VIOL_STATUS/VIOL_ADDR/VIOL_INFO0/VIOL_COUNT
  - W1C 清除 IRQ/VIOL_STATUS
expected_result:
  - 首个 violation 信息 sticky 保持，后续不覆盖
  - VIOL_COUNT 累加并饱和到 MAX
  - IRQ 置位，W1C 清除后 IRQ 释放
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.LOCK.001 — Region/Global Lock

<!-- TESTCASE_META
id: TC.AXI_MPU.LOCK.001
name: config_lock
type: negative
description: REGION_LOCK 置位后 BASE/LIMIT/ATTR/MASTER_MASK 冻结；GLOBAL_LOCK 置位后全配置冻结、1->0 仅 reset
priority: must
tier: regression
implementation: verification/tc/tc_config_lock.sv
feature_ref:
  - FL.AXI_MPU.LOCK
design_ref:
  - LLD.MOD.AXI_MPU.REGS
preconditions:
  - 配置 Region0 并置 REGION_CONTROL.lock
  - 置 GLOBAL_LOCK.lock
stimulus:
  - 改写 locked Region 的 BASE/LIMIT/PERMISSION（应无效）
  - 尝试写 GLOBAL_LOCK=0（应无效）
  - reset 后验证 lock 清除
expected_result:
  - lock 后配置保持稳定；GLOBAL_LOCK 不能 1->0；reset 后全部清除
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.RESET.001 — Reset 行为

<!-- TESTCASE_META
id: TC.AXI_MPU.RESET.001
name: reset_behavior
type: reset
description: Reset 后所有 Region disabled、Default Deny、lock/violation/IRQ 清除；traffic 中 reset 恢复
priority: must
tier: regression
implementation: verification/tc/tc_reset_behavior.sv
feature_ref:
  - FL.AXI_MPU.RESET
design_ref:
  - LLD.MOD.AXI_MPU.TOP
preconditions:
  - 配置 Region 并产生 violation 后执行 reset
stimulus:
  - reset（idle 与 traffic 中）
  - reset 后读 GLOBAL_STATUS/VIOL_STATUS/IRQ_STATUS
  - reset 后发未匹配访问
expected_result:
  - reset 后 region_any_enabled=0、lock=0、violation/IRQ 清除
  - 未匹配访问被 deny
timeout_policy: 2000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.OUTSTANDING.001 — 多 Outstanding 与反压

<!-- TESTCASE_META
id: TC.AXI_MPU.OUTSTANDING.001
name: outstanding
type: stress
description: 多 ID 多 outstanding read/write、backpressure、AW/W 解耦；ordering 保持
priority: must
tier: regression
implementation: verification/tc/tc_outstanding.sv
feature_ref:
  - FL.AXI_MPU.OUTSTANDING
design_ref:
  - LLD.MOD.AXI_MPU.READ
  - LLD.MOD.AXI_MPU.WRITE
preconditions:
  - 配置多个 Region 覆盖测试地址
stimulus:
  - 多 ID（4 个）混合 read/write outstanding（各 8 深度）
  - 下游随机 backpressure（M_AXI READY 随机拉低）
  - AW/W 通道解耦注入
expected_result:
  - 所有合法事务按 AXI ordering 完成，无数据错误
  - 非法事务 DECERR 且不阻塞合法事务
  - 无 deadlock
timeout_policy: 10000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

### TC.AXI_MPU.RANDOM.001 — 随机混合流量

<!-- TESTCASE_META
id: TC.AXI_MPU.RANDOM.001
name: random_traffic
type: random
description: 随机混合流量（合法/非法、read/write、burst、多 ID、随机 backpressure）压力验证
priority: should
tier: extended
implementation: verification/tc/tc_random_traffic.sv
feature_ref:
  - FL.AXI_MPU.OUTSTANDING
design_ref:
  - LLD.MOD.AXI_MPU.READ
  - LLD.MOD.AXI_MPU.WRITE
preconditions:
  - 配置多个 Region（含允许/拒绝组合）与 Master Attr
stimulus:
  - 随机地址（命中/未命中 Region）、随机 burst 类型/长度
  - 随机 PROT（secure/privileged/instruction）组合
  - 随机 ID、随机 backpressure
expected_result:
  - 所有事务按权限模型判定正确（RM 对比）
  - 无 hang、无断言违例、无数据破坏
timeout_policy: 50000 cycles
config_ref:
  - CFGSET.AXI_MPU.DEFAULT
applicability:
  expr: "true"
END_TESTCASE_META -->

---

# 6. Configuration Sets

### CFGSET.AXI_MPU.DEFAULT

<!-- CONFIG_SET_META
id: CFGSET.AXI_MPU.DEFAULT
strategy: default
parameters:
  ADDR_WIDTH: 48
  DATA_WIDTH: 128
  ID_WIDTH: 8
  MASTER_NUM: 8
  MASTER_ID_WIDTH: 4
  REGION_NUM: 16
  READ_OUTSTANDING: 8
  WRITE_OUTSTANDING: 8
  HAS_EXECUTE: true
  HAS_MASTER_ATTR: true
  HAS_IRQ: true
  HAS_VIOLATION_LOG: true
  PIPELINE: 0
  WRAP_SUPPORT: true
purpose: 默认配置（CFG_MAIN）：验证主功能路径与完整特性集
END_CONFIG_SET_META -->

---

### CFGSET.AXI_MPU.MINIMAL

<!-- CONFIG_SET_META
id: CFGSET.AXI_MPU.MINIMAL
strategy: boundary
parameters:
  ADDR_WIDTH: 32
  DATA_WIDTH: 32
  ID_WIDTH: 4
  MASTER_NUM: 2
  MASTER_ID_WIDTH: 1
  REGION_NUM: 4
  READ_OUTSTANDING: 2
  WRITE_OUTSTANDING: 2
  HAS_EXECUTE: false
  HAS_MASTER_ATTR: true
  HAS_IRQ: false
  HAS_VIOLATION_LOG: false
  PIPELINE: 0
  WRAP_SUPPORT: false
purpose: 最小裁剪配置（CFG_MINIMAL）：验证功能裁剪下的最小结构
END_CONFIG_SET_META -->

---

### CCOV.AXI_MPU.GEN_PARAMS

<!-- CONFIG_COVERAGE_META
id: CCOV.AXI_MPU.GEN_PARAMS
dimensions:
  - REGION_NUM
  - MASTER_NUM
  - DATA_WIDTH
  - HAS_IRQ
  - HAS_VIOLATION_LOG
strategy:
  default: true
  boundary: true
  risk_based: true
feature_ref:
  - FL.AXI_MPU.GEN_PARAM
END_CONFIG_COVERAGE_META -->