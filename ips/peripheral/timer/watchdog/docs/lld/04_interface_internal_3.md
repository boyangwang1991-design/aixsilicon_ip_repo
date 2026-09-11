# Watchdog：内部信号接口

## SAFETY_CONTEXT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.SAFETY_CONTEXT
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.INT.WATCHDOG.SAFETY_CONTEXT
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
protocol: integrity_observation
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: SAFETY_EN == 1
signals:
- name: q/n protected state
  width: parameter dependent
  direction: local
  stability: 旧状态/独立候选/原始请求分别观察
- name: raw_service_inputs/refresh_decisions
  width: structured
  direction: local
  stability: 完整服务谓词须双路径核验
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| q/n protected state | parameter dependent | local | 旧状态/独立候选/原始请求分别观察 |
| raw_service_inputs/refresh_decisions | structured | local | 完整服务谓词须双路径核验 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## SAFETY_FAULT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.SAFETY_FAULT
owner_module: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.IF.INT.WATCHDOG.SAFETY_FAULT
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
protocol: fatal_request
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: SAFETY_EN == 1
signals:
- name: fatal_events
  width: '19'
  direction: local
  stability: 实际检测原因OR
- name: independent_final_request
  width: 1 per channel
  direction: local
  stability: 普通FSM失效仍保持并汇总
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| fatal_events | 19 | local | 实际检测原因OR |
| independent_final_request | 1 per channel | local | 普通FSM失效仍保持并汇总 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## CHANNEL_OUTPUT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.INTERNAL.CHANNEL_OUTPUT
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.INT.WATCHDOG.CHANNEL_OUTPUT
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
protocol: status_request
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: irq/fault/local/final/alert/wake
  width: 1 each per channel
  direction: local
  stability: 各自状态所有权，跨通道只OR不相互清除
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| irq/fault/local/final/alert/wake | 1 each per channel | local | 各自状态所有权，跨通道只OR不相互清除 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

