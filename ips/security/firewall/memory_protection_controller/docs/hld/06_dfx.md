# AXI Memory Protection Unit — HLD DFX 与约束

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. DFX 架构

Violation 状态经 APB4 寄存器可观测（`VIOL_STATUS`/`VIOL_ADDR`/`VIOL_INFO*`/
`VIOL_COUNT`），IRQ 提供事件通知。详见 LRS DFX 需求与 Register Architecture。

---

## 2. 架构约束

### 2.1 单时钟域约束

#### HLD.CONSTRAINT.AXI_MPU.SINGLE_CLK 单时钟域约束

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.AXI_MPU.SINGLE_CLK
constraint: V1.0 必须为单时钟域设计，AXI datapath 与 APB4 同域，不引入异步 CDC
status: active
req_ref:
  - LRS.RESET.AXI_MPU.CLOCK.001
END_HLD_CONSTRAINT_META -->

### 2.2 部署约束

#### HLD.CONSTRAINT.AXI_MPU.DEPLOY 部署位置约束

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.AXI_MPU.DEPLOY
constraint: 推荐部署于受保护 Slave 侧，也允许 Master 侧；V1.0 不依赖特定部署位置
status: active
req_ref:
  - LRS.CONS.AXI_MPU.DEPLOY.001
END_HLD_CONSTRAINT_META -->

### 2.3 Profile 约束

#### HLD.CONSTRAINT.AXI_MPU.PROFILE FULL AXI4 Profile 约束

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.AXI_MPU.PROFILE
constraint: FULL AXI4 Profile 默认支持 WRAP burst；裁剪 WRAP 时 INCR/FIXED 必须支持
status: active
req_ref:
  - LRS.CONS.AXI_MPU.PROFILE.001
  - LRS.CFG.AXI_MPU.BURST.001
END_HLD_CONSTRAINT_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
