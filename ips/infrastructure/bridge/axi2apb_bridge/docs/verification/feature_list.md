# X2P 功能列表 / Feature List

> 本文档是 [verification_plan.md](verification_plan.md) 的详细展开（第 6 章）。

---

## Feature 列表

| Feature ID | 名称 | 优先级 | 关联 LRS |
|---|---|---|---|
| FL.INTF.X2P.01 | AXI Slave 接口 | must | LRS.INTF.X2P.01.* |
| FL.INTF.X2P.02 | APB Master 接口 | must | LRS.INTF.X2P.02.* |
| FL.INTF.X2P.03 | 时钟复位 | must | LRS.INTF.X2P.03.* |
| FL.FUNC.X2P.01 | AW/W 关联 | must | LRS.FUNC.X2P.01.* |
| FL.FUNC.X2P.02 | Burst 转换 | must | LRS.FUNC.X2P.02.* |
| FL.FUNC.X2P.03 | Narrow/Width 转换 | must | LRS.FUNC.X2P.03.* |
| FL.FUNC.X2P.04 | Request Buffer | must | LRS.FUNC.X2P.04.* |
| FL.FUNC.X2P.05 | 仲裁 | must | LRS.FUNC.X2P.05.* |
| FL.FUNC.X2P.06 | 响应/错误 | must | LRS.FUNC.X2P.06.* |
| FL.FUNC.X2P.07 | APB Timeout | must | LRS.FUNC.X2P.07.* |
| FL.FUNC.X2P.08 | APB 事务 | must | LRS.FUNC.X2P.08.* |
| FL.FUNC.X2P.09 | Regslice/Ordering | must | LRS.FUNC.X2P.09.* |
| FL.FUNC.X2P.10 | CDC/Async | must | LRS.FUNC.X2P.10.* |
| FL.PERF.X2P.01 | 性能 | should | LRS.PERF.X2P.01.* |
| FL.PERF.X2P.02 | 资源裁剪 | should | LRS.PERF.X2P.02.* |
| FL.CONS.X2P.01 | 约束 | must | LRS.CONS.X2P.* |

---

## Feature 定义（FEATURE_META）

### FL.INTF.X2P.01 AXI Slave 接口

<!-- FEATURE_META
id: FL.INTF.X2P.01
name: AXI Slave Interface
priority: must
category: INTF
req_ref:
  - LRS.INTF.X2P.01.001
  - LRS.INTF.X2P.01.002
END_FEATURE_META -->

### FL.INTF.X2P.02 APB Master 接口

<!-- FEATURE_META
id: FL.INTF.X2P.02
name: APB Master Interface
priority: must
category: INTF
req_ref:
  - LRS.INTF.X2P.02.001
  - LRS.INTF.X2P.02.002
END_FEATURE_META -->

### FL.INTF.X2P.03 时钟复位

<!-- FEATURE_META
id: FL.INTF.X2P.03
name: Clock and Reset
priority: must
category: INTF
req_ref:
  - LRS.INTF.X2P.03.001
  - LRS.INTF.X2P.03.002
END_FEATURE_META -->

### FL.FUNC.X2P.01 AW/W 关联

<!-- FEATURE_META
id: FL.FUNC.X2P.01
name: AW/W Association
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.01.001
  - LRS.FUNC.X2P.01.002
END_FEATURE_META -->

### FL.FUNC.X2P.02 Burst 转换

<!-- FEATURE_META
id: FL.FUNC.X2P.02
name: Burst Conversion
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.02.001
  - LRS.FUNC.X2P.02.002
  - LRS.FUNC.X2P.02.003
  - LRS.FUNC.X2P.02.004
END_FEATURE_META -->

### FL.FUNC.X2P.03 Narrow/Width 转换

<!-- FEATURE_META
id: FL.FUNC.X2P.03
name: Narrow / Width Conversion
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.03.001
  - LRS.FUNC.X2P.03.002
  - LRS.FUNC.X2P.03.003
  - LRS.FUNC.X2P.03.004
  - LRS.FUNC.X2P.03.005
  - LRS.FUNC.X2P.03.006
END_FEATURE_META -->

### FL.FUNC.X2P.04 Request Buffer

<!-- FEATURE_META
id: FL.FUNC.X2P.04
name: Request Buffering / Outstanding
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.04.001
  - LRS.FUNC.X2P.04.002
END_FEATURE_META -->

### FL.FUNC.X2P.05 仲裁

<!-- FEATURE_META
id: FL.FUNC.X2P.05
name: Read/Write Arbitration
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.05.001
  - LRS.FUNC.X2P.05.002
END_FEATURE_META -->

### FL.FUNC.X2P.06 响应/错误

<!-- FEATURE_META
id: FL.FUNC.X2P.06
name: Response and Error
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.06.001
  - LRS.FUNC.X2P.06.002
  - LRS.FUNC.X2P.06.003
  - LRS.FUNC.X2P.06.004
  - LRS.FUNC.X2P.06.005
END_FEATURE_META -->

### FL.FUNC.X2P.07 APB Timeout

<!-- FEATURE_META
id: FL.FUNC.X2P.07
name: APB Timeout
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.07.001
END_FEATURE_META -->

### FL.FUNC.X2P.08 APB 事务

<!-- FEATURE_META
id: FL.FUNC.X2P.08
name: APB Transaction / Wait-State
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.08.001
  - LRS.FUNC.X2P.08.002
END_FEATURE_META -->

### FL.FUNC.X2P.09 Regslice/Ordering

<!-- FEATURE_META
id: FL.FUNC.X2P.09
name: Register Stage / Ordering
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.09.001
  - LRS.FUNC.X2P.09.002
END_FEATURE_META -->

### FL.FUNC.X2P.10 CDC/Async

<!-- FEATURE_META
id: FL.FUNC.X2P.10
name: CDC / Async Clock
priority: must
category: FUNC
req_ref:
  - LRS.FUNC.X2P.10.001
  - LRS.FUNC.X2P.10.002
  - LRS.FUNC.X2P.10.003
END_FEATURE_META -->

### FL.PERF.X2P.01 性能

<!-- FEATURE_META
id: FL.PERF.X2P.01
name: Performance
priority: should
category: PERF
req_ref:
  - LRS.PERF.X2P.01.001
  - LRS.PERF.X2P.01.002
  - LRS.PERF.X2P.02.001
  - LRS.PERF.X2P.03.001
END_FEATURE_META -->

### FL.CONS.X2P.01 约束

<!-- FEATURE_META
id: FL.CONS.X2P.01
name: Constraints
priority: must
category: CONS
req_ref:
  - LRS.CONS.X2P.01.001
  - LRS.CONS.X2P.02.001
  - LRS.CONS.X2P.03.001
END_FEATURE_META -->