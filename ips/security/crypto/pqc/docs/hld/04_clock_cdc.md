# PQC 加速器高层设计：时钟、复位、电源与 CDC/RDC

## 时钟域

### HLD.DOM.CLK.PQC.CORE

<!-- HLD_DOMAIN_META
id: HLD.DOM.CLK.PQC.CORE
type: clk
name: core_clk
source: SoC clock controller
modules:
- HLD.MOD.PQC.TOP
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.SRAM
- HLD.MOD.PQC.KEYSLOT
- HLD.MOD.PQC.WORKKEY
- HLD.MOD.PQC.DMA
- HLD.MOD.PQC.FAULT
req_ref:
- LRS.RESET.PQC.CLK.001
applicability:
  expr: 'true'
END_HLD_DOMAIN_META -->

规划目标频率 400 MHz（Balanced 配置，28 nm 级工艺）。全部 L1 模块处于该单一域。

## 复位域

### HLD.DOM.RST.PQC.MAIN

<!-- HLD_DOMAIN_META
id: HLD.DOM.RST.PQC.MAIN
type: rst
name: rst_n
source: SoC reset controller
polarity: low
modules:
- HLD.MOD.PQC.TOP
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.SRAM
- HLD.MOD.PQC.KEYSLOT
- HLD.MOD.PQC.WORKKEY
- HLD.MOD.PQC.DMA
- HLD.MOD.PQC.FAULT
req_ref:
- LRS.RESET.PQC.COLD.001
- LRS.RESET.PQC.WARM.001
applicability:
  expr: 'true'
END_HLD_DOMAIN_META -->

异步低有效复位，覆盖全部模块。warm reset 语义（ephemeral 清除 / persistent 保持）
由复位序列区分；长期材料的保持只发生在外部 Key Manager，PQC 工作副本始终退休。
复位期间拒绝请求，释放后擦除与自检未完成前禁止派发。详细实现属 LLD。

## 电源域

### HLD.DOM.PWR.PQC.CORE

<!-- HLD_DOMAIN_META
id: HLD.DOM.PWR.PQC.CORE
type: pwr
name: core_power
source: SoC power controller
modules:
- HLD.MOD.PQC.TOP
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.SRAM
- HLD.MOD.PQC.KEYSLOT
- HLD.MOD.PQC.WORKKEY
- HLD.MOD.PQC.DMA
- HLD.MOD.PQC.FAULT
req_ref:
- LRS.RESET.PQC.POWERDOWN.001
applicability:
  expr: 'true'
END_HLD_DOMAIN_META -->

单电源域。密钥保持域的 retention 策略由 key manager 决定，不在本 IP 内定义独立
保持域。power-down 前必须完成或安全中止并清零（`LRS.RESET.PQC.POWERDOWN.001`）。

## CDC / RDC

### HLD.CDC.PQC.SIDEBAND

<!-- HLD_CDC_META
id: HLD.CDC.PQC.SIDEBAND
source_domain: async_external
destination_domain: HLD.DOM.CLK.PQC.CORE
information_type: level
transfer_requirement:
  lossless: true
  ordered: false
architecture_strategy: synchronizer
req_ref:
- LRS.INTF.PQC.SIDEBAND.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
END_HLD_CDC_META -->

lifecycle、tamper 与 `zeroize_req` 为异步电平输入，需同步化后进入核心域。
`zeroize_req` 另需独立的安全路径，不依赖主 FSM。

### HLD.CDC.PQC.ENTROPY

<!-- HLD_CDC_META
id: HLD.CDC.PQC.ENTROPY
source_domain: entropy_source
destination_domain: HLD.DOM.CLK.PQC.CORE
information_type: stream
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: handshake
req_ref:
- LRS.INTF.PQC.ENTROPY.001
applicability:
  expr: 'true'
END_HLD_CDC_META -->

熵输入在 PQC 边界必须同步于核心时钟。若物理熵源异步，SoC 包装层负责完整流 CDC；
单纯 valid/ready 不能完成跨时钟传输。Key Manager 材料同样遵守该边界。
复位异步置位、在主时钟域同步释放；外部未决事务必须在系统复位协议中撤销或隔离，
不以“单复位域”豁免 release/recovery/removal 与外部复位差异检查。