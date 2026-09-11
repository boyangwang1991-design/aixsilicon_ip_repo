# Watchdog：内部信号接口

## CHANNEL_REPLY

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.CHANNEL_REPLY
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.INT.WATCHDOG.CHANNEL_REPLY
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
protocol: completion_record
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: channel_result
  width: 8 per channel
  direction: local
  stability: 本拍命令结果
- name: channel_snap
  width: 19968 per channel
  direction: local
  stability: 112主字+32*16客户端字的更新后快照
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| channel_result | 8 per channel | local | 本拍命令结果 |
| channel_snap | 19968 per channel | local | 112主字+32*16客户端字的更新后快照 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## APB_REPLY

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.APB_REPLY
owner_module: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.IF.INT.WATCHDOG.APB_REPLY
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.IDENTITY.001
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
protocol: held_response
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.POR_APB
applicability:
  expr: 'true'
signals:
- name: ack_sync
  width: S
  direction: local
  stability: POR保持应答同步链
- name: reply_result/reply_snapshot
  width: 8/19968
  direction: local
  stability: 应答发布前稳定至下个命令执行
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| ack_sync | S | local | POR保持应答同步链 |
| reply_result/reply_snapshot | 8/19968 | local | 应答发布前稳定至下个命令执行 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## ACCESS_ERROR

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.ACCESS_ERROR
owner_module: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.IF.INT.WATCHDOG.ACCESS_ERROR
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
protocol: coalesced_event
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: err_req/err_ack
  width: NUM_CHANNELS each
  direction: local
  stability: 独立四相合并事件，不占命令邮箱
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| err_req/err_ack | NUM_CHANNELS each | local | 独立四相合并事件，不占命令邮箱 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

