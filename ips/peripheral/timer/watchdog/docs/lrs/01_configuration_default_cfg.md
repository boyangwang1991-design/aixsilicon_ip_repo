# Watchdog：DEFAULT_CFG 实例输入结构

来源：LRS.CFG.WATCHDOG.DEFAULT_CFG.001 和原契约 §3.2/§16.5。
每通道数组项包含完整逻辑配置；CLIENT_DEFAULT 定义每个已实现客户端的初值，
CLIENT_OVERRIDES 为完整的特定客户端替换值，客户端索引不能重复或越界。
命名属性是实例输入，不是额外寄存器结构事实源；实际字段布局仍由 SystemRDL 管理。

代表实例选用 TIMEOUT=BOOT_TIMEOUT=65536 tick、PRESCALE=0、SEQ_LIMIT=256 WDT 周期，
与已有候选默认配置一致，仅作为可重复构建的实例选择，**不是适用于任意系统时钟的
强制时间需求**。自动启动实际消费者必须重新检查这些时间是否满足系统监督预算。
默认 CLIENT 数值在 SINGLE 模式下未参与的 ALIVE/FLOW 项允许为 0；选中相应模式
后必须满足原契约约束，不能因结构 schema 接受而忽略语义非法。

<!-- PARAM_META
name: DEFAULT_CFG
type: array
category: compile_time
default:
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
  TIMEOUT: 65536
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
repeat_default_expr: NUM_CHANNELS
length_expr: NUM_CHANNELS
domain:
  schema: inline
schema:
  type: array
  minItems: 1
  maxItems: 16
  items:
    type: object
    required:
    - WIN_EN
    - PREWARN_EN
    - BOOT_EN
    - SERVICE_MODE
    - SUP_MODE
    - RESPONSE_MODE
    - ALLOW_LOCAL_RECOVERY
    - PAUSE_SLEEP
    - PAUSE_DEBUG
    - WAKE_EN
    - SERVICE_PATH
    - PRESCALE
    - WIN_MIN
    - TIMEOUT
    - PRETIMEOUT
    - BOOT_TIMEOUT
    - SEQ_LIMIT
    - REQUIRE_MASK
    - FAULT_POLICY
    - LOCAL_DELAY
    - FINAL_DELAY
    - RECOVERY_LIMIT
    - CLIENT_DEFAULT
    - CLIENT_OVERRIDES
    additionalProperties: false
    properties:
      WIN_EN:
        type: integer
        enum: &id001
        - 0
        - 1
      PREWARN_EN:
        type: integer
        enum: *id001
      BOOT_EN:
        type: integer
        enum: *id001
      SERVICE_MODE:
        type: integer
        minimum: 0
        maximum: 3
      SUP_MODE:
        type: integer
        minimum: 0
        maximum: 3
      RESPONSE_MODE:
        type: integer
        enum: *id001
      ALLOW_LOCAL_RECOVERY:
        type: integer
        enum: *id001
      PAUSE_SLEEP:
        type: integer
        enum: *id001
      PAUSE_DEBUG:
        type: integer
        enum: *id001
      WAKE_EN:
        type: integer
        enum: *id001
      SERVICE_PATH:
        type: integer
        enum: *id001
      PRESCALE:
        type: integer
        minimum: 0
        maximum: 4294967295
      WIN_MIN:
        type: integer
        minimum: 0
        maximum: 18446744073709551615
      TIMEOUT:
        type: integer
        minimum: 0
        maximum: 18446744073709551615
      PRETIMEOUT:
        type: integer
        minimum: 0
        maximum: 18446744073709551615
      BOOT_TIMEOUT:
        type: integer
        minimum: 0
        maximum: 18446744073709551615
      SEQ_LIMIT:
        type: integer
        minimum: 0
        maximum: 4294967295
      REQUIRE_MASK:
        type: integer
        minimum: 0
        maximum: 4294967295
      FAULT_POLICY:
        type: integer
        minimum: 0
        maximum: 4294967295
      LOCAL_DELAY:
        type: integer
        minimum: 0
        maximum: 4294967295
      FINAL_DELAY:
        type: integer
        minimum: 0
        maximum: 4294967295
      RECOVERY_LIMIT:
        type: integer
        minimum: 0
        maximum: 4294967295
      CLIENT_DEFAULT: &id002
        type: object
        required:
        - OWNER_SOURCE
        - MIN_ALIVE
        - MAX_ALIVE
        - LAST_STEP
        - DEADLINE_MIN
        - DEADLINE_MAX
        additionalProperties: false
        properties:
          OWNER_SOURCE:
            type: integer
            minimum: 0
            maximum: 4294967295
          MIN_ALIVE:
            type: integer
            minimum: 0
            maximum: 4294967295
          MAX_ALIVE:
            type: integer
            minimum: 0
            maximum: 4294967295
          LAST_STEP:
            type: integer
            minimum: 0
            maximum: 4294967295
          DEADLINE_MIN:
            type: integer
            minimum: 0
            maximum: 18446744073709551615
          DEADLINE_MAX:
            type: integer
            minimum: 0
            maximum: 18446744073709551615
      CLIENT_OVERRIDES:
        type: array
        maxItems: 32
        items:
          type: object
          required:
          - client
          - values
          additionalProperties: false
          properties:
            client:
              type: integer
              minimum: 0
              maximum: 31
            values: *id002
depends_on: []
description: 每通道完整配置数组；模式/位宽/客户端关系由项目语义校验器按冻结 LRS 检查
END_PARAM_META -->
