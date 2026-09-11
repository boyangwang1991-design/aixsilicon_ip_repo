# Watchdog：外部接口合同

所有可信输入均有明确系统来源，异步信号在进入本合同前同步或完整握手。

## APB

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.APB
name: apb
scope: external
protocol: APB4
role: slave
owner_module: HLD.MOD.WATCHDOG.BUS
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.PORTS.001
- LRS.REG.WATCHDOG.ACCESS.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

32-bit little-endian，PADDR 至少15位；无突发/多在途，所有写完整字节使能；在 ACCESS 完成边沿接收一次。非法地址/写属性/权限/保留位返回 PSLVERR，不执行所请求操作。

## AUTH

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.AUTH
name: auth
scope: external
protocol: trusted_sideband
role: consumer
owner_module: HLD.MOD.WATCHDOG.BUS
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
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
- LRS.SEC.WATCHDOG.AUTH.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

access_source_i[SOURCE_WIDTH] 与 cfg_auth_i/service_auth_i/diag_auth_i 随 APB 请求稳定并捕获；PPROT 不被当作 Master ID。

## APB_CLOCK_RESET

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.APB_CLOCK_RESET
name: apb_clock_reset
scope: external
protocol: clock_reset
role: consumer
owner_module: HLD.MOD.WATCHDOG.INTEGRATION
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

pclk 与低有效 preset_n；preset 仅影响接口可用性/staging/选择器/接口镜像同步，不能重置已接受邮箱事务。

## WDT_CLOCK_RESET

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.WDT_CLOCK_RESET
name: wdt_clock_reset
scope: external
protocol: clock_reset
role: consumer
owner_module: HLD.MOD.WATCHDOG.INTEGRATION
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

独立 wdt_clk 与低有效 por_n；POR 异步有效，各域同步释放。停 pclk 不影响 WDT 检测和请求。

## POWER_DEBUG

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.POWER_DEBUG
name: power_debug
scope: external
protocol: trusted_level
role: consumer
owner_module: HLD.MOD.WATCHDOG.CHANNEL
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
req_ref:
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

sleep_req_i/debug_req_i/debug_auth_i 为 WDT 同域稳定输入；pause_ack_o[NUM_CHANNELS] 表示实际进入授权暂停，不表示时钟或电源可以任意关闭。

## WARM_EVENT

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.WATCHDOG.WARM_EVENT
name: warm_event
scope: external
protocol: trusted_event
role: consumer
owner_module: HLD.MOD.WATCHDOG.CHANNEL
clock_domain: HLD.DOM.CLK.WATCHDOG.WDT
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
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
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

warm_reset_evt_i 是系统管理器提供的一次可信完成事件，不是直接复位脚；外部保持电平必须先转换为单事件，不能连续重启监督。

