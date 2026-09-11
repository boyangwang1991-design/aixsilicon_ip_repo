# POLICY 微设计

<!-- LLD_MODULE_META
id: LLD.MOD.APB_SECURE_DEMUX.POLICY
name: policy
hld_ref:
- HLD.MOD.APB_SECURE_DEMUX.POLICY
req_ref:
- LRS.REG.APB_SECURE_DEMUX.UPD.001
- LRS.REG.APB_SECURE_DEMUX.UPD.002
- LRS.REG.APB_SECURE_DEMUX.UPD.003
- LRS.REG.APB_SECURE_DEMUX.UPD.004
- LRS.REG.APB_SECURE_DEMUX.UPD.00501
- LRS.REG.APB_SECURE_DEMUX.UPD.00502
- LRS.REG.APB_SECURE_DEMUX.UPD.00601
- LRS.REG.APB_SECURE_DEMUX.UPD.00602
- LRS.REG.APB_SECURE_DEMUX.UPD.00701
- LRS.REG.APB_SECURE_DEMUX.UPD.00702
- LRS.REG.APB_SECURE_DEMUX.UPD.008
- LRS.REG.APB_SECURE_DEMUX.UPD.00901
- LRS.REG.APB_SECURE_DEMUX.UPD.00902
- LRS.REG.APB_SECURE_DEMUX.UPD.010
- LRS.REG.APB_SECURE_DEMUX.UPD.011
- LRS.SAFE.APB_SECURE_DEMUX.INT.001
- LRS.SAFE.APB_SECURE_DEMUX.INT.002
- LRS.SAFE.APB_SECURE_DEMUX.INT.00301
- LRS.SAFE.APB_SECURE_DEMUX.INT.00302
- LRS.SAFE.APB_SECURE_DEMUX.INT.004
- LRS.SAFE.APB_SECURE_DEMUX.INT.005
- LRS.SAFE.APB_SECURE_DEMUX.INT.006
- LRS.SAFE.APB_SECURE_DEMUX.INT.00701
- LRS.SAFE.APB_SECURE_DEMUX.INT.00702
- LRS.SAFE.APB_SECURE_DEMUX.INT.008
- LRS.SAFE.APB_SECURE_DEMUX.INT.009
- LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007
objects:
- LLD.DP.APB_SECURE_DEMUX.POLICY
rtl_intent:
  separate_module: true
  suggested_name: apb_secure_demux_policy
clock_domains:
- CLK_PCLK
reset_domains:
- RST_PRESET_N
END_LLD_MODULE_META -->

## 单写 owner 与提交

active_cfg/shadow_cfg 与 active_perm/shadow_perm 由同一模块管理。shadow 成功写只改目标字段及偶校验；commit 接收非空且无越界位的端口掩码，检查所有目标后同一边沿复制所选端口的整个 CFG 和全部 PERM，并更新 active 校验。任一失败全量保持；成功即使值相同也 policy_version+1。reload 同样全量检查后 active→shadow，不增加版本。

global/port lock 写一置位，写零保持。GLOBAL_LOCK 禁止全部 shadow 修改、reload、commit；仍允许 PORT_LOCK 追加设锁。PORT_LOCK 禁止本端口 shadow、reload、commit。读策略、处理审计和授权 DFX 不受锁限制。单 APB 没有后台队列，commit 完成前不存在另一笔在途外设事务；下一 SETUP 立即使用新 active/version。

## 存储保护与位置

POLICY_PARITY_EN=1 时各 CFG/PERM 计算偶校验，CFG 两位零扩展为四位接 parity CBB；PERM 以八位接入。同一状态 owner 同步更新数据和保护位。锁存储采用 01/10 互补编码，任何其他编码视为锁定且产生原始完整性错误。全部 active/shadow/锁并行持续检查，不能只检查当前访问项。

位置选择为 global_lock 优先；随后端口升序，每端口 lock、active_cfg、shadow_cfg、active_perm 主体升序、shadow_perm 主体升序。首次原始故障在下一边沿锁存 FATAL 和位置；后续故障不覆盖首次位置。DFX 合成完整性只有无真实错误时选 synthetic 位置，TEST=1。真实与合成同时触发时真实位置优先、记录不冒充合成。

FATAL 永久保持到可信复位，新 SETUP 组合阻断。shadow 写、reload、commit 被拒绝；诊断读及普通清除保持可用，PORT_LOCK/GLOBAL_LOCK 只能继续收紧，无法恢复 FATAL。POLICY_PARITY_EN=0 的分支不生成校验存储和保护逻辑，状态读零，锁仍用合法功能状态维持单向置位。

## 资源和组合检查

典型双银行 permission=2048 位，最大32768位，不含校验。保护位额外为每份每字一个，不把 32bit CSR 槽位当作32bit存储。归约按端口层次实现，所有保护检查组合汇入准入；不能逐周期巡检以缩短路径。复用 CBB 只通过依赖引用，不复制源码。
<!-- LLD_DATAPATH_META
id: LLD.DP.APB_SECURE_DEMUX.POLICY
module_ref: LLD.MOD.APB_SECURE_DEMUX.POLICY
operation: 拥有 active/shadow 权限与端口配置、单向锁、版本及完整性 FATAL。按提交掩码全量预检后原子更新；所有配置存储持续完整性检查。
latency: 组合判定；状态仅在 pclk 完成/事件边沿更新
req_ref:
- LRS.REG.APB_SECURE_DEMUX.UPD.001
- LRS.REG.APB_SECURE_DEMUX.UPD.002
- LRS.REG.APB_SECURE_DEMUX.UPD.003
- LRS.REG.APB_SECURE_DEMUX.UPD.004
- LRS.REG.APB_SECURE_DEMUX.UPD.00501
- LRS.REG.APB_SECURE_DEMUX.UPD.00502
- LRS.REG.APB_SECURE_DEMUX.UPD.00601
- LRS.REG.APB_SECURE_DEMUX.UPD.00602
- LRS.REG.APB_SECURE_DEMUX.UPD.00701
- LRS.REG.APB_SECURE_DEMUX.UPD.00702
- LRS.REG.APB_SECURE_DEMUX.UPD.008
- LRS.REG.APB_SECURE_DEMUX.UPD.00901
- LRS.REG.APB_SECURE_DEMUX.UPD.00902
- LRS.REG.APB_SECURE_DEMUX.UPD.010
- LRS.REG.APB_SECURE_DEMUX.UPD.011
- LRS.SAFE.APB_SECURE_DEMUX.INT.001
- LRS.SAFE.APB_SECURE_DEMUX.INT.002
- LRS.SAFE.APB_SECURE_DEMUX.INT.00301
- LRS.SAFE.APB_SECURE_DEMUX.INT.00302
- LRS.SAFE.APB_SECURE_DEMUX.INT.004
- LRS.SAFE.APB_SECURE_DEMUX.INT.005
- LRS.SAFE.APB_SECURE_DEMUX.INT.006
- LRS.SAFE.APB_SECURE_DEMUX.INT.00701
- LRS.SAFE.APB_SECURE_DEMUX.INT.00702
- LRS.SAFE.APB_SECURE_DEMUX.INT.008
- LRS.SAFE.APB_SECURE_DEMUX.INT.009
- LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007
END_LLD_DATAPATH_META -->
<!-- LLD_SAFETY_META
id: LLD.SAFETY.APB_SECURE_DEMUX.POLICY_INTEGRITY
mechanism: 全部active/shadow偶校验和互补锁持续检查
module_ref: LLD.MOD.APB_SECURE_DEMUX.POLICY
latency: raw组合阻断新SETUP；下一边沿锁存FATAL
limitation: 不保护译码逻辑/日志/任意多位故障
END_LLD_SAFETY_META -->
