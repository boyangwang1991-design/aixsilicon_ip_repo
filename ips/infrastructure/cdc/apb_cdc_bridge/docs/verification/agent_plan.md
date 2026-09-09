# APB CDC Bridge Agent 规划

本文档是 `verification_plan.md` 第 4 章的详细展开。

## 1. Agent 列表

| Agent | 协议 | 模式 | 用途 |
|-------|------|------|------|
| `apb_source_agent` | APB3/APB4 | Active Master | 驱动上游事务（读写/等待/错误） |
| `apb_dest_agent` | APB3/APB4 | Passive Slave | 响应下游事务（wait/PSLVERR） |
| `clk_gen` | — | 配置 | 双时钟生成（频率比/相位/暂停） |

## 2. APB Agent 组件

- Driver：驱动 PSEL/PENABLE/PADDR/PWRITE/PWDATA/PSTRB/PPROT，采样 PREADY/PRDATA/PSLVERR。
- Monitor：采样事务（上游 slave 侧 / 下游 master 侧）。
- Sequencer：事务 sequence 生成。
- Config：APB_PROFILE（APB3/APB4）、wait 策略。

## 3. 时钟生成

- `s_pclk`/`m_pclk` 各自独立频率（参数化比值），支持相位偏移、暂停/恢复。
- 支持 near-frequency、irrational ratio。

## 4. 目录位置

```text
verification/env/utils/apb_utils/src/
  apb_agent.sv
  apb_driver.sv
  apb_monitor.sv
  apb_sequencer.sv
  apb_transaction.sv
verification/env/apb_cdc_bridge_env.sv
verification/env/apb_cdc_bridge_env_cfg.sv
```

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
