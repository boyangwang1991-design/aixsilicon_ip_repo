# RTL 实现映射与交接

这些路径是实现责任映射，当前尚无 RTL 通过证据。优先级 P0：先完成参数/复位/SETUP隔离与generated CSR适配，再实现原子策略、日志竞争、通知及DFX。每个模块的初始版本必须与本目录设计核对；不得把未完成TODO视为RTL交付。

<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.FRONTEND
rtl_file: rtl/apb_secure_demux.sv
rtl_module: apb_secure_demux
implements:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.DECODE
rtl_file: rtl/apb_secure_demux_decode.sv
rtl_module: apb_secure_demux_decode
implements:
- LLD.MOD.APB_SECURE_DEMUX.DECODE
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.ACCESS
rtl_file: rtl/apb_secure_demux_access.sv
rtl_module: apb_secure_demux_access
implements:
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.ROUTE
rtl_file: rtl/apb_secure_demux.sv
rtl_module: apb_secure_demux
implements:
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.CSR
rtl_file: rtl/apb_secure_demux_csr.sv
rtl_module: apb_secure_demux_csr
implements:
- LLD.MOD.APB_SECURE_DEMUX.CSR
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.POLICY
rtl_file: rtl/apb_secure_demux_policy.sv
rtl_module: apb_secure_demux_policy
implements:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.EVENTS
rtl_file: rtl/apb_secure_demux_events.sv
rtl_module: apb_secure_demux_events
implements:
- LLD.MOD.APB_SECURE_DEMUX.EVENTS
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.IRQ
rtl_file: rtl/apb_secure_demux_irq.sv
rtl_module: apb_secure_demux_irq
implements:
- LLD.MOD.APB_SECURE_DEMUX.IRQ
generated: false
END_RTL_MAP_META -->
<!-- RTL_MAP_META
id: RTL.APB_SECURE_DEMUX.DFX
rtl_file: rtl/apb_secure_demux_dfx.sv
rtl_module: apb_secure_demux_dfx
implements:
- LLD.MOD.APB_SECURE_DEMUX.DFX
generated: false
END_RTL_MAP_META -->

PeakRDL 输出单独放 rtl/generated，wrapper 不替代生成的结构译码。parity CBB 的实例与 include 通过 FuseSoC 依赖解析。生成器绑定真实版本与 RDL 输入哈希。
