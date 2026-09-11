# 独立数字诊断链：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.SAFETY
name: 独立数字诊断链
description: 独立数字诊断链的可执行正确性证明
priority: must
req_ref:
- LRS.PERF.WATCHDOG.SAFETY.001
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
design_ref:
- LLD.MOD.WATCHDOG.SAFETY
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

六种受控注入及独立故障活动：主/影子计数、分频/tick、阈值/锁/状态、完整服务资格、到期比较、final保持；覆盖RUN/PAUSED/恢复。

独立判据：注入必须经过真实检测路径；从可观测边沿起≤2WDT周期告警/最终保持；共享错误不可使两路同时刷新；最终保持不依赖普通状态选择；另做综合网表独立性检查。

风险与边界：故障位置×状态×诊断授权×锁×检测延迟；未激活/共因明确不计覆盖。

### LRS.PERF.WATCHDOG.SAFETY.001

对已定义且已激活的数字比较/编码异常，安全配置应在可观测边沿起最多 2 个 WDT 周期产生安全/最终请求。

验收：逐诊断路径测量最坏检测时间；系统请求后安全状态实际到达时间另行预算。

### LRS.SAFE.WATCHDOG.SAF.001

SAFETY 配置应检测计数状态的单点错误；启动、服务、暂停、饱和、恢复均在诊断范围。诊断必须具备独立性，不能由同一失效数据派生两份相同结果后宣称冗余有效。

验收：启动、服务、暂停、饱和、恢复各条件下注入计数单点错误均可检测；共源复制不能充当独立诊断证据。

### LRS.SAFE.WATCHDOG.SAF.002

SAFETY 配置应检测分频/tick、阈值、故障策略、锁和使能的单点完整性错误，不能因公共 tick 失效而永久停止监督却无报告。独立保护表示由 HLD/LLD 选择。

验收：对分频/tick 与阈值、策略、锁、使能保护逐项注入错误，不能因共享故障永久停止监督且无告警。

### LRS.SAFE.WATCHDOG.SAF.003

SAFETY 配置应检测窗口、超时、最终升级判定错误和非法运行状态；任一独立有效到期判定均须提出故障，不一致不得静默恢复正常服务。

验收：分别破坏窗口/超时/升级判断与非法状态，任一路到期能请求故障，不一致不能静默恢复。

### LRS.SAFE.WATCHDOG.SAF.004

命令控制、关键状态以及服务通过判定需要完整性保护；任意单一受保护寄存器翻转不得导致永久关闭监督而无报告。最终请求的锁存路径不得只依赖已经失效的普通通道状态机。

验收：受保护控制/状态/服务判定位单点翻转不能永久关断监督；普通状态损坏后最终请求仍能保持。

### LRS.SAFE.WATCHDOG.SAF.005

对“已定义的数字比较/编码异常”从异常可观测边沿起到 safety_alert/system_reset_req 有效最多 2 个 wdt_clk 周期。该期限不涵盖尚未激活的潜伏故障、模拟问题或时钟整体停振；具体诊断覆盖由故障分析给出。

验收：已激活数字异常至 safety_alert/system_reset_req 不超过 2 个 WDT 周期，潜伏/停钟/模拟故障另列范围。

### LRS.SAFE.WATCHDOG.SAF.006

关键逻辑应避免综合将冗余路径合并，交付相应综合约束和门级检查方法；仅 RTL 上存在两份变量不能作为冗余有效性证据。面积/功耗增加必须按具体配置报告。

验收：实际综合网表证明受保护冗余未合并；各配置报告面积功耗条件，不以 RTL 双变量代替检查。
