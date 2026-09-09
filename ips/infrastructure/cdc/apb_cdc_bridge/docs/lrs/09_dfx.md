# APB CDC Bridge — 可测性/可观测需求（DFX）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 可测性/可观测需求 / DFX Requirements

### 1.1 协议断言

#### LRS.DFX.APB_CDC_BRIDGE.01.001 协议断言提供

<!-- LRS_META
id: LRS.DFX.APB_CDC_BRIDGE.01.001
category: DFX
feature: assertions
priority: P1
verify_method: formal
status: active
END_LRS_META -->

##### 需求描述

1. 至少提供以下断言：one upstream transfer → at most one downstream transfer；
   one downstream completion → at most one upstream completion；request payload
   stable during CDC；response payload stable during CDC；no downstream APB protocol
   violation；no transaction while destination reset；no spurious PREADY；no spurious PSLVERR。
2. 断言放在 `verification/` 下，DUT 行为不得依赖断言。

##### 验证关注点

1. 断言全部有效且仿真/formal 通过。
2. 断言不改变 DUT 行为。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
