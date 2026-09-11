# 安全性质与周期断言 1

每条性质需报告触发及完成覆盖，避免vacuous pass。DUT性质用assert，可信输入假设用assume，不能混淆；复位中隔离性质不被disable iff全部屏蔽。

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.DECODE.ONEHOT
name: onehot
feature_ref:
- FL.APB_SECURE_DEMUX.DECODE
property: 每个周期下游PSEL为onehot0，多命中/空洞从SETUP起零选择
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.DECODE
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.ACL.NO_SIDE_EFFECT
name: no_side_effect
feature_ref:
- FL.APB_SECURE_DEMUX.ACL
property: 自然拒绝或DFX拒绝从SETUP到完成不产生任何下游选择或目标读清/写触发
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.APB.STABLE_WAIT
name: stable_wait
feature_ref:
- FL.APB_SECURE_DEMUX.APB
property: 下游等待期间选择、地址、写数据、属性及身份保持；PSEL不得因FATAL/授权撤销中断
severity: error
verification_method: assertion
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.APB.LOCAL_LATENCY
name: local_latency
feature_ref:
- FL.APB_SECURE_DEMUX.APB
property: 两模式的CSR与拒绝均在第一个ACCESS完成，register合法外设恰有一拍额外等待
severity: error
verification_method: assertion
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.CSR.UNAUTHORIZED_STATE
name: unauthorized_state
feature_ref:
- FL.APB_SECURE_DEMUX.CSR
property: 未授权CSR完成只允许规定审计状态更新，目标配置/命令状态保持且读零
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.CSR
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.UPDATE.LOCK_MONOTONIC
name: lock_monotonic
feature_ref:
- FL.APB_SECURE_DEMUX.UPDATE
property: 可信复位未发生时已经置位的锁不清除，锁定策略不能经shadow/reload/commit绕过
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
- LLD.MOD.APB_SECURE_DEMUX.DFX
END_ASSERTION_META -->
