# 时序断言计划 3

所有断言有attempt/nonvacuous覆盖；只报告不失败而从未激活不能证明属性。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.RECOVERY.001
name: recovery_once
feature_ref:
- FL.WATCHDOG.RECOVERY
req_ref:
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
property: done/ack四阶段仅接受一次；旧done不能让下一故障获得恢复；最终期限不被延后。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：done/ack四阶段仅接受一次；旧done不能让下一故障获得恢复；最终期限不被延后。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.PAUSE.001
name: frozen_phase
feature_ref:
- FL.WATCHDOG.PAUSE
req_ref:
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
property: PAUSED冻结普通计时及客户端期限，但不冻结升级和自身诊断；恢复原相位。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：PAUSED冻结普通计时及客户端期限，但不冻结升级和自身诊断；恢复原相位。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.RESET.001
name: reset_retention
feature_ref:
- FL.WATCHDOG.RESET
req_ref:
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
property: preset不影响WDT域活动请求、配置锁及邮箱；POR同步释放级数符合配置。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：preset不影响WDT域活动请求、配置锁及邮箱；POR同步释放级数符合配置。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.SAFETY.001
name: diagnostic_latency
feature_ref:
- FL.WATCHDOG.SAFETY
req_ref:
- LRS.PERF.WATCHDOG.SAFETY.001
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
design_ref:
- LLD.MOD.WATCHDOG.SAFETY
property: 激活的数字完整性异常可观测起最多2WDT周期提出并保持安全/最终请求，包括PAUSED。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：激活的数字完整性异常可观测起最多2WDT周期提出并保持安全/最终请求，包括PAUSED。
