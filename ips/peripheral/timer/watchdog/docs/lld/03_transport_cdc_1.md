# Watchdog：CDC/RDC 结构与时序

## COMMAND

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.COMMAND
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.COMMAND
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
signal_type: bus
implementation:
  method: handshake
  depth: SYNC_STAGES
lossless: true
ordered: true
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
applicability:
  expr: 'true'
END_LLD_CDC_META -->

req_toggle源在APB接收边沿翻转，负载同边沿写入并保持至返回ack。目的S级同步器
仅同步req，末级与ack不同才认新命令；目的在下一可执行边沿读取稳定负载。
数据路径须满足最短控制到捕获窗口的max_delay；不允许仅false-path取消其时序要求。
时钟持续时首级捕获后的S级传播加判定边沿至多S+1；停止目的时钟保持busy和负载。

## REPLY

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.REPLY
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.REPLY
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
signal_type: bus
implementation:
  method: handshake
  depth: SYNC_STAGES
lossless: true
ordered: true
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
applicability:
  expr: 'true'
END_LLD_CDC_META -->

执行边沿锁存result/snapshot并令ack等于请求token，ack经S级返回，APB再统一发布。
busy仅此时清除，reply保持到下一命令执行；源完成后下一次接受才能改负载。
两域POR一起初始化token，单域功能复位不接入链，避免伪完成和重复执行。

## ACCESS_ERROR

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.ACCESS_ERROR
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.ACCESS_ERROR
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
signal_type: event
implementation:
  method: handshake
  depth: SYNC_STAGES
lossless: true
ordered: true
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
END_LLD_CDC_META -->

每通道err_req置1直到同步回来的err_ack为1才置0；目的同步req后仅在req高且旧ack
低时产生一次事件，ack跟随同步req；源新错误与清req同拍以置位优先。连续错误允许
合并，req保持高期间不重复计数；双方回0后才开始新轮。不承诺错误逐次计数。

