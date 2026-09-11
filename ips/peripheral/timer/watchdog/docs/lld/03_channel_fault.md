# Watchdog：故障、升级与恢复

## 事件分类与优先处理

<!-- LLD_ERROR_META
id: LLD.ERR.WATCHDOG.CHANNEL.EVENTS
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
detection: all current-edge event predicates evaluated before state priority
severity: fatal
response:
  transaction: CANCELED_FAULT when conflicting mutation
  status: sticky cause bitmap and first record
  interrupt: raw & irq_enable
  recovery: trusted reset manager only
END_LLD_ERROR_META -->

事件位使用原契约19类原因。普通策略只允许位1..10，强制TIMEOUT/ALIVE_MISSING/
ALIVE_OVERFLOW/FLOW_SEQUENCE/DEADLINE；安全档另强制EARLY/BAD_KEY/SEQ_TIMEOUT。
位11..14/16/17固定致命。PREWARN/测试/访问/配置拒绝仅记录，不自动刷新或屏蔽请求。
同拍原因先全部OR；主原因顺序11/12/13/14/17→16→1/6→9→8→7→2→3→4→其他。

首次由正常/暂停进入故障时E=0、FAULT_COUNT饱和加一；DIRECT_SYSTEM同拍置final，
LOCAL_THEN_SYSTEM置fault/NMI/alert，LOCAL_DELAY=0时同拍置local。以后每拍E候选sat(E+1)，
达到LOCAL_DELAY置local，达到FINAL_DELAY置final/RESET_PENDING；同一故障的重复
事件、服务、IRQ清除或升级不重置E、不重复增加FAULT_COUNT。致命直接final。

FIRST_FAULT仅在旧valid=0且进入新故障时捕获；来源包含旧状态/配置版本、候选年龄、
全部同拍原因、缺失mask及旧服务序号。超时无唯一客户端则valid=0；不能将当前无关
命令的client/source伪装成故障来源。新故障与DIAG_CLEAR同拍，新故障记录优先。

## 可信恢复握手

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.CHANNEL.RECOVERY
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
applicability:
  expr: 'true'
encoding: binary
reset_state: WAIT_LOW
illegal_state_policy: fatal
illegal_state_handling: detect illegal encoding/protection mismatch, block normal mutation and latch fatal request
states:
- WAIT_LOW
- ARMED
- ACK_HIGH
transitions:
- source: WAIT_LOW
  condition: done=0
  target: ARMED
- source: ARMED
  condition: qualified done and no due/new fault
  target: ACK_HIGH
- source: ACK_HIGH
  condition: done=0
  target: ARMED
- source: ANY
  condition: otherwise
  target: same
END_LLD_FSM_META -->

只有FAULT、local已置、LOCAL_THEN_SYSTEM、允许恢复且未final到期才接收done。还需
已观察done低，避免旧done跨故障重复使用。接受后ack保持直到done低；未到计数上限
时recoveries+1，清活动故障/local/E，保留历史/锁/active，清pending，重新BOOT/RUN。
已达上限时置RECOVERY_LIMIT并final，不授予新宽限；该事件参与同拍原因和首次记录逻辑。
warm清恢复次数，活动通道重启，DISABLED不自动启动；new fault/final_due仍先于warm。

