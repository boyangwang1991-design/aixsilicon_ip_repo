# Watchdog：外部信号接口

## WDT_CLOCK_RESET

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.WDT_CLOCK_RESET
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.EXT.WATCHDOG.WDT_CLOCK_RESET
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
protocol: clock_reset
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: wdt_clk
  width: '1'
  direction: in
  stability: 独立计时上升沿
- name: por_n
  width: '1'
  direction: in
  stability: 两域共同异步初始化，同步独立释放
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| wdt_clk | 1 | in | 独立计时上升沿 |
| por_n | 1 | in | 两域共同异步初始化，同步独立释放 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## POWER_DEBUG

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.POWER_DEBUG
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.EXT.WATCHDOG.POWER_DEBUG
req_ref:
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
protocol: trusted_level
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: sleep_req_i/debug_req_i/debug_auth_i
  width: 1 each
  direction: in
  stability: 已同步WDT电平，暂停规则组合判定
- name: pause_ack_o
  width: NUM_CHANNELS
  direction: out
  stability: 实际PAUSED状态电平
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| sleep_req_i/debug_req_i/debug_auth_i | 1 each | in | 已同步WDT电平，暂停规则组合判定 |
| pause_ack_o | NUM_CHANNELS | out | 实际PAUSED状态电平 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## WARM_EVENT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.WARM_EVENT
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.EXT.WATCHDOG.WARM_EVENT
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
protocol: trusted_event
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: warm_reset_evt_i
  width: '1'
  direction: in
  stability: 已同步单周期可信事件，不能持续重启
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| warm_reset_evt_i | 1 | in | 已同步单周期可信事件，不能持续重启 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

