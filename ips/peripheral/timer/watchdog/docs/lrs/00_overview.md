# Watchdog 逻辑需求规格：文档控制与范围

<!-- LRS_DOC_META
schema_version: '2.0'
ip_name: watchdog
ip_display_name: 多通道安全增强看门狗
delivery_model: parameterized
register_model: required
ppa_signoff: required
document_version: 1.0.0
status: reviewed
requirement_baseline: watchdog-contract-1.0.0-full-flow-r1
END_LRS_DOC_META -->

## 文档控制

本次模式为 **full-flow**，覆盖适用的 00–20 阶段和 G0–G5。版本为 1.0.0，VLNV 为
`aixsilicon:ip:watchdog:1.0.0`。输入为原始 [watchdog_contract.md](../../watchdog_contract.md)
1.0.0-draft；其 SHA-256 为 `9bbb88115193928f73fe13e899f4713a677bc4a6be1c78a5153299619769f302`。保留输入原文，不用既有 RTL 反向决定需求。
本目录为规范化设计需求编辑入口；原契约是保留的输入基线，二者差异须显式评审。

本基线已按用户对 G0 交接问题的 `continue` 回复登记 reviewed / G0 pass / requirement_freeze=true。
[交接记录](../../reports/full_flow/g0_review.md) 绑定原始回复及批准前文件哈希；不代替后续设计和验证门禁。

## 建模规则

需求 ID 使用 `LRS.<CATEGORY>.WATCHDOG.<原需求族>.<原序号>`，通过 source_ref 保留
原 `WDT-xxx-nnn` 来源。每条需求写明条件、外部结果与验收判据；对同一事务的条件、
成功结果和拒绝结果一起描述，避免拆开后失去优先级。表格中未编号的接口、参数、
配置档及交付约束补充独立 ID，来源定位到原章节。P0 表示适用配置中必须满足。
可裁剪功能关闭时仍验证其拒绝行为，故契约条目不因裁剪而从追踪链消失。

本文中的 C、D、A、E 与状态名是可观察行为的抽象记号，不指定 RTL 存储、FSM 编码
或文件组织。来源中的微架构细节移交 HLD/LLD；寄存器 offset/bit 定义由 SystemRDL
承担，本目录只规定软件可见能力。所有 canonical YAML 由 owner extractor 生成。

## IP Overview

IP 监督软件活性及可信硬件事件，提供普通/窗口计时、启动宽限、预警、受保护服务、
多客户端 GROUP/ALIVE/FLOW 监督、故障升级、恢复和留痕。控制接口为 APB4 32-bit，
计时基于独立 wdt_clk。产品配置包括 STANDARD、SAFETY、SUPERVISOR。

系统边界：IP 提出 IRQ、NMI、局部/系统复位、唤醒和安全状态请求；系统负责复位树、
独立振荡器、电源、任务调度、外部身份授权和请求后的实际安全状态到达时间。
令牌问答不是密码学认证，多客户端编号不是任务隔离；时钟整体停振与掉电由系统覆盖。

## 需求优先级

复位/致命故障/计时边界优先于一般寄存器动作；TIMEOUT 同拍服务不能挽救到期故障，
硬件新事件优先于清除。仅 ALIVE 成功固定周期边界可自动刷新。详细边界见计时分册，
冲突应回到本目录和原来源评审，不能用实现行为覆盖需求。
