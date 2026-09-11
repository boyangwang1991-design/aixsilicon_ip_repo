# 配置覆盖

<!-- CONFIG_COVERAGE_META
id: CCOV.WATCHDOG.PARAMETERS
dimensions:
- DEFAULT_CFG
- AUTO_START_MASK
- NO_STOP_MASK
- HARD_CFG_LOCK_MASK
- NUM_CHANNELS
- COUNTER_WIDTH
- PRESCALE_WIDTH
- NUM_CLIENTS
- SOURCE_WIDTH
- SYNC_STAGES
- SUPPORT_TOKEN_QA
- SUPPORT_SUPERVISION
- SUPPORT_HW_EVENT
- SAFETY_EN
- ALLOW_RUNTIME_UPDATE
- DIAG_INJECT_EN
strategy:
  default: true
  boundary: true
  pairwise: true
  risk_based: true
feature_ref:
- FL.WATCHDOG.CONFIG
END_CONFIG_COVERAGE_META -->

配置执行必须区分input-validation、elaboration、simulation、synthesis，输入校验188/188不等于PV通过。
DEFAULT、MIN/MAX、能力开/关、宽度、客户端、通道、同步级数、运行更新及注入裁剪均有构建记录；结构和安全关键组合另有功能运行。
STANDARD/SAFETY/SUPERVISOR分别有回归与PPA，不合并不同结构的覆盖分母。
非法DEFAULT_CFG、mask超宽、位宽非法等需要独立负向预期；非零退出但原因无关（如许可证错误）不能判预期拒绝成功。
