# APB CDC Bridge — 接口需求（INTF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 接口需求 / Interface Requirements

### 1.1 上游 APB 从接口

#### LRS.INTF.APB_CDC_BRIDGE.01.001 上游 APB 接口提供

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.01.001
category: INTF
feature: upstream_apb_interface
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 应提供一个上游 APB Slave 接口，包含：`s_pclk`、`s_presetn`、`s_psel`、`s_penable`、`s_paddr`、`s_pwrite`、`s_pwdata`、`s_prdata`、`s_pready`、`s_pslverr`。
2. 上游接口为单 PSEL 从端口，不接受多 Slave Select。
3. 地址位宽由 `ADDR_WIDTH` 参数决定，数据位宽由 `DATA_WIDTH` 参数决定。

##### 验证关注点

1. 上游接口信号完整且与 APB 协议一致。
2. 不同 `ADDR_WIDTH`/`DATA_WIDTH` 配置下位宽正确。

---

#### LRS.INTF.APB_CDC_BRIDGE.01.002 APB4 扩展字段

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.01.002
category: INTF
feature: upstream_apb_interface
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `APB_PROFILE = APB4` 时，上游接口应额外提供 `s_pstrb`、`s_pprot`。
2. 当 `APB_PROFILE = APB3` 时，`PSTRB`/`PPROT` 相关逻辑应裁剪，不保留无意义数据通路。

##### 验证关注点

1. APB4 配置下 PSTRB/PPROT 正确跨域并重新生成。
2. APB3 配置下无相关逻辑残留（综合/面积证据）。

---

### 1.2 下游 APB 主接口

#### LRS.INTF.APB_CDC_BRIDGE.02.001 下游 APB 接口提供

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.02.001
category: INTF
feature: downstream_apb_interface
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 应提供一个下游 APB Master 接口，包含：`m_pclk`、`m_presetn`、`m_psel`、`m_penable`、`m_paddr`、`m_pwrite`、`m_pwdata`、`m_prdata`、`m_pready`、`m_pslverr`。
2. 下游接口为单 PSEL 主端口。
3. 下游接口在 IDLE 时 `m_psel = 0`、`m_penable = 0`，输出保持稳定。

##### 验证关注点

1. 下游接口信号完整且符合 APB Master 时序。
2. IDLE 期间输出稳定，无无意义翻转。

---

#### LRS.INTF.APB_CDC_BRIDGE.02.002 APB4 下游扩展字段

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.02.002
category: INTF
feature: downstream_apb_interface
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `APB_PROFILE = APB4` 时，下游接口应额外提供 `m_pstrb`、`m_pprot`。
2. 下游 `PSTRB`/`PPROT` 应与上游捕获的 payload 一致。

##### 验证关注点

1. PSTRB/PPROT 从上游到下游保真传输。

---

### 1.3 时钟与复位

#### LRS.INTF.APB_CDC_BRIDGE.03.001 双独立时钟域

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.03.001
category: INTF
feature: clock_reset
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 应支持 `s_pclk` 与 `m_pclk` 两个独立的时钟域输入。
2. 两个时钟可完全异步（无固定频率/相位关系），可快→慢、慢→快、同频异相、同源同步异频。
3. 不得对两时钟的频率比、相位、启动顺序做任何假设（ASYNC_SAFE 默认模式）。

##### 验证关注点

1. 各种时钟关系组合下事务正确完成。
2. 完全异步时钟（频率接近/相位漂移）下无亚稳态传播错误。

---

#### LRS.INTF.APB_CDC_BRIDGE.03.002 独立复位

<!-- LRS_META
id: LRS.INTF.APB_CDC_BRIDGE.03.002
category: INTF
feature: clock_reset
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 应支持独立复位 `s_presetn`、`m_presetn`，可在任意一侧独立 assert。
2. 复位风格推荐 async assert / sync deassert（`RESET_MODE = ASYNC`）。
3. 任一侧 reset 发生时，跨域进行中的事务可被 abort；reset 后不得把 reset 前的
   request/response toggle、payload、FIFO entry 识别为新事务。
4. 不得要求 source reset 先于 destination reset 的固定顺序。

##### 验证关注点

1. 单侧复位/双侧复位/复位期间事务场景。
2. 复位释放后无伪 request/response（No Stale Transfer）。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
