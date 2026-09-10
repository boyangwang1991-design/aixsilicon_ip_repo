# SPI Master 架构

单 PCLK，独立 APB 控制面与 SPI 执行面。命令队列实现提交/完成分离；数据队列支持流式搬运。参数仅改变 CS 数及三类队列深度，CSR 地址不变。

<!-- HLD_DOC_META
schema_version: '2.0'
ip_name: spi_master
delivery_model: parameterized
status: draft
lrs_baseline: SPI_MASTER_V1_CONTRACT_0.1
architecture_baseline: SPI_MASTER_HLD_V1
END_HLD_DOC_META -->
<!-- HLD_GATE_META
gate: G1
status: open
architecture_freeze: false
approvals: {}
END_HLD_GATE_META -->
