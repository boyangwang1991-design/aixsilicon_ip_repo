# Full-flow 当前执行状态

用户持续授权：`finish the rest, you don't have to ask for permission`。后续无需逐阶段再请求许可，技术门禁仍以实际证据检查。本页是执行进度，不代替 G0–G5 质量报告。

- G0/G1：已检查冻结，LRS 139 条，HLD 24 份文档/六个 L1 模块。
- G2：已检查冻结，68 份 LLD/167 对象/97 字段；正式 apb4-flat CSR 再生并经 VCS 编译，异步 APB 回归通过。
- VP0：已检查冻结，74 份 VPLAN/20 features/20 TC/12 assertions，139 需求全部规划，188 配置关联。快照 preset 保留语义已与 LLD 对齐并重新抽取检查，见 `vp0_snapshot_correction_check_retry.log`。
- RTL：实现完整独立服务资格复算、final_hold 独立保持、扩大控制完整性保护、取消窗口仲裁屏蔽、COMMIT 错误优先级修正。五个模块测试配置实际通过，见 `g3_safety_channel32_retry2.log` 与 `g3_safety_remaining_ut.log`。
- 真实 28nm 综合：`g3_dc_standard_holdfix.log` 对应 DC 原始报告中 WATCHDOG_SYNTHESIS PASS，未映射 0、锁存器 0，setup 最小裕量 2.47005 ns、hold 最小裕量 0.00550701 ns。约束为 pclk 100 MHz/WDT 50 MHz；无 SAIF，功耗是工具默认活动率估计。此项不是三产品 PPA 签核。
- SpyGlass：默认/全功能配置均 0 Fatal/0 Error；全功能原始 2412 warnings 的分类闭合仍待完成。保留 FuseSoC 对 warning 返回的失败状态。
- VIP：直接复用资产仓 APB VIP，构建元数据适配留在 build。项目资格验证实际 242 checks/0 UVM Error/Fatal，见 `vip_qualification_retry.log`；不声明该 developing VIP 已获得全局 qualification。
- UVM：已实现实际 VIP master/monitor/checker/coverage/RAL、独立事件历史 RM、双流 scoreboard、控制 agent、18 个用例入口及 Makefile/哈希运行器。BUS smoke 2153 次比较通过；四种服务算法含每种三次成功目标、错误服务与异步 POR，24551 次比较通过，见 `reports/uvm/20260911_044816_738164/manifest.json`。其余 17 个全功能用例正在逐项运行，不能据入口存在声明 VPLAN 已全部覆盖。
- Formal：本机 VC Formal 完成工具启动和 RTL/SVA 解析；首轮在证明引擎启动时退出 4、未生成性质结果，已记录失败并诊断。不是形式证明通过，见 `reports/formal/20260911_044810/manifest.json`。

G3/G4/G5 尚未完成：仍需 lint 分类闭合、CDC/RDC 与形式证明、剩余 UVM 场景和断言/功能交叉覆盖、多配置实际执行、最终 RTM、软件与集成安全文档、三产品 PPA 和发布打包。历史失败日志及每次构建身份全部保留。
