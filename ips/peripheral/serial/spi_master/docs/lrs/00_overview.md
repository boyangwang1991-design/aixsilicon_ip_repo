# SPI Master 需求基线

原始产品合同：[spi_master_contract.md](../../spi_master_contract.md)。本基线保留原 ID 的 source_ref；架构提示 ARCH 不作为外部行为需求。正式数值/软件 ABI 以合同第 9 章与 SystemRDL 为准。

<!-- LRS_DOC_META
schema_version: '2.0'
ip_name: spi_master
delivery_model: parameterized
register_model: required
ppa_signoff: required
document_version: 1.0.0
status: draft
requirement_baseline: SPI_MASTER_V1_CONTRACT_0.1
END_LRS_DOC_META -->
<!-- LRS_GATE_META
gate: G0
status: open
requirement_freeze: false
approvals: {}
END_LRS_GATE_META -->

安全 SAFE：N/A，无功能安全诊断。SEC：无权限过滤，由 SoC 保护。DFX：内部回环。GEN：N/A，无拓扑生成器。物理 PCLK/Pad/IO 预算未指定，不承诺实际最大频率。
