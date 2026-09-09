# APB CDC Bridge — 低功耗需求（LP）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 低功耗需求 / Low Power Requirements

### 1.1 负载寄存器低翻转

#### LRS.LP.APB_CDC_BRIDGE.01.001 负载寄存器按需更新

<!-- LRS_META
id: LRS.LP.APB_CDC_BRIDGE.01.001
category: LP
feature: payload_power
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Payload register 仅在接受新 transaction 时更新；IDLE 时不得无意义 toggle。
2. 只同步必要 control，禁止 PADDR/PWDATA/PRDATA bit-by-bit 2FF。
3. 以一个 request control crossing 保护整个 request bundle，不以字段建独立 CDC handshake。

##### 验证关注点

1. IDLE 期间 payload 寄存器无翻转（功率/翻转率分析）。
2. 同步器数量最小化（RTL review）。

---

### 1.2 时钟门控兼容

#### LRS.LP.APB_CDC_BRIDGE.02.001 时钟门控兼容

<!-- LRS_META
id: LRS.LP.APB_CDC_BRIDGE.02.001
category: LP
feature: clock_gating
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 必须兼容 clock gating：若某一域处于 gating，pending transaction 状态必须保持；该域恢复 clock 后应继续完成 transaction。
2. IDLE 时 handshake toggle 不变化、request/response payload register 不更新、downstream APB outputs 尽量保持稳定、optional FIFO pointer 不变化。

##### 验证关注点

1. 时钟暂停/恢复场景下无事务丢失。
2. IDLE 时输出稳定。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
