# Watchdog LLD 与 Register Freeze 评审包

基线：`watchdog-lld-1.0.0-full-flow-r1`。当前 **draft / G2 open**，未代填架构/RTL/DV审批。
上游 G0/G1 已获用户批准；本次 G1 记录见 [g1_approval.md](g1_approval.md)。

## 设计交付

[LLD 索引](../../docs/lld/index.md)包含六个模块及按设计对象拆分的完整正文：

- [全局边沿与优先级](../../docs/lld/02_global_constraints.md)、[候选年龄与状态转移](../../docs/lld/03_channel_timing.md)。
- 服务协议、GROUP/ALIVE/FLOW、Deadline、配置版本/pending、解锁额度、锁、恢复和事件留痕。
- 22 个外部/内部信号接口、POR/接口复位、6 条 CDC/RDC 路径、单槽有序邮箱、warm 取消逐拍推导。
- 97 个 RDL 字段的 SW/HW 行为、碰撞优先级、更新时机及复位保留；RDL 保持结构源，未另造地址位表。
- 独立安全机制、一次注入、参数影响、资源/PPA取舍、所有167个设计/映射对象的RTL承接。

每份文档均低于300行和12个META对象；正文中文，顶层平铺，原短实现笔记保留历史入口。
[作者检查](../quality/lld_check.md)通过，输入文件哈希见 lld_check.json。该检查不冒充独立设计评审。

## 关键实施选择

1. 六个逻辑模块保持 HLD 责任边界；top/channel/package 承载物理实现，独立安全锥不靠文件拆分自证。
2. warm 取消标记与请求同步链使用同一 S 深度，明确 E0 至 E(S+1) 边界；单域功能复位不清 toggle。
3. CBB 组合仲裁模式忽略 grant_ack；取消窗口屏蔽 CBB 请求，旁路取消邮箱，避免错误推进公平性指针。
4. 完整服务资格必须独立重算，覆盖 TOKEN/QA/FLOW 等全部路径；新增独立 final_hold，不能只取普通 q.final_req。
5. 正式 CSR 选择原生 `apb4-flat`，传入完整 APB 信号；权限/格式/忙拒绝前不产生业务副作用，WO 读零。

## 寄存器候选证据

PeakRDL 已从当前 RDL 生成 `build/g2_csr_candidate/watchdog_csr{,_pkg}.sv`，原生接口
确认15位地址、32位数据及PSTRB/PPROT。VCS `vlogan` 编译成功，owner 工具记录生成器/
商业工具身份、命令及RDL/输出/日志SHA-256，见[候选寄存器报告](../quality/register_candidate_check.md)。

候选留在build目录；旧passthrough正式路径尚未替换。正式生成需按本次字段行为冻结
结论实施，package/module/adapter必须一起更新，随后生成规范register_check与CSR manifest。
候选报告的pass仅指原生CSR编译检查，不代表G2通过、顶层APB集成通过或完整IP验证通过。

## 回归与剩余工作

- LLD检查：139/139需求、6模块、22接口、97字段、6 FSM、6 CDC，引用/字段/映射闭合。
- 完整套件：165 passed、1默认skip；该VCS测试随后单独执行1 passed，无未执行的该项测试。
- 工作区make check与pre-commit全通过；作者检查器的错误字段、失效上游、未知引用反例均正确拒绝。
- 当前机器G2 fail：缺正式路径的CSR manifest与register_check；G3–G5仍blocked。

批准本包表示冻结本次LLD及寄存器行为，允许正式再生并完成G2技术检查；不提前批准
尚未形成的VPLAN，也不宣称旧RTL/UT已满足新设计。正式检查失败时保留G2 open并修复。
之后继续六卷VPLAN/VP0、RTL安全修复、UT/UVM/CDC/RDC、多配置/覆盖率/RTM及PPA/发布。
