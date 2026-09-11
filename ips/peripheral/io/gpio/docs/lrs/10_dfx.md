# GPIO LRS：可观测性与交付边界

### LRS.DFX.GPIO.OBSERVE.001

<!-- LRS_META
id: LRS.DFX.GPIO.OBSERVE.001
category: DFX
feature: observe
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-DIAG-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件应能通过 IRQ_TEST、DIAG_TEST 以及启用时的 PARITY_INJECT 检查记录/报警/安全响应路径。

#### Acceptance Criteria

- 各测试入口保持其独立权限、锁和功能裁剪规则；不得将数字注入结果宣称为完整 PAD 电气路径验证。

## 不适用范围

专用 scan/MBIST/JTAG 接口为 N/A：输入合同未要求；后续 DFT 集成不得由本 LRS 假设已完成。
