# 功能安全需求 - UART (uart)
# Safety Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 安全定义参考 OpenTitan UART `data/uart.hjson` 的 countermeasures 与 alert_list。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **SAFE**：功能安全需求（总线完整性检测、fatal_fault alert、alert 测试等）

---

## 1. 功能安全需求 / Safety Requirements

### 1.1 总线完整性 / Bus Integrity

#### LRS.SAFE.UART.01.001 总线完整性检测（BUS.INTEGRITY）

<!-- LRS_META
id: LRS.SAFE.UART.01.001
category: SAFE
ip: UART
feature: bus_integrity
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应实现 TL-UL 端到端总线完整性方案（countermeasure `BUS.INTEGRITY`）。
2. 检测到总线完整性错误（如寄存器写使能 one-hot 违规）时，应触发 `fatal_fault` alert。
3. `uart.sv` 中 `ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT` 应确保 reg_we one-hot 错误触发 alert。

##### 验证关注点

1. 注入总线完整性错误后 fatal_fault alert 置位。
2. 正常访问不产生误报。

---

### 1.2 Alert 机制 / Alert Mechanism

#### LRS.SAFE.UART.01.002 Alert 发送与测试

<!-- LRS_META
id: LRS.SAFE.UART.01.002
category: SAFE
ip: UART
feature: alert_mechanism
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `prim_alert_sender` 发送 `fatal_fault` alert（`AlertAsyncOn=1` 支持异步、`IsFatal=1`）。
2. 应支持 `ALERT_TEST` 寄存器软件注入 alert 测试。
3. 复位后 alert_tx_o 应为已知状态。

##### 验证关注点

1. ALERT_TEST 写入触发 alert_tx_o。
2. 复位后 alert 输出已知。
3. 异步 alert 路径（AlertAsyncOn）行为正确。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
