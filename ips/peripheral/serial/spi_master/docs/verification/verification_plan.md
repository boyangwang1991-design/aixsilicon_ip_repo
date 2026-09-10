# SPI Master 验证方案

<!-- VPLAN_META
schema_version: '2.0'
ip_name: spi_master
delivery_model: parameterized
lrs_baseline: SPI_MASTER_V1_CONTRACT_0.1
hld_baseline: SPI_MASTER_HLD_V1
lld_baseline: SPI_MASTER_LLD_V1
verification_level: full
document_version: 1.0.0
status: draft
verification_baseline: SPI_MASTER_VPLAN_V1
END_VPLAN_META -->

合同第 14 章是验证输入。外部从机 MISO clock-to-out 覆盖 0.2 ns 和 3 ns；内部 loopback 只作补充。100 MHz 是本次表征条件。

最小、默认、最大、非对称参数全部执行九组。随机组固定种子 1、17、101、2026，保留失败日志。wall-clock 超时 180 秒，测试内另有有界等待。

没有安装 VC Formal 时不得标记证明通过；模块 UT 覆盖精确竞争沿。最终报告分别列仿真、静态、综合证据和待集成签核项。
