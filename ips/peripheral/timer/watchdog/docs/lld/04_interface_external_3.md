# Watchdog：外部信号接口

## RECOVERY

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.RECOVERY
owner_module: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.IF.EXT.WATCHDOG.RECOVERY
req_ref:
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
protocol: four_phase_handshake
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: 'true'
signals:
- name: recovery_done_i
  width: NUM_CHANNELS
  direction: in
  stability: 保持直到ack，随后回0
- name: recovery_ack_o
  width: NUM_CHANNELS
  direction: out
  stability: 合格恢复后保持到done回0
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| recovery_done_i | NUM_CHANNELS | in | 保持直到ack，随后回0 |
| recovery_ack_o | NUM_CHANNELS | out | 合格恢复后保持到done回0 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## HW_EVENT

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.HW_EVENT
owner_module: LLD.MOD.WATCHDOG.DISPATCH
hld_ref:
- HLD.IF.EXT.WATCHDOG.HW_EVENT
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
protocol: ready_valid
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: SUPPORT_HW_EVENT == 1
signals:
- name: hw_evt_valid/hw_evt_ready
  width: 1 each
  direction: in/out
  stability: valid&&ready消费一次；stall时不撤销payload
- name: hw_evt_channel/client/type
  width: 4/5/3
  direction: in
  stability: 同域目标与事件类型
- name: hw_evt_data
  width: '32'
  direction: in
  stability: 密钥/响应/检查点
- name: hw_evt_source
  width: SOURCE_WIDTH
  direction: in
  stability: 可信硬件事件身份
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| hw_evt_valid/hw_evt_ready | 1 each | in/out | valid&&ready消费一次；stall时不撤销payload |
| hw_evt_channel/client/type | 4/5/3 | in | 同域目标与事件类型 |
| hw_evt_data | 32 | in | 密钥/响应/检查点 |
| hw_evt_source | SOURCE_WIDTH | in | 可信硬件事件身份 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## TEST_AUTH

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.TEST_AUTH
owner_module: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.IF.EXT.WATCHDOG.TEST_AUTH
req_ref:
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
protocol: trusted_level
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
applicability:
  expr: SAFETY_EN == 1
signals:
- name: test_auth_i
  width: '1'
  direction: in
  stability: WDT已同步生命周期/测试授权
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| test_auth_i | 1 | in | WDT已同步生命周期/测试授权 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

