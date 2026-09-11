# Watchdog：通道 FSM 与候选年龄

## 通道控制

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.CHANNEL.CONTROL
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
- LRS.FUNC.WATCHDOG.STA.001
- LRS.FUNC.WATCHDOG.STA.002
- LRS.FUNC.WATCHDOG.STA.003
- LRS.FUNC.WATCHDOG.STA.004
- LRS.FUNC.WATCHDOG.STA.005
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
applicability:
  expr: 'true'
encoding: binary
reset_state: DISABLED
illegal_state_policy: fatal
illegal_state_handling: detect illegal encoding/protection mismatch, block normal mutation and latch fatal request
states: &id001
- DISABLED
- BOOT
- RUN
- PAUSED
- FAULT
- RESET_PENDING
transitions:
- source: *id001
  condition: fatal or final_due
  target: RESET_PENDING
  action: latch final request
- source:
  - BOOT
  - RUN
  - PAUSED
  condition: new supervision fault and DIRECT_SYSTEM
  target: RESET_PENDING
  action: capture first; discard pending
- source:
  - BOOT
  - RUN
  - PAUSED
  condition: new supervision fault and LOCAL_THEN_SYSTEM
  target: FAULT
  action: capture first; start escalation
- source: &id002
  - BOOT
  - RUN
  - PAUSED
  - FAULT
  - RESET_PENDING
  condition: trusted warm and BOOT_EN, no higher-priority event
  target: BOOT
  action: restart, clear recovery count, preserve history/locks
- source: *id002
  condition: trusted warm and not BOOT_EN, no higher-priority event
  target: RUN
  action: restart, clear recovery count, preserve history/locks
- source: FAULT
  condition: qualified local recovery below limit and BOOT_EN
  target: BOOT
  action: restart and acknowledge
- source: FAULT
  condition: qualified local recovery below limit and not BOOT_EN
  target: RUN
  action: restart and acknowledge
- source: FAULT
  condition: qualified recovery exceeds limit
  target: RESET_PENDING
  action: record RECOVERY_LIMIT and latch final
- source:
  - BOOT
  - RUN
  condition: successful refresh
  target: RUN
  action: clear round, atomically apply approved pending
- source: DISABLED
  condition: valid START and BOOT_EN
  target: BOOT
  action: restart
- source: DISABLED
  condition: valid START and not BOOT_EN
  target: RUN
  action: restart
- source:
  - BOOT
  - RUN
  condition: valid STOP
  target: DISABLED
  action: clear incomplete service
- source:
  - BOOT
  - RUN
  condition: authorized pause
  target: PAUSED
  action: save resume state
- source: PAUSED
  condition: pause removed and resume_state=BOOT
  target: BOOT
  action: resume counting on next edge
- source: PAUSED
  condition: pause removed and resume_state=RUN
  target: RUN
  action: resume counting on next edge
reset_overrides:
  AUTO_START and BOOT_EN: BOOT
  AUTO_START and not BOOT_EN: RUN
default_transition: hold current state; evolve only permitted counters/records
END_LLD_FSM_META -->

状态编码依次为0..5，6/7立即产生 STATE_INVALID；SAFETY 下合法编码但反码不符也致命。
优先表从上到下匹配，未命中保持。PAUSED 保存进入前 BOOT/RUN；恢复边沿不加年龄，
进入暂停边沿仍完成候选到期检查。FAULT 的普通服务/配置均无效；最终状态只接受
可信 warm/POR，且同拍新的致命或监督故障仍优先。

## 主与影子候选年龄

<!-- LLD_DATAPATH_META
id: LLD.DP.WATCHDOG.CHANNEL.AGE
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
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
  expr: 'true'
input_width: COUNTER_WIDTH + PRESCALE_WIDTH
output_width: COUNTER_WIDTH
latency: 0
signed: false
saturation: true
END_LLD_DATAPATH_META -->

运行旧状态为 BOOT/RUN 且初始化完成时：tick=(D=P)，Dnext=tick?0:D+1，
A=tick?sat(C+1):C。影子正向解释 Cs=~Cbar，Ds=~Dbar，独立 Ps=~Pbar；由
Ds/Ps 产生 ticks 并从 Cs 计算 As，不读取主 tick。未运行 C/D 保持。
完整服务合法区间为 BOOT 的[0,BOOT_TIMEOUT)或 RUN 的[WIN_MIN,TIMEOUT)；所有
比较用 A。超时边沿服务失败；WIN_MIN 边沿完整服务可成功。成功刷新 C/D 归零，
否则 C=A。启动/刷新边沿本身不计数，因此未暂停期限恰为 T*(P+1) 个边沿。
预警只在 RUN、enable、此前本轮未预警且 A>=PRETIMEOUT 时置；成功刷新同拍抑制
新预警，旧 raw 不清。ALIVE 还要求至少一客户端未达 MIN。

