# 内部接口组

以下为功能接口组，不固定 RTL 端口名、编码或文件层次；全部同步于 pclk。

## CLASSIFY

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.CLASSIFY
name: classify
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.FRONTEND
participants:
- HLD.MOD.APB_SECURE_DEMUX.FRONTEND
- HLD.MOD.APB_SECURE_DEMUX.DECODE
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.IF.001
- LRS.INTF.APB_SECURE_DEMUX.IF.002
- LRS.INTF.APB_SECURE_DEMUX.IF.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

请求地址与事务类型；所有地址位保留。

## TARGET

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.TARGET
name: target
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.DECODE
participants:
- HLD.MOD.APB_SECURE_DEMUX.DECODE
- HLD.MOD.APB_SECURE_DEMUX.ACCESS
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.CFG.APB_SECURE_DEMUX.PAR.001
- LRS.CFG.APB_SECURE_DEMUX.PAR.002
- LRS.CFG.APB_SECURE_DEMUX.PAR.00301
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

唯一目标、CSR 分类、零/多命中错误。

## POLICY_LOOKUP

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.POLICY_LOOKUP
name: policy_lookup
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.POLICY
participants:
- HLD.MOD.APB_SECURE_DEMUX.POLICY
- HLD.MOD.APB_SECURE_DEMUX.ACCESS
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.REG.APB_SECURE_DEMUX.UPD.001
- LRS.REG.APB_SECURE_DEMUX.UPD.002
- LRS.REG.APB_SECURE_DEMUX.UPD.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

active 权限、端口控制、版本、原始完整性和 FATAL。

## ADMISSION

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.ADMISSION
name: admission
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.ACCESS
participants:
- HLD.MOD.APB_SECURE_DEMUX.ACCESS
- HLD.MOD.APB_SECURE_DEMUX.ROUTE
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.SEC.APB_SECURE_DEMUX.ACL.00101
- LRS.SEC.APB_SECURE_DEMUX.ACL.00102
- LRS.SEC.APB_SECURE_DEMUX.ACL.00201
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

目标、准入、错误原因、请求属性和 TEST 标记，事务期间保持一致。

## CSR_COMMAND

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.CSR_COMMAND
name: csr_command
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.CSR
participants:
- HLD.MOD.APB_SECURE_DEMUX.CSR
- HLD.MOD.APB_SECURE_DEMUX.POLICY
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.REG.APB_SECURE_DEMUX.CSR.00101
- LRS.REG.APB_SECURE_DEMUX.CSR.00102
- LRS.REG.APB_SECURE_DEMUX.CSR.002
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

读写、提交、reload、锁操作和诊断状态；地址/访问授权已在 CSR 检查。

## EVENT_CANDIDATES

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.EVENT_CANDIDATES
name: event_candidates
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.EVENTS
participants:
- HLD.MOD.APB_SECURE_DEMUX.EVENTS
- HLD.MOD.APB_SECURE_DEMUX.IRQ
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.LOG.001
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00201
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00202
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

所有来源事件位及记录选择/丢失结果，IRQ 不只看被选记录。

## DFX_INJECTION

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.DFX_INJECTION
name: dfx_injection
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.DFX
participants:
- HLD.MOD.APB_SECURE_DEMUX.DFX
- HLD.MOD.APB_SECURE_DEMUX.ACCESS
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.DFX.APB_SECURE_DEMUX.DFX.00101
- LRS.DFX.APB_SECURE_DEMUX.DFX.00102
- LRS.DFX.APB_SECURE_DEMUX.DFX.00201
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

授权的单次注入目标与模式，只有自然允许请求才能消费。

## ACTIVITY

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.ACTIVITY
name: activity
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.ROUTE
participants:
- HLD.MOD.APB_SECURE_DEMUX.ROUTE
- HLD.MOD.APB_SECURE_DEMUX.DFX
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.APB.001
- LRS.INTF.APB_SECURE_DEMUX.APB.002
- LRS.INTF.APB_SECURE_DEMUX.APB.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

当前目标、下游等待和完成分类，寄存模式本地额外 SETUP 不计入下游等待。

## AUDIT_CONTROL

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_SECURE_DEMUX.AUDIT_CONTROL
name: audit_control
scope: internal
protocol: synchronous_control
role: producer_consumer
owner_module: HLD.MOD.APB_SECURE_DEMUX.CSR
participants:
- HLD.MOD.APB_SECURE_DEMUX.CSR
- HLD.MOD.APB_SECURE_DEMUX.EVENTS
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
req_ref:
- LRS.REG.APB_SECURE_DEMUX.CSR.00101
- LRS.REG.APB_SECURE_DEMUX.CSR.00102
- LRS.REG.APB_SECURE_DEMUX.CSR.002
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

快照读取、POP/clear、全局统计读清；不回压总线。

