# GPIO 参数契约：验证场景 2

此处是参数计划，不是已运行验证证据；PV 在完整回归之后执行。

## CFG_BAD_GPIO_ZERO

<!-- PARAM_CASE_META
id: CFG_BAD_GPIO_ZERO
layer: negative
values:
  N_GPIO: 0
expect_fail:
  stage: Schema
  reason: 引脚数下界
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_GPIO_129

<!-- PARAM_CASE_META
id: CFG_BAD_GPIO_129
layer: negative
values:
  N_GPIO: 129
expect_fail:
  stage: Schema
  reason: 引脚数上界
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_SYNC_1

<!-- PARAM_CASE_META
id: CFG_BAD_SYNC_1
layer: negative
values:
  SYNC_STAGES: 1
expect_fail:
  stage: Schema
  reason: 同步级数下界
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_FIFO_3

<!-- PARAM_CASE_META
id: CFG_BAD_FIFO_3
layer: negative
values:
  EVENT_FIFO_DEPTH: 3
expect_fail:
  stage: Schema
  reason: 非法深度
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_OE_CAP

<!-- PARAM_CASE_META
id: CFG_BAD_OE_CAP
layer: negative
values:
  OUTPUT_CAP_MASK: 0
  RESET_OE: 1
expect_fail:
  stage: Schema
  reason: 复位 OE 超出输出能力
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_SAFE_CAP

<!-- PARAM_CASE_META
id: CFG_BAD_SAFE_CAP
layer: negative
values:
  OUTPUT_CAP_MASK: 0
  HW_SAFE_OE: 1
expect_fail:
  stage: Schema
  reason: 安全 OE 超出输出能力
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_IN_CAP

<!-- PARAM_CASE_META
id: CFG_BAD_IN_CAP
layer: negative
values:
  INPUT_CAP_MASK: 0
  RESET_IN_EN: 1
expect_fail:
  stage: Schema
  reason: 输入使能超出能力
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_BAD_MASK_WIDTH

<!-- PARAM_CASE_META
id: CFG_BAD_MASK_WIDTH
layer: negative
values:
  N_GPIO: 8
  RESET_OUT: 256
expect_fail:
  stage: Schema
  reason: 位图超出引脚宽度
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

