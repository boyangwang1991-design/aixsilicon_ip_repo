# 接口需求 - AXI-to-APB Bridge (X2P)
# Interface Requirements - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **INTF**：接口需求（时钟/复位、AXI 从接口、APB 主接口、保护属性、参数化裁剪）

---

## 2. 接口需求 / Interface Requirements

### 2.1 AXI 从接口 / AXI Slave Interface

#### LRS.INTF.X2P.01.001 AXI 从接口提供

<!-- LRS_META
id: LRS.INTF.X2P.01.001
category: INTF
ip: X2P
feature: axi_slave_interface
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应提供一个 AXI Slave 接口。
2. AXI4 Profile 应支持五个标准 Channel：AW、W、B、AR、R。
3. 接口位宽由 AXI_ADDR_WIDTH（地址）、AXI_DATA_WIDTH（数据）、AXI_ID_WIDTH（ID）参数决定。

##### 验证关注点

1. AXI Slave 端口存在且完整（ADDR/ID/DATA/PROT/READY/VALID/LAST/STRB）。
2. 五通道 VALID/READY 连接正确。

---

#### LRS.INTF.X2P.01.002 AXI4-Lite 自动裁剪

<!-- LRS_META
id: LRS.INTF.X2P.01.002
category: INTF
ip: X2P
feature: axi_slave_interface
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. AXI4-Lite Profile 应自动裁剪 AXI ID、burst length、burst type、WLAST/RLAST 及 AXI4-only 功能。
2. AXI4-Lite 应按协议固定 AxLEN=0、AxBURST=FIXED、AxSIZE=数据位宽对应值。

##### 验证关注点

1. AXI4-Lite 配置下不产生 ID/burst 逻辑。
2. AXI4-Lite 写/读为单拍事务。

---

### 2.2 APB 主接口 / APB Master Interface

#### LRS.INTF.X2P.02.001 APB 主接口提供

<!-- LRS_META
id: LRS.INTF.X2P.02.001
category: INTF
ip: X2P
feature: apb_master_interface
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应提供一个 APB Master 接口，至少包含：PADDR、PSEL、PENABLE、PWRITE、PWDATA、PRDATA、PREADY、PSLVERR。
2. APB4 Profile 应额外支持 PSTRB、PPROT。
3. X2P 应输出单一 PSEL，不得生成 PSEL[N:0] 多 Slave Select。

##### 验证关注点

1. APB 端口集正确（APB3 无 PSTRB/PPROT，APB4 有）。
2. PSEL 为单比特。

---

#### LRS.INTF.X2P.02.002 保护属性转换

<!-- LRS_META
id: LRS.INTF.X2P.02.002
category: INTF
ip: X2P
feature: apb_master_interface
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. APB4 Profile 应把 AXI AWPROT/ARPROT 转换为 PPROT 并保持协议属性语义（Privileged/Secure/Instruction）。
2. APB3 Profile 不输出 PPROT。

##### 验证关注点

1. PPROT 与请求侧 PROT 一致。
2. APB3 下 PPROT 不存在。

---

### 2.3 时钟与复位 / Clock and Reset

#### LRS.INTF.X2P.03.001 同步/异步时钟模式

<!-- LRS_META
id: LRS.INTF.X2P.03.001
category: INTF
ip: X2P
feature: clock_reset
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应支持 SYNC（ACLK 与 PCLK 同域或确定同步关系）与 ASYNC（完全异步）两种时钟模式。
2. ASYNC 模式下不得对两时钟的频率比、相位、启动顺序做任何假设。

##### 验证关注点

1. SYNC 模式功能正确。
2. ASYNC 模式功能正确（无同步假设）。

---

#### LRS.INTF.X2P.03.002 复位语义

<!-- LRS_META
id: LRS.INTF.X2P.03.002
category: INTF
ip: X2P
feature: clock_reset
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 复位后 PSEL=0、PENABLE=0、BVALID=0、RVALID=0，并清除内部 pending state。
2. 复位期间及复位后不得产生新的 APB access，不得恢复执行复位前未完成的 transaction。
3. ASYNC 模式下 ACLK/PCLK 复位可独立 assertion，reset release 不得产生伪 request/response。

##### 验证关注点

1. 复位后所有输出信号复位值正确。
2. 复位后无 APB access。
3. ASYNC 下任一域单独复位不产生伪请求。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*