# HLD 分解与验证规划 - UART

## 16. LLD 分解建议

| HLD 模块 | LLD 覆盖内容 | 建议 |
|---|---|---|
| uart_reg_top | 寄存器访问时序、中断逻辑 | 保留 OpenTitan 原版，LLD 描述其接口 |
| uart_core | FIFO 控制、波特率分频、中断事件、break 状态机、超时计数 | LLD 详细描述 |
| uart_rx | 接收状态机、采样窗口 | LLD 详细描述 |
| uart_tx | 发送状态机 | LLD 详细描述 |
| apb2tlul（新增） | APB→TL-UL 转换 FSM、地址映射、pslverr | LLD 详细描述 |

## 17. 验证规划

### 17.1 验证特性（对应 LRS）

| 特性 | 覆盖需求 | 验证手段 |
|---|---|---|
| 串行帧/收发 | FUNC.01.001/003/004 | UART agent 激励 + RM 比对 |
| 波特率 | FUNC.01.002, PERF.01.001/002 | 时序测量 |
| 奇偶 | FUNC.01.005 | 错误注入 |
| 回环 | FUNC.01.006/007 | 回环场景 |
| 错误检测 | FUNC.01.008/009/012 | 错误注入 |
| FIFO | FUNC.01.011, REG.01.005 | 满/空/水位 |
| 中断 | FUNC.01.013, REG.01.007 | 中断场景 |
| 寄存器 | REG.* | RAL + CSR 检查 |
| APB 接入 | INTF.01.003 | APB agent |
| Alert | SAFE.01.* | ALERT_TEST |

### 17.2 覆盖点与断言

- 功能覆盖：波特率配置、FIFO 水位、错误事件、回环模式、奇偶配置。
- 断言：`ASSERT`（OpenTitan 内置）+ 自研时序断言。

### 17.3 验证环境

- UVM 1.2：uart 协议 agent、TL-UL/APB 总线 agent、env/RM/checker/coverage、testcase。
- 编译/回归：`verification/sim/Makefile`（VCS）。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
