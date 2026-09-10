# AXI Memory Protection Unit — LLD 附录（验证关注点 + G2 门禁）

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 验证关注点

| ID | 关注点 | 来源 |
|----|--------|------|
| VP-001 | 非法 AR 不得出现在 M_AXI_AR | LRS.FUNC.AXI_MPU.READ.002 |
| VP-002 | 非法 AW/W 不得出现在 M_AXI / 不修改下游状态 | LRS.FUNC.AXI_MPU.WRITE.002 |
| VP-003 | 非法 transaction 最终收到本地 DECERR | LRS.FUNC.AXI_MPU.ERR_RESP.001 |
| VP-004 | Locked region 配置保持稳定至 reset | LRS.FUNC.AXI_MPU.REGION_LOCK.001 |
| VP-005 | GLOBAL_LOCK 不能 1→0 除 reset | LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001 |
| VP-006 | Default Deny 下无未匹配 access 被允许 | LRS.FUNC.AXI_MPU.DEFAULT_DENY.001 |
| VP-007 | Burst 跨边界整事务拒绝 | LRS.FUNC.AXI_MPU.BURST.002 |
| VP-008 | 多 outstanding 下 WQ 正确关联 AW/W | LRS.FUNC.AXI_MPU.WRITE_QUEUE.001 |
| VP-009 | FIRST_ERROR_STICKY 捕获与 W1C | LRS.FUNC.AXI_MPU.VIOLATION.002 |
| VP-010 | forged Secure AxPROT 拒绝 | LRS.SEC.AXI_MPU.ATTACK.001 |

## 2. RTL TODO

| 优先级 | RTL 路径 | 内容 | 引用 |
|--------|----------|------|------|
| P0 | `rtl/axi_mpu.sv` | 顶层参数化 + 实例化 | LLD.MOD.AXI_MPU.TOP |
| P0 | `rtl/axi_mpu_permission.sv` | 权限引擎（region match/priority/checker） | LLD.MOD.AXI_MPU.PERM |
| P0 | `rtl/axi_mpu_read.sv` | Read path | LLD.MOD.AXI_MPU.READ |
| P0 | `rtl/axi_mpu_write.sv` | Write path + WQ | LLD.MOD.AXI_MPU.WRITE |
| P0 | `rtl/axi_mpu_violation.sv` | violation/IRQ | LLD.MOD.AXI_MPU.VIOLATION |
| P1 | `rtl/axi_mpu_error_resp.sv` | local DECERR | LLD.MOD.AXI_MPU.ERR_RESP |
| P1 | `rtl/axi_mpu_master_attr.sv` | Master attr | LLD.MOD.AXI_MPU.MASTER_ATTR |
| P0 | `regs/axi_mpu.rdl` | SystemRDL | 02-reg-model |

## 3. G2 Gate 状态

<!-- LLD_GATE_META
gate: G2
status: open
architecture_freeze: false
register_freeze: false
notes: LLD 编写完成，待 micro_design.yaml 抽取、SystemRDL 生成与 register_check 证据后置为 pass。
END_LLD_GATE_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
