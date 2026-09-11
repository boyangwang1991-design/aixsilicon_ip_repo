# 外部信号绑定

外部端口名/方向/位宽沿用受控合同第3节，不添加APB5信号。s_paddr/m_paddr为ADDR_WIDTH；数据32、strb4、prot3；MASTERID为MASTER_ID_WIDTH。下游各请求/响应端口为NUM_PORTS元素的数组。irq与alert独立单bit；DFX active_port固定5bit，其余观测与授权单bit。pclk与preset_ni只输入。

外部APB payload与身份从SETUP到完成保持。输出选择来自03_route，禁止将master_valid广播。系统外部DFX授权及复位释放必须同步；不在本IP增加CDC。复位中全部输出按02_global_constraints门控。接口组合信号不存在额外寄存隐含延迟。

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_UPSTREAM
owner_module: LLD.MOD.APB_SECURE_DEMUX.FRONTEND
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.UPSTREAM
protocol: APB4
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_DOWNSTREAM
owner_module: LLD.MOD.APB_SECURE_DEMUX.ROUTE
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.DOWNSTREAM
protocol: APB4
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_MASTERID_IN
owner_module: LLD.MOD.APB_SECURE_DEMUX.FRONTEND
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.MASTERID_IN
protocol: project_masterid
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_MASTERID_OUT
owner_module: LLD.MOD.APB_SECURE_DEMUX.ROUTE
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.MASTERID_OUT
protocol: project_masterid
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_NOTIFY
owner_module: LLD.MOD.APB_SECURE_DEMUX.IRQ
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.NOTIFY
protocol: level_signals
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_DIAGNOSTIC
owner_module: LLD.MOD.APB_SECURE_DEMUX.DFX
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.DIAGNOSTIC
protocol: project_dfx
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EXT_CLOCK_RESET
owner_module: LLD.MOD.APB_SECURE_DEMUX.FRONTEND
hld_ref:
- HLD.IF.EXT.APB_SECURE_DEMUX.CLOCK_RESET
protocol: clock_reset
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
END_LLD_INTERFACE_META -->
