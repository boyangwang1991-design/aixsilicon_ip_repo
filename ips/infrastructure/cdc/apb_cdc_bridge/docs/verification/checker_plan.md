# APB CDC Bridge 比对器策略

本文档是 `verification_plan.md` 第 9 章的详细展开。

## 1. 比对器目标

验证 DUT（Bridge）的事务级行为与 UVM RM 一致，且满足协议不变量。

## 2. Scoreboard

- 上游完成事务（地址/数据/方向/错误）与 RM 预期比对。
- 下游观察到的每个事务与上游发起一一对应（no loss / no duplicate）。
- RM 模型化跨域往返延迟（SYNC_STAGES 相关）。

## 3. 断言（Assertions）

引用以下断言 ID（见 06 文档与 RTL SVA）：

| 断言 ID | 属性 |
|---------|------|
| ASR.APB_CDC_BRIDGE.01 | 一个上游 transfer → 至多一个下游 transfer |
| ASR.APB_CDC_BRIDGE.02 | 一个下游 completion → 至多一个上游 completion |
| ASR.APB_CDC_BRIDGE.03 | request payload CDC 期间稳定 |
| ASR.APB_CDC_BRIDGE.04 | response payload CDC 期间稳定 |
| ASR.APB_CDC_BRIDGE.05 | 无下游 APB 协议违例（SETUP 先于 ACCESS） |
| ASR.APB_CDC_BRIDGE.06 | 目的域复位时无事务 |
| ASR.APB_CDC_BRIDGE.07 | 无 spurious PREADY |
| ASR.APB_CDC_BRIDGE.08 | 无 spurious PSLVERR |

## 4. 协议检查

- 上游：PSEL/PENABLE 时序、PREADY 不早于跨桥完成。
- 下游：SETUP→ACCESS、wait-state 输出稳定、COMPLETE 捕获。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
