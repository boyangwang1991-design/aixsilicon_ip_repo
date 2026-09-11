# Watchdog：单槽源状态机

## 邮箱接收与释放

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.TRANSPORT.SOURCE
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.MOD.WATCHDOG.TRANSPORT
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
applicability:
  expr: 'true'
encoding: binary
reset_state: IDLE
illegal_state_policy: fatal
illegal_state_handling: protected busy/toggle/sequence mismatch raises CDC_PROTOCOL; never replay a command
states:
- IDLE
- WAIT_ACK
transitions:
- source: IDLE
  condition: accepted legal APB command
  target: WAIT_ACK
  action: capture payload/seq; toggle req
- source: WAIT_ACK
  condition: synchronized ack matches current req
  target: IDLE
  action: publish exact reply/seq then release slot
- source:
  - IDLE
  - WAIT_ACK
  condition: POR
  target: IDLE
  action: initialize both ends together
default_transition: hold phase; reject new command while WAIT_ACK
END_LLD_FSM_META -->

逻辑状态由busy实现，另保护busy与req/ack和完成序号之间的一致性。目的端不使用
第二个可独立复位的事务FSM：同步req!=ack表示未完成，每次正常执行或取消只把ack
更新为该req。软件源满时必须保持整个command/config，错误返回不能覆盖在途状态。
preset/warm不是源FSM复位，warm取消仍通过正常应答使WAIT_ACK退出。迟到旧ack在
IDLE无效，下一事务req翻转，不能误清新busy。

