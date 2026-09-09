# APB CDC Bridge 功能列表

本文档是 `verification_plan.md` 第 6 章的详细展开。

## 功能元数据

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.01
name: upstream_capture
description: 上游 APB 事务捕获与单事务语义
priority: must
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.01.001, LRS.FUNC.APB_CDC_BRIDGE.01.002, LRS.FUNC.APB_CDC_BRIDGE.01.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.02
name: downstream_regeneration
description: 下游 APB 事务重新生成与响应
priority: must
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.02.001, LRS.FUNC.APB_CDC_BRIDGE.02.002, LRS.FUNC.APB_CDC_BRIDGE.02.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.03
name: handshake_cdc
description: HANDSHAKE 跨域实现（默认）
priority: must
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.03.001, LRS.FUNC.APB_CDC_BRIDGE.03.002, LRS.FUNC.APB_CDC_BRIDGE.04.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.04
name: async_fifo_cdc
description: ASYNC_FIFO 跨域实现（可选）
priority: should
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.04.001, LRS.FUNC.APB_CDC_BRIDGE.04.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.05
name: clock_relation
description: 时钟关系矩阵（快慢/异步/暂停）与低功耗
priority: must
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.05.001, LRS.FUNC.APB_CDC_BRIDGE.06.001, LRS.FUNC.APB_CDC_BRIDGE.07.001, LRS.FUNC.APB_CDC_BRIDGE.08.001, LRS.INTF.APB_CDC_BRIDGE.03.001, LRS.LP.APB_CDC_BRIDGE.01.001, LRS.LP.APB_CDC_BRIDGE.02.001]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_CDC_BRIDGE.06
name: reset_behavior
description: 独立复位与 reset-abort
priority: must
req_ref: [LRS.FUNC.APB_CDC_BRIDGE.09.001, LRS.INTF.APB_CDC_BRIDGE.03.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.INTF.APB_CDC_BRIDGE.01
name: apb_interface
description: 上游/下游 APB 接口与 APB4 扩展
priority: must
req_ref: [LRS.INTF.APB_CDC_BRIDGE.01.001, LRS.INTF.APB_CDC_BRIDGE.01.002, LRS.INTF.APB_CDC_BRIDGE.02.001, LRS.INTF.APB_CDC_BRIDGE.02.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.CONS.APB_CDC_BRIDGE.01
name: config_validation
description: 非法配置检测与 CDC 静态
priority: must
req_ref: [LRS.CONS.APB_CDC_BRIDGE.01.001, LRS.CONS.APB_CDC_BRIDGE.02.001]
END_FEATURE_META -->

## 功能列表

| ID | 功能 | 描述 | 优先级 | 需求引用 |
|----|------|------|--------|----------|
| FL.FUNC.APB_CDC_BRIDGE.01 | upstream_capture | 上游捕获/单事务/负载稳定 | must | LRS.FUNC.01.001-003 |
| FL.FUNC.APB_CDC_BRIDGE.02 | downstream_regeneration | 下游 SETUP/ACCESS/完成 | must | LRS.FUNC.02.001-003 |
| FL.FUNC.APB_CDC_BRIDGE.03 | handshake_cdc | 握手跨域/同步器级数/二选一隔离 | must | LRS.FUNC.03.001-002,04.002 |
| FL.FUNC.APB_CDC_BRIDGE.04 | async_fifo_cdc | FIFO 跨域/无人工 outstanding/隔离 | should | LRS.FUNC.04.001-002 |
| FL.FUNC.APB_CDC_BRIDGE.05 | clock_relation | 快慢/慢快/同步资格/时钟暂停/低功耗 | must | LRS.FUNC.05-08,INTF.03.001,LP.01-02 |
| FL.FUNC.APB_CDC_BRIDGE.06 | reset_behavior | 独立复位/中止/无 stale | must | LRS.FUNC.09.001,INTF.03.002 |
| FL.INTF.APB_CDC_BRIDGE.01 | apb_interface | APB3/APB4 接口与 PSTRB/PPROT | must | LRS.INTF.01-02 |
| FL.CONS.APB_CDC_BRIDGE.01 | config_validation | 配置校验/CDC 静态 | must | LRS.CONS.01.001,02.001 |

## 需求覆盖声明

| 需求类别 | 覆盖 |
|----------|------|
| must 需求 | 全部通过 FEATURE 覆盖 |
| should 需求 | FIFO（FL.04）覆盖 |
| LP/PERF/DFX | 通过对应 testcase 间接覆盖（见 test_matrix） |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 06-verification-plan*
