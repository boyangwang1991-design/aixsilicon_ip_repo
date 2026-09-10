# AXI Memory Protection Unit — LLD 顶层与核心模块微架构

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 模块定义

#### LLD.MOD.AXI_MPU.TOP 顶层模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.TOP
name: axi_mpu
hld_ref:
  - HLD.MOD.L1.AXI_MPU.TOP
req_ref:
  - LRS.INTF.AXI_MPU.AXI_SLAVE.001
  - LRS.INTF.AXI_MPU.AXI_MASTER.001
  - LRS.INTF.AXI_MPU.APB_CFG.001
  - LRS.CFG.AXI_MPU.ADDR_WIDTH.001
  - LRS.CFG.AXI_MPU.MASTER_NUM.001
  - LRS.CFG.AXI_MPU.REGION_NUM.001
  - LRS.CFG.AXI_MPU.OUTSTANDING.001
  - LRS.CFG.AXI_MPU.FEATURE.001
  - LRS.CFG.AXI_MPU.PIPELINE.001
  - LRS.RESET.AXI_MPU.RESET.001
description: 顶层参数化模块，实例化 read/write/permission/violation/regs/master_attr
rtl_intent:
  suggested_name: rtl/axi_mpu.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

---

## 2. Read Path 微架构

#### LLD.MOD.AXI_MPU.READ Read Path 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.READ
name: axi_mpu_read
hld_ref:
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
req_ref:
  - LRS.FUNC.AXI_MPU.REQ_CONTEXT.001
  - LRS.FUNC.AXI_MPU.READ.001
  - LRS.FUNC.AXI_MPU.READ.002
  - LRS.FUNC.AXI_MPU.OUTSTANDING.001
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
description: AR 捕获、Request Context 构建、合法转发、非法本地 R DECERR、Read outstanding 跟踪
rtl_intent:
  suggested_name: rtl/axi_mpu_read.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

### 2.1 Read FSM

#### LLD.FSM.AXI_MPU.READ Read Path FSM

<!-- LLD_FSM_META
id: LLD.FSM.AXI_MPU.READ
module_ref: LLD.MOD.AXI_MPU.READ
states:
  - IDLE
  - CHECK
  - FWD_AR
  - WAIT_R
  - LOCAL_R
transitions: |
  IDLE --ARVALID && ARREADY--> CHECK
  CHECK --ALLOW--> FWD_AR
  CHECK --DENY--> LOCAL_R
  FWD_AR --M_ARREADY--> WAIT_R
  WAIT_R --RLAST && RVALID && RREADY--> IDLE
  LOCAL_R --(len+1) beats R, RLAST--> IDLE
reset_state: IDLE
encoding: onehot
illegal_state_handling: 全 0 复位；非法状态经全局复位恢复 IDLE
req_ref:
  - LRS.FUNC.AXI_MPU.READ.001
  - LRS.FUNC.AXI_MPU.READ.002
END_LLD_FSM_META -->

### 2.2 Read Request Context 数据通路

#### LLD.DATAPATH.AXI_MPU.REQ_CTX Request Context 构建

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.REQ_CTX
module_ref: LLD.MOD.AXI_MPU.READ
hld_ref:
  - HLD.IF.INT.AXI_MPU.REQ_CTX
width: ADDR_WIDTH + 16 + MASTER_ID_WIDTH
direction: combinational
latency: 0
description: |
  req.ctx.address = ARADDR; read_write = READ; axi_id = ARID;
  secure = ARPROT[1]; privileged = ARPROT[0]; instruction = ARPROT[2];
  master_id = 输入 sideband / 配置；
  burst_start/end 由 Burst Analyzer 计算（INCR/FIXED/WRAP）。
req_ref:
  - LRS.FUNC.AXI_MPU.REQ_CONTEXT.001
END_LLD_DATAPATH_META -->

---

## 3. Write Path 微架构

#### LLD.MOD.AXI_MPU.WRITE Write Path 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.WRITE
name: axi_mpu_write
hld_ref:
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
req_ref:
  - LRS.FUNC.AXI_MPU.REQ_CONTEXT.001
  - LRS.FUNC.AXI_MPU.WRITE.001
  - LRS.FUNC.AXI_MPU.WRITE.002
  - LRS.FUNC.AXI_MPU.WRITE_QUEUE.001
  - LRS.FUNC.AXI_MPU.OUTSTANDING.001
  - LRS.FUNC.AXI_MPU.ERR_RESP.001
description: AW/W 捕获、Request Context 构建、Write Decision Queue 维护、合法转发、非法 W consume + 本地 B DECERR
rtl_intent:
  suggested_name: rtl/axi_mpu_write.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

### 3.1 Write Decision Queue

#### LLD.BUFFER.AXI_MPU.WQ Write Decision Queue

<!-- LLD_BUFFER_META
id: LLD.BUFFER.AXI_MPU.WQ
module_ref: LLD.MOD.AXI_MPU.WRITE
type: circular_fifo
depth: WRITE_OUTSTANDING
entry_fields:
  - AWID
  - AWLEN
  - ALLOW/DENY
  - selected_region
  - deny_reason
  - master_id
  - security_state
flow_control: 满时 AWREADY=0（背压）
req_ref:
  - LRS.FUNC.AXI_MPU.WRITE_QUEUE.001
  - LRS.FUNC.AXI_MPU.OUTSTANDING.001
END_LLD_BUFFER_META -->

### 3.2 Write FSM

#### LLD.FSM.AXI_MPU.WRITE Write Path FSM

<!-- LLD_FSM_META
id: LLD.FSM.AXI_MPU.WRITE
module_ref: LLD.MOD.AXI_MPU.WRITE
states:
  - IDLE
  - AW_CHECK
  - WQ_WAIT
  - FWD_AW
  - FWD_W
  - CONSUME_W
  - LOCAL_B
transitions: |
  IDLE --AWVALID && AWREADY--> AW_CHECK
  AW_CHECK --ALLOW--> FWD_AW
  AW_CHECK --DENY--> CONSUME_W
  FWD_AW --M_AWREADY--> FWD_W
  FWD_W --WLAST && WVALID && WREADY--> WQ_WAIT
  WQ_WAIT --M_BVALID && BREADY--> IDLE
  CONSUME_W --WLAST && WVALID && WREADY--> LOCAL_B
  LOCAL_B --BVALID && BREADY--> IDLE
reset_state: IDLE
encoding: onehot
illegal_state_handling: 复位恢复 IDLE
req_ref:
  - LRS.FUNC.AXI_MPU.WRITE.001
  - LRS.FUNC.AXI_MPU.WRITE.002
END_LLD_FSM_META -->

### 3.3 Write Ordering

#### LLD.ORDER.AXI_MPU.WRITE Write Ordering 模型

<!-- LLD_ORDER_META
id: LLD.ORDER.AXI_MPU.WRITE
model: per_id_fifo
description: |
  同一 AWID 的 write 按发出顺序返回 B（WQ 顺序出队）；
  不同 ID 间保持 AXI 允许的 reorder 自由度。
req_ref:
  - LRS.FUNC.AXI_MPU.ORDERING.001
END_LLD_ORDER_META -->

---

## 4. Permission Engine 微架构

#### LLD.MOD.AXI_MPU.PERM Permission Engine 模块

<!-- LLD_MODULE_META
id: LLD.MOD.AXI_MPU.PERM
name: axi_mpu_permission
hld_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
req_ref:
  - LRS.FUNC.AXI_MPU.DEFAULT_DENY.001
  - LRS.FUNC.AXI_MPU.DEFAULT_DENY.002
  - LRS.FUNC.AXI_MPU.REGION.002
  - LRS.FUNC.AXI_MPU.REGION.003
  - LRS.FUNC.AXI_MPU.REGION.004
  - LRS.FUNC.AXI_MPU.BURST.001
  - LRS.FUNC.AXI_MPU.BURST.002
  - LRS.FUNC.AXI_MPU.PERM_MASTER.001
  - LRS.FUNC.AXI_MPU.PERM_SECURITY.001
  - LRS.FUNC.AXI_MPU.PERM_PRIVILEGE.001
  - LRS.FUNC.AXI_MPU.PERM_OP.001
  - LRS.FUNC.AXI_MPU.PERM_DECISION.001
  - LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001
  - LRS.PERF.AXI_MPU.THROUGHPUT.001
  - LRS.CFG.AXI_MPU.PIPELINE.001
description: Burst Analyzer + Region Matcher + Priority Select + Permission Checker
rtl_intent:
  suggested_name: rtl/axi_mpu_permission.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

### 4.1 Region Matcher 数据通路

#### LLD.DATAPATH.AXI_MPU.REGION_MATCH Region Matcher

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.REGION_MATCH
module_ref: LLD.MOD.AXI_MPU.PERM
hld_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
width: REGION_NUM
direction: combinational
latency: 0-1 (pipeline 可配置)
description: |
  match[i] = REGION_ENABLE[i] && burst_start >= REGION_BASE[i]
             && burst_end <= REGION_LIMIT[i]
  全部 Region 并行比较；BASE > LIMIT 时视为 disabled。
req_ref:
  - LRS.FUNC.AXI_MPU.REGION.003
  - LRS.FUNC.AXI_MPU.REGION.002
END_LLD_DATAPATH_META -->

### 4.2 Priority Select

#### LLD.DATAPATH.AXI_MPU.PRIORITY Priority Select

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.PRIORITY
module_ref: LLD.MOD.AXI_MPU.PERM
hld_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
width: clog2(REGION_NUM)+1
direction: combinational
latency: 0-1
description: |
  priority_encode(match) 选择最小索引命中 Region；
  no_match 时 selected_valid=0（NO_REGION）。
req_ref:
  - LRS.FUNC.AXI_MPU.REGION.004
  - LRS.FUNC.AXI_MPU.PERM_DECISION.001
END_LLD_DATAPATH_META -->

### 4.3 Permission Checker

#### LLD.DATAPATH.AXI_MPU.PERM_CHECK Permission Checker

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.AXI_MPU.PERM_CHECK
module_ref: LLD.MOD.AXI_MPU.PERM
hld_ref:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
width: 1
direction: combinational
latency: 0-1
description: |
  allow = master_allowed && master_security_valid && security_allowed
          && privilege_allowed && operation_allowed；
  deny_reason 按首因编码（NO_REGION/MASTER_DENY/MASTER_SECURITY_DENY/
  SECURITY_DENY/PRIVILEGE_DENY/READ_DENY/WRITE_DENY/EXECUTE_DENY/
  BURST_BOUNDARY_DENY/INVALID_CONTEXT）。
req_ref:
  - LRS.FUNC.AXI_MPU.PERM_DECISION.001
  - LRS.FUNC.AXI_MPU.PERM_DECISION.002
END_LLD_DATAPATH_META -->

### 4.4 Pipeline

#### LLD.PIPELINE.AXI_MPU.PERM Permission Pipeline

<!-- LLD_PIPELINE_META
id: LLD.PIPELINE.AXI_MPU.PERM
module_ref: LLD.MOD.AXI_MPU.PERM
stages: 0-1
description: |
  PIPELINE=0: 组合判定；PIPELINE=1: Burst Analyzer+Region Match 后插 1 级寄存器。
  吞吐保持 1 request/cycle。
req_ref:
  - LRS.CFG.AXI_MPU.PIPELINE.001
  - LRS.PERF.AXI_MPU.THROUGHPUT.001
  - LRS.PERF.AXI_MPU.THROUGHPUT.002
END_LLD_PIPELINE_META -->

### 4.5 PPA 决策

#### LLD.PPA.AXI_MPU.PERM_STRUCT Permission Engine 结构 PPA

<!-- LLD_PPA_META
id: LLD.PPA.AXI_MPU.PERM_STRUCT
decision: |
  REGION_NUM<=4 Flat comparator；<=16 Parallel + priority tree；
  >16 Hierarchical match + optional pipeline。
  共享 vs 独立 Read/Write 权限引擎由 PPA profile 决定（AREA 共享 / PERFORMANCE 独立）。
cost: 并行比较器面积随 REGION_NUM 线性增长；pipeline 增 1 拍延迟换时序。
req_ref:
  - LRS.GEN.AXI_MPU.STRUCTURE.001
  - LRS.PERF.AXI_MPU.THROUGHPUT.001
END_LLD_PPA_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
