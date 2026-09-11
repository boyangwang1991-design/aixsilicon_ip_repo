# Watchdog：外部信号接口

## REQUESTS

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.REQUESTS
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.EXT.WATCHDOG.REQUESTS
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
protocol: sticky_request
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: nmi_req_o/local_reset_req_o
  width: NUM_CHANNELS
  direction: out
  stability: WDT保持请求，接收方完成CDC
- name: system_reset_req_o/safety_alert_o/safe_state_req_o/wake_req_o
  width: 1 each
  direction: out
  stability: WDT通道OR，不依赖pclk
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| nmi_req_o/local_reset_req_o | NUM_CHANNELS | out | WDT保持请求，接收方完成CDC |
| system_reset_req_o/safety_alert_o/safe_state_req_o/wake_req_o | 1 each | out | WDT通道OR，不依赖pclk |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## IRQ

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.IRQ
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.EXT.WATCHDOG.IRQ
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
protocol: synchronized_level
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
applicability:
  expr: 'true'
signals:
- name: irq_o
  width: NUM_CHANNELS
  direction: out
  stability: WDT粘滞IRQ同步后APB电平
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| irq_o | NUM_CHANNELS | out | WDT粘滞IRQ同步后APB电平 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

