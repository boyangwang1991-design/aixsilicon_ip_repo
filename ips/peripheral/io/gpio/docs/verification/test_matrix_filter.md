# GPIO 验证域：滤波与去抖

<!-- FEATURE_META
id: FL.GPIO.FILTER
name: 滤波与去抖
description: 滤波与去抖的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.FLT001.001
- LRS.FUNC.GPIO.FLT001.002
- LRS.FUNC.GPIO.FLT002.001
- LRS.FUNC.GPIO.FLT002.002
- LRS.FUNC.GPIO.FLT002.003
- LRS.FUNC.GPIO.FLT003.001
- LRS.FUNC.GPIO.FLT004.001
- LRS.FUNC.GPIO.FLT004.002
- LRS.FUNC.GPIO.FLT005.001
- LRS.FUNC.GPIO.FLT006.001
- LRS.FUNC.GPIO.FLT007.001
design_ref:
- HLD.MOD.GPIO.INPUT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.FILTER.001
name: gpio_filter
type: boundary
description: 滤波与去抖
priority: must
tier: regression
implementation: verification/tc/tc_gpio_filter.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.FILTER
design_ref:
- LLD.MOD.GPIO.INPUT
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- K/D取1/2/255/256，DIV取0/1/65535，阈值前后翻转，处理中重配置并混合使能
expected_result:
- RM以连续样本段长度及Bank采样时间表计算有效输出；下游使用沿前上游样本，检查延迟上界
oracle: RM以连续样本段长度及Bank采样时间表计算有效输出；下游使用沿前上游样本，检查延迟上界
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：K×D×DIV边界×短脉冲×重配置时刻。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
