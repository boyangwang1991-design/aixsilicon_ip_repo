# 时序断言计划 1

所有断言有attempt/nonvacuous覆盖；只报告不失败而从未激活不能证明属性。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.BUS.001
name: apb_accept
feature_ref:
- FL.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.PORTS.001
- LRS.REG.WATCHDOG.ACCESS.001
- LRS.REG.WATCHDOG.IDENTITY.001
design_ref:
- LLD.MOD.WATCHDOG.BUS
property: APB接受仅PSEL/PENABLE/PREADY边沿，连续等待负载稳定且每事务一次；ACCESS两周期内完成。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：APB接受仅PSEL/PENABLE/PREADY边沿，连续等待负载稳定且每事务一次；ACCESS两周期内完成。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.CDC.001
name: mailbox
feature_ref:
- FL.WATCHDOG.CDC
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.VER.004
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
property: 从接受至ack负载稳定；每序号最多执行或取消一次；preset不清toggle，warm不重放。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：从接受至ack负载稳定；每序号最多执行或取消一次；preset不清toggle，warm不重放。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.HW_EVENT.001
name: arbitration
feature_ref:
- FL.WATCHDOG.HW_EVENT
req_ref:
- LRS.INTF.WATCHDOG.IF.003
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.PERF.WATCHDOG.COMMAND.001
- LRS.CONS.WATCHDOG.NFR.003
design_ref:
- LLD.MOD.WATCHDOG.DISPATCH
property: 每边沿最多消费一个状态修改请求；持续竞争的可见邮箱在3周期内被执行；取消窗口不消费HW。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：每边沿最多消费一个状态修改请求；持续竞争的可见邮箱在3周期内被执行；取消窗口不消费HW。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.TIMING.001
name: no_illegal_refresh
feature_ref:
- FL.WATCHDOG.TIMING
req_ref:
- LRS.CFG.WATCHDOG.PAR.003
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.PERF.WATCHDOG.TIME.001
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.VER.001
- LRS.CONS.WATCHDOG.VER.002
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
property: 除合法START/recovery/warm/完整服务及ALIVE健康边界外，周期起点不能重置；非法服务不得延后timeout。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：除合法START/recovery/warm/完整服务及ALIVE健康边界外，周期起点不能重置；非法服务不得延后timeout。
