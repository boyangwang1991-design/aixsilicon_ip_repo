# GPIO 微设计：mailbox控制状态

<!-- LLD_FSM_META
id: LLD.FSM.GPIO.MAILBOX
module_ref: LLD.MOD.GPIO.MAILBOX
hld_ref:
- HLD.MOD.GPIO.MAILBOX
encoding: binary
reset_state: RECOVER
illegal_state_handling: 回到RECOVER；保留传输token和载荷，排空旧应答后才允许新命令
states:
- RECOVER
- READY
- BUSY
transitions:
- from: RECOVER
  to: READY
  condition: 同步填充完成且inflight=0且ack=req
- from: READY
  to: BUSY
  condition: 合法命令接受
- from: BUSY
  to: READY
  condition: 匹配应答返回
- from: BUSY
  to: BUSY
  condition: 超时或AON停钟
- from: READY
  to: RECOVER
  condition: 主暖复位
- from: BUSY
  to: RECOVER
  condition: 主暖复位
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_FSM_META -->

RECOVER的软件READY=0；保持型传输槽即使在RECOVER也继续回收旧ACK。非法状态回RECOVER，不翻转token、不清载荷、不允许新命令。READY与BUSY没有隐含ACK超时取消路径。
