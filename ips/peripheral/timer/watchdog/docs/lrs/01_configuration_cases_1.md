# Watchdog：参数验证场景

本册只定义配置验证输入与预期；不是已执行的配置报告。引用冻结参数值域及 DEFAULT_CFG 合法性要求。

## CFG_RISK_MAX

<!-- PARAM_CASE_META
id: CFG_RISK_MAX
layer: risk
values:
  NUM_CHANNELS: 16
  NUM_CLIENTS: 32
  COUNTER_WIDTH: 64
  PRESCALE_WIDTH: 16
  SOURCE_WIDTH: 16
  SYNC_STAGES: 4
  SAFETY_EN: 1
  SUPPORT_TOKEN_QA: 1
  SUPPORT_SUPERVISION: 1
  SUPPORT_HW_EVENT: 1
  ALLOW_RUNTIME_UPDATE: 1
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_RISK_AUTOSTART_ALL

<!-- PARAM_CASE_META
id: CFG_RISK_AUTOSTART_ALL
layer: risk
values:
  NUM_CHANNELS: 16
  NUM_CLIENTS: 32
  COUNTER_WIDTH: 64
  PRESCALE_WIDTH: 16
  SOURCE_WIDTH: 16
  SYNC_STAGES: 4
  SAFETY_EN: 1
  SUPPORT_TOKEN_QA: 1
  SUPPORT_SUPERVISION: 1
  SUPPORT_HW_EVENT: 1
  ALLOW_RUNTIME_UPDATE: 1
  AUTO_START_MASK: 65535
  HARD_CFG_LOCK_MASK: 65535
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_RISK_DIAG

<!-- PARAM_CASE_META
id: CFG_RISK_DIAG
layer: risk
values:
  SAFETY_EN: 1
  DIAG_INJECT_EN: 1
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_RISK_STOP_ALLOWED

<!-- PARAM_CASE_META
id: CFG_RISK_STOP_ALLOWED
layer: risk
values:
  NO_STOP_MASK: 0
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_CONSUMER_DEFAULT

<!-- PARAM_CASE_META
id: CFG_CONSUMER_DEFAULT
layer: consumer
values: {}
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

## CFG_NEG_NUM_CHANNELS_0

<!-- PARAM_CASE_META
id: CFG_NEG_NUM_CHANNELS_0
layer: negative
values:
  NUM_CHANNELS: 0
expect_fail:
  stage: Schema
  reason: 违反冻结参数值域/结构/长度约束
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

## CFG_NEG_NUM_CHANNELS_17

<!-- PARAM_CASE_META
id: CFG_NEG_NUM_CHANNELS_17
layer: negative
values:
  NUM_CHANNELS: 17
expect_fail:
  stage: Schema
  reason: 违反冻结参数值域/结构/长度约束
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

