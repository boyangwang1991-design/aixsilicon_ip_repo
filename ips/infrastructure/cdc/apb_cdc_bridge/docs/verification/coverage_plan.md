# APB CDC Bridge 覆盖率策略

本文档是 `verification_plan.md` 第 10 章的详细展开。

## 覆盖率目标

覆盖事务方向、下游 wait、时钟关系、CDC 实现、复位时机、APB profile。

## 覆盖点元数据

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.01.001.RW
name: rw_coverage
description: 事务方向（read/write）+ back-to-back
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.02.001.WAIT
name: wait_coverage
description: 下游 wait 数 bins（0/1/random/long）
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.05.001.CLK
name: clk_relation_coverage
description: 时钟关系 bins（1:1/1:2/1:4/1:8/2:1/4:1/8:1/near/irrational）
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.06.001.RST
name: reset_coverage
description: 复位时机 bins（both/src/dst/req-cdc/access/rsp-cdc）
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.03.001.IMPL
name: impl_coverage
description: CDC 实现（HANDSHAKE/ASYNC_FIFO）+ SYNC_STAGES（2/3）
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.INTF.APB_CDC_BRIDGE.01.001.PROF
name: apb_profile_coverage
description: APB profile（APB3/APB4）cross PSTRB/PPROT 使能
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.02.001.ERR
name: error_coverage
description: PSLVERR 传播
type: functional
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_CDC_BRIDGE.05.001.PAUSE
name: pause_coverage
description: 时钟暂停时机（src-before-req/src-during-rsp/dst-before-req/dst-access）
type: functional
END_COVERAGE_META -->

## 覆盖点列表

| ID | 覆盖点 | 描述 | 类型 |
|----|--------|------|------|
| COV.FUNC.APB_CDC_BRIDGE.01.001.RW | rw_coverage | 读/写/背靠背 | functional |
| COV.FUNC.APB_CDC_BRIDGE.02.001.WAIT | wait_coverage | wait bins | functional |
| COV.FUNC.APB_CDC_BRIDGE.05.001.CLK | clk_relation_coverage | 时钟关系 | functional |
| COV.FUNC.APB_CDC_BRIDGE.06.001.RST | reset_coverage | 复位时机 | functional |
| COV.FUNC.APB_CDC_BRIDGE.03.001.IMPL | impl_coverage | 实现×同步级 | functional |
| COV.INTF.APB_CDC_BRIDGE.01.001.PROF | apb_profile_coverage | APB profile | functional |
| COV.FUNC.APB_CDC_BRIDGE.02.001.ERR | error_coverage | PSLVERR | functional |
| COV.FUNC.APB_CDC_BRIDGE.05.001.PAUSE | pause_coverage | 时钟暂停 | functional |

## 覆盖率关闭标准

- 功能覆盖率 ≥ 90%（加权）。
- 所有 COVERAGE_META 覆盖点均有 bins 且被命中。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
