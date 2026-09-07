# X2P 覆盖率策略 / Coverage Plan

> 本文档是 [verification_plan.md](verification_plan.md) 第 10 章的详细展开。

---

## 1. 覆盖率模型总览

| Covergroup | 内容 | 类型 |
|---|---|---|
| cg_axi_burst | burst type/len/size 组合 | functional |
| cg_aw_w_order | AW-W 三种时序 | functional |
| cg_width | AXI/APB 宽度组合 | functional |
| cg_apb_fsm | APB FSM 状态与跳转 | fsm |
| cg_arb | 仲裁粒度/策略 | functional |
| cg_timeout | timeout 触发/恢复 | functional |
| cg_cdc | SYNC/ASYNC 模式 | functional |

## 2. Coverpoint 定义（COVERAGE_META）

### COV.INTF.X2P.02.01 APB profile

<!-- COVERAGE_META
id: COV.INTF.X2P.02.01
name: APB profile coverpoint
description: APB3/APB4 两种 profile 均被覆盖
type: functional
feature_ref:
  - FL.INTF.X2P.02
END_COVERAGE_META -->

### COV.FUNC.X2P.02.01 Burst 类型

<!-- COVERAGE_META
id: COV.FUNC.X2P.02.01
name: Burst type/len coverpoint
description: INCR/FIXED/WRAP × len 组合覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.02
END_COVERAGE_META -->

### COV.FUNC.X2P.03.01 宽度组合

<!-- COVERAGE_META
id: COV.FUNC.X2P.03.01
name: Width combo coverpoint
description: AXI32/64/128 × APB32/64 覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.03
END_COVERAGE_META -->

### COV.FUNC.X2P.04.01 队列深度

<!-- COVERAGE_META
id: COV.FUNC.X2P.04.01
name: Buffer depth coverpoint
description: depth 1/2/4/8 与满标志覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.04
END_COVERAGE_META -->

### COV.FUNC.X2P.05.01 仲裁策略

<!-- COVERAGE_META
id: COV.FUNC.X2P.05.01
name: Arb policy/granularity coverpoint
description: 3 策略 × 2 粒度覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.05
END_COVERAGE_META -->

### COV.FUNC.X2P.06.01 错误响应

<!-- COVERAGE_META
id: COV.FUNC.X2P.06.01
name: Error response coverpoint
description: OKAY/SLVERR 与 ID 保真覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.06
END_COVERAGE_META -->

### COV.FUNC.X2P.07.01 Timeout

<!-- COVERAGE_META
id: COV.FUNC.X2P.07.01
name: Timeout coverpoint
description: timeout 使能/关闭、计数命中覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.07
END_COVERAGE_META -->

### COV.FUNC.X2P.08.01 APB 状态机

<!-- COVERAGE_META
id: COV.FUNC.X2P.08.01
name: APB FSM coverpoint
description: SETUP/ACCESS/Wait/Timeout 状态覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.08
END_COVERAGE_META -->

### COV.FUNC.X2P.10.01 CDC 模式

<!-- COVERAGE_META
id: COV.FUNC.X2P.10.01
name: CDC mode coverpoint
description: SYNC/ASYNC 两模式覆盖
type: functional
feature_ref:
  - FL.FUNC.X2P.10
END_COVERAGE_META -->

> **原则**：coverage 只衡量激励/状态到达，不代替 checker（checker 见
> `checker_plan.md`）。