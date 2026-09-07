# X2P 测试矩阵 / Test Matrix

> 本文档是 [verification_plan.md](verification_plan.md) 的详细展开（第 11 章）。

---

## 测试组划分

| 测试组 | 数量 | 说明 |
|---|---|---|
| sanity | 1 | smoke：基本读写 |
| basic | 2 | 参数化读写 burst、APB4/APB3 |
| scenario | 1 | 参数化：仲裁/宽度/时钟模式 |
| corner | 2 | WRAP+width、4KB 边界 |
| random | 1 | 随机负载双发 |
| **去重总计** | **≤ 20** | 复杂 IP 上限 20 |

## 测试矩阵（TESTCASE_META）

### TC.INTF.X2P.01.01 AXI Slave 接口完整性（smoke）

- type: smoke / directed
- feature_ref: FL.INTF.X2P.01

<!-- TESTCASE_META
id: TC.INTF.X2P.01.01
name: AXI Slave Interface Basic
description: AXI Slave Interface Basic
type: directed
priority: P0
tier: smoke
preconditions: reset released
stimulus: 单笔 AXI 读写事务（INCR len=1）
expected_result: AXI 读写完成，BID/RID 正确
timeout_policy: 1000 cycles
feature_ref:
  - FL.INTF.X2P.01
END_TESTCASE_META -->

### TC.INTF.X2P.02.01 APB Master 接口 APB4（regression）

- type: basic / directed
- feature_ref: FL.INTF.X2P.02

<!-- TESTCASE_META
id: TC.INTF.X2P.02.01
name: APB4 Master Interface
description: APB4 Master Interface
type: directed
priority: P0
tier: regression
preconditions: APB_PROFILE=APB4
stimulus: AXI 写读事务验证 PSTRB/PPROT
expected_result: PSTRB/PPROT 正确，PSEL 单一
timeout_policy: 1000 cycles
feature_ref:
  - FL.INTF.X2P.02
END_TESTCASE_META -->

### TC.INTF.X2P.03.01 时钟模式与复位（regression）

- type: reset / directed
- feature_ref: FL.INTF.X2P.03

<!-- TESTCASE_META
id: TC.INTF.X2P.03.01
name: Sync/Async Clock and Reset
description: Sync/Async Clock and Reset
type: reset
priority: P0
tier: regression
preconditions: CLOCK_MODE=SYNC/ASYNC 参数化
stimulus: 复位 assert/release，读写
expected_result: 复位后无伪请求；ASYNC 单独复位正常
timeout_policy: 2000 cycles
feature_ref:
  - FL.INTF.X2P.03
END_TESTCASE_META -->

### TC.FUNC.X2P.01.01 AW/W 关联（regression）

- type: algorithm / directed
- feature_ref: FL.FUNC.X2P.01

<!-- TESTCASE_META
id: TC.FUNC.X2P.01.01
name: AW/W Association Timing
description: AW/W Association Timing
type: algorithm
priority: P0
tier: regression
preconditions: AXI4, Depth=4
stimulus: AW before W / W before AW / same cycle / 任意间隔
expected_result: 数据与地址正确配对，WLAST 正确
timeout_policy: 2000 cycles
feature_ref:
  - FL.FUNC.X2P.01
END_TESTCASE_META -->

### TC.FUNC.X2P.02.01 Burst 转换 INCR/FIXED（regression）

- type: directed / algorithm
- feature_ref: FL.FUNC.X2P.02

<!-- TESTCASE_META
id: TC.FUNC.X2P.02.01
name: INCR and FIXED Burst
description: INCR and FIXED Burst
type: directed
priority: P0
tier: regression
preconditions: AXI4, full burst
stimulus: INCR len=1..16、FIXED len=1..16
expected_result: 地址递增/不变正确，全部 beat 返回
timeout_policy: 4000 cycles
feature_ref:
  - FL.FUNC.X2P.02
END_TESTCASE_META -->

### TC.FUNC.X2P.02.02 WRAP Burst（regression）

- type: boundary / algorithm
- feature_ref: FL.FUNC.X2P.02

<!-- TESTCASE_META
id: TC.FUNC.X2P.02.02
name: WRAP Burst
description: WRAP Burst
type: algorithm
priority: P0
tier: regression
preconditions: AXI4, WRAP len=4/8/16
stimulus: WRAP 回绕地址验证
expected_result: 回绕点正确，无越界
timeout_policy: 4000 cycles
feature_ref:
  - FL.FUNC.X2P.02
END_TESTCASE_META -->

### TC.FUNC.X2P.02.03 4KB 边界（extended）

- type: boundary
- feature_ref: FL.FUNC.X2P.02

<!-- TESTCASE_META
id: TC.FUNC.X2P.02.03
name: 4KB Boundary
description: 4KB Boundary
type: boundary
priority: P0
tier: extended
preconditions: AXI4
stimulus: 地址跨越 4KB 边界（边界前后）
expected_result: burst 不跨 4KB，邻近地址正确
timeout_policy: 4000 cycles
feature_ref:
  - FL.FUNC.X2P.02
END_TESTCASE_META -->

### TC.FUNC.X2P.03.01 Narrow/Width 转换（regression）

- type: algorithm / parameterized
- feature_ref: FL.FUNC.X2P.03

<!-- TESTCASE_META
id: TC.FUNC.X2P.03.01
name: Narrow and Width Conversion
description: Narrow and Width Conversion
type: algorithm
priority: P0
tier: regression
preconditions: AXI64/APB32, AXI128/APB32, AXI32/APB64 参数化
stimulus: 各宽度组合读写 + narrow（AxSIZE<data width）+ APB3 partial write
expected_result: 拆解/组装/STRB 正确；APB3 partial write 返回 SLVERR
timeout_policy: 4000 cycles
feature_ref:
  - FL.FUNC.X2P.03
END_TESTCASE_META -->

### TC.FUNC.X2P.03.02 Read Data Assembly（regression）

- type: algorithm
- feature_ref: FL.FUNC.X2P.03

<!-- TESTCASE_META
id: TC.FUNC.X2P.03.02
name: Read Data Assembly and Error Aggregation
description: Read Data Assembly and Error Aggregation
type: algorithm
priority: P0
tier: regression
preconditions: AXI64->APB32
stimulus: 拆分读 + 注入子传输出错
expected_result: RDATA 拼接正确；子传输出错 RRESP=SLVERR
timeout_policy: 3000 cycles
feature_ref:
  - FL.FUNC.X2P.03
END_TESTCASE_META -->

### TC.FUNC.X2P.04.01 Request Buffer / Outstanding（regression）

- type: stress / boundary
- feature_ref: FL.FUNC.X2P.04

<!-- TESTCASE_META
id: TC.FUNC.X2P.04.01
name: Buffer Depth and Outstanding
description: Buffer Depth and Outstanding
type: boundary
priority: P0
tier: regression
preconditions: Depth=1/2/4/8 参数化
stimulus: 填满队列、RREADY/BREADY 背压、多 outstanding 读写
expected_result: 无溢出/下溢，READY 反压正确，多 outstanding 完成
timeout_policy: 5000 cycles
feature_ref:
  - FL.FUNC.X2P.04
END_TESTCASE_META -->

### TC.FUNC.X2P.05.01 仲裁策略与粒度（regression）

- type: algorithm / random
- feature_ref: FL.FUNC.X2P.05

<!-- TESTCASE_META
id: TC.FUNC.X2P.05.01
name: Arbitration Policy and Granularity
description: Arbitration Policy and Granularity
type: algorithm
priority: P0
tier: regression
preconditions: ARB_POLICY=RR/READ_PRI/WRITE_PRI, GRANULARITY=BEAT/TRANSACTION 参数化
stimulus: 双发读写，验证轮转/优先级/粒度
expected_result: 无饥饿（RR），Beat 内 sub-transfer 原子
timeout_policy: 5000 cycles
feature_ref:
  - FL.FUNC.X2P.05
END_TESTCASE_META -->

### TC.FUNC.X2P.06.01 响应与错误映射（regression）

- type: error_injection / directed
- feature_ref: FL.FUNC.X2P.06

<!-- TESTCASE_META
id: TC.FUNC.X2P.06.01
name: Response OKAY/SLVERR and ID
description: Response OKAY/SLVERR and ID
type: error_injection
priority: P0
tier: regression
preconditions: APB 可注 PSLVERR
stimulus: 正常 PSLVERR=0、异常 PSLVERR=1、多 ID 事务
expected_result: OKAY/SLVERR 正确、BID/RID 匹配、write 错误聚合
timeout_policy: 4000 cycles
feature_ref:
  - FL.FUNC.X2P.06
END_TESTCASE_META -->

### TC.FUNC.X2P.07.01 APB Timeout（regression）

- type: error_injection / boundary
- feature_ref: FL.FUNC.X2P.07

<!-- TESTCASE_META
id: TC.FUNC.X2P.07.01
name: APB Timeout
description: APB Timeout
type: error_injection
priority: P0
tier: regression
preconditions: TIMEOUT_ENABLE=1, TIMEOUT_CYCLES=32
stimulus: PREADY 持续 0 达 timeout
expected_result: 返回 SLVERR，FSM 恢复，无死锁
timeout_policy: 2000 cycles
feature_ref:
  - FL.FUNC.X2P.07
END_TESTCASE_META -->

### TC.FUNC.X2P.08.01 APB 事务/Wait-State（regression）

- type: directed / boundary
- feature_ref: FL.FUNC.X2P.08

<!-- TESTCASE_META
id: TC.FUNC.X2P.08.01
name: APB Transaction and Wait-State
description: APB Transaction and Wait-State
type: directed
priority: P0
tier: regression
preconditions: APB4
stimulus: PREADY=0 穿插、back-to-back
expected_result: SETUP/ACCESS 正确，Wait-State 信号稳定
timeout_policy: 3000 cycles
feature_ref:
  - FL.FUNC.X2P.08
END_TESTCASE_META -->

### TC.FUNC.X2P.09.01 Register Stage 与 Ordering（extended）

- type: directed / boundary
- feature_ref: FL.FUNC.X2P.09

<!-- TESTCASE_META
id: TC.FUNC.X2P.09.01
name: Register Stage and Ordering
description: Register Stage and Ordering
type: boundary
priority: P1
tier: extended
preconditions: AXI_INPUT_REG/OUTPUT_REG/APB_OUTPUT_REG 开关
stimulus: 各 regslice 开关下读写 + 同 ID 多事务
expected_result: 语义不变，同 ID 按序返回
timeout_policy: 3000 cycles
feature_ref:
  - FL.FUNC.X2P.09
END_TESTCASE_META -->

### TC.FUNC.X2P.10.01 CDC 同步/异步（regression）

- type: directed / stress
- feature_ref: FL.FUNC.X2P.10

<!-- TESTCASE_META
id: TC.FUNC.X2P.10.01
name: Async Clock CDC
description: Async Clock CDC
type: stress
priority: P0
tier: regression
preconditions: CLOCK_MODE=ASYNC, 两时钟不同频率比
stimulus: 随机跨域读写 + 单域复位
expected_result: 无事务丢失，无伪请求/响应
timeout_policy: 5000 cycles
feature_ref:
  - FL.FUNC.X2P.10
END_TESTCASE_META -->

### TC.PERF.X2P.01.01 性能与负载（extended）

- type: performance
- feature_ref: FL.PERF.X2P.01

<!-- TESTCASE_META
id: TC.PERF.X2P.01.01
name: Throughput and No-Bubble
description: Throughput and No-Bubble
type: performance
priority: P1
tier: extended
preconditions: PREADY=1 恒定
stimulus: 满负载连续读写
expected_result: APB 无额外 idle，解耦正常
timeout_policy: 5000 cycles
feature_ref:
  - FL.PERF.X2P.01
END_TESTCASE_META -->

### TC.CONS.X2P.01.01 约束合法性（extended）

- type: negative
- feature_ref: FL.CONS.X2P.01

<!-- TESTCASE_META
id: TC.CONS.X2P.01.01
name: Parameter Legality and Unsupported
description: Parameter Legality and Unsupported
type: negative
priority: P1
tier: extended
preconditions: 非法参数组合（AXI4-Lite+WRAP 等）
stimulus: 非法事务/参数
expected_result: 返回明确错误，不静默改变语义
timeout_policy: 2000 cycles
feature_ref:
  - FL.CONS.X2P.01
END_TESTCASE_META -->

> **说明**：所有 TC 已全局去重，每个 TESTCASE_META 只有单一 feature_ref，符合
> extractor 与 build_trace 的要求。