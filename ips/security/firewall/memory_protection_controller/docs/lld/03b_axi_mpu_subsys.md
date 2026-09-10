# AXI Memory Protection Unit — LLD 子系统微架构（Violation / Error / Regs / Master Attr）

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. Violation Logger 微架构

#### LLD.MOD.AXI_MPU.VIOLATION Violation Logger 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.VIOLATION
name: axi_mpu_violation
hld_ref:
  - HLD.MOD.L1.AXI_MPU.VIOLATION
req_ref:
  - LRS.FUNC.AXI_MPU.VIOLATION.001
  - LRS.FUNC.AXI_MPU.VIOLATION.002
  - LRS.FUNC.AXI_MPU.VIOLATION.003
  - LRS.FUNC.AXI_MPU.IRQ.001
  - LRS.DFX.AXI_MPU.OBSERVABILITY.001
description: violation 捕获（FIRST_ERROR_STICKY）、计数器、IRQ 生成
rtl_intent:
  suggested_name: rtl/axi_mpu_violation.sv
applicability:
  expr: "has_violation_log == true"
END_LLD_MODULE_META -->

### 1.1 Violation 捕获逻辑

#### LLD.REG.AXI_MPU.VIOL_STATUS VIOL_STATUS 行为

<!-- LLD_REG_META
id: LLD.REG.AXI_MPU.VIOL_STATUS
register_ref: VIOL_STATUS
behavior: FIRST_ERROR_STICKY
sw_behavior: RO；VIOL_VALID 置位后 sticky；W1C 清除（写 1 清）
hw_behavior: 首次 violation 时置 VIOL_VALID 并锁存首错信息；后续 violation 不覆盖
update_timing: violation 发生拍
collision: hw_capture 优先于 sw_read
reset_semantics: reset 清除（VIOL_VALID=0）
req_ref:
  - LRS.FUNC.AXI_MPU.VIOLATION.002
END_LLD_REG_META -->

### 1.2 Violation Counter

#### LLD.REG.AXI_MPU.VIOL_COUNT VIOL_COUNT 行为

<!-- LLD_REG_META
id: LLD.REG.AXI_MPU.VIOL_COUNT
register_ref: VIOL_COUNT
behavior: saturating_counter
sw_behavior: RO；软件 W1C 清零
hw_behavior: 每次 violation count+1，饱和到最大值
update_timing: violation 发生拍
collision: hw 递增优先于 sw 清零
reset_semantics: reset 清零
req_ref:
  - LRS.FUNC.AXI_MPU.VIOLATION.003
END_LLD_REG_META -->

### 1.3 IRQ

#### LLD.IRQ.AXI_MPU.VIOLATION Violation IRQ

<!-- LLD_IRQ_META
id: LLD.IRQ.AXI_MPU.VIOLATION
module_ref: LLD.MOD.AXI_MPU.VIOLATION
source: violation_event
irq_model: status_sticky + enable + w1c_clear
trigger: IRQ_ENABLE.VIOL_EN & violation_event
clear: 软件写 IRQ_CLEAR（W1C）
priority: 单一中断源
req_ref:
  - LRS.FUNC.AXI_MPU.IRQ.001
  - LRS.INTF.AXI_MPU.IRQ.001
END_LLD_IRQ_META -->

---

## 2. Error Responder 微架构

#### LLD.MOD.AXI_MPU.ERR_RESP Error Responder 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.ERR_RESP
name: axi_mpu_error_resp
hld_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
req_ref:
  - LRS.FUNC.AXI_MPU.READ.002
  - LRS.FUNC.AXI_MPU.WRITE.002
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
description: 本地 R/B DECERR 响应生成
rtl_intent:
  suggested_name: rtl/axi_mpu_error_resp.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

### 2.1 Error 检测与响应

#### LLD.ERROR.AXI_MPU.DECERR Local DECERR

<!-- LLD_ERROR_META
id: LLD.ERROR.AXI_MPU.DECERR
module_ref: LLD.MOD.AXI_MPU.ERR_RESP
detection: permission_deny
response: |
  Read: 返回 (AWLEN+1) beat，每 beat RRESP=DECERR, RDATA=0, RLAST 正确；
  Write: consume W beats（WVALID && WREADY 直到 WLAST），返回 BRESP=DECERR。
escalation: violation 记录 + IRQ（可配）
req_ref:
  - LRS.FUNC.AXI_MPU.READ.002
  - LRS.FUNC.AXI_MPU.WRITE.002
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
END_LLD_ERROR_META -->

---

### 2.2 Local Response 数据通路

#### LLD.DATAPATH.AXI_MPU.LOCAL_RESP Local DECERR 响应生成

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.LOCAL_RESP
module_ref: LLD.MOD.AXI_MPU.ERR_RESP
hld_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
width: 1
direction: sequential
latency: (len+1) beats (read) / W consume 后 1 beat (write)
description: |
  Read deny: 本地返回 (AWLEN+1) beat，每 beat RRESP=DECERR、RDATA=0、RLAST 正确；
  Write deny: 消费 W beats（直至 WLAST），返回 BRESP=DECERR；
  不向 M_AXI 发送任何 deny 事务。
req_ref:
  - LRS.FUNC.AXI_MPU.READ.002
  - LRS.FUNC.AXI_MPU.WRITE.002
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
END_LLD_DATAPATH_META -->

---

## 3. Register File 微架构

#### LLD.MOD.AXI_MPU.REGS Register File 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.REGS
name: axi_mpu_regs
hld_ref:
  - HLD.MOD.L1.AXI_MPU.REG_FILE
req_ref:
  - LRS.INTF.AXI_MPU.APB_CFG.001
  - LRS.REG.AXI_MPU.GLOBAL.001
  - LRS.REG.AXI_MPU.IRQ.001
  - LRS.REG.AXI_MPU.VIOLATION.001
  - LRS.REG.AXI_MPU.MASTER_ATTR.001
  - LRS.REG.AXI_MPU.REGION.001
  - LRS.FUNC.AXI_MPU.REGION_LOCK.001
  - LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001
description: APB4 从接口、PeakRDL 生成 CSR + 特殊 HW 行为、Lock 保护
rtl_intent:
  suggested_name: rtl/generated/axi_mpu_csr.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

### 3.1 CSR 配置投影数据通路

#### LLD.DATAPATH.AXI_MPU.CSR_PROJ CSR 配置投影

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.CSR_PROJ
module_ref: LLD.MOD.AXI_MPU.REGS
hld_ref:
  - HLD.MOD.L1.AXI_MPU.REG_FILE
width: ADDR_WIDTH*2 + MASTER_NUM + 3 (per region)
direction: combinational
latency: 0
description: |
  CSR 寄存器值投影为权限引擎输入：REGION_ENABLE/BASE/LIMIT/MASTER_MASK/
  SECURE_ALLOW/NONSECURE_ALLOW/PRIV_ALLOW/UNPRIV_ALLOW/READ_ALLOW/
  WRITE_ALLOW/EXEC_ALLOW 与 MASTER_ATTR.SECURE_CAPABLE/NONSECURE_CAPABLE；
  Region/Global Lock 屏蔽相应写路径。
req_ref:
  - LRS.REG.AXI_MPU.REGION.001
  - LRS.REG.AXI_MPU.MASTER_ATTR.001
END_LLD_DATAPATH_META -->

### 3.2 Region Lock 行为

#### LLD.REG.AXI_MPU.REGION_LOCK REGION_CONTROL.LOCK 行为

<!-- LLD_REG_META
id: LLD.REG.AXI_MPU.REGION_LOCK
register_ref: REGION_CONTROL
field: LOCK
behavior: write_once_lock
sw_behavior: 写 0 无效果；写 1 锁定（BASE/LIMIT/ATTR/MASTER_MASK 写保护）
hw_behavior: lock 置位后对应 Region 写路径屏蔽
update_timing: 写拍
collision: sw 写 lock 生效
reset_semantics: reset 清除
req_ref:
  - LRS.FUNC.AXI_MPU.REGION_LOCK.001
END_LLD_REG_META -->

### 3.2 Global Lock 行为

#### LLD.REG.AXI_MPU.GLOBAL_LOCK GLOBAL_LOCK 行为

<!-- LLD_REG_META
id: LLD.REG.AXI_MPU.GLOBAL_LOCK
register_ref: GLOBAL_LOCK
behavior: write_once_lock
sw_behavior: 0->1 allowed；1->0 prohibited
hw_behavior: 置位后 Region/Master Attr/Global 保护策略写屏蔽；运行态（violation/IRQ clear）仍可访问
update_timing: 写拍
collision: sw 写 lock 生效
reset_semantics: reset 清除
req_ref:
  - LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001
END_LLD_REG_META -->

### 3.3 IRQ 寄存器行为

#### LLD.REG.AXI_MPU.IRQ_REGS IRQ_ENABLE/STATUS/CLEAR 行为

<!-- LLD_REG_META
id: LLD.REG.AXI_MPU.IRQ_REGS
register_ref: IRQ_ENABLE
field: VIOL_EN
behavior: rw
sw_behavior: RW 使能位
hw_behavior: 无
update_timing: 写拍
collision: sw
reset_semantics: reset 清除
irq_model: IRQ = IRQ_STATUS.VIOL_STICKY & IRQ_ENABLE.VIOL_EN；IRQ_CLEAR W1C
req_ref:
  - LRS.FUNC.AXI_MPU.IRQ.001
  - LRS.REG.AXI_MPU.IRQ.001
END_LLD_REG_META -->

### 3.4 寄存器架构 PPA

#### LLD.PPA.AXI_MPU.REGS 寄存器 PPA

<!-- LLD_PPA_META
id: LLD.PPA.AXI_MPU.REGS
decision: 由 PeakRDL 生成 CSR RTL，避免手写寄存器译码；APB 数据宽 32
cost: 生成 CSR 面积固定；Region 配置寄存器随 REGION_NUM 增长
req_ref:
  - LRS.REG.AXI_MPU.REGION.001
END_LLD_PPA_META -->

---

## 4. Master Attribute 微架构

#### LLD.MOD.AXI_MPU.MASTER_ATTR Master Attribute 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.MASTER_ATTR
name: axi_mpu_master_attr
hld_ref:
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
req_ref:
  - LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001
  - LRS.REG.AXI_MPU.MASTER_ATTR.001
description: 每 Master SECURE_CAPABLE/NONSECURE_CAPABLE 存储
rtl_intent:
  suggested_name: rtl/axi_mpu_master_attr.sv
applicability:
  expr: "has_master_attr == true"
END_LLD_MODULE_META -->

### 4.1 Master Security 检查

#### LLD.DATAPATH.AXI_MPU.MASTER_SEC master_security_valid

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.MASTER_SEC
module_ref: LLD.MOD.AXI_MPU.MASTER_ATTR
hld_ref:
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
width: 1
direction: combinational
latency: 0
description: |
  master_security_valid =
    (request.secure ? MASTER_ATTR[master_id].SECURE_CAPABLE : 1)
    && (!request.secure ? MASTER_ATTR[master_id].NONSECURE_CAPABLE : 1)；
  master_id >= MASTER_NUM 时 INVALID_CONTEXT。
req_ref:
  - LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001
END_LLD_DATAPATH_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
