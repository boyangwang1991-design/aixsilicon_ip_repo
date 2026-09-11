# GPIO 逻辑需求规格：文档控制

<!-- LRS_DOC_META
schema_version: '2.0'
ip_name: gpio
ip_display_name: 通用 GPIO
delivery_model: parameterized
register_model: required
ppa_signoff: required
document_version: 1.0.0-draft
status: approved
requirement_baseline: GPIO-CONTRACT-59597f3b2da6
END_LRS_DOC_META -->

## 来源与版本

原始输入为 [gpio_contract.md](../../gpio_contract.md)，版本 `1.0.0-draft`，SHA-256 `59597f3b2da6408c3f95c95a4aadc05749b8ea9e0712c16d3a63edf577dff705`。
源文件保留；本目录是派生设计工作开始后的 LRS 编辑入口。修改需求须重新评审，并核对来源差异。
包开发版本沿用 registry 的 `0.1.0`，与需求文档版本及 IP 软件 VERSION 常量分开管理。
作者为本次执行 Agent；未提供人类/独立评审结论，未填写审批人。本次 LRS 根据用户明确授权，在完成作者校验后自动审批。

## 范围

交付参数化 SystemVerilog GPIO，APB4 32-bit、1～128 路、一个主功能时钟域及可选 AON 域。
包含输入处理、输出与原子操作、中断、安全访问与锁、休眠、安全覆盖、AON 唤醒、快照、Strap、事件 FIFO/DMA 请求、诊断与 parity。
可裁剪功能仍是产品必备实现能力；不能以实例关闭功能免除产品实现和验证。
Pad 电气、全芯片 Pinmux、系统隔离/保持、PMU 最终关电仲裁由集成层负责。

## 建模与文档分工

需求使用 `LRS.<CATEGORY>.GPIO.<GROUP>.<INDEX>`；P0 表示必须满足。
每项记录来源、适用条件、可观察行为和验收条件。源 ID 内的补充 A 项独立保留。
source_ref 中 `gpio_contract.md#GPIO-*` 是原始需求定位符；表格项使用 `§章节/行名`。
本目录不规定 RTL 文件、模块分解、FSM 编码；原合同中的架构建议留给 HLD/LLD 处理。
寄存器 offset/bit 地图仍保留在输入合同 §15，后续由 SystemRDL 承接；LRS 只定义软件能力与兼容约束。
VPLAN 负责具体 TC/ASSERT/COV；本目录的验收条件是需求检查种子，尚无执行结果。
分册按主题平铺，每册最多 12 项需求；全目录抽取检查在每册编辑后运行。

## 评审状态

G0 pass；requirement_freeze=true（用户授权自动审批）。需求结构检查与作者自查不代表独立评审或技术冻结。
SoC 实例配置见来源 §20.2，当前未提供；产品通用功能与实例级物理签核分别记录。

## 本次审批授权

用户原文：`automatically approve the lrs for me later;`。
审批方式为用户授权后的自动审批，执行者为本次 Agent；不代表另有独立人类评审。
审批范围仅 LRS，且只针对本次校验通过的需求基线；后续语义变更需重新校验并重新记录审批。

## 本次审批授权

用户原文：`automatically approve the lrs for me later;`。
审批方式为用户授权后的自动审批，执行者为本次 Agent；不代表另有独立人类评审。
审批范围仅 LRS，且只针对本次校验通过的需求基线；后续语义变更需重新校验并重新记录审批。
