# APB CDC Bridge 测试矩阵

本文档是 `verification_plan.md` 第 11 章的详细展开。

## 测试用例元数据

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.01.001.SAN
name: sanity_read_write
type: directed
coverage_type: functional
description: 验证单次读写事务跨桥正确完成
preconditions: 复位释放，两时钟异步
stimulus: 源 agent 发起单次读、单次写
expected_result: 下游观察到对应事务，上游收到一致 PRDATA/无错误
timeout_policy: 10000 周期
priority: must
tier: smoke
feature_ref: FL.FUNC.APB_CDC_BRIDGE.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.02.001.DOWN
name: downstream_wait_states
type: directed
coverage_type: functional
description: 验证下游任意 wait-state 下事务完成
preconditions: 复位释放
stimulus: 目的 agent 配置随机/长 wait，源发起读写
expected_result: wait 期间输出稳定，最终完成
timeout_policy: 20000 周期
priority: must
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.02
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.02.002.ERR
name: pslverr_propagation
type: directed
coverage_type: functional
description: 验证下游 PSLVERR 正确返回上游
preconditions: 复位释放
stimulus: 目的 agent 对特定地址返回 SLVERR
expected_result: 上游收到对应 PSLVERR
timeout_policy: 10000 周期
priority: must
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.02
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.03.001.HS
name: handshake_multi_config
type: randomized
coverage_type: functional
description: 验证 HANDSHAKE 实现下多配置（SYNC_STAGES 2/3）读写
preconditions: CDC_IMPL=HANDSHAKE
stimulus: 随机地址/数据读写序列
expected_result: 无丢失/重复，payload 稳定
timeout_policy: 20000 周期
priority: must
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.03
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.04.001.FIFO
name: fifo_depth12
type: randomized
coverage_type: functional
description: 验证 ASYNC_FIFO 实现 depth 1/2
preconditions: CDC_IMPL=ASYNC_FIFO
stimulus: 随机读写序列
expected_result: 无丢失/重复，单事务完成语义保持
timeout_policy: 20000 周期
priority: should
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.04
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.05.001.CLK
name: clock_relation_matrix
type: randomized
coverage_type: functional
description: 验证时钟关系矩阵（1:1/1:2/1:4/1:8/2:1/4:1/8:1/near/irrational）
preconditions: 复位释放
stimulus: 各时钟关系下随机读写
expected_result: 所有关系下事务正确
timeout_policy: 50000 周期
priority: must
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.05
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.05.002.PAUSE
name: clock_pause
type: directed
coverage_type: functional
description: 验证源/目的时钟暂停与恢复
preconditions: 复位释放
stimulus: 事务进行中暂停源/目的时钟
expected_result: 暂停期间保持，恢复后完成，无丢失
timeout_policy: 30000 周期
priority: must
tier: extended
feature_ref: FL.FUNC.APB_CDC_BRIDGE.05
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_CDC_BRIDGE.06.001.RST
name: reset_scenarios
type: directed
coverage_type: functional
description: 验证独立复位（源/目的/双侧/传输中）
preconditions: 无
stimulus: 各复位时机下发起事务
expected_result: 复位后无 stale transfer，无伪事务
timeout_policy: 30000 周期
priority: must
tier: regression
feature_ref: FL.FUNC.APB_CDC_BRIDGE.06
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.INTF.APB_CDC_BRIDGE.01.001.APB4
name: apb4_extension
type: directed
coverage_type: functional
description: 验证 APB4 PSTRB/PPROT 跨域保真
preconditions: APB_PROFILE=APB4
stimulus: 设置非零 PSTRB/PPROT 的写事务
expected_result: 下游 PSTRB/PPROT 与上游一致
timeout_policy: 10000 周期
priority: must
tier: regression
feature_ref: FL.INTF.APB_CDC_BRIDGE.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.CONS.APB_CDC_BRIDGE.01.001.CFG
name: config_validation
type: directed
coverage_type: functional
description: 验证非法配置被拒绝
preconditions: 无
stimulus: 编译期非法参数（DATA_WIDTH%8!=0 等）
expected_result: 编译/elab 失败（assert）
timeout_policy: n/a
priority: must
tier: smoke
feature_ref: FL.CONS.APB_CDC_BRIDGE.01
END_TESTCASE_META -->

## 测试矩阵

| 测试ID | 功能 | 测试名称 | 类型 | 描述 | 通过标准 |
|--------|------|----------|------|------|----------|
| TC.FUNC.APB_CDC_BRIDGE.01.001.SAN | FL.FUNC.APB_CDC_BRIDGE.01 | sanity_read_write | directed | 基础读写 | 读回一致，PSLVERR=0 |
| TC.FUNC.APB_CDC_BRIDGE.02.001.DOWN | FL.FUNC.APB_CDC_BRIDGE.02 | downstream_wait_states | directed | 下游等待 | 事务完成，输出稳定 |
| TC.FUNC.APB_CDC_BRIDGE.02.002.ERR | FL.FUNC.APB_CDC_BRIDGE.02 | pslverr_propagation | directed | PSLVERR 传播 | 上游 PSLVERR 一致 |
| TC.FUNC.APB_CDC_BRIDGE.03.001.HS | FL.FUNC.APB_CDC_BRIDGE.03 | handshake_multi_config | randomized | 握手多配置 | 无丢失/重复 |
| TC.FUNC.APB_CDC_BRIDGE.04.001.FIFO | FL.FUNC.APB_CDC_BRIDGE.04 | fifo_depth12 | randomized | FIFO 深度 | 无丢失/重复 |
| TC.FUNC.APB_CDC_BRIDGE.05.001.CLK | FL.FUNC.APB_CDC_BRIDGE.05 | clock_relation_matrix | randomized | 时钟关系矩阵 | 全部通过 |
| TC.FUNC.APB_CDC_BRIDGE.05.002.PAUSE | FL.FUNC.APB_CDC_BRIDGE.05 | clock_pause | directed | 时钟暂停 | 无丢失 |
| TC.FUNC.APB_CDC_BRIDGE.06.001.RST | FL.FUNC.APB_CDC_BRIDGE.06 | reset_scenarios | directed | 独立复位 | 无 stale |
| TC.INTF.APB_CDC_BRIDGE.01.001.APB4 | FL.INTF.APB_CDC_BRIDGE.01 | apb4_extension | directed | APB4 扩展 | PSTRB/PPROT 一致 |
| TC.CONS.APB_CDC_BRIDGE.01.001.CFG | FL.CONS.APB_CDC_BRIDGE.01 | config_validation | directed | 配置校验 | elab 失败 |

## Tier 汇总

| Tier | 数量 | 说明 |
|------|------|------|
| smoke | 2 | sanity_read_write、config_validation |
| regression | 7 | wait/err/handshake/fifo/clk/rst/apb4 |
| extended | 1 | clock_pause |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
