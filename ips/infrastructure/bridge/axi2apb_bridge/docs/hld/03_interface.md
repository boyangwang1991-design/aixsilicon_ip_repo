# 03. 接口与寄存器架构设计 `[必填]`

> 对应原章节：6. 接口架构设计、7. 寄存器架构设计

---

## 6. 接口架构设计

### 6.1 接口概览

| 接口名称 | 接口类型 | 方向 | 位宽 | 时钟域 | 说明 | 对应 LRS |
|---|---|---|---|---|---|---|
| axi_slave_if | AXI4 / AXI4-Lite | Input | N | clk_axi | AXI 从接口 | LRS.INTF.X2P.01.001 |
| apb_master_if | APB3 / APB4 | Output | N | clk_apb | APB 主接口 | LRS.INTF.X2P.02.001 |
| clk_axi | Clock | Input | 1 | - | AXI 时钟 | LRS.CONS.X2P.* |
| clk_apb | Clock | Input | 1 | - | APB 时钟 | LRS.CONS.X2P.* |
| rst_axi_n | Reset | Input | 1 | - | AXI 复位（低有效） | LRS.CONS.X2P.* |
| rst_apb_n | Reset | Input | 1 | - | APB 复位（低有效，ASYNC） | LRS.CONS.X2P.* |

#### 6.1.1 AXI 从接口 - axi_slave_if

AXI Slave 接口支持 AXI4 / AXI4-Lite，位宽由参数决定。HLD 仅描述接口组。

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.AXI_SLAVE
name: axi_slave_if
type: AXI
direction: slave
description: AXI4 / AXI4-Lite 从接口（AW/W/B/AR/R 五通道，含地址/ID/数据/保护属性/LAST/STRB）
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: "AXI 侧解耦于 APB 执行"
req_ref:
  - LRS.INTF.X2P.01.001
  - LRS.INTF.X2P.01.002
  - LRS.FUNC.X2P.01.001
END_HLD_IF_META -->

#### 6.1.2 APB 主接口 - apb_master_if

APB Master 接口输出单一 PSEL，APB4 额外含 PSTRB/PPROT。

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.APB_MASTER
name: apb_master_if
type: APB
direction: master
description: APB3/APB4 主接口（PADDR/PSEL/PENABLE/PWRITE/PWDATA/PRDATA/PREADY/PSLVERR，APB4 含 PSTRB/PPROT）
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: "APB 每次单 transfer"
req_ref:
  - LRS.INTF.X2P.02.001
  - LRS.INTF.X2P.02.002
  - LRS.FUNC.X2P.08.001
END_HLD_IF_META -->

#### 6.1.3 AXI 时钟输入 - clk_axi

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.CLK_AXI
name: clk_axi
type: Clock
direction: input
description: AXI 域时钟
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: null
req_ref:
  - LRS.INTF.X2P.03.001
END_HLD_IF_META -->

#### 6.1.4 APB 时钟输入 - clk_apb

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.CLK_APB
name: clk_apb
type: Clock
direction: input
description: APB 域时钟
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: null
req_ref:
  - LRS.INTF.X2P.03.001
END_HLD_IF_META -->

#### 6.1.5 AXI 复位输入 - rst_axi_n

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.RST_AXI
name: rst_axi_n
type: Reset
direction: input
description: AXI 域低有效复位
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: null
req_ref:
  - LRS.INTF.X2P.03.002
END_HLD_IF_META -->

#### 6.1.6 APB 复位输入 - rst_apb_n

<!-- HLD_IF_META
id: HLD.IF.EXT.X2P.RST_APB
name: rst_apb_n
type: Reset
direction: input
description: APB 域低有效复位（ASYNC 模式独立）
ports: []
timing:
  clock_frequency: null
  latency_cycles: null
  throughput: null
req_ref:
  - LRS.INTF.X2P.03.002
END_HLD_IF_META -->

### 6.2 总线接口设计

| 项目 | 设计说明 |
|---|---|
| 总线协议 | AXI4 / AXI4-Lite (slave) · APB3 / APB4 (master) |
| 地址宽度 | AXI_ADDR_WIDTH / APB_ADDR_WIDTH（参数化） |
| 数据宽度 | AXI_DATA_WIDTH ∈ {32,64,128} / APB_DATA_WIDTH ∈ {32,64} |
| 访问类型 | Read / Write / Byte Enable |
| 支持 outstanding | 是（READ/WRITE_REQUEST_DEPTH） |
| 支持 burst | 是（INCR/FIXED/WRAP） |
| 非法访问响应 | OKAY / SLVERR |
| 未对齐访问 | 支持（按 AxSIZE/地址 lane 语义） |
| 访问保护 | AWPROT/ARPROT → PPROT（APB4） |
| 时钟域 | clk_axi / clk_apb（SYNC/ASYNC） |
| 复位行为 | PSEL/PENABLE/BVALID/RVALID 复位为 0 |

---

## 7. 寄存器架构设计

> **类别状态：N/A - 纯桥无寄存器**

X2P 无可编程寄存器（`register_model = none`）。所有配置为编译期参数。
不生成 SystemRDL / CSR RTL / C header。