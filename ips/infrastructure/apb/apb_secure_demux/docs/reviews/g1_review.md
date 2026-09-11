# G1 架构评审包

G0 已按用户“approve, continue”批准。当前请求评审的是新完成的 HLD，不重复请求 G0 执行授权。

## 本轮需评审的架构决策

1. 九个责任块：FRONTEND、DECODE、ACCESS、ROUTE、CSR、POLICY、EVENTS、IRQ、DFX。它们表达所有权，不预先规定 RTL 文件拆分。
2. 在下游 SETUP 前准入；ROUTE 单事务、无后台队列，按 REGISTER_MODE 保持零/单额外等待契约；FATAL 不取消在途访问。
3. POLICY 独占 active/shadow、原子提交、锁、版本与完整性；CSR 主错误与 COMMIT_STATUS 独立排序。
4. EVENTS 不向总线或权限路径施加反压；IRQ 捕获全部候选事件；日志队列支持深度0/1与清空/POP/新事件竞争。
5. 复用 parity CBB；FIFO 由于接口和深度不匹配由 IP 实现。APB VIP/HWIF 差异保留明确接入缺口。

## 可审核材料

- docs/hld/index.md：架构分册、接口、寄存器组、域、性能/容量、安全、DFX、参数影响与 LLD 工作包。
- reports/quality/hld/architecture_audit.json：169 个需求到9个模块的分配、引用与文件规模检查。
- reports/quality/param_semantic_check.json：75 个参数检查点的结构和地址语义结果，含11个预期失败配置；不代表 RTL 执行。
- docs/reuse_plan.md：当次资产读取、匹配决策与未完成资格项。
- reports/quality/hld/review_identity.json：本次评审文件哈希。

## 不属于本次批准的结论

尚无 LLD/Register Freeze、RTL/形式/UVM/PPA/发布验证结果。CR-004 受控协议核验和 CR-005 实际集成/工艺输入仍待各 owner 完成。
现有 evaluator 会把结构完整的 HLD 标为 G1 pass，却不消费 architecture_freeze；实际 G1 以 HLD_GATE_META 的 open/false 为准，不能使用机器报告代替审批。
