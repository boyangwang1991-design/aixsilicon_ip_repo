# Watchdog：参数对架构的影响

每个 config_ref 引用 PC canonical 的参数 ID；产品配置引用同一参数空间，不另发明旋钮。

## PRESCALE_WIDTH

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.PRESCALE_WIDTH
config_ref: PARAM.WATCHDOG.PRESCALE_WIDTH
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
  - HLD.MOD.WATCHDOG.SAFETY
architecture_effect: 调整分频合法空间与独立相位保护，配置截断禁止。
req_ref:
- LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

调整分频合法空间与独立相位保护，配置截断禁止。

## NUM_CLIENTS

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.NUM_CLIENTS
config_ref: PARAM.WATCHDOG.NUM_CLIENTS
affects:
  modules:
  - HLD.MOD.WATCHDOG.BUS
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 调整每通道客户端状态与配置规模；仍要求整表原子快照与固定命令时限。
req_ref:
- LRS.CFG.WATCHDOG.NUM_CLIENTS.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

调整每通道客户端状态与配置规模；仍要求整表原子快照与固定命令时限。

## SOURCE_WIDTH

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SOURCE_WIDTH
config_ref: PARAM.WATCHDOG.SOURCE_WIDTH
affects:
  modules:
  - HLD.MOD.WATCHDOG.BUS
  - HLD.MOD.WATCHDOG.TRANSPORT
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 调整可信身份负载宽度与授权比较，不生成额外身份可信性。
req_ref:
- LRS.CFG.WATCHDOG.SOURCE_WIDTH.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

调整可信身份负载宽度与授权比较，不生成额外身份可信性。

## SYNC_STAGES

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SYNC_STAGES
config_ref: PARAM.WATCHDOG.SYNC_STAGES
affects:
  modules:
  - HLD.MOD.WATCHDOG.INTEGRATION
  - HLD.MOD.WATCHDOG.TRANSPORT
architecture_effect: 调整同步释放/控制传递和时限预算；不直接同步多位负载。
req_ref:
- LRS.CFG.WATCHDOG.SYNC_STAGES.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

调整同步释放/控制传递和时限预算；不直接同步多位负载。

## SUPPORT_TOKEN_QA

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SUPPORT_TOKEN_QA
config_ref: PARAM.WATCHDOG.SUPPORT_TOKEN_QA
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 裁剪增强服务算法与 token 状态，未实现模式返回 UNSUPPORTED。
req_ref:
- LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

裁剪增强服务算法与 token 状态，未实现模式返回 UNSUPPORTED。

## SUPPORT_SUPERVISION

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.SUPPORT_SUPERVISION
config_ref: PARAM.WATCHDOG.SUPPORT_SUPERVISION
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 裁剪 GROUP/ALIVE/FLOW，基础 SINGLE 保留；不能因裁剪重排地址。
req_ref:
- LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

裁剪 GROUP/ALIVE/FLOW，基础 SINGLE 保留；不能因裁剪重排地址。

