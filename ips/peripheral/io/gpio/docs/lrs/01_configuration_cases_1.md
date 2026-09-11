# GPIO 参数契约：验证场景 1

此处是参数计划，不是已运行验证证据；PV 在完整回归之后执行。

## CFG_WIDTH_1

<!-- PARAM_CASE_META
id: CFG_WIDTH_1
layer: mandatory
values:
  N_GPIO: 1
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_WIDTH_8

<!-- PARAM_CASE_META
id: CFG_WIDTH_8
layer: mandatory
values:
  N_GPIO: 8
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: true
END_PARAM_CASE_META -->

## CFG_WIDTH_31

<!-- PARAM_CASE_META
id: CFG_WIDTH_31
layer: mandatory
values:
  N_GPIO: 31
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_WIDTH_32

<!-- PARAM_CASE_META
id: CFG_WIDTH_32
layer: mandatory
values:
  N_GPIO: 32
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: true
END_PARAM_CASE_META -->

## CFG_WIDTH_33

<!-- PARAM_CASE_META
id: CFG_WIDTH_33
layer: mandatory
values:
  N_GPIO: 33
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_WIDTH_64

<!-- PARAM_CASE_META
id: CFG_WIDTH_64
layer: mandatory
values:
  N_GPIO: 64
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_WIDTH_128

<!-- PARAM_CASE_META
id: CFG_WIDTH_128
layer: mandatory
values:
  N_GPIO: 128
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: true
END_PARAM_CASE_META -->

## CFG_MIXED_CAP

<!-- PARAM_CASE_META
id: CFG_MIXED_CAP
layer: risk
values:
  N_GPIO: 33
  INPUT_CAP_MASK: 5726623061
  OUTPUT_CAP_MASK: 2863311530
  RESET_IN_EN: 5726623061
END_PARAM_CASE_META -->

## CFG_PARITY_WITHOUT_DIAG

<!-- PARAM_CASE_META
id: CFG_PARITY_WITHOUT_DIAG
layer: risk
values:
  CFG_PARITY_EN: 1
  DIAG_EN: 0
END_PARAM_CASE_META -->

## CFG_INPUT_ZERO_STRAP

<!-- PARAM_CASE_META
id: CFG_INPUT_ZERO_STRAP
layer: risk
values:
  INPUT_CAP_MASK: 0
  RESET_IN_EN: 0
  STRAP_EN: 1
END_PARAM_CASE_META -->

