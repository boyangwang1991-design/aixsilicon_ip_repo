# HLD 功能安全架构设计 - UART

## 11. 功能安全架构设计

### 11.1 安全目标

| 安全目标 | 说明 | LRS 引用 |
|---|---|---|
| 总线完整性 | 检测 TL-UL 总线完整性错误并上报 fatal_fault alert | SAFE.01.001 |

### 11.2 故障模型

| 故障 | 模型 | 影响 |
|---|---|---|
| 总线完整性故障 | TL-UL 命令/数据完整性错误、reg_we one-hot 违规 | 上报 fatal_fault |

### 11.3 安全机制

| 机制 | 实现 | 说明 |
|---|---|---|
| BUS.INTEGRITY | `uart_reg_top` 内建完整性检测 + `ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT` | 完整性错误 → alert |
| Alert 发送 | `prim_alert_sender`（IsFatal=1，AlertAsyncOn 可配） | 可靠上报 |
| Alert 测试 | `ALERT_TEST` 寄存器软件注入 | 可验证 alert 通路 |

### 11.4 故障响应

- 检测到总线完整性错误 → `fatal_fault` alert 置位（异步路径可选）。
- 无安全状态降级机制（fatal alert 由 SoC Alert Handler 处理）。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
