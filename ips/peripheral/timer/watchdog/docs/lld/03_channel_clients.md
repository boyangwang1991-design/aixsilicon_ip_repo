# Watchdog：客户端并行监督

## 客户端状态表

<!-- LLD_BUFFER_META
id: LLD.BUF.WATCHDOG.CHANNEL.CLIENTS
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
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
applicability:
  expr: 'true'
type: register_array
depth: NUM_CLIENTS
width: COUNTER_WIDTH + 107
implementation_intent: reg
full_behavior: error
empty_behavior: default
END_LLD_BUFFER_META -->

每项：seen/pending/flow_active 各1位、last_step8、source16、alive16、seq_age32、token32、
elapsed W。总宽为 W+107；客户端按 NUM_CLIENTS 裁剪，软件32槽配置容器未实现项无作用。
无队列读写指针；各客户端时间可同时更新，最多一个选中客户端服务更新。冲突以
新故障优先，restart/refresh 清本轮状态优先于普通时间增量；非选中客户端保持非时间字段。

SINGLE 仅client0，完整合法服务立即刷新。GROUP 合法完成置seen；比较(seen|onehot)
与REQUIRE_MASK，最后一客户端完成当拍刷新并清seen。重复客户端不重复贡献、token不变。
缺失记录为mask & ~seen；主超时前不能人为把未完成客户端视为完成。

ALIVE 计数16位饱和，完整服务先比较旧count>=MAX则当拍ALIVE_OVERFLOW且不计成功；
否则加一。A达到周期期限时先评价全部旧计数的MIN/MAX范围，全满足则自动刷新，
否则ALIVE_MISSING并记录不足mask。该拍 SERVICE 返回EPOCH_BOUNDARY，不计入任一轮，
不额外生成服务错误；这是ALIVE代替普通TIMEOUT判故障的唯一例外。BOOT使用启动期限。

FLOW每客户端START(type1,data0)只能一次，清elapsed并设active；后续STEP(type2)
必须last_step+1且小于LAST_STEP；END(type3)必须等于LAST_STEP并紧邻上步。LAST_STEP=1
允许START后直接END。乱序/重复/缺START产生FLOW_SEQUENCE。START/STEP可在主窗口前，
END同时满足主窗口和DEADLINE_MIN<=候选elapsed<DEADLINE_MAX才置seen、关flow_active。
START后下一未暂停边沿起elapsed饱和加一，达到MAX即DEADLINE优先于END。每客户端
独立推进，其他客户端服务不延后期限；全部必需END后刷新通道。

