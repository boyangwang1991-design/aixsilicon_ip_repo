# 04. 时钟复位与性能设计 `[条件必填]`

> 对应原章节：10. 时钟、复位与低功耗设计、12. 性能与容量设计

---

## 10. 时钟、复位与低功耗设计

### 10.1 时钟架构

| 时钟名称 | 来源 | 频率 | 使用模块 | 是否可门控 | 对应 LRS |
|---|---|---|---|---|---|
| clk_axi | SoC Clock Controller | - | FE/QB/SCH/TE/RSP | 否 | LRS.INTF.X2P.03.001 |
| clk_apb | SoC Clock Controller | - | CDC/APB | 否 | LRS.INTF.X2P.03.001 |

#### 10.1.1 AXI 时钟域 - clk_axi

AXI 域时钟，驱动 AXI Frontend、队列、调度器、Transfer Engine、Response Engine。

<!-- HLD_CLK_META
id: HLD.DOM.X2P.CLK_AXI
name: clk_axi
type: clock
description: AXI 时钟域（AXI Frontend/队列/调度/Transfer Engine/Response）
frequency: "parameterized (SYNC: equal to clk_apb; ASYNC: independent)"
active_level: null
source: soc_clk_ctrl
affected_modules:
  - HLD.MOD.L1.X2P.FE
  - HLD.MOD.L1.X2P.QB
  - HLD.MOD.L1.X2P.SCH
  - HLD.MOD.L1.X2P.TE
  - HLD.MOD.L1.X2P.RSP
req_ref:
  - LRS.INTF.X2P.03.001
END_HLD_CLK_META -->

#### 10.1.2 APB 时钟域 - clk_apb

APB 域时钟，驱动 APB Engine（ASYNC 模式独立）。

<!-- HLD_CLK_META
id: HLD.DOM.X2P.CLK_APB
name: clk_apb
type: clock
description: APB 时钟域（APB Engine）
frequency: "parameterized (SYNC: equal to clk_axi; ASYNC: independent)"
active_level: null
source: soc_clk_ctrl
affected_modules:
  - HLD.MOD.L1.X2P.APB
req_ref:
  - LRS.INTF.X2P.03.001
END_HLD_CLK_META -->

### 10.2 复位架构

| 复位名称 | 类型 | 有效电平 | 同步方式 | 影响范围 | 对应 LRS |
|---|---|---|---|---|---|
| rst_axi_n | 异步 assert，同步 release | Low | Reset Sync | AXI 域模块 | LRS.INTF.X2P.03.002 |
| rst_apb_n | 异步 assert，同步 release | Low | Reset Sync | APB 域模块 | LRS.INTF.X2P.03.002 |

#### 10.2.1 AXI 复位域 - rst_axi_n

<!-- HLD_CLK_META
id: HLD.DOM.X2P.RST_AXI
name: rst_axi_n
type: reset
description: AXI 复位域（异步 assert，同步 release）
frequency: null
active_level: low
source: soc_rst_ctrl
affected_modules:
  - HLD.MOD.L1.X2P.FE
  - HLD.MOD.L1.X2P.QB
  - HLD.MOD.L1.X2P.SCH
  - HLD.MOD.L1.X2P.TE
  - HLD.MOD.L1.X2P.RSP
req_ref:
  - LRS.INTF.X2P.03.002
  - LRS.FUNC.X2P.10.003
END_HLD_CLK_META -->

#### 10.2.2 APB 复位域 - rst_apb_n

<!-- HLD_CLK_META
id: HLD.DOM.X2P.RST_APB
name: rst_apb_n
type: reset
description: APB 复位域（ASYNC 模式独立复位）
frequency: null
active_level: low
source: soc_rst_ctrl
affected_modules:
  - HLD.MOD.L1.X2P.APB
req_ref:
  - LRS.INTF.X2P.03.002
  - LRS.FUNC.X2P.10.003
END_HLD_CLK_META -->

### 10.3 CDC / RDC 设计

> ASYNC 模式下存在两条 CDC 路径（请求/响应），均在 Transaction Level 完成。

| 跨域路径 | 源时钟域 | 目标时钟域 | 信号类型 | 同步方式 | 风险等级 | 对应 LRS |
|---|---|---|---|---|---|---|
| req_cdc | clk_axi | clk_apb | bus | async_fifo | High | LRS.FUNC.X2P.10.001 |
| rsp_cdc | clk_apb | clk_axi | bus | async_fifo | High | LRS.FUNC.X2P.10.001 |

#### 10.3.1 APB 请求跨域路径 - req_cdc

<!-- HLD_CDC_META
id: HLD.CDC.X2P.REQ_CDC
name: req_cdc
source_clock: clk_axi
target_clock: clk_apb
signal_type: bus
sync_method: async_fifo
req_ref:
  - LRS.FUNC.X2P.10.001
  - LRS.FUNC.X2P.10.002
END_HLD_CDC_META -->

#### 10.3.2 APB 响应跨域路径 - rsp_cdc

<!-- HLD_CDC_META
id: HLD.CDC.X2P.RSP_CDC
name: rsp_cdc
source_clock: clk_apb
target_clock: clk_axi
signal_type: bus
sync_method: async_fifo
req_ref:
  - LRS.FUNC.X2P.10.001
  - LRS.FUNC.X2P.10.002
END_HLD_CDC_META -->

### 10.4 低功耗设计

> 通过参数化裁剪实现（功能 generate-out），无独立电源域/低功耗状态机。

---

## 12. 性能与容量设计

### 12.1 性能需求映射

| 性能指标 | 目标值 | 设计保证方式 | 对应 LRS |
|---|---|---|---|
| APB 无多余 idle | PREADY=1 时无 bubble | APB Engine 背靠背 | LRS.PERF.X2P.01.001 |
| Request Buffer 深度 | 1/2/4/8 | 读写队列参数化 | LRS.PERF.X2P.01.002 |
| 宽度组合 | 32/64/128 AXI · 32/64 APB | Width Engine 参数化 | LRS.PERF.X2P.03.001 |

### 12.2 关键路径分析

| 路径 | 潜在瓶颈 | 架构缓解措施 | 后续 LLD 关注点 |
|---|---|---|---|
| AWVALID/ARVALID → queue full → READY | 队列满信号组合 | 预计算队列计数 | 时序约束 |
| queue state → arbiter → request select | 仲裁链 | 两级仲裁/优先级编码 | timing closure |
| addr+size+subbeat → lane mux → PWDATA/PSTRB | 宽度转换组合 | 拆分 mux 结构 | 时序约束 |
| PRDATA/PREADY → response | 响应链 | ASYNC 天然切断跨域路径 | CDC 验证 |

### 12.3 参数化配置

| 参数名称 | 默认值 | 可选范围 | 影响模块 | 对应 LRS |
|---|---|---|---|---|
| AXI_PROFILE | AXI4 | AXI4/AXI4_LITE | FE/QB/RSP | LRS.CONS.X2P.02.001 |
| APB_PROFILE | APB4 | APB3/APB4 | TE/APB | LRS.CONS.X2P.02.001 |
| AXI_DATA_WIDTH | 64 | 32/64/128 | TE | LRS.PERF.X2P.03.001 |
| APB_DATA_WIDTH | 32 | 32/64 | TE | LRS.PERF.X2P.03.001 |
| READ/WRITE_REQUEST_DEPTH | 4 | 1/2/4/8 | QB | LRS.FUNC.X2P.04.001 |
| ARB_POLICY | ROUND_ROBIN | 3 策略 | SCH | LRS.FUNC.X2P.05.001 |
| ARB_GRANULARITY | BEAT | BEAT/TRANSACTION | SCH | LRS.FUNC.X2P.05.002 |
| TIMEOUT_ENABLE/CYCLES | 1/256 | 0/1 · ≥1 | APB | LRS.FUNC.X2P.07.001 |
| CLOCK_MODE | SYNC | SYNC/ASYNC | CDC | LRS.INTF.X2P.03.001 |
| CDC_REQ/RSP_DEPTH | 4 | 参数化 | CDC | LRS.FUNC.X2P.10.002 |
| AXI_INPUT/OUTPUT_REG | 0/0 | 0/1 | FE/RSP | LRS.FUNC.X2P.09.001 |
| APB_OUTPUT_REG | 1 | 0/1 | APB | LRS.FUNC.X2P.09.001 |