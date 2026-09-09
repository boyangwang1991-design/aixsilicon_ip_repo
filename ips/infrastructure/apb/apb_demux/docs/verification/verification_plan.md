# APB Demux 验证方案

<!-- VPLAN_META
schema_version: 2.0
ip_name: apb_demux
verification_level: regression
status: draft
delivery_model: parameterized
lrs_baseline: LRS-APB_DEMUX-V100
hld_baseline: HLD-APB_DEMUX-V100
lld_baseline: LLD-APB_DEMUX-V100
END_VPLAN_META -->

## 1. DUT 概述

APB Demux（`aixsilicon:ip:apb_demux:1.0.0`）是 1→N APB Router：一个上游 APB
Slave-facing 接口按地址空间路由至 N 个下游 APB Master-facing 接口。支持地址
译码、PSEL one-hot 生成、请求 fanout、响应 mux、Decode Miss 错误响应、PSLVERR
透传、APB wait-state，以及可选 remap / timeout / response register。

## 2. 时钟与复位

| 时钟 | 频率 | 时钟域 |
|------|------|--------|
| PCLK | 可变 | CLK_APB（单域） |

复位：`PRESETn`，低有效，async assert / sync deassert。

## 3. 接口列表

| 接口 | 方向 | 协议 | 数量 |
|------|------|------|------|
| s_apb | slave | APB3/APB4 | 1 |
| m_apb[N] | master | APB3/APB4 | N（NUM_SLAVES） |

## 4. Agent 列表

| Agent | 模式 | 角色 |
|-------|------|------|
| apb_master_agent | Active | 驱动上游事务 |
| apb_slave_agent[N] | Passive | 响应下游事务 |

## 5. 寄存器验证范围

N/A — `register_model = none`，无寄存器。

## 6. 功能验证范围

- 地址译码正确性（每端口读/写）；
- PSEL onehot0；
- wait-state 保持；
- PSLVERR 透传；
- Decode Miss 错误响应；
- remap 开关；
- timeout 终止；
- response register 插入；
- APB3/APB4 profile；
- 参数组合（NUM_SLAVES 1/2/4/8/16）。

## 7. 错误注入范围

- 下游 PSLVERR；
- Decode Miss 地址访问；
- 下游长 wait（触发 timeout）；
- reset during transaction。

## 8. 参考模型策略

UVM RM（reference model）在事务级建模 Demux 行为：根据 `PADDR` 与地址映射
计算命中端口、生成预期响应（PRDATA/PREADY/PSLVERR）。RM 与 DUT 输出比对。

## 9. 比对器策略

scoreboard 比对：上游完成事务的属性（地址/数据/错误/端口）与 RM 预期一致；
下游观察到的每个事务与上游发起一一对应。详见 [checker_plan.md](checker_plan.md)。

## 10. 功能覆盖率策略

覆盖事务方向（read/write）、命中端口、wait 数、Decode Miss、PSLVERR、remap、
timeout、参数组合等。详见 [coverage_plan.md](coverage_plan.md)。

## 11. 测试矩阵

测试策略摘要：smoke 覆盖基础读写 + Decode Miss；regression 覆盖 wait/PSLVERR/
remap/timeout/参数组合；extended 覆盖 APB4 扩展与极端组合。完整矩阵见
[test_matrix.md](test_matrix.md)。

## 12. 回归策略

- smoke tier：每次提交运行（`TC.FUNC.APB_DEMUX.01.001`、`TC.FUNC.APB_DEMUX.05.001`）；
- regression tier：全参数空间回归（NUM_SLAVES 1/2/4/8/16 × APB3/APB4）；
- extended tier：长 wait + timeout、remap + response register 组合。

## 13. Signoff 标准

- 所有 must 需求对应 testcase 通过；
- 断言全部通过（onehot0、wait 稳定、decode 正确、decode miss 响应）；
- 功能覆盖率达标（functional/code/assertion）。

## 14. 假设与待确认项

- 综合（DC）/ formal（VC Formal）在独立阶段完成（记录为 gap）；
- 下游 APB Slave 由 passive agent 模拟，行为可配置（wait/error）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 06-verification-plan*
