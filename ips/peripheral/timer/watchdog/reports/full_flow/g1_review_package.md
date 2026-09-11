# Watchdog G1 架构评审包

评审对象：`watchdog-hld-1.0.0-full-flow-r1`。当前 **draft / G1 open / 未冻结**。
输入为已交接 G0 的 139 条 LRS 和 PC 完整 16 项参数合同，原契约正文未修改。

## 可审阅设计

- [HLD 索引](../../docs/hld/index.md)：24 个平铺文件，按模块/接口/功能/域/安全语义分册。
- [寄存器架构](../../docs/hld/03_register_architecture.md)：组、所有权、staging/active/pending、快照、锁与错误模型。
- [性能预算](../../docs/hld/04_performance.md)与[CDC/RDC](../../docs/hld/04_clock_cdc.md)：明确有限 APB 响应、单在途握手、稳定负载和复位交错；频率仅为表征输入。
- [安全机制](../../docs/hld/05_safety.md)：独立演进/比较与保持型最终请求；不把复制主结果当成独立检测。
- [LLD 工作包](../../docs/hld/07_decomposition.md)：六个 L1 模块的后续设计责任，未提前固定 RTL 文件/FSM 编码。
- [风险与检查清单](../../docs/hld/08_risk_checklist.md)、[复用计划](../../docs/reuse_plan.md)。

## 需确认的架构选择

1. 每通道并行监督、客户端并行评价/原子快照；用面积换固定时限，最大配置的真实时序留待 LLD/综合验证。
2. 单在途、POR 保持邮箱；APB 接口复位不撤销事务，可信 warm 取消尚未执行事务并保留可查询结果；软件忙拒绝不排队。
3. 独立安全检测与最终请求路径；DIAG_INJECT_EN=1 且 SAFETY_EN=0 仍可构建，对未实现检测对象的注入按不支持拒绝，不伪造诊断成功。
4. APB 原生 15 位地址/32 位数据、保留 PPROT/PSTRB；现有两个 HWIF profile 不直接匹配，LLD 显式绑定基础契约和差异。
5. 两源 RR 使用现有 CBB；APB VIP 预备复用并单独 qualification，尚未完成的依赖质量、CDC/RDC、网表独立性和真实 PPA 继续作为必需证据。

## 已完成检查与限制

[HLD 作者检查](../quality/hld_check.md)：139/139 需求有模块承接，16/16 参数有影响对象；
6 模块、11 外部接口、11 内部接口、6 域、6 CDC/RDC 路径，引用和五个派生模型一致。
源文件哈希见 hld_check.json。多接收者接口明确所有端点并核对模块反向引用。

[PC 输入检查](../quality/param_semantic_check.md)：188/188 项符合输入合同预期；不代表
188 个配置已编译或仿真。PC 工具相关 114 项回归通过，套件结构检查 24 skills 无错误/警告。
机器 G0/G1 pass 只表示 evaluator 的结构检查通过；真实 G1 仍 open。

评审结论只覆盖本次 HLD 基线，不提前批准 G2/VP0，也不替代 RTL/验证/发布证据。
本包由作者整理，未伪造独立评审人。收到明确架构冻结结论后进入 LLD/寄存器阶段。
