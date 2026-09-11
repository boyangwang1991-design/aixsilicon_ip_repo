# ip-development-suite 实施反馈

本记录随实现更新；只记录观察和建议，不代填技能审批或修改共享技能。

| 编号 | 观察 | 改进建议 | 验收方式 |
|---|---|---|---|
| SK-01 | 07 子技能要求非法 FSM 回到复位，安全契约要求立即最终升级 | 改为由 LLD 决定 fail-safe 行为，禁止通用“回到复位”模板 | 注入非法状态，应保持最终请求 |
| SK-02 | 00–20 完整门禁前置与 partial-task 的直接契约输入边界不够明确 | 增加 contract-to-candidate 路径，列出适用证据和未做的正式门禁 | 无人工冻结可执行候选 RTL，不伪造 META/审批 |
| SK-03 | 寄存器模板主要覆盖普通存储寄存器 | 增加 external register + APB 权限前置 + POR-retained mailbox 示例 | preset 接收后复位仍恰好完成一次；WO 读零 |
| SK-04 | Module UT 模板要求单一时钟直驱，不适合 CDC 模块 | 区分同步叶子与多域 UT，要求停钟、任意相位及独立复位交错 | APB/WDT 比率与在途复位交叉回归 |
| SK-05 | 08 target 列表同时要求 formal 与“无后端不创建” | 统一为能力探测后声明真实 target | 缺工具报告 unavailable，不伪造通过 |
| SK-06 | 初始直接 git 诊断与 workspace 的 aix 状态输出不一致 | 明确 aix 状态是否受目录/ignore/profile 影响，绑定实际契约哈希 | 契约既有修改必须保留；不能仅以 dirty=false 推断干净 |

| SK-07 | CBB 已登记 implemented，但其 core 缺少 paramtype，当前 FuseSoC 拒绝解析 | 复用预检同时验证 CAPI schema；支持构建目录中的只读源引用适配器 | 不修改资产源码，真实编译日志记录依赖来源 |
| SK-08 | VCS 接受的多异步复位条件被 DC/SpyGlass 拒绝 | 复位模板先形成明确 reset net，再使用单一 if(!reset_n) | 三工具都能 elaborate |
| SK-09 | 回归过程中更改 RTL 会使已经执行的结果失效 | runner 在编译前冻结清单并在每次运行后检查，发现变化即失败 | 本次旧运行虽 PASS，因源码改变被正确标记 fail |
| SK-10 | 外部寄存器的生成代码含大量顺序归约赋值 lint 提示 | 区分生成器代码、参数裁剪、用户 RTL；按规则和路径报告，不整体清零 | 保留完整 warnings，禁止以退出码0替代错误数检查 |
