# 参数负例计划

Schema 表示结构/类型/标量约束失败；Elaboration 表示项目地址语义检查，后续 RTL elaboration 也必须复现。
这里的声明不算 EDA 已执行证据。

<!-- PARAM_CASE_META
id: CFG_INVALID_PORTS_ZERO
layer: negative
values:
  NUM_PORTS: 0
expect_fail:
  stage: Schema
  reason: PORTS_ZERO
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_WIDTH_BAD
layer: negative
values:
  DATA_WIDTH: 64
expect_fail:
  stage: Schema
  reason: WIDTH_BAD
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_ID_SPACE
layer: negative
values:
  NUM_MASTERS: 32
  MASTER_ID_WIDTH: 4
expect_fail:
  stage: Schema
  reason: ID_SPACE
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_MASK_ZERO
layer: negative
values:
  MGMT_MASTER_MASK: 0
expect_fail:
  stage: Schema
  reason: MASK_ZERO
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_BASE_LENGTH
layer: negative
values:
  PORT_BASE: [256]
expect_fail:
  stage: Schema
  reason: BASE_LENGTH
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_BASE_OVERLAP
layer: negative
values:
  PORT_BASE: [256, 256, 256, 256, 256, 256, 256, 256]
expect_fail:
  stage: Elaboration
  reason: BASE_OVERLAP
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_CSR_OVERLAP
layer: negative
values:
  CSR_BASE: 256
expect_fail:
  stage: Elaboration
  reason: CSR_OVERLAP
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_PORT_WRAP
layer: negative
values:
  PORT_BASE: [4294967292, 512, 768, 1024, 1280, 1536, 1792, 2048]
expect_fail:
  stage: Elaboration
  reason: PORT_WRAP
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_SIZE_ZERO
layer: negative
values:
  PORT_SIZE: [0, 0, 0, 0, 0, 0, 0, 0]
expect_fail:
  stage: Elaboration
  reason: SIZE_ZERO
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_BASE_ALIGN
layer: negative
values:
  PORT_BASE: [257, 512, 768, 1024, 1280, 1536, 1792, 2048]
expect_fail:
  stage: Elaboration
  reason: BASE_ALIGN
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

<!-- PARAM_CASE_META
id: CFG_INVALID_PERM_RANGE
layer: negative
values:
  RESET_PERM: [256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256]
expect_fail:
  stage: Schema
  reason: PERM_RANGE
verify:
  elab: true
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

