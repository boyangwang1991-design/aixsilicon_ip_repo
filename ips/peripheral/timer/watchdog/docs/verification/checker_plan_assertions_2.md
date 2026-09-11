# 时序断言计划 2

所有断言有attempt/nonvacuous覆盖；只报告不失败而从未激活不能证明属性。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.COMMIT.001
name: atomic_config
feature_ref:
- FL.WATCHDOG.COMMIT
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
- LRS.CONS.WATCHDOG.VER.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
property: 活动配置各字段始终来自同一个已验证版本；RUN只在旧配置成功刷新整体切换。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：活动配置各字段始终来自同一个已验证版本；RUN只在旧配置成功刷新整体切换。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.LOCK.001
name: monotonic_lock
feature_ref:
- FL.WATCHDOG.LOCK
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.SEC.WATCHDOG.AUTH.001
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
property: 锁从0到1后只在POR清零；敏感操作消费一次额度，错误也不能复用。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：锁从0到1后只在POR清零；敏感操作消费一次额度，错误也不能复用。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.SNAPSHOT.001
name: held_image
feature_ref:
- FL.WATCHDOG.SNAPSHOT
req_ref:
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
property: SNAP_VALID有效后镜像在下次成功快照或POR前保持，preset不清快照；高低字和全客户端同代。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：SNAP_VALID有效后镜像在下次成功快照或POR前保持，preset不清快照；高低字和全客户端同代。

<!-- ASSERTION_META
id: ASSERT.WATCHDOG.FAULT.001
name: final_hold
feature_ref:
- FL.WATCHDOG.FAULT
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
- LRS.CONS.WATCHDOG.VER.003
design_ref:
- LLD.MOD.WATCHDOG.SAFETY
property: 最终请求一旦置位，在POR或合格warm且无同拍新故障之前持续为1；IRQ清除不影响。
severity: error
verification_method: assertion
implementation: verification/assertions/watchdog_assertions.sv
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发和失败意义：最终请求一旦置位，在POR或合格warm且无同拍新故障之前持续为1；IRQ清除不影响。
