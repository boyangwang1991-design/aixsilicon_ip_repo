# Watchdog：配置事务、版本与解锁

## 活动与待生效配置

<!-- LLD_BUFFER_META
id: LLD.BUF.WATCHDOG.CHANNEL.CONFIG
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
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
applicability:
  expr: 'true'
type: register_array
depth: 2
width: (16 + 32*7)*32
implementation_intent: reg
full_behavior: error
empty_behavior: default
END_LLD_BUFFER_META -->

两槽分别active和pending完整配置；总线另有staging和稳定mailbox_config，不共享可变
数组引用。COMMIT在目的域先检查授权/额度/CFG_LOCK/状态，再原子校验全部适用字段。
高位、支持能力、模式、阈值、mask、策略及每个已选客户端均按LRS §16.5检查；未使用
模式的ALIVE/FLOW字段允许保留，不因此拒绝合法配置。失败整组保持active/版本，置CFG_REJECTED。

DISABLED合法提交当拍应用。RUN且ALLOW_RUNTIME_UPDATE且无pending时，仅PRESCALE/
WIN_MIN/TIMEOUT/PRETIMEOUT可与active不同；将新配置这些字段临时替换为旧值后与整份
active（包括所有客户端）比较，以检出未允许变更。成功提交submitted_version+1，
pending_version取新值，返回PENDING_APPLY。下一旧配置成功刷新边沿先按旧值判合法，
再整体切pending及版本并清C/D。第二次提交拒绝，BOOT/PAUSED/FAULT/最终态均不接受。
取消清pending，不回退submitted_version，允许版本间隙；故障/warm取消pending。

## 解锁额度和只置位锁

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.CHANNEL.UNLOCK
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
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
applicability:
  expr: 'true'
encoding: binary
reset_state: CLOSED
illegal_state_policy: fatal
illegal_state_handling: detect illegal encoding/protection mismatch, block normal mutation and latch fatal request
states:
- CLOSED
- WAIT_KEY2
- CREDIT
transitions:
- source: ANY
  condition: authorized UNLOCK1
  target: WAIT_KEY2
- source: WAIT_KEY2
  condition: same-source UNLOCK2 at age 1..32
  target: CREDIT
- source: CREDIT
  condition: sensitive command or expiry64
  target: CLOSED
- source: ANY
  condition: invalid unlock / warm / POR
  target: CLOSED
- source: ANY
  condition: otherwise
  target: same
END_LLD_FSM_META -->

解锁常量依次0xC0DE1234、0x3F21EDCB。首笔记录source和年龄0，候选年龄1..32接受
第二笔；在第32边沿无合格第二笔即失效。额度成功边沿年龄0，第64边沿到期优先于
敏感命令；年龄以未分频WDT推进且不暂停。CFG_COMMIT/START/STOP/LOCK/DIAG_CLEAR/
FAULT_INJECT在目的域处理时消费一额度，即使失败也消费；staging/普通诊断不消费。
LOCK_SET只OR写入四锁，硬CFG锁POR值来自参数。CFG_LOCK不阻止合法active的START，
ENABLE_LOCK禁止STOP，DEBUG_LOCK禁调试暂停，DIAG_LOCK禁注入；只有POR清锁。

