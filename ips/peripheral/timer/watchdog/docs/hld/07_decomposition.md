# Watchdog：LLD 工作包与验证交接

LLD 根据六个 L1 边界定义实际内部设计对象和文件映射；本册不指定实现文件、FSM
编码或 procedural 结构。各工作包必须消费同一冻结 LRS/PC/HLD 输入。

| HLD 模块 | LLD 必须冻结的内容 | 核心风险 |
|---|---|---|
| INTEGRATION | 域释放边界、复位作用范围、外部可信事件、逐通道请求汇总、参数裁剪 | warm 事件重放、一个通道解除另一个请求 |
| BUS | APB 接收/错误/权限、staging/选择器、本地完成及快照可见、寄存器行为 | 错误写副作用、跨复位丢事务、客户端窗口混写 |
| TRANSPORT | 请求/应答握手、负载保持、序号、取消时点、合并错误及 RDC | preset 清握手、同步链中 warm 取消、最多一次失败 |
| DISPATCH | 两来源仲裁、单拍唯一命令、路径/目标选择与执行时限 | 反压延后超时、排队事件被当成提前服务 |
| CHANNEL | 所有状态/优先级、年龄/分频、服务/客户端、pending、锁、故障/恢复与快照 | 边界竞争、重载期限、统计/快照不一致 |
| SAFETY | 独立保护演进、比较/非法态、服务判定、真实注入、最终保持与防合并对象 | 共源伪冗余、普通状态失效后解除最终请求 |

LLD_REG_META 逐类定义 SW/HW 行为、更新时机、race 优先序、各类 reset_semantics，
再交 SystemRDL 固化结构。最大参数实例须检查整表快照/配置的组合代价与时限，
不能在微设计阶段悄然引入多拍扫描并维持原来原子性声明。

## 给 VPLAN 的架构关注点

## COMMAND

<!-- HLD_VERIFY_HOOK_META
id: HLD.VHOOK.WATCHDOG.COMMAND
type: formal_candidate
architecture_ref:
- HLD.MOD.WATCHDOG.TRANSPORT
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
description: 在所有复位交错和时钟比下观察接收/执行/取消/返回，证明单在途最多一次。
END_HLD_VERIFY_HOOK_META -->

在所有复位交错和时钟比下观察接收/执行/取消/返回，证明单在途最多一次。

## TIMING

<!-- HLD_VERIFY_HOOK_META
id: HLD.VHOOK.WATCHDOG.TIMING
type: observability
architecture_ref:
- HLD.MOD.WATCHDOG.CHANNEL
- HLD.MOD.WATCHDOG.DISPATCH
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.FUNC.WATCHDOG.SUP.001
- LRS.FUNC.WATCHDOG.SUP.002
- LRS.FUNC.WATCHDOG.SUP.003
- LRS.FUNC.WATCHDOG.SUP.004
- LRS.FUNC.WATCHDOG.SUP.005
- LRS.FUNC.WATCHDOG.SUP.006
- LRS.FUNC.WATCHDOG.SUP.007
- LRS.FUNC.WATCHDOG.SUP.008
- LRS.FUNC.WATCHDOG.SUP.009
- LRS.FUNC.WATCHDOG.SUP.010
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
description: 从独立时基核对候选年龄、主超时/Deadline、服务窗口及调度竞争。
END_HLD_VERIFY_HOOK_META -->

从独立时基核对候选年龄、主超时/Deadline、服务窗口及调度竞争。

## SAFETY

<!-- HLD_VERIFY_HOOK_META
id: HLD.VHOOK.WATCHDOG.SAFETY
type: fault_injection
architecture_ref:
- HLD.MOD.WATCHDOG.SAFETY
- HLD.MOD.WATCHDOG.INTEGRATION
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
description: 对六类实际保护路径检查诊断反应时限和最终保持，并区分 RTL 与网表独立性。
END_HLD_VERIFY_HOOK_META -->

对六类实际保护路径检查诊断反应时限和最终保持，并区分 RTL 与网表独立性。

## CONFIG

<!-- HLD_VERIFY_HOOK_META
id: HLD.VHOOK.WATCHDOG.CONFIG
type: controllability
architecture_ref:
- HLD.MOD.WATCHDOG.BUS
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.CFG.WATCHDOG.PAR.001
- LRS.CFG.WATCHDOG.PAR.002
- LRS.CFG.WATCHDOG.PAR.003
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
description: 观察完整旧/新配置生效、参数裁剪/非法输入、锁与只读快照语义。
END_HLD_VERIFY_HOOK_META -->

观察完整旧/新配置生效、参数裁剪/非法输入、锁与只读快照语义。

