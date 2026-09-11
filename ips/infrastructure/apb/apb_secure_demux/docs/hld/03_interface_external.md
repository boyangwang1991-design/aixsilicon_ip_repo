# 外部接口

接口信号完整定义沿用 LRS 02_interface_signals；本册定义架构角色、所有权和连接约束。

## 上游 APB4

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.UPSTREAM
name: upstream
scope: external
protocol: APB4
role: slave
owner_module: HLD.MOD.APB_SECURE_DEMUX.FRONTEND
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.IF.001
- LRS.INTF.APB_SECURE_DEMUX.IF.002
- LRS.INTF.APB_SECURE_DEMUX.IF.003
- LRS.INTF.APB_SECURE_DEMUX.IF.00401
- LRS.INTF.APB_SECURE_DEMUX.IF.00402
- LRS.RESET.APB_SECURE_DEMUX.RST.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

完整地址、32 bit 数据、选通、保护与握手；只接受协议稳定请求。

## 下游 APB4 数组

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.DOWNSTREAM
name: downstream
scope: external
protocol: APB4
role: master
owner_module: HLD.MOD.APB_SECURE_DEMUX.ROUTE
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.APB.001
- LRS.INTF.APB_SECURE_DEMUX.APB.002
- LRS.INTF.APB_SECURE_DEMUX.APB.003
- LRS.INTF.APB_SECURE_DEMUX.APB.004
- LRS.INTF.APB_SECURE_DEMUX.APB.00501
- LRS.INTF.APB_SECURE_DEMUX.APB.00502
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

NUM_PORTS 个同宽端口，透传原始地址，身份有效只跟随选中端口。

## 可信身份输入

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.MASTERID_IN
name: masterid_in
scope: external
protocol: project_masterid
role: consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.FRONTEND
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.IF.001
- LRS.INTF.APB_SECURE_DEMUX.IF.002
- LRS.INTF.APB_SECURE_DEMUX.IF.003
- LRS.INTF.APB_SECURE_DEMUX.IF.00401
- LRS.INTF.APB_SECURE_DEMUX.IF.00402
- LRS.RESET.APB_SECURE_DEMUX.RST.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

MASTER_ID_WIDTH 位身份与有效指示，与上游 APB 请求绑定。

## 身份输出数组

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.MASTERID_OUT
name: masterid_out
scope: external
protocol: project_masterid
role: producer
owner_module: HLD.MOD.APB_SECURE_DEMUX.ROUTE
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.APB.001
- LRS.INTF.APB_SECURE_DEMUX.APB.002
- LRS.INTF.APB_SECURE_DEMUX.APB.003
- LRS.INTF.APB_SECURE_DEMUX.APB.004
- LRS.INTF.APB_SECURE_DEMUX.APB.00501
- LRS.INTF.APB_SECURE_DEMUX.APB.00502
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

向被选下游透传完整身份，未选有效指示固定零。

## IRQ 与安全告警

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.NOTIFY
name: notify
scope: external
protocol: level_signals
role: producer
owner_module: HLD.MOD.APB_SECURE_DEMUX.IRQ
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.001
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.002
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.003
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.004
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00501
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00502
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

两个独立屏蔽的 pclk 域电平，跨域接收由系统负责。

## DFX 授权与观测

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.DIAGNOSTIC
name: diagnostic
scope: external
protocol: project_dfx
role: consumer_producer
owner_module: HLD.MOD.APB_SECURE_DEMUX.DFX
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.DFX.APB_SECURE_DEMUX.DFX.00101
- LRS.DFX.APB_SECURE_DEMUX.DFX.00102
- LRS.DFX.APB_SECURE_DEMUX.DFX.00201
- LRS.DFX.APB_SECURE_DEMUX.DFX.00202
- LRS.DFX.APB_SECURE_DEMUX.DFX.003
- LRS.DFX.APB_SECURE_DEMUX.DFX.004
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

可信授权输入；busy/port_valid/port/wait_threshold 输出受功能开关与授权门控。

## 功能时钟与复位

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_SECURE_DEMUX.CLOCK_RESET
name: clock_reset
scope: external
protocol: clock_reset
role: consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.FRONTEND
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.IF.001
- LRS.INTF.APB_SECURE_DEMUX.IF.002
- LRS.INTF.APB_SECURE_DEMUX.IF.003
- LRS.INTF.APB_SECURE_DEMUX.IF.00401
- LRS.INTF.APB_SECURE_DEMUX.IF.00402
- LRS.RESET.APB_SECURE_DEMUX.RST.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

pclk 与低有效 preset_ni；异步置位复位、由集成同步释放。

