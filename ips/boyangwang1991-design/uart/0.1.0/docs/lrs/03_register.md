# 寄存器需求 - UART (uart)
# Register Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 寄存器定义参考 OpenTitan UART `data/uart.hjson` 与 `doc/registers.md`。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **REG**：寄存器需求（寄存器空间分配、寄存器列表、访问属性、非法访问行为等）

---

## 1. 寄存器需求 / Register Requirements

### 1.1 寄存器空间 / Register Space

#### LRS.REG.UART.01.001 寄存器空间分配

<!-- LRS_META
id: LRS.REG.UART.01.001
category: REG
ip: UART
feature: reg_space
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供 `BlockAw=6` 位地址（64 字节）的寄存器空间，寄存器宽度 32 位（`regwidth: "32"`）。
2. `NumRegs=13`，寄存器地址映射见下表。

| 地址偏移 | 寄存器名 | 访问属性 | 说明 |
|---|---|---|---|
| 0x00 | CTRL | rw | UART 控制寄存器 |
| 0x04 | STATUS | ro | UART 状态寄存器（hwext） |
| 0x08 | RDATA | ro | UART 读数据（hwext） |
| 0x0C | WDATA | wo | UART 写数据 |
| 0x10 | FIFO_CTRL | rw | FIFO 控制 |
| 0x14 | FIFO_STATUS | ro | FIFO 状态（hwext） |
| 0x18 | OVRD | rw | TX 引脚覆盖控制 |
| 0x1C | VAL | ro | 过采样值（hwext） |
| 0x20 | TIMEOUT_CTRL | rw | RX 超时控制 |
| 0x24 | INTR_STATE | rw1c | 中断状态（W1C） |
| 0x28 | INTR_ENABLE | rw | 中断使能 |
| 0x2C | INTR_TEST | rw | 中断测试 |
| 0x30 | INTR_STATUS | ro | 中断状态（state & enable） |
| 0x34 | ALERT_TEST | rw | Alert 测试 |

3. 非法地址（超出已定义寄存器范围）访问应返回错误响应（TL-UL error / APB pslverr）。

##### 验证关注点

1. 各寄存器地址偏移与访问属性正确。
2. 非法地址访问返回错误响应。
3. hwext 寄存器（STATUS/RDATA/FIFO_STATUS/VAL）读行为正确。

---

### 1.2 控制寄存器 / Control Register

#### LRS.REG.UART.01.002 CTRL 控制寄存器

<!-- LRS_META
id: LRS.REG.UART.01.002
category: REG
ip: UART
feature: reg_ctrl
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `CTRL`（0x00，rw）字段定义应如下：
   - bit0 `TX`：TX 使能。
   - bit1 `RX`：RX 使能。
   - bit2 `NF`：RX 噪声滤波使能。
   - bit4 `SLPBK`：系统回环使能。
   - bit5 `LLPBK`：线路回环使能。
   - bit6 `PARITY_EN`：奇偶校验使能。
   - bit7 `PARITY_ODD`：1=奇校验，0=偶校验。
   - bit[9:8] `RXBLVL`：RX break 检测阈值（enum break2/break4/break8/break16）。
   - bit[31:16] `NCO`：波特率时钟控制。
2. 默认值：CTRL 复位为 0。

##### 验证关注点

1. 各字段读写/复位值正确。
2. 各控制位对功能行为的影响正确。

---

### 1.3 状态寄存器 / Status Register

#### LRS.REG.UART.01.003 STATUS 状态寄存器

<!-- LRS_META
id: LRS.REG.UART.01.003
category: REG
ip: UART
feature: reg_status
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `STATUS`（0x04，ro，hwext）字段应如下：
   - bit0 `TXFULL`：TX 缓冲满。
   - bit1 `RXFULL`：RX 缓冲满。
   - bit2 `TXEMPTY`：TX FIFO 空（复位值 1）。
   - bit3 `TXIDLE`：TX FIFO 空且所有位已发送（复位值 1）。
   - bit4 `RXIDLE`：RX 空闲（复位值 1）。
   - bit5 `RXEMPTY`：RX FIFO 空（复位值 1）。
2. 该寄存器由硬件实时更新，软件只读。

##### 验证关注点

1. 复位后状态位默认值正确。
2. 各状态位随 FIFO/收发活动实时变化。

---

### 1.4 数据寄存器 / Data Registers

#### LRS.REG.UART.01.004 RDATA 与 WDATA

<!-- LRS_META
id: LRS.REG.UART.01.004
category: REG
ip: UART
feature: reg_data
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `RDATA`（0x08，ro，hwext）：读返回 RX FIFO 头部字节（bit[7:0]），读操作使 FIFO 出队。
2. `WDATA`（0x0C，wo）：写将数据字节（bit[7:0]）入队 TX FIFO。

##### 验证关注点

1. RDATA 读回数据与 FIFO 顺序一致，读后出队。
2. WDATA 写后数据入队、TX 发送。
3. FIFO 空时读 RDATA 行为（允许未知数据，不报错）。

---

### 1.5 FIFO 控制/状态寄存器 / FIFO Control/Status Registers

#### LRS.REG.UART.01.005 FIFO_CTRL 与 FIFO_STATUS

<!-- LRS_META
id: LRS.REG.UART.01.005
category: REG
ip: UART
feature: reg_fifo
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `FIFO_CTRL`（0x10，rw）字段：
   - bit0 `RXRST`（wo）：写 1 复位 RX FIFO，读返回 0。
   - bit1 `TXRST`（wo）：写 1 复位 TX FIFO，读返回 0。
   - bit[4:2] `RXILVL`：RX watermark 触发（enum rxlvl1/2/4/8/16/32/62）。
   - bit[7:5] `TXILVL`：TX watermark 触发（enum txlvl1/2/4/8/16）。
2. `FIFO_STATUS`（0x14，ro，hwext）字段：
   - bit[7:0] `TXLVL`：TX FIFO 当前填充水平。
   - bit[23:16] `RXLVL`：RX FIFO 当前填充水平。

##### 验证关注点

1. RXRST/TXRST 写复位行为、读返回 0。
2. RXILVL/TXILVL 复位值与枚举映射正确。
3. TXLVL/RXLVL 实时反映 FIFO 深度。

---

### 1.6 其他寄存器 / Other Registers

#### LRS.REG.UART.01.006 OVRD / VAL / TIMEOUT_CTRL

<!-- LRS_META
id: LRS.REG.UART.01.006
category: REG
ip: UART
feature: reg_misc
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `OVRD`（0x18，rw）字段：
   - bit0 `TXEN`：TX 引脚覆盖使能。
   - bit1 `TXVAL`：覆盖电平值。
2. `VAL`（0x1C，ro，hwext）：bit[15:0] `RX` 最近 16 次过采样值，最近位 bit0。
3. `TIMEOUT_CTRL`（0x20，rw）字段：
   - bit[23:0] `VAL`：RX 超时值（UART bit-time 数）。
   - bit31 `EN`：RX 超时功能使能。

##### 验证关注点

1. OVRD 使能/值对 TX 引脚的控制。
2. VAL 反映过采样历史。
3. TIMEOUT_CTRL 使能/超时值配置与 rx_timeout 行为。

---

### 1.7 中断/Alert 寄存器 / Interrupt & Alert Registers

#### LRS.REG.UART.01.007 INTR 与 ALERT 寄存器

<!-- LRS_META
id: LRS.REG.UART.01.007
category: REG
ip: UART
feature: reg_intr_alert
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `INTR_STATE`（0x24，rw1c）：9 位中断状态，写 1 清除（W1C）。
2. `INTR_ENABLE`（0x28，rw）：9 位中断使能。
3. `INTR_TEST`（0x2C，rw）：9 位中断测试，写 1 置位对应状态。
4. `INTR_STATUS`（0x30，ro）：`INTR_STATE & INTR_ENABLE`。
5. `ALERT_TEST`（0x34，rw）：写 1 触发对应 alert 测试。

##### 验证关注点

1. 各中断位使能/状态/测试/清除行为正确。
2. INTR_STATUS 为 state 与 enable 的与结果。
3. ALERT_TEST 触发 alert 测试。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
