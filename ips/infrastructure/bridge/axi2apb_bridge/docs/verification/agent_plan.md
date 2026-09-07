# X2P Agent 规划 / Agent Plan

> 本文档是 [verification_plan.md](verification_plan.md) 第 4 章的详细展开。

---

## 1. Agent 结构

| Agent | 接口 | 模式 | 组件 | 说明 |
|---|---|---|---|---|
| axi_agent | AXI4/AXI4-Lite Slave 接口 | passive + active | driver/sequencer/monitor | 驱动 AXI Master 侧事务，监控 AXI 侧响应 |
| apb_agent | APB3/APB4 Master 接口 | passive | monitor | 监控 APB 侧事务与响应 |
| apb_slave_bfm | APB Slave 背板 | passive/active | driver | 响应 APB 传输（含 PREADY 控制、PSLVERR 注入） |

> **说明**：VIP 仓 axi4/apb 均为 developing/M0，不支撑 G4（见
> `docs/reuse_plan.md`），验证环境 self-contained 自建 Agent。

## 2. 组件职责

- **axi_driver**：按 AXI 协议驱动 AW/W/AR 通道，支持 burst/narrow/背压。
- **axi_monitor**：采样 AXI Slave 接口，识别事务/响应，转送 scoreboard。
- **apb_monitor**：采样 APB Master 接口，识别 transfer 与响应。
- **apb_slave_driver**：模拟 APB Slave（PREADY 随机/固定、PSLVERR 注入、Wait 注入）。
- **sequencer**：为序列提供事务队列。

## 3. 连接关系

```mermaid
flowchart LR
    SEQ[Sequences] --> AXI_DRV[axi_driver]
    AXI_DRV --> DUT[DUT x2p]
    DUT --> APB_SLV[apb_slave_bfm]
    AXI_MON[axi_monitor] --> SB[scoreboard]
    APB_MON[apb_monitor] --> SB