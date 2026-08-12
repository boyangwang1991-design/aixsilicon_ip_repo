# LLD 设计文档 - UART

## 1. 模块总体概述

本 IP 由以下微架构模块组成：

| LLD 模块 | HLD 引用 | 来源 | 说明 |
|---|---|---|---|
| LLD.MOD.UART.TOP | HLD.MOD.L1.UART.TOP | OpenTitan 原版 | 顶层封装 |
| LLD.MOD.UART.REG_TOP | HLD.MOD.L1.UART.REG_TOP | OpenTitan 生成 | 寄存器堆（TL-UL） |
| LLD.MOD.UART.CORE | HLD.MOD.L1.UART.CORE | OpenTitan 原版 | 核心逻辑 |
| LLD.MOD.UART.TX | HLD.MOD.L1.UART.TX | OpenTitan 原版 | 发送模块 |
| LLD.MOD.UART.RX | HLD.MOD.L1.UART.RX | OpenTitan 原版 | 接收模块 |
| LLD.MOD.UART.APB2TLUL | HLD.MOD.L1.UART.APB2TLUL | 新增 | APB→TL-UL 桥 |

## 2. 全局设计约束

- 单时钟域 CLK_SYS，异步复位同步释放（RST_SYS_N 低有效）。
- 核心 RTL 不改动；apb2tlul 为新增可综合 SystemVerilog。
- 寄存器访问：TL-UL target（BlockAw=6）或 APB target（经 apb2tlul），二者互斥。
- UVM 1.2 验证，编译命令带 `-ntb_opts uvm-1.2`。

## 3. 模块微架构设计

### 3.1 LLD.MOD.UART.TOP（uart 顶层）

<!-- LLD_META
module_id: LLD.MOD.UART.TOP
hld_ref: HLD.MOD.L1.UART.TOP
fsm: []
datapath:
  pipeline_stages:
    - stage: S0
      name: Integration
      operation: 顶层连接寄存器堆、核心、alert、中断输出
  backpressure:
    type: none
    mechanism: TL-UL 握手由 uart_reg_top 处理
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
interrupt:
  - id: LLD.IRQ.UART.TOP.TX_WATERMARK
    name: intr_tx_watermark_o
    trigger: TX FIFO 低于 TXILVL
    clear: 电平型（FIFO 状态恢复）
    maskable: true
    priority: 1
  - id: LLD.IRQ.UART.TOP.TX_EMPTY
    name: intr_tx_empty_o
    trigger: TX FIFO 空
    clear: 电平型（FIFO 非空）
    maskable: true
    priority: 1
  - id: LLD.IRQ.UART.TOP.RX_WATERMARK
    name: intr_rx_watermark_o
    trigger: RX FIFO 高于 RXILVL
    clear: 电平型（FIFO 状态恢复）
    maskable: true
    priority: 1
END_LLD_META -->

- **职责**：实例化 `uart_reg_top`、`uart_core`、`prim_alert_sender`，连接总线、中断、IO、RACL。
- **复位行为**：rst_ni 低有效异步复位；复位后中断/alert 输出已知状态。
- **关键连接**：`cio_tx_en_o` 恒为 1；alert 由 intg_err 触发。

### 3.2 LLD.MOD.UART.REG_TOP（寄存器堆）

<!-- LLD_META
module_id: LLD.MOD.UART.REG_TOP
hld_ref: HLD.MOD.L1.UART.REG_TOP
fsm: []
datapath:
  pipeline_stages:
    - stage: S0
      name: CSR Access
      operation: TL-UL 从接口译码、14 寄存器读写、中断逻辑、BUS.INTEGRITY 检测
  backpressure:
    type: valid_ready
    mechanism: TL-UL 握手
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
interrupt:
  - id: LLD.IRQ.UART.REG_TOP.INTR
    name: intr_*_o
    trigger: INTR_STATE & INTR_ENABLE
    clear: W1C（事件型）/ 电平恢复（电平型）
    maskable: true
    priority: 1
END_LLD_META -->

- **职责**：寄存器访问译码（BlockAw=6）、中断状态/使能/测试/状态寄存器、fatal_fault alert 触发。
- **来源**：PeakRDL/reggen 自动生成模块，寄存器字段定义见 `regs/uart.rdl`，本 LLD 不重复展开。
- **复位行为**：所有寄存器复位到 RDL 定义的复位值。

### 3.3 LLD.MOD.UART.CORE（核心逻辑）

<!-- LLD_META
module_id: LLD.MOD.UART.CORE
hld_ref: HLD.MOD.L1.UART.CORE
fsm:
  - id: LLD.FSM.UART.CORE.BREAK
    name: Break Detection FSM
    encoding_style: auto
    reset_state: BRK_CHK
    states:
      - name: BRK_CHK
      - name: BRK_WAIT
    transitions:
      - from: BRK_CHK
        to: BRK_WAIT
        condition: 连续低达到 RXBLVL 阈值
      - from: BRK_WAIT
        to: BRK_CHK
        condition: 收到非全零字符或线恢复
    illegal_state_handling: return_to_reset
datapath:
  pipeline_stages:
    - stage: S0
      name: BaudDiv
      operation: NCO 16 位累加产生 16x baud tick
    - stage: S1
      name: FifoCtrl
      operation: TX/RX FIFO 读写控制与水位检测
    - stage: S2
      name: EventGen
      operation: 中断事件产生（watermark/empty/done/overflow/err/timeout）
  backpressure:
    type: fifo
    mechanism: FIFO 满/空控制反压
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
interrupt:
  - id: LLD.IRQ.UART.CORE.TX_DONE
    name: intr_tx_done_o
    trigger: TX FIFO 变空且末字节发送完成
    clear: W1C
    maskable: true
    priority: 2
  - id: LLD.IRQ.UART.CORE.RX_OVERFLOW
    name: intr_rx_overflow_o
    trigger: RX FIFO 满时收到新字符
    clear: W1C
    maskable: true
    priority: 2
  - id: LLD.IRQ.UART.CORE.RX_FRAME_ERR
    name: intr_rx_frame_err_o
    trigger: 停止位不为 1
    clear: W1C
    maskable: true
    priority: 2
  - id: LLD.IRQ.UART.CORE.RX_BREAK_ERR
    name: intr_rx_break_err_o
    trigger: break 条件检测
    clear: W1C
    maskable: true
    priority: 2
  - id: LLD.IRQ.UART.CORE.RX_TIMEOUT
    name: intr_rx_timeout_o
    trigger: RX FIFO 超时未取走
    clear: W1C
    maskable: true
    priority: 2
  - id: LLD.IRQ.UART.CORE.RX_PARITY_ERR
    name: intr_rx_parity_err_o
    trigger: 奇偶位极性错误
    clear: W1C
    maskable: true
    priority: 2
END_LLD_META -->

- **职责**：FIFO 控制、波特率分频、中断事件、回环/噪声滤波/break/超时/覆盖。
- **数据通路**：NCO 分频 → 16x tick；FIFO 读写；事件产生 → reg2hw/hw2reg。
- **FSM**：break 检测（BRK_CHK/BRK_WAIT）。
- **复位行为**：FIFO 深度计数清零，状态回默认。

### 3.4 LLD.MOD.UART.TX（发送模块）

<!-- LLD_META
module_id: LLD.MOD.UART.TX
hld_ref: HLD.MOD.L1.UART.TX
fsm:
  - id: LLD.FSM.UART.TX.MAIN
    name: TX Shift FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
      - name: SHIFT
    transitions:
      - from: IDLE
        to: SHIFT
        condition: 有数据且 TX 使能
      - from: SHIFT
        to: IDLE
        condition: 帧发送完成
    illegal_state_handling: return_to_reset
datapath:
  pipeline_stages:
    - stage: S0
      name: ShiftOut
      operation: 逐位输出 START+8 数据+（奇偶）+STOP
  backpressure:
    type: none
    mechanism: 按 bit-time 移位
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
END_LLD_META -->

- **职责**：从核心接收数据，按波特率逐位移位输出。
- **FSM**：IDLE/SHIFT 状态。

### 3.5 LLD.MOD.UART.RX（接收模块）

<!-- LLD_META
module_id: LLD.MOD.UART.RX
hld_ref: HLD.MOD.L1.UART.RX
fsm:
  - id: LLD.FSM.UART.RX.MAIN
    name: RX Sampling FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
      - name: SAMPLE
    transitions:
      - from: IDLE
        to: SAMPLE
        condition: 检测到起始位（低电平）
      - from: SAMPLE
        to: IDLE
        condition: 帧采样完成或毛刺中止
    illegal_state_handling: return_to_reset
datapath:
  pipeline_stages:
    - stage: S0
      name: Oversample
      operation: 16x 过采样 + 中点采样
    - stage: S1
      name: ErrCheck
      operation: 帧/奇偶错误检测
  backpressure:
    type: none
    mechanism: 按 bit-time 采样
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
END_LLD_META -->

- **职责**：16x 过采样、中点采样、帧/奇偶错误检测。
- **FSM**：IDLE/SAMPLE（起始位确认 → 数据采样 → 停止位）。

### 3.6 LLD.MOD.UART.APB2TLUL（APB 桥，新增）

<!-- LLD_META
module_id: LLD.MOD.UART.APB2TLUL
hld_ref: HLD.MOD.L1.UART.APB2TLUL
fsm:
  - id: LLD.FSM.UART.APB2TLUL.MAIN
    name: APB2TLUL Bridge FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
      - name: SETUP
      - name: ACCESS
      - name: WAIT_TL
      - name: RESP
    transitions:
      - from: IDLE
        to: SETUP
        condition: psel && !penable
      - from: SETUP
        to: ACCESS
        condition: penable
      - from: ACCESS
        to: WAIT_TL
        condition: 发起 TL-UL 请求
      - from: WAIT_TL
        to: RESP
        condition: TL-UL 响应返回
      - from: RESP
        to: IDLE
        condition: 返回 pready/pslverr
    illegal_state_handling: return_to_reset
datapath:
  pipeline_stages:
    - stage: S0
      name: APBDecode
      operation: 解析 APB 事务（paddr/pwrite/pwdata）
    - stage: S1
      name: TLGen
      operation: 生成 TL-UL A/D 通道请求
    - stage: S2
      name: RespGen
      operation: 生成 pready/pslverr/prdata
  backpressure:
    type: handshake
    mechanism: APB pready 反压等待 TL-UL 响应
reset:
  - signal: rst_ni
    polarity: active_low
    reset_value: 0
    reset_type: async
END_LLD_META -->

- **职责**：APB4 从事务 → TL-UL 主机事务转换，驱动 uart_reg_top。
- **FSM**：IDLE/SETUP/ACCESS/WAIT_TL/RESP 五状态。
- **地址映射**：paddr[7:2] → TL-UL a_address（6 位块内地址）；非法地址返回 pslverr。
- **读写**：读 → TL-UL Get；写 → TL-UL PutFullData。
- **时序**：APB 两相（setup/access），pready 在响应返回后拉高，pslverr 指示错误。
- **复位行为**：FSM 回 IDLE，输出已知值。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 05-lld-microdesign*
