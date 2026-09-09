# APB CDC Bridge — 约束需求（CONS）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 约束需求 / Constraint Requirements

### 1.1 配置校验

#### LRS.CONS.APB_CDC_BRIDGE.01.001 非法配置检测

<!-- LRS_META
id: LRS.CONS.APB_CDC_BRIDGE.01.001
category: CONS
feature: config_validation
priority: P0
verify_method: test
status: active
END_LRS_META -->

##### 需求描述

1. 至少检测并拒绝以下非法配置：`ADDR_WIDTH <= 0`、`DATA_WIDTH <= 0`、`DATA_WIDTH % 8 != 0`、`SYNC_STAGES < 2`（async mode）、unsupported `CDC_IMPL`、illegal FIFO depth、unsupported APB profile。
2. 非法配置通过编译期 assertion 或 FuseSoC 参数校验报错。

##### 验证关注点

1. 非法参数导致编译/elaboration 失败（assert）。
2. 合法参数范围全部通过。

---

### 1.2 CDC 静态约束

#### LRS.CONS.APB_CDC_BRIDGE.02.001 CDC 静态检查

<!-- LRS_META
id: LRS.CONS.APB_CDC_BRIDGE.02.001
category: CONS
feature: cdc_static
priority: P0
verify_method: formal
status: active
END_LRS_META -->

##### 需求描述

1. 必须通过 CDC signoff，至少检查：synchronizer、bundled data、control crossing、reset crossing、reconvergence、combinational CDC、multi-bit CDC。
2. 禁止同一个控制事件经多个独立 synchronizer crossing 后在另一侧直接 reconverge。
3. 严格禁止 `m_pready` combinational → `s_pready` 等跨时钟域组合路径。

##### 验证关注点

1. SpyGlass CDC 检查通过。
2. 无 combinational CDC 路径。

---

### 1.3 接口连接约束

#### LRS.CONS.APB_CDC_BRIDGE.03.001 集成约束

<!-- LRS_META
id: LRS.CONS.APB_CDC_BRIDGE.03.001
category: CONS
feature: integration_constraints
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 上游 APB Initiator 与下游 APB Target 的地址空间应分别由外部互连保证。
2. 两时钟域的 reset 释放必须各自同步（async assert / sync deassert）。
3. 系统需保证必要时能唤醒被 gate 的 clock。

##### 验证关注点

1. 集成文档说明约束。
2. reset synchronizer 配置。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
