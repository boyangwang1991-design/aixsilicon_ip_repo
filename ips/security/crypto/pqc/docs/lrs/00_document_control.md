# 可配置 ML-KEM + ML-DSA PQC 加速器逻辑需求规格：文档控制

<!-- LRS_DOC_META
schema_version: '2.0'
ip_name: pqc
ip_display_name: 可配置 ML-KEM + ML-DSA 后量子密码加速器
delivery_model: parameterized
register_model: required
ppa_signoff: none
ppa_signoff_reason: 用户明确要求从 RTL 结构评估 PPA，本轮不进行实测 PPA 签核。
document_version: 1.1.0
status: reviewed
requirement_baseline: PQC-20260916-WORKKEY
END_LRS_DOC_META -->

## 来源与版本

原始输入为 [`pqc_contract.md`](../../../pqc_contract.md)，版本 `0.2.0`，SHA-256
`4bd5e557b56f644ac7a5ee625b663bc9bfa4da80c3e95f853b185eca99ed1b89`。
此哈希绑定已加入 2026-09-16 密钥边界决定的当前契约；本目录是 LRS 编辑入口。规范基线为 NIST FIPS 203（ML-KEM）、
FIPS 204（ML-DSA）与 SP 800-227（KEM 用法指南），最终以 NIST errata 文本为准。

## 范围

交付可配置 SystemVerilog 后量子密码加速器，完整支持 ML-KEM 与 ML-DSA 全部六个标准
参数集的 KeyGen/Encaps/Decaps/Sign/Verify，含 APB4 控制接口、AXI4 master 数据接口、
key handle、工作态私钥托管、zeroize、自检与故障控制。长期密钥所有权属于外部 Key Manager；
私钥通过专用安全接口流转，普通 APB/AXI DMA 不得读取或导入私钥材料。

不包含：TRNG/DRBG 物理实现、key manager 实现、SoC 级 IOMMU/防火墙、Pad 电气、
掩码结构的具体电路（Level 2 由 `SCA_LEVEL` 参数选择，本 LRS 只规定可观察安全属性）。

## 建模与文档分工

需求使用 `LRS.<CATEGORY>.PQC.<GROUP>.<INDEX>`；P0 表示 V1.0 Signoff 必须满足。
`source_ref` 中的 `pqc_contract.md#§<章节>` 是原始合同定位符。本目录不规定 RTL 文件、
模块分解、FSM 编码、pipeline 级数；原始合同中的微架构建议由 HLD/LLD 承接。
寄存器 offset/bit 地图不在 LRS，由 `02-reg-model` 的 SystemRDL 承接；本 LRS 只定义
软件可见能力与兼容约束。VPLAN 负责 TC/ASSERT/COV；本目录验收条件是需求检查种子。

## 语言与完成范围

正文为中文；标识符、协议名、算法参数与原始工具输出保留原文。本次为 full-flow
执行，交付范围覆盖 LRS/HLD/LLD/VPLAN/RTL/验证/文档全链路。PPA 仅评估 RTL 的
资源共享、算术深度、存储端口、吞吐与切换结构；不要求实测面积、时序或功耗签核。
该范围不豁免功能验证，也不把代码分析视为达到目标频率的证明。
所有生成产物在拥有者校验通过前为 candidate。

## 阶段状态与授权

用户已明确授权自动完成本 IP 的设计与验证。本 LRS 按 01-lrs-author 的作者校验流程
编写并保持 `reviewed`；未提供独立人类评审结论。G0 门禁状态见
[`99_quality_gate.md`](99_quality_gate.md)。后续语义变更需重新校验并重开 G0。

## 输入与引用

| ID | 输入文档 | 版本 | 类型 |
|---|---|---|---|
| SRC-001 | `pqc_contract.md` | 0.2.0 | Requirement + Architecture |
| SRC-002 | NIST FIPS 203 ML-KEM | final | Specification |
| SRC-003 | NIST FIPS 204 ML-DSA | final | Specification |
| SRC-004 | NIST SP 800-227 KEM Usage | final | Specification |

## 用户决定（当前契约的优先补充）

- 密钥边界原话：“PQC加速器内部应保留‘工作态安全Key RAM’，但长期密钥所有权交给外部Key Manager；私钥通过专用sideload/导入接口进入，不经过普通AXI DMA，也默认不可读回。”
- PPA 范围原话：“我是让你从PPA的视角去评估代码，不是用真实的PPA去参考”。
- 继续执行原话：“请继续根据Ip-development-suite完成剩余的工作”。

这些指令授权继续开发及上述设计选择；本文件未将执行授权冒充 G0/G1/G2 技术冻结。
