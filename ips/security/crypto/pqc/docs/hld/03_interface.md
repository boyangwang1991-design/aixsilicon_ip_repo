# PQC 加速器高层设计：接口架构

## 外部接口

| HLD Interface ID | Protocol / Type | Role | Clock Domain | Related LRS |
|---|---|---|---|---|
| HLD.IF.EXT.PQC.APB | APB4 32-bit | slave | CORE | LRS.INTF.PQC.APB.001 |
| HLD.IF.EXT.PQC.DMA | AXI4 master | master | CORE | LRS.INTF.PQC.DMA.001 |
| HLD.IF.EXT.PQC.PIO | valid/ready byte stream | slave | CORE | LRS.INTF.PQC.APB.001 |
| HLD.IF.EXT.PQC.ENTROPY | valid/ready + tag | slave | CORE | LRS.INTF.PQC.ENTROPY.001 |
| HLD.IF.EXT.PQC.SIDEBAND | level/strap | input/output | CORE | LRS.INTF.PQC.SIDEBAND.001 |
| HLD.IF.EXT.PQC.CLKRESET | clk/rst | input | CORE | LRS.INTF.PQC.CLKRESET.001 |

### HLD.IF.EXT.PQC.APB

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.APB
name: apb_config
scope: external
protocol: apb4
role: slave
owner_module: HLD.MOD.PQC.FE
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.APB.001
- LRS.REG.PQC.ID.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

软件配置与状态访问的主通道，32 bit 数据宽度，自然对齐。

#### Supported Architectural Capabilities

- 单次读写；
- 非法地址由默认从端返回错误响应；
- 中断状态与清除访问。

#### Unsupported Capabilities

- APB5 扩展信号；
- burst 传输。

---

### HLD.IF.EXT.PQC.DMA

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.DMA
name: axi4_data
scope: external
protocol: axi4
role: master
owner_module: HLD.MOD.PQC.DMA
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.002
- LRS.INTF.PQC.DMA.003
- LRS.SEC.PQC.SLOT.005
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

消息、公钥、密文、签名与经安全策略允许的结果搬运通道。私钥材料没有普通 DMA 路径。

#### Supported Architectural Capabilities

- INCR burst，遵守 4 KiB 边界；
- outstanding，但同一 buffer 内保序；
- 携带安全/特权属性；
- 分段输入等价于连续输入；
- 宽度由 `DMA_DATA_WIDTH` 配置。

#### Unsupported Capabilities

- FIXED/WRAP burst；
- exclusive access；
- scatter-gather（V1.0）。

---

### HLD.IF.EXT.PQC.PIO

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.PIO
name: pio_fifo
scope: external
protocol: valid_ready
role: slave
owner_module: HLD.MOD.PQC.FE
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.APB.001
applicability:
  expr: 'ENABLE_PIO == true'
END_HLD_INTERFACE_META -->

#### Interface Role

小数据可选 PIO 通道，避免为短消息启动 DMA。

#### Supported Architectural Capabilities

- byte stream 有效字节与结束标记，短消息及尾字节不得被补零后当作消息；
- 与 DMA 互斥使用同一命令。

#### Unsupported Capabilities

- 与 DMA 同时用于同一 buffer；
- 私钥导入、材料读回或 debug 通道。

---

### HLD.IF.EXT.PQC.ENTROPY

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.ENTROPY
name: entropy
scope: external
protocol: valid_ready
role: slave
owner_module: HLD.MOD.PQC.TOP
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.ENTROPY.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

接收系统 TRNG/DRBG 随机量，供 KeyGen/Encaps/Sign 及 Level 2 masking 使用。
算法随机量与掩码随机量按 purpose/domain 隔离，禁止跨事务或 gadget 复用。
现有 64-bit 通道的带宽必须计入掩码预算，详见 [Level 2 专卷](09_masking_level2.md)。

#### Supported Architectural Capabilities

- valid/ready 握手；
- health status；
- domain tag 绑定算法与参数集。

#### Unsupported Capabilities

- 生产模式软件直接注入 seed 绕过熵路径；仅授权测试生命周期可使用隔离 KAT 注入。

---

### HLD.IF.EXT.PQC.SIDEBAND

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.SIDEBAND
name: security_sideband
scope: external
protocol: level
role: input
owner_module: HLD.MOD.PQC.FAULT
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.SIDEBAND.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.SLOT.004
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

承载 lifecycle、tamper、`zeroize_req` 与中断输出。

#### Supported Architectural Capabilities

- 异步输入同步化；
- zeroize 独立路径；
- 五类中断输出。

#### Unsupported Capabilities

- 通过旁带读写秘密。

---

### HLD.IF.EXT.PQC.CLKRESET

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.CLKRESET
name: clk_reset
scope: external
protocol: clock_reset
role: input
owner_module: HLD.MOD.PQC.TOP
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.CLKRESET.001
- LRS.RESET.PQC.CLK.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

单主时钟与异步低有效复位。

#### Supported Architectural Capabilities

- 单时钟域；
- 低有效异步复位。

#### Unsupported Capabilities

- 多时钟域输入。

---

