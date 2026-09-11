# 安全性质与周期断言 2

每条性质需报告触发及完成覆盖，避免vacuous pass。DUT性质用assert，可信输入假设用assume，不能混淆；复位中隔离性质不被disable iff全部屏蔽。

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.UPDATE.ATOMIC_COMMIT
name: atomic_commit
feature_ref:
- FL.APB_SECURE_DEMUX.UPDATE
property: 失败commit所有active保持；成功commit同沿全量复制全部所选端口，未选保持，版本加一
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
- LLD.MOD.APB_SECURE_DEMUX.DFX
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.LOG.EVENT_ONCE
name: event_once
feature_ref:
- FL.APB_SECURE_DEMUX.LOG
property: 每笔失败完成只产生一次候选；全部候选数等于选中数加仲裁丢失，FIFO丢失另计
severity: error
verification_method: assertion
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.EVENTS
- LLD.MOD.APB_SECURE_DEMUX.DFX
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.IRQ.MASK_INDEPENDENCE
name: mask_independence
feature_ref:
- FL.APB_SECURE_DEMUX.IRQ
property: 屏蔽输出不停止raw/日志捕获；事件与W1C同周期新事件优先；FATAL使对应raw持续置位
severity: error
verification_method: assertion
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.IRQ
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.INTEGRITY.FATAL_BLOCK
name: fatal_block
feature_ref:
- FL.APB_SECURE_DEMUX.INTEGRITY
property: 当前原始完整性错误即阻断新SETUP且下一沿锁存FATAL；已经发出的下游事务继续遵守协议
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.DFX.NO_BYPASS
name: no_bypass
feature_ref:
- FL.APB_SECURE_DEMUX.DFX
property: 授权不足不能新武装；测试注入不能把自然拒绝变允许，自然拒绝不消耗武装
severity: error
verification_method: formal
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.DFX
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.APB_SECURE_DEMUX.RESET.RESET_ISOLATION
name: reset_isolation
feature_ref:
- FL.APB_SECURE_DEMUX.RESET
property: preset_ni有效时全部选择/身份有效/响应/通知/观测为零；无先行SETUP的ACCESS不接收
severity: error
verification_method: assertion
implementation: verification/assertions/apb_secure_demux_properties.sv
applicability:
  expr: 'true'
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
END_ASSERTION_META -->
