# 安全 APB Demux 高层架构

<!-- HLD_DOC_META
schema_version: '2.0'
ip_name: apb_secure_demux
delivery_model: parameterized
lrs_baseline: ASD-LRS-1.0.0-USER-APPROVED
document_version: 1.0.0
status: draft
architecture_baseline: ASD-HLD-1.0.0-DRAFT
END_HLD_DOC_META -->

## 输入与状态

输入为已批准的 LRS、CR-001～CR-003 和 19-PC 参数合同。75 个配置检查点的项目语义校验通过；此结果不代表 RTL 执行。
本 HLD 是待独立评审的设计，不借用 G0 的批准作为 G1 冻结。

## 架构目标与边界

用一个上游 APB4 管理事务顺序；在输出 SETUP 前实现权限阻断，保持本地响应和两种转发延迟合同。
权限存储、更新入口、诊断与通知分别由明确 owner 管理，避免日志堵塞反向影响访问控制。
本 IP 不负责身份真实性、系统旁路封堵、外部 CDC、SoC 复位控制、DFT 安全或工艺签核。

## 复杂度

169 条逻辑需求、可变规模权限表、原子更新、故障锁存和同周期日志竞争形成较高耦合，按复杂 IP 组织评审。
虽然只有一个功能时钟域，不能因此将其视为简单路由器。九个架构责任块表达行为所有权，不规定 RTL 文件数量。

## 输入假设

MASTERID/PPROT 的绑定、同步释放复位和硬件 DFX 授权由可信集成保证。队列位于上游桥时，策略在请求到达本 IP 时生效。
实际端口映射、管理主体、复位权限和物理时序约束由集成提供；PC 示例不能成为静默默认配置。
