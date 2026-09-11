# Watchdog：内部信号接口

## RESET_APB

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.RESET_APB
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.INT.WATCHDOG.RESET_APB
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
protocol: reset_domain
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.POR_APB
applicability:
  expr: 'true'
signals:
- name: prst_n/apb_rst_n
  width: 1 each
  direction: local
  stability: POR保持域与接口域分别使用，不能混复位
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| prst_n/apb_rst_n | 1 each | local | POR保持域与接口域分别使用，不能混复位 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## RESET_WDT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.RESET_WDT
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.INT.WATCHDOG.RESET_WDT
req_ref:
- LRS.FUNC.WATCHDOG.STA.001
- LRS.FUNC.WATCHDOG.STA.002
- LRS.FUNC.WATCHDOG.STA.003
- LRS.FUNC.WATCHDOG.STA.004
- LRS.FUNC.WATCHDOG.STA.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
protocol: reset_domain
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: wrst_n
  width: '1'
  direction: local
  stability: POR异步置低/S级释放，warm不是复位脚
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| wrst_n | 1 | local | POR异步置低/S级释放，warm不是复位脚 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

