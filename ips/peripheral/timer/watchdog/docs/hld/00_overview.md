# Watchdog 高层设计：文档控制与架构目标

<!-- HLD_DOC_META
schema_version: '2.0'
ip_name: watchdog
delivery_model: parameterized
lrs_baseline: watchdog-contract-1.0.0-full-flow-r1
document_version: 1.0.0
status: reviewed
architecture_baseline: watchdog-hld-1.0.0-full-flow-r1
END_HLD_DOC_META -->

## 输入与状态

本文从已完成 G0 交接的 139 条 LRS 和完整 16 参数 PC 合同建立架构。
LRS 的真实交接记录见 [g0_review](../../reports/full_flow/g0_review.md)；PC 的
188 个有界配置计划及结构/语义校验见 [参数矩阵](../../reports/quality/param_matrix.md)
和 [语义报告](../../reports/quality/param_semantic_check.md)。配置合同有效不等于 RTL
已对这些配置完成验证。输入模型与文档哈希由本阶段检查报告绑定。

HLD 当前 reviewed，G1 pass，architecture_freeze=true；依据用户明确批准登记，见 reports/full_flow/g1_approval.md。
旧 architecture.md 的短摘要改为导航，原文留在历史报告中，避免两份架构事实源。
架构定义编辑入口为本目录正文与分对象 META，五个 canonical 模型由 extractor 生成。

## 复杂度与范围

该 IP 有两个不相关时钟域、多个功能复位边界、最多 16 通道与每通道 32 客户端、
6 种外部运行状态、多种服务/监督模式、跨域原子事务和安全增强，按复杂 IP 组织。
冻结的是六个 L1 逻辑责任边界；其实现可由 LLD 进一步分解或映射到共同顶层，HLD
不决定 SystemVerilog 文件组织、寄存器位表或内部状态编码。

架构目标是独立监督时限、最多一次命令执行、配置/快照一致性、受控恢复、故障保持
和参数化可验证性。IP 提出安全/复位请求；系统提供可信授权、独立时基、复位完成
事件以及请求后的安全状态到达保证。没有完整系统假设不能宣称安全等级达成。

## 架构原则

1. pclk 域只拥有接口、staging、选择器和可读镜像；权威监督状态在 wdt_clk 域。
2. 监督计时与升级不排队，不依赖 APB 进度、邮箱空闲或软件处理中断。
3. 接收、执行、返回三个状态分开；单在途语义保留 across preset，暖复位有明确取消点。
4. 完整配置和整表快照分别原子提交/捕获；多位数据不逐位同步。
5. 安全诊断与最终请求保持具有独立责任，普通状态失效不能让致命故障静默消失。
6. 能力裁剪保持软件地址与错误语义，所有未实现能力必须拒绝且不改变监督状态。
