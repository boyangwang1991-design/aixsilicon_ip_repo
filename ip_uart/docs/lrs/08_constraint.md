# 约束需求 - UART (uart)
# Constraint Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 约束定义参考 OpenTitan UART `doc/theory_of_operation.md`（波特率 NCO 约束、FIFO 深度约束）与 `data/uart.hjson`。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **CONS**：约束需求（接口连接约束、时钟复位约束、波特率 NCO 约束、FIFO 深度约束、不支持场景等）

---

## 1. 约束需求 / Constraint Requirements

### 1.1 时钟与复位约束 / Clock & Reset Constraints

#### LRS.CONS.UART.01.001 时钟复位约束

<!-- LRS_META
id: LRS.CONS.UART.01.001
category: CONS
ip: UART
feature: clock_reset_constraint
priority: P0
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 模块应在单一时钟域 `clk_i` 下工作，复位 `rst_ni` 低有效异步复位。
2. 所有寄存器与状态机应同步于 `clk_i` 上升沿。
3. 复位释放时序应符合异步复位同步释放要求，避免亚稳态。

##### 验证关注点

1. 时钟/复位连接满足约束。
2. 复位释放后无亚稳态风险。

---

### 1.2 接口连接约束 / Interface Connection Constraints

#### LRS.CONS.UART.01.002 接口连接约束

<!-- LRS_META
id: LRS.CONS.UART.01.002
category: CONS
ip: UART
feature: interface_connection
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. TL-UL 接入方式下，`tl_i`/`tl_o` 应连接 TL-UL 主机总线；APB 接入方式下，UART 核心应通过 `apb2tlul` wrapper 连接 APB 主机。
2. 两种接入方式不应同时使能（通过 FuseSoC `.core` target 隔离）。
3. `cio_tx_en_o` 恒为 1，用于 TX 输出使能；外部应正确连接。

##### 验证关注点

1. 两种 target（tlul/apb）分别正确连接。
2. 未选择的接口不干扰工作。

---

### 1.3 波特率 NCO 约束 / Baud Rate NCO Constraints

#### LRS.CONS.UART.01.003 波特率配置约束

<!-- LRS_META
id: LRS.CONS.UART.01.003
category: CONS
ip: UART
feature: baud_rate_constraint
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 NCO 计算值 < 40 时（即 `baud < (40 × f_pclk) / 2^20` 或 `f_pclk > (2^20 × baud)/40`），波特率误差可能不可接受，需要检查并可能取整。
2. 建议对 NCO 结果四舍五入到最近整数以减小误差。
3. 系统时钟越高，低波特率（如 9600 及以下）需特别注意 NCO 取整误差（参考 theory_of_operation 各频率边界）。

##### 验证关注点

1. 低波特率 + 高系统时钟场景下误差在容限内。
2. NCO 取整策略正确。

---

### 1.4 FIFO 深度约束 / FIFO Depth Constraints

#### LRS.CONS.UART.01.004 FIFO 深度上限

<!-- LRS_META
id: LRS.CONS.UART.01.004
category: CONS
ip: UART
feature: fifo_depth_constraint
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. TX/RX FIFO 深度参数必须 < 256（设计不支持更深 FIFO，`ASSERT_INIT` 约束）。
2. 修改 FIFO 深度时需同步调整 watermark 相关 CSR 布局与文档。

##### 验证关注点

1. 深度参数符合 < 256 约束。
2. 深度与 watermark 配置一致。

---

### 1.5 软件约束 / Software Constraints

#### LRS.CONS.UART.01.005 初始化与软件顺序约束

<!-- LRS_META
id: LRS.CONS.UART.01.005
category: CONS
ip: UART
feature: software_constraint
priority: P2
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 使用前软件应配置 `CTRL.NCO` 设定波特率，并按需配置 `CTRL`（TX/RX/奇偶/回环等）、`FIFO_CTRL`（水位）与 `TIMEOUT_CTRL`。
2. `WDATA`/`OVRD` 写入会影响其他 CSR 状态，需按软件指南顺序访问。
3. RX 未在 pinmux 选中时 RX 引脚被驱动为 0 会导致 RX 状态非默认值，软件需知悉。

##### 验证关注点

1. 初始化顺序正确后功能正常。
2. 非法访问顺序不造成挂死。

---

### 1.6 不支持场景 / Unsupported Scenarios

#### LRS.CONS.UART.01.006 不支持场景说明

<!-- LRS_META
id: LRS.CONS.UART.01.006
category: CONS
ip: UART
feature: unsupported_scenarios
priority: P2
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 本模块不支持数据位宽非 8 位（固定 8 位，`uart.hjson` 说明）。
2. 本模块不支持硬件流控（RTS/CTS），流量控制仅可软件握手实现。
3. RACL 功能默认关闭（`EnableRacl=0`），如启用需额外集成 RACL 控制器。

##### 验证关注点

1. 上述不支持场景不产生错误行为。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
