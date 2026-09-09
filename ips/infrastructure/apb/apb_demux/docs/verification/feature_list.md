# APB Demux 功能列表

本文档是 `verification_plan.md` 第 6 章的详细展开。

## 功能元数据

<!-- FEATURE_META
id: FL.INTF.APB_DEMUX.01
name: apb_interface
description: 上游/下游 APB 接口、APB3/APB4 profile、单时钟与复位接口
priority: P0
req_ref: [LRS.INTF.APB_DEMUX.01.001, LRS.INTF.APB_DEMUX.01.002, LRS.INTF.APB_DEMUX.02.001, LRS.INTF.APB_DEMUX.02.002, LRS.INTF.APB_DEMUX.03.001, LRS.INTF.APB_DEMUX.03.002, LRS.CFG.APB_DEMUX.04.001]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.CFG.APB_DEMUX.01
name: parameters
description: 核心参数、地址映射数组、配置合法性校验、参数化复用
priority: P0
req_ref: [LRS.CFG.APB_DEMUX.01.001, LRS.CFG.APB_DEMUX.01.002, LRS.CFG.APB_DEMUX.01.003, LRS.CFG.APB_DEMUX.02.001, LRS.CFG.APB_DEMUX.02.002, LRS.CONS.APB_DEMUX.01.001, LRS.CONS.APB_DEMUX.01.002, LRS.CONS.APB_DEMUX.01.003, LRS.CONS.APB_DEMUX.01.004, LRS.CONS.APB_DEMUX.01.005, LRS.CONS.APB_DEMUX.01.006, LRS.CONS.APB_DEMUX.02.001, LRS.CONS.APB_DEMUX.02.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.01
name: address_decode
description: 地址译码正确性、单端口命中、对齐优化
priority: P0
req_ref: [LRS.FUNC.APB_DEMUX.01.001, LRS.FUNC.APB_DEMUX.01.002, LRS.FUNC.APB_DEMUX.01.003, LRS.FUNC.APB_DEMUX.01.004, LRS.FUNC.APB_DEMUX.01.005]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.02
name: request_routing
description: 请求信号广播、PSEL 命中门控、PENABLE 时序合规
priority: P0
req_ref: [LRS.FUNC.APB_DEMUX.02.001, LRS.FUNC.APB_DEMUX.02.002, LRS.FUNC.APB_DEMUX.02.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.03
name: transaction_behavior
description: APB 事务语义保持、wait-state 保持、低延迟
priority: P0
req_ref: [LRS.FUNC.APB_DEMUX.03.001, LRS.FUNC.APB_DEMUX.03.002, LRS.PERF.APB_DEMUX.01.001]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.04
name: response_routing
description: 响应 mux、未选中屏蔽、PSLVERR 透传
priority: P0
req_ref: [LRS.FUNC.APB_DEMUX.04.001, LRS.FUNC.APB_DEMUX.04.002]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.05
name: decode_error
description: Decode Miss 检测、错误响应、不挂死
priority: P0
req_ref: [LRS.FUNC.APB_DEMUX.05.001, LRS.FUNC.APB_DEMUX.05.002, LRS.FUNC.APB_DEMUX.05.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.06
name: remap
description: 地址重映射开关与静态偏移
priority: P1
req_ref: [LRS.FUNC.APB_DEMUX.06.001, LRS.FUNC.APB_DEMUX.06.002, LRS.CFG.APB_DEMUX.03.001]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.07
name: timeout
description: transaction timeout 终止与计数条件
priority: P1
req_ref: [LRS.FUNC.APB_DEMUX.07.001, LRS.FUNC.APB_DEMUX.07.002, LRS.CFG.APB_DEMUX.03.002, LRS.CFG.APB_DEMUX.03.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.FUNC.APB_DEMUX.08
name: response_register
description: 响应寄存器插入与协议合规
priority: P1
req_ref: [LRS.FUNC.APB_DEMUX.08.001, LRS.FUNC.APB_DEMUX.08.002, LRS.CFG.APB_DEMUX.03.004]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.RESET.APB_DEMUX.01
name: reset_behavior
description: PRESETn 复位、复位期间无有效事务、内部状态确定复位
priority: P0
req_ref: [LRS.RESET.APB_DEMUX.01.001, LRS.RESET.APB_DEMUX.02.001, LRS.RESET.APB_DEMUX.02.002, LRS.RESET.APB_DEMUX.02.003]
END_FEATURE_META -->

<!-- FEATURE_META
id: FL.DFX.APB_DEMUX.01
name: protocol_assertions
description: onehot0、wait 稳定、decode 正确性、decode miss 响应断言；PPA 与规模
priority: P0
req_ref: [LRS.DFX.APB_DEMUX.01.001, LRS.DFX.APB_DEMUX.01.002, LRS.DFX.APB_DEMUX.01.003, LRS.PERF.APB_DEMUX.02.001, LRS.PERF.APB_DEMUX.03.001]
END_FEATURE_META -->

## 功能列表

| ID | 功能 | 描述 | 优先级 | 需求引用 |
|----|------|------|--------|----------|
| FL.INTF.APB_DEMUX.01 | apb_interface | 上游/下游 APB 接口、profile、时钟复位 | P0 | INTF.01-03, CFG.04.001 |
| FL.CFG.APB_DEMUX.01 | parameters | 参数/地址映射/配置校验/参数化复用 | P0 | CFG.01-02, CONS.01-02 |
| FL.FUNC.APB_DEMUX.01 | address_decode | 地址译码正确性/单命中/对齐 | P0 | FUNC.01.001-005 |
| FL.FUNC.APB_DEMUX.02 | request_routing | 广播/PSEL 门控/PENABLE 时序 | P0 | FUNC.02.001-003 |
| FL.FUNC.APB_DEMUX.03 | transaction_behavior | 语义保持/wait-state/低延迟 | P0 | FUNC.03.001-002, PERF.01.001 |
| FL.FUNC.APB_DEMUX.04 | response_routing | mux/屏蔽/PSLVERR 透传 | P0 | FUNC.04.001-002 |
| FL.FUNC.APB_DEMUX.05 | decode_error | Decode Miss 检测/响应/不挂死 | P0 | FUNC.05.001-003 |
| FL.FUNC.APB_DEMUX.06 | remap | 地址重映射 | P1 | FUNC.06.001-002, CFG.03.001 |
| FL.FUNC.APB_DEMUX.07 | timeout | 超时终止 | P1 | FUNC.07.001-002, CFG.03.002-003 |
| FL.FUNC.APB_DEMUX.08 | response_register | 响应寄存器 | P1 | FUNC.08.001-002, CFG.03.004 |
| FL.RESET.APB_DEMUX.01 | reset_behavior | 复位行为 | P0 | RESET.01.001, 02.001-003 |
| FL.DFX.APB_DEMUX.01 | protocol_assertions | 断言 + PPA + 规模 | P0 | DFX.01.001-003, PERF.02-03 |

## 需求覆盖声明

| 需求类别 | 覆盖 |
|----------|------|
| must 需求（P0） | 全部通过 FEATURE 覆盖（testcase 或 assertion 承接） |
| should 需求（P1） | remap/timeout/response_register 通过对应 FEATURE 覆盖 |
| CONS 配置校验 | 通过 FL.CFG + 配置校验脚本（param_sweep testcase）覆盖 |

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 06-verification-plan*
