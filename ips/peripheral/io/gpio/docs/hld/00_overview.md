# GPIO 高层架构：目标与输入

<!-- HLD_DOC_META
schema_version: '2.0'
ip_name: gpio
ip_display_name: 通用 GPIO
delivery_model: parameterized
lrs_baseline: GPIO-CONTRACT-59597f3b2da6
document_version: 1.0.0-draft
status: approved
architecture_baseline: GPIO-HLD-001
END_HLD_DOC_META -->

## 架构目标

在固定 APB 软件合同下覆盖 1～128 路、全部静态裁剪及 AON 独立运行，优先保证事务无部分更新、复位保持正确和跨域命令不重复。
输入是已按用户授权自动审批的 LRS 与 PC 参数模型。20 个参数、269 个有界配置点为设计空间，不代表已经验证 269 个硬件实例。
HLD 采用 12 个职责模块、2 个工作时钟域、主业务/主 POR 保持/AON 三类复位语义；Bank 只做软件分组。
复杂度由对象抽取结果审计；本设计包含多时钟、可恢复命令和安全保持，按复杂 IP 管理。

## 参数对架构的影响

N_GPIO 决定输入/输出/中断/诊断通道数，N_BANK=ceil(N_GPIO/32)；最后一 Bank 屏蔽不存在位。
SYNC_STAGES 只改变主输入同步与有效填充延迟；AON 输入固定两级。N_IRQ_GROUPS 只改变汇总数和合法路由编码。
各 *_EN 参数移除相应功能逻辑，软件地址不移动；EVENT_FIFO_DEPTH=0 裁剪记录能力。
CFG_PARITY_EN 与 DIAG_EN 独立；parity-only 实例仍必须提供安全请求。BOOT_* 只规定 POR 后访问策略。
RESET_* 与 HW_SAFE_* 不改变拓扑，但必须通过能力包含检查。

## 阶段状态

用户已批准当前HLD（approve, complete the rest），G1 pass，architecture_freeze=true。
本文件及 canonical 模型不代表 RTL、CDC、RDC、综合、功能或覆盖率已经通过。
