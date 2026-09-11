# 管理请求与通知控制接口

补足本地请求分流及软件通知/DFX 控制的明确所有权。

## LOCAL_REQUEST

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.LOCAL_REQUEST
name: local_request
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.DECODE
participants:
- HLD.MOD.APB_SECURE_DEMUX.DECODE
- HLD.MOD.APB_SECURE_DEMUX.CSR
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

唯一 CSR 命中的完整请求、身份与分类错误；CSR 返回本地响应。

## IRQ_CONTROL

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.IRQ_CONTROL
name: irq_control
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.CSR
participants:
- HLD.MOD.APB_SECURE_DEMUX.CSR
- HLD.MOD.APB_SECURE_DEMUX.IRQ
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

使能、事件清除和通知测试命令；返回原始与屏蔽状态。

## DFX_CONTROL

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.DFX_CONTROL
name: dfx_control
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.CSR
participants:
- HLD.MOD.APB_SECURE_DEMUX.CSR
- HLD.MOD.APB_SECURE_DEMUX.DFX
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

已完成管理授权的诊断操作、目标/武装命令；返回授权状态、统计和操作错误。

