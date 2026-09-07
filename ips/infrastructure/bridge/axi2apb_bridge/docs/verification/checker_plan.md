# X2P 比对器策略 / Checker Plan

> 本文档是 [verification_plan.md](verification_plan.md) 第 9 章的详细展开。

---

## 1. Scoreboard / RM 策略

- **RM（参考模型）**：UVM 中开发 `x2p_scoreboard`（行为建模 AXI→APB 转换）：
  对每个 AXI 事务，按 burst/WRAP/width 语义计算期望的 APB 序列与期望响应，
  AXI 侧响应与 APB 侧观测必须一致。RM 为验证唯一参考来源（UVM 1.2）。
- **Checker 划分**：
  - `x2p_burst_checker`：地址推进（INCR/WRAP/4KB）。
  - `x2p_width_checker`：WSTRB→PSTRB、Read assembly、Error 聚合。
  - `x2p_apb_checker`：SETUP/ACCESS 相位、Wait-State 稳定、Timeout 恢复。
  - `x2p_protocol_checker`：AXI READY 背压、R/B 稳定、同 ID ordering。

## 2. Assertion 列表（ASSERTION_META）

> 每个 assertion 单一 feature_ref，全局唯一 ID。

<!-- ASSERTION_META
id: AS.INTF.X2P.01.01
name: AXI channel alignment
description: AWVALID 与 WVALID 独立，BVALID 与 RREADY 不冲突
property: assert property (AWVALID 与 WVALID 独立，BVALID 与 RREADY 不冲突)
feature_ref:
  - FL.INTF.X2P.01
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.INTF.X2P.02.01
name: APB SINGLE PSEL
description: PSEL 始终单比特 1（不出现多选择）
property: assert property (PSEL 始终单比特 1（不出现多选择）)
feature_ref:
  - FL.INTF.X2P.02
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.INTF.X2P.03.01
name: Reset no phantom
description: 复位后无 BVALID/RVALID/PSEL/PENABLE（无伪请求）
property: assert property (复位后无 BVALID/RVALID/PSEL/PENABLE（无伪请求）)
feature_ref:
  - FL.INTF.X2P.03
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.01.01
name: AW/W pairing data integrity
description: 配对事务数据不被丢失/重复（WLAST 对齐）
property: assert property (配对事务数据不被丢失/重复（WLAST 对齐）)
feature_ref:
  - FL.FUNC.X2P.01
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.02.01
name: Burst address monotonic/wrap
description: INCR 地址正确递增、FIXED 不变、WRAP 回绕点正确
property: assert property (INCR 地址正确递增、FIXED 不变、WRAP 回绕点正确)
feature_ref:
  - FL.FUNC.X2P.02
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.03.01
name: Width conversion correctness
description: PSTRB 与有效 lane 一致；R 仅在完整 beat 后 valid
property: assert property (PSTRB 与有效 lane 一致；R 仅在完整 beat 后 valid)
feature_ref:
  - FL.FUNC.X2P.03
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.04.01
name: No overflow underflow
description: 队列在深度内操作，READY 满时反压
property: assert property (队列在深度内操作，READY 满时反压)
feature_ref:
  - FL.FUNC.X2P.04
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.05.01
name: Beat atomicity
description: 同一 AXI Beat 的子传输不被打断（原子性）
property: assert property (同一 AXI Beat 的子传输不被打断（原子性）)
feature_ref:
  - FL.FUNC.X2P.05
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.06.01
name: Error aggregation
description: 任一子传输出错，最终 BRESP/RRESP=SLVERR
property: assert property (任一子传输出错，最终 BRESP/RRESP=SLVERR)
feature_ref:
  - FL.FUNC.X2P.06
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.07.01
name: Timeout recovery
description: Timeout 后 APB FSM 返回 IDLE，可再处理请求
property: assert property (Timeout 后 APB FSM 返回 IDLE，可再处理请求)
feature_ref:
  - FL.FUNC.X2P.07
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.08.01
name: APB phase timing
description: ACCESS 期间 PREADY=0 时控制/数据稳定
property: assert property (ACCESS 期间 PREADY=0 时控制/数据稳定)
feature_ref:
  - FL.FUNC.X2P.08
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.09.01
name: Ordering preserved
description: 同 ID 事务 R/B 顺序保持
property: assert property (同 ID 事务 R/B 顺序保持)
feature_ref:
  - FL.FUNC.X2P.09
END_ASSERTION_META -->

<!-- ASSERTION_META
id: AS.FUNC.X2P.10.01
name: CDC no loss
description: ASYNC 模式跨域无事务丢失、无重复
property: assert property (ASYNC 模式跨域无事务丢失、无重复)
feature_ref:
  - FL.FUNC.X2P.10
END_ASSERTION_META -->