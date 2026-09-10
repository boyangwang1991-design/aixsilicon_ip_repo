# 域、预算与集成约束

内部不存在 CDC，MISO 是源同步返回时序路径，不加两级同步器、不置 false path。外部 IO/PDK 目标待集成；综合表征使用明确的实验约束，不等于产品频率保证。功能安全与 DFT 插入不在本版范围。

<!-- HLD_DOMAIN_META
id: HLD.DOM.SPI_MASTER.PCLK
type: clk
name: pclk
source: SoC
modules:
- HLD.MOD.SPI_MASTER.CSR
- HLD.MOD.SPI_MASTER.ENGINE
- HLD.MOD.SPI_MASTER.QUEUES
END_HLD_DOMAIN_META -->
<!-- HLD_DOMAIN_META
id: HLD.DOM.SPI_MASTER.PRESET_N
type: rst
name: preset_n
source: SoC asynchronous assert / synchronous release
modules:
- HLD.MOD.SPI_MASTER.CSR
- HLD.MOD.SPI_MASTER.ENGINE
- HLD.MOD.SPI_MASTER.QUEUES
END_HLD_DOMAIN_META -->
<!-- HLD_DOMAIN_META
id: HLD.DOM.SPI_MASTER.ALWAYS_ON
type: pwr
name: always_on
source: SoC supply
modules:
- HLD.MOD.SPI_MASTER.CSR
- HLD.MOD.SPI_MASTER.ENGINE
- HLD.MOD.SPI_MASTER.QUEUES
END_HLD_DOMAIN_META -->
<!-- HLD_PERF_META
id: HLD.PERF.SPI_MASTER.CONTINUOUS
metric: SCLK half period
target: CLKDIV+1 PCLK; no intra-segment bubble when FRAME_GAP=0 and resources available
allocated_to:
- HLD.MOD.SPI_MASTER.ENGINE
END_HLD_PERF_META -->
