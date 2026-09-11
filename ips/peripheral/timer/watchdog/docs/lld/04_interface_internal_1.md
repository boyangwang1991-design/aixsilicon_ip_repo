# Watchdog：内部信号接口

## BUS_COMMAND

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.BUS_COMMAND
owner_module: LLD.MOD.WATCHDOG.BUS
hld_ref:
- HLD.IF.INT.WATCHDOG.BUS_COMMAND
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
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
protocol: bundled_request
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.POR_APB
applicability:
  expr: 'true'
signals:
- name: apb_fire/is_command/busy
  width: 1 each
  direction: local
  stability: 成功完成且!busy才捕获
- name: mailbox_cmd
  width: '104'
  direction: local
  stability: channel4+client5+type3+opcode8+data32+seq32+source16+auth3+hardware1
- name: mailbox_config
  width: '7680'
  direction: local
  stability: 16主字+32*7客户端字，捕获后保持
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| apb_fire/is_command/busy | 1 each | local | 成功完成且!busy才捕获 |
| mailbox_cmd | 104 | local | channel4+client5+type3+opcode8+data32+seq32+source16+auth3+hardware1 |
| mailbox_config | 7680 | local | 16主字+32*7客户端字，捕获后保持 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## WDT_MAILBOX

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.WDT_MAILBOX
owner_module: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.IF.INT.WATCHDOG.WDT_MAILBOX
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.CONS.WATCHDOG.NFR.001
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.NFR.003
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.NFR.005
- LRS.CONS.WATCHDOG.NFR.006
protocol: stable_request
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: req_sync/ack_toggle
  width: S / 1
  direction: local
  stability: 末级req!=ack形成一次待执行
- name: mailbox_cmd/mailbox_config
  width: 104/7680
  direction: local
  stability: 跨域稳定负载，不逐位同步
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| req_sync/ack_toggle | S / 1 | local | 末级req!=ack形成一次待执行 |
| mailbox_cmd/mailbox_config | 104/7680 | local | 跨域稳定负载，不逐位同步 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## SELECTED_COMMAND

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.SELECTED_COMMAND
owner_module: LLD.MOD.WATCHDOG.DISPATCH
hld_ref:
- HLD.IF.INT.WATCHDOG.SELECTED_COMMAND
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
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
protocol: command_event
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: cmd_v
  width: NUM_CHANNELS
  direction: local
  stability: 至多onehot；仅执行边沿有效
- name: selected_cmd/cmd_config
  width: 104/7680
  direction: local
  stability: 软件源邮箱、硬件源实时稳定握手；目的域采样
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| cmd_v | NUM_CHANNELS | local | 至多onehot；仅执行边沿有效 |
| selected_cmd/cmd_config | 104/7680 | local | 软件源邮箱、硬件源实时稳定握手；目的域采样 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

