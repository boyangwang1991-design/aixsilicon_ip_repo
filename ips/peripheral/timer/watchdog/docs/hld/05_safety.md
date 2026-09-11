# Watchdog：安全机制与故障边界

## 独立计时/分频保护

<!-- HLD_SAFETY_META
id: HLD.SAFE.WATCHDOG.TIMEBASE
name: 独立计时/分频保护
protects:
- HLD.MOD.WATCHDOG.CHANNEL
failure_target:
- 计数或分频单点异常、tick 使能失效
detection_strategy: 独立状态演进和比较，包含启动/刷新/暂停/饱和/恢复条件
response_strategy: 致命不一致立即提出最终请求
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_HLD_SAFETY_META -->

诊断不能仅由主值组合派生影子，不能共同依赖一个失效 tick 使能。

## 配置、锁与控制完整性

<!-- HLD_SAFETY_META
id: HLD.SAFE.WATCHDOG.CONFIG_CONTROL
name: 配置、锁与控制完整性
protects:
- HLD.MOD.WATCHDOG.CHANNEL
- HLD.MOD.WATCHDOG.TRANSPORT
failure_target:
- 阈值/策略/锁/使能/命令控制损坏
detection_strategy: 独立编码副本或等效校验，持续核对包括暂停状态
response_strategy: 固定致命响应，不受普通策略屏蔽
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_HLD_SAFETY_META -->

关键配置与锁在 WDT 域为权威；APB 暂存不用于自证活动值正确。

## 比较与非法状态检测

<!-- HLD_SAFETY_META
id: HLD.SAFE.WATCHDOG.COMPARE_STATE
name: 比较与非法状态检测
protects:
- HLD.MOD.WATCHDOG.CHANNEL
failure_target:
- 到期判定不一致或非法状态
detection_strategy: 窗口/超时/最终升级独立判定及非法编码检测
response_strategy: 任一路有效到期可请求故障，不一致本身致命
req_ref:
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_HLD_SAFETY_META -->

非法状态不能归零后静默正常服务；主状态损坏不能清最终保持。

## 服务通过判定完整性

<!-- HLD_SAFETY_META
id: HLD.SAFE.WATCHDOG.SERVICE_PATH
name: 服务通过判定完整性
protects:
- HLD.MOD.WATCHDOG.CHANNEL
- HLD.MOD.WATCHDOG.DISPATCH
failure_target:
- 命令/身份/服务成功控制被单点破坏
detection_strategy: 观测原始合法性条件并保护通过判定，不以普通 refresh 作为唯一诊断依据
response_strategy: 单点故障不得永久关闭监督且无报告
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
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_HLD_SAFETY_META -->

诊断边界包含原始事件、授权、时间窗和完整服务；具体独立实现交 LLD。

## 最终请求保持独立性

<!-- HLD_SAFETY_META
id: HLD.SAFE.WATCHDOG.FINAL_REQUEST
name: 最终请求保持独立性
protects:
- HLD.MOD.WATCHDOG.INTEGRATION
- HLD.MOD.WATCHDOG.CHANNEL
failure_target:
- 普通通道状态或恢复控制异常
detection_strategy: 独立致命检测及保持路径，恢复事件按可信条件处理
response_strategy: 最终请求保持到规定 POR/可信系统恢复
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_HLD_SAFETY_META -->

系统响应路径和时钟/电源共因在 IP 外分析；RTL 变量双份不是物理独立性证据。

## 检测覆盖与共因

覆盖范围是指定数字状态/配置/控制/比较异常，检测时限从异常成为 WDT 可观察状态
计算；潜伏错误、完整时钟停振、电源失效、外部恢复管理器伪造不自动被这些机制覆盖。
系统需独立时基/电源/复位安全论证，安全手册列出具体故障模型和未覆盖项，不虚构
ASIL 或固定诊断覆盖百分比。

## 诊断与裁剪

DIAG_INJECT_EN 控制入口，SAFETY_EN 控制增强检测对象。只对实际实现对象允许真实
注入，未实现对象须按未支持能力拒绝，不允许直接置结果位冒充检测。对于
DIAG_INJECT_EN=1、SAFETY_EN=0 的合法构建组合，LLD 必须核对能力寄存器和拒绝行为，
不得把“入口使能但没有检测对象”当成成功测试；此解释作为 G1 审查关注点保留。
IRQ_TEST 独立于增强注入，仅检验中断通路，不能证明计时/冗余覆盖。

## 物理实现交接

保护寄存器与比较锥的防合并、独立 tick 路径、最终请求保持、跨域完整性输入需在
真实映射网表检查。综合约束只作用于有理由的保护对象，不能用全局 dont_touch 掩盖
未实现独立性；面积/时序/功耗代价随配置披露。
