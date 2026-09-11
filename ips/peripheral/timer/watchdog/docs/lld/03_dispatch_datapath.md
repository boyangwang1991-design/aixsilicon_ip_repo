# Watchdog：取消与正常请求隔离

## 请求屏蔽和命令选择

<!-- LLD_DATAPATH_META
id: LLD.DP.WATCHDOG.DISPATCH.SELECT
module_ref: LLD.MOD.WATCHDOG.DISPATCH
hld_ref:
- HLD.MOD.WATCHDOG.DISPATCH
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
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
applicability:
  expr: 'true'
input_width: two request bits and command payloads
output_width: onehot channel enable + command_t
latency: 0
signed: false
END_LLD_DATAPATH_META -->

采用REQ_TYPE=0、FAST_GRANT=0、GRANT_ACK_EN=0的组合轮询。CBB在此模式忽略
grant_ack_i并每个正常授予更新指针，因此在warm/取消窗口将送入CBB的req_i两位
同时屏蔽为0；mailbox取消由旁路独立完成，不借用grant。窗口结束后恢复原有效请求。
这样取消不消费硬件事件、不更新公平性指针，也不会锁住一个后来被取消的grant。
hw_evt_ready在屏蔽期间为0，来源必须保持payload；计时/检测继续。正常时有效
mailbox和硬件请求最多一条被执行，grant到目标索引要先范围检查，不能越界选择。

