# 00. 文档概述、需求概述、架构目标 `[必填]`

---

## 1. 文档概述

本文档描述 X2P（AXI-to-APB Bridge）的高层架构设计（HLD），作为 LLD 与 RTL 实现的架构输入。

## 2. 需求概述

X2P 需求基线为 `model/requirements.yaml`（42 条需求，G0 Freeze）：

| 类别 | 数量 |
|---|---|
| INTF | 6 |
| FUNC | 29 |
| PERF | 4 |
| CONS | 3 |
| **总计** | **42** |

核心能力：AXI4/AXI4-Lite → APB3/APB4 协议转换、Burst 拆解（INCR/FIXED/WRAP）、
Narrow Transfer、Width Conversion、Write Strobe、Request Buffering、R/W 仲裁、
APB Wait-State/Timeout、SYNC/ASYNC 时钟模式、输出流水、错误传播与 Protection Attribute。

## 3. 架构目标

| 目标 | 说明 |
|---|---|
| 协议边界清晰 | AXI Frontend 与 APB Backend 通过内部 Transaction Request/Response 接口解耦 |
| 组合灵活 | SYNC/ASYNC、buffer depth、width conversion、timeout 可独立组合 |
| CDC 最小化 | Width Conversion 在 CDC 之前完成，跨域只传 APB-sized request |
| 仲裁公平 | R/W 仲裁支持 RR/Read-Pri/Write-Pri，Beat 粒度且不切分 AXI Beat 内 sub-transfer |
| PPA 可裁 | 参数关闭功能 generate-out，不保留无用逻辑 |
| 可验证 | 全流程追踪 LRS→HLD→LLD→RTL→TC |