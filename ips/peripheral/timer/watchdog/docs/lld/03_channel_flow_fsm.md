# Watchdog：FLOW 状态转移

## 客户端流程状态

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.CHANNEL.FLOW
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
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
applicability:
  expr: 'true'
encoding: binary
reset_state: IDLE
illegal_state_policy: fatal
illegal_state_handling: invalid protected state produces fatal; protocol order violation records FLOW_SEQUENCE
states:
- IDLE
- ACTIVE
- COMPLETE
transitions:
- source: IDLE
  condition: valid START with data0
  target: ACTIVE
  action: elapsed=0,last_step=0
- source: ACTIVE
  condition: valid next STEP below LAST_STEP
  target: ACTIVE
  action: advance last_step only
- source: ACTIVE
  condition: valid final END within both windows
  target: COMPLETE
  action: seen=1; close elapsed
- source:
  - IDLE
  - ACTIVE
  - COMPLETE
  condition: successful full round refresh or trusted restart
  target: IDLE
  action: clear round
- source:
  - IDLE
  - ACTIVE
  - COMPLETE
  condition: wrong sequence or deadline
  target: IDLE
  action: report fault; no healthy contribution
default_transition: hold logical state; elapsed increments only while ACTIVE and running
END_LLD_FSM_META -->

每个被选择客户端由flow_active/seen编码逻辑状态：IDLE=00、ACTIVE=10、COMPLETE=01；
11不合法，保护检查不能默许这种状态。协议错序与编码翻转不同：错序记录FLOW_SEQUENCE
并按强制策略故障；编码不一致直接安全故障。STEP不停止未分频Deadline；COMPLETE
不能第二次START，只有整轮刷新或可信重启清seen。完整转移优先于默认保持，主故障
优先于所有健康贡献。NA：不支持分支图、多路径或重入流程。

