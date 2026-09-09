# APB Demux 测试矩阵

本文档是 `verification_plan.md` 第 11 章的详细展开。

## 测试用例元数据

<!-- TESTCASE_META
id: TC.INTF.APB_DEMUX.01.001.SAN
name: sanity_read_write
type: directed
coverage_type: functional
description: 验证每个下游端口基础读写事务正确路由
preconditions: 复位释放，NUM_SLAVES=4
stimulus: 对每个端口发起单次读、单次写
expected_result: 命中端口收到事务，上游收到一致 PRDATA/无错误
timeout_policy: 10000 周期
priority: P0
tier: smoke
feature_ref: FL.INTF.APB_DEMUX.01
implementation: verification/tc/tc_sanity.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.01.001.DEC
name: address_decode_ports
type: directed
coverage_type: functional
description: 验证地址译码：每个端口命中唯一正确端口，边界地址
preconditions: NUM_SLAVES=4，地址窗口 0x4000_0000/0x4000_1000/0x4000_2000/0x4000_3000
stimulus: 覆盖每个端口基地址/末尾/边界外 1 地址的读写
expected_result: 命中唯一正确端口；边界外命中相邻端口或 decode miss
timeout_policy: 20000 周期
priority: P0
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.01
implementation: verification/tc/tc_address_decode.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.02.001.PSEL
name: psel_onehot
type: directed
coverage_type: functional
description: 验证任意地址访问 M_PSEL 满足 onehot0，未命中端口 PSEL=0
preconditions: NUM_SLAVES=4
stimulus: 随机地址序列访问
expected_result: $onehot0(M_PSEL) 恒成立；未选中端口 PSEL=0
timeout_policy: 20000 周期
priority: P0
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.02
implementation: verification/tc/tc_psel_onehot.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.03.001.WAIT
name: wait_states
type: randomized
coverage_type: functional
description: 验证下游任意 wait-state 下事务完成且 selection 稳定
preconditions: 复位释放
stimulus: 各端口配置随机 wait，上游发起读写
expected_result: wait 期间 PSEL/PENABLE/响应源稳定，最终完成
timeout_policy: 30000 周期
priority: P0
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.03
implementation: verification/tc/tc_wait_states.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.04.001.ERR
name: pslverr_propagation
type: directed
coverage_type: functional
description: 验证下游 PSLVERR 正确透传上游
preconditions: 复位释放
stimulus: 特定端口对写访问返回 SLVERR
expected_result: 上游收到对应 PSLVERR，未被屏蔽
timeout_policy: 10000 周期
priority: P0
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.04
implementation: verification/tc/tc_pslverr.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.05.001.MISS
name: decode_miss
type: directed
coverage_type: functional
description: 验证 Decode Miss 立即返回 PREADY=1, PSLVERR=1, PRDATA=0
preconditions: 复位释放
stimulus: 访问未命中任何端口的地址
expected_result: 上游观察到 PREADY=1, PSLVERR=1, PRDATA=0，transaction 立即结束
timeout_policy: 10000 周期
priority: P0
tier: smoke
feature_ref: FL.FUNC.APB_DEMUX.05
implementation: verification/tc/tc_decode_miss.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.06.001.REMAP
name: remap_enable
type: directed
coverage_type: functional
description: 验证 remap 开启时 M_PADDR = PADDR - BASE_ADDR
preconditions: ADDR_REMAP_ENABLE=1
stimulus: 访问各端口带 offset 地址
expected_result: 下游 M_PADDR 为 local offset；关闭时透传
timeout_policy: 20000 周期
priority: P1
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.06
implementation: verification/tc/tc_remap.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.07.001.TOUT
name: timeout_terminate
type: directed
coverage_type: functional
description: 验证 timeout 终止 transaction 并返回 error
preconditions: TIMEOUT_ENABLE=1, TIMEOUT_CYCLES=16
stimulus: 下游保持 PREADY=0 超过 TIMEOUT_CYCLES
expected_result: 超时后返回 PREADY=1, PSLVERR=1
timeout_policy: 20000 周期
priority: P1
tier: regression
feature_ref: FL.FUNC.APB_DEMUX.07
implementation: verification/tc/tc_timeout.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.08.001.OREG
name: output_register
type: directed
coverage_type: functional
description: 验证 response register 插入后协议合规且延迟增加
preconditions: OUTPUT_REGISTER=1
stimulus: 基础读写事务
expected_result: APB 协议断言通过；响应延迟增加一拍
timeout_policy: 20000 周期
priority: P1
tier: extended
feature_ref: FL.FUNC.APB_DEMUX.08
implementation: verification/tc/tc_output_register.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.RESET.APB_DEMUX.01.001.RST
name: reset_scenarios
type: directed
coverage_type: functional
description: 验证 idle/transaction 期间复位，复位后无有效事务
preconditions: 无
stimulus: idle 时复位、事务进行中复位
expected_result: 复位期间 M_PSEL 全 0，复位后状态确定
timeout_policy: 20000 周期
priority: P0
tier: regression
feature_ref: FL.RESET.APB_DEMUX.01
implementation: verification/tc/tc_reset.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.APB_DEMUX.01.002.PARAM
name: num_slaves_sweep
type: randomized
coverage_type: functional
description: 验证 NUM_SLAVES 1/2/4/8/16 各参数组合下功能正确
preconditions: NUM_SLAVES 参数扫描
stimulus: 随机地址/数据读写序列
expected_result: 所有参数组合下译码/路由/响应正确
timeout_policy: 50000 周期
priority: P0
tier: regression
feature_ref: FL.CFG.APB_DEMUX.01
implementation: verification/tc/tc_num_slaves_sweep.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.INTF.APB_DEMUX.01.002.APB4
name: apb4_extensions
type: directed
coverage_type: functional
description: 验证 APB4 profile 下 PSTRB/PPROT 透传与字节写入
preconditions: APB_PROFILE=APB4
stimulus: 字节/半字写（PSTRB 部分使能）+ PPROT 变化
expected_result: PSTRB/PPROT 正确透传；APB3 下无相关通路
timeout_policy: 20000 周期
priority: P0
tier: extended
feature_ref: FL.INTF.APB_DEMUX.01
implementation: verification/tc/tc_apb4.sv
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.DFX.APB_DEMUX.01.001.ASSERT
name: assertion_checks
type: assertion
coverage_type: functional
description: 验证协议断言（onehot0/wait 稳定/decode 正确/decode miss 响应）
preconditions: 无
stimulus: 随机事务序列（含 miss/PSLVERR/wait）
expected_result: 所有断言成立，无违例
timeout_policy: 30000 周期
priority: P0
tier: regression
feature_ref: FL.DFX.APB_DEMUX.01
implementation: verification/tc/tc_assertions.sv
END_TESTCASE_META -->

## 测试矩阵

| ID | 名称 | 类型 | tier | 优先级 | 功能 |
|----|------|------|------|--------|------|
| TC.INTF.APB_DEMUX.01.001.SAN | sanity_read_write | directed | smoke | P0 | 基础读写 |
| TC.FUNC.APB_DEMUX.01.001.DEC | address_decode_ports | directed | regression | P0 | 地址译码 |
| TC.FUNC.APB_DEMUX.02.001.PSEL | psel_onehot | directed | regression | P0 | PSEL onehot |
| TC.FUNC.APB_DEMUX.03.001.WAIT | wait_states | randomized | regression | P0 | wait-state |
| TC.FUNC.APB_DEMUX.04.001.ERR | pslverr_propagation | directed | regression | P0 | PSLVERR 透传 |
| TC.FUNC.APB_DEMUX.05.001.MISS | decode_miss | directed | smoke | P0 | Decode Miss |
| TC.FUNC.APB_DEMUX.06.001.REMAP | remap_enable | directed | regression | P1 | remap |
| TC.FUNC.APB_DEMUX.07.001.TOUT | timeout_terminate | directed | regression | P1 | timeout |
| TC.FUNC.APB_DEMUX.08.001.OREG | output_register | directed | extended | P1 | response register |
| TC.RESET.APB_DEMUX.01.001.RST | reset_scenarios | directed | regression | P0 | 复位 |
| TC.FUNC.APB_DEMUX.01.002.PARAM | num_slaves_sweep | randomized | regression | P0 | 参数组合 |
| TC.INTF.APB_DEMUX.01.002.APB4 | apb4_extensions | directed | extended | P0 | APB4 扩展 |
| TC.DFX.APB_DEMUX.01.001.ASSERT | assertion_checks | assertion | regression | P0 | 断言 |

## 需求覆盖

所有 P0（must）需求由 testcase 或 assertion 承接：

- 地址译码/路由/事务/响应/错误/复位/接口：`FL.FUNC/INTF/RESET` 对应 testcase；
- 协议断言：`TC.DFX.APB_DEMUX.01.001.ASSERT` 承接 `FL.DFX`；
- P1 可选特性：remap/timeout/response register 独立 testcase 覆盖。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 06-verification-plan*
