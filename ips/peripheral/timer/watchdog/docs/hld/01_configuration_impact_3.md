# Watchdog：参数对架构的影响

每个 config_ref 引用 PC canonical 的参数 ID；产品配置引用同一参数空间，不另发明旋钮。

## SUPPORT_HW_EVENT

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SUPPORT_HW_EVENT
config_ref: PARAM.WATCHDOG.SUPPORT_HW_EVENT
affects:
  modules:
  - HLD.MOD.WATCHDOG.DISPATCH
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 决定硬件服务来源是否存在；启用时与邮箱共享公平仲裁，关闭时不接受该路径。
req_ref:
- LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

决定硬件服务来源是否存在；启用时与邮箱共享公平仲裁，关闭时不接受该路径。

## SAFETY_EN

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SAFETY_EN
config_ref: PARAM.WATCHDOG.SAFETY_EN
affects:
  modules:
  - HLD.MOD.WATCHDOG.SAFETY
  - HLD.MOD.WATCHDOG.CHANNEL
  - HLD.MOD.WATCHDOG.TRANSPORT
architecture_effect: 控制增强独立检测与保护；普通监督与最终保持不随增强关闭而消失。
req_ref:
- LRS.CFG.WATCHDOG.SAFETY_EN.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

控制增强独立检测与保护；普通监督与最终保持不随增强关闭而消失。

## ALLOW_RUNTIME_UPDATE

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE
config_ref: PARAM.WATCHDOG.ALLOW_RUNTIME_UPDATE
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 决定 RUN 计时配置是否可进入 pending；无条件保留禁用态完整配置提交。
req_ref:
- LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

决定 RUN 计时配置是否可进入 pending；无条件保留禁用态完整配置提交。

## DIAG_INJECT_EN

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.DIAG_INJECT_EN
config_ref: PARAM.WATCHDOG.DIAG_INJECT_EN
affects:
  modules:
  - HLD.MOD.WATCHDOG.BUS
  - HLD.MOD.WATCHDOG.SAFETY
architecture_effect: 控制受保护诊断注入入口；生产默认关闭。未实现的检测对象不得用无效注入宣称诊断通过。
req_ref:
- LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

控制受保护诊断注入入口；生产默认关闭。未实现的检测对象不得用无效注入宣称诊断通过。

