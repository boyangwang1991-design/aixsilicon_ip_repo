# APB CDC Bridge 验证方案

<!-- VPLAN_META
schema_version: 1.0
ip_name: apb_cdc_bridge
verification_level: regression
status: draft
END_VPLAN_META -->

## 1. DUT 概述

APB CDC Bridge（`aixsilicon:ip:apb_cdc_bridge:1.0.0`）是双时钟域、单事务、协议保持型
APB 跨时钟桥。上游 APB 事务被捕获 → CDC 传输（HANDSHAKE 或 ASYNC_FIFO）→ 下游 APB
重新生成 → 响应（PRDATA/PSLVERR/completion）返回。

## 2. 时钟与复位

| 时钟 | 频率 | 时钟域 |
|------|------|--------|
| s_pclk | 可变（无固定假设） | SRC_CLK |
| m_pclk | 可变（无固定假设） | DST_CLK |

复位：`s_presetn`/`m_presetn`，低有效，async assert / sync deassert，可独立断言。

时钟关系覆盖：1:1 async / 1:2 / 1:4 / 1:8 / 2:1 / 4:1 / 8:1 / near-frequency async /
random irrational-like ratio。

## 3. 接口列表

| 接口 | 方向 | 协议 | 信号 |
|------|------|------|------|
| s_apb | slave | APB3/APB4 | s_psel/s_penable/s_paddr/s_pwrite/s_pwdata/s_pstrb/s_pprot/s_prdata/s_pready/s_pslverr |
| m_apb | master | APB3/APB4 | m_psel/m_penable/m_paddr/m_pwrite/m_pwdata/m_pstrb/m_pprot/m_prdata/m_pready/m_pslverr |

## 4. Agent 列表

| Agent | 模式 | Master/Slave |
|-------|------|--------------|
| apb_source_agent | Active | Master（驱动上游事务） |
| apb_dest_agent | Passive | Slave（响应下游事务） |
| clk_gen_source | — | 源时钟生成器 |
| clk_gen_dest | — | 目的时钟生成器 |

## 5. 寄存器验证范围

N/A — `register_model = none`，无寄存器。

## 6. 功能验证范围

- 上游捕获（read/write/back-to-back）
- 下游重新生成（SETUP/ACCESS/COMPLETE、wait-state）
- Response 返回（PRDATA/PSLVERR）
- CDC：HANDSHAKE 与 ASYNC_FIFO 两种实现
- 时钟关系矩阵、时钟暂停、独立复位

## 7. 错误注入范围

- 下游 PSLVERR
- reset during transfer（源/目的独立复位）
- 时钟暂停

## 8. 参考模型策略

UVM RM（reference model）在事务级建模 Bridge 行为：捕获上游请求 → 跨域（模型化
握手/FIFO）→ 转发到下游 → 返回响应。RM 与 DUT 输出比对。

## 9. 比对器策略

scoreboard 比对：上游完成事务的属性（地址/数据/错误）与 RM 预期一致；
下游观察到的每个事务与上游发起一一对应。详见 [checker_plan.md](checker_plan.md)。

## 10. 功能覆盖率策略

覆盖事务方向（read/write）、下游 wait 数、时钟关系、CDC 实现、复位时机等。
详见 [coverage_plan.md](coverage_plan.md)。

## 11. 测试矩阵

测试策略摘要：smoke 覆盖基础读写；regression 覆盖时钟矩阵/等待/复位/FIFO。
完整矩阵见 [test_matrix.md](test_matrix.md)。

## 12. 回归策略

- smoke tier：每次提交运行。
- regression tier：全参数空间回归（HANDSHAKE + FIFO 配置）。
- extended tier：长随机时钟关系、极端 wait、时钟暂停组合。

## 13. Signoff 标准

- 所有 must 需求对应 testcase 通过。
- 断言全部通过（one↔one 映射、payload 稳定、无伪 PREADY/PSLVERR）。
- 功能覆盖率达标。

## 14. 假设与待确认项

- CDC 静态 signoff（SpyGlass CDC）在独立阶段完成（LRS.CONS.02.001）。
- `vc_formal` 缺失时 formal 类验证方法待工具环境补充（记录为 finding）。
- SYNC_RATIO 模式预留，不在 V1.0 验证范围。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
