# Watchdog：参数验证场景

本册只定义配置验证输入与预期；不是已执行的配置报告。引用冻结参数值域及 DEFAULT_CFG 合法性要求。

## CFG_NEG_DEFAULT_TIMEOUT

<!-- PARAM_CASE_META
id: CFG_NEG_DEFAULT_TIMEOUT
layer: negative
values:
  AUTO_START_MASK: 1
  DEFAULT_CFG:
  - WIN_EN: 0
    PREWARN_EN: 0
    BOOT_EN: 1
    SERVICE_MODE: 1
    SUP_MODE: 0
    RESPONSE_MODE: 0
    ALLOW_LOCAL_RECOVERY: 0
    PAUSE_SLEEP: 0
    PAUSE_DEBUG: 0
    WAKE_EN: 0
    SERVICE_PATH: 0
    PRESCALE: 0
    WIN_MIN: 0
    TIMEOUT: 0
    PRETIMEOUT: 0
    BOOT_TIMEOUT: 65536
    SEQ_LIMIT: 256
    REQUIRE_MASK: 1
    FAULT_POLICY: 990
    LOCAL_DELAY: 0
    FINAL_DELAY: 0
    RECOVERY_LIMIT: 0
    CLIENT_DEFAULT:
      OWNER_SOURCE: 0
      MIN_ALIVE: 0
      MAX_ALIVE: 0
      LAST_STEP: 0
      DEADLINE_MIN: 0
      DEADLINE_MAX: 0
    CLIENT_OVERRIDES: []
expect_fail:
  stage: Schema
  reason: 自动启动默认 TIMEOUT=0，项目语义校验必须拒绝
verify:
  elab: false
  lint: false
  formal: false
  sim: false
  synth: false
END_PARAM_CASE_META -->

