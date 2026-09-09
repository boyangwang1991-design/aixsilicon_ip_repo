# APB Demux Agent 规划

本文档是 `verification_plan.md` 第 4 章的详细展开。

## 1. Agent 结构

| Agent | 模式 | 协议 | 角色 | 说明 |
|-------|------|------|------|------|
| `apb_master_agent` | Active | APB3/APB4 | 上游 Master | 驱动上游事务（读写/back-to-back） |
| `apb_slave_agent[N]` | Passive | APB3/APB4 | 下游 Slave | 响应下游事务（可配置 wait/PSLVERR） |

## 2. Agent 内部结构

### apb_master_agent

```text
apb_master_agent
├── apb_master_driver    # 驱动上游 APB 信号（SETUP/ACCESS 时序）
├── apb_master_sequencer # 事务序列发生器
└── apb_master_monitor   # 观察上游完成事务（响应侧）
```

### apb_slave_agent[N]

```text
apb_slave_agent
├── apb_slave_driver     # 响应下游事务（PREADY/PSLVERR/PRDATA 可配置）
└── apb_slave_monitor    # 观察下游事务（发起侧）
```

## 3. 事务定义

| 事务 | 字段 | 说明 |
|------|------|------|
| `apb_master_xact` | addr/wr_data/rd_data/write/strb/prot/pslverr | 上游事务 |
| `apb_slave_xact` | addr/wr_data/rd_data/write/pready/pslverr | 下游事务 |

## 4. Active/Passive 模式

- 上游 `apb_master_agent`：Active（验证环境驱动 DUT 上游）；
- 下游 `apb_slave_agent[N]`：Passive response 模式（模拟 slave 行为）。

## 5. 配置能力

- slave agent 支持配置 wait 数（0~N）、是否返回 PSLVERR、返回数据 pattern；
- master agent 支持配置地址范围（命中/未命中）、back-to-back 间隔。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 06-verification-plan*
