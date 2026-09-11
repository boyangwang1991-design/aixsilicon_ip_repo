# 安全 APB Demux 逻辑需求规格：概览

<!-- LRS_DOC_META
schema_version: "2.0"
ip_name: apb_secure_demux
ip_display_name: 安全 APB Demux
delivery_model: parameterized
register_model: required
ppa_signoff: required
document_version: "1.0.0"
status: approved
requirement_baseline: ASD-LRS-1.0.0-USER-APPROVED
END_LRS_DOC_META -->

## 文档控制与来源

本文由输入契约整理，为经用户批准的需求基线。原始需求保留为 source_ref；新增条目引用原文具体章节。
输入：[apb_secure_demux_contract.md](../../../apb_secure_demux_contract.md)，版本 1.0.0-reviewed。
SHA-256：`3cdc8fcce41b02cda601a4589d0b65e6e340043c6c494b333d9d0656e95ad6a2`。批准来源为本会话用户回复 “approve, continue”；批准范围为上一轮 LRS 和 CR-001～CR-003，非未来架构/实现签核。

## 建模规则

需求编号为 LRS.类别.APB_SECURE_DEMUX.来源族.编号；功能标识稳定，分册移动不改 ID。
参数、接口和验收条件属于本阶段；RTL 模块分解和寄存器物理位表由后续 owner 承接。
原始条目包含多个独立句子时分成子条目并保留同一来源引用。原文的条件分支保持在同一语义对象。
所有需求是强制 P0；仿真、形式、静态和评审字段为后续验证方法要求，不代表已经验证。

## 产品概览

本 IP 为一个 APB4 输入提供 1～32 个输出，以可信 MASTERID 与 PPROT 做逐端口读写授权。
数据宽度固定 32 bit；本地 CSR 提供 shadow/active 权限、原子提交、锁、日志、中断和授权 DFX。
支持直接和寄存转发，非法请求从下游 SETUP 之前阻断。复位默认拒绝所有外设访问。
不包含多输入仲裁、CDC、DMA、协议转换、APB5、事务取消或无条件安全旁路。

## 本次评审范围

需求正文、接口与参数范围来自固定契约。寄存器描述语言冲突、FIFO 裁剪错误码和提交失败优先级
详见 [契约评审](../../reports/quality/contract_review.md)。CR-001～CR-003 已按用户批准关闭；CR-004/005 仍为后续协议/集成签核输入。
工艺库、周期/IO 预算、地址分配和可信主体掩码为受控集成输入，不虚构项目签核值。
