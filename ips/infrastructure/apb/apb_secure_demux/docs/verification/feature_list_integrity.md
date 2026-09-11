# 真实保护位故障

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.INTEGRITY
name: 真实保护位故障
description: 真实保护位故障
priority: must
req_ref:
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
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.SAFE.APB_SECURE_DEMUX.INT.001`：POLICY_PARITY_EN=1 时，对每个 active/shadow PERM[7:0] 配置偶校验位，对每个 active/shadow CFG[1:0] 配置偶校验位；正常写、复制、复位同步更新校验。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.002`：PORT_LOCK 与 GLOBAL_LOCK 使用互补双位编码，合法解锁为 01、合法锁定为 10；00/11 为完整性错误，不得解码为解锁。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.00301`：必须持续检查上述全部存储，稳定单 bit 错误最迟在下一 pclk 边沿置 INTEGRITY_FATAL。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.00302`：用于当前 SETUP 的组合判权同时受当前原始完整性错误指示门控，不能仅等待粘滞位生效。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.004`：任一 active/shadow/lock 完整性错误触发全局 FATAL；新外设请求全部拒绝；现有已经发到下游的事务继续完成，不承诺撤销已有副作用。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.005`：FATAL 后管理诊断入口仍开放，允许读状态/日志/配置和清除普通事件；shadow 写、reload、commit 返回 CFG_INTEGRITY，不支持通过写新 parity 清除 FATAL。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.006`：首个完整性位置记录在 INTEGRITY_STATUS；多处同时错误按 global lock、端口升序，每端口 lock→active CFG→shadow CFG→active PERM 主体升序→shadow PERM 主体升序的优先级选择。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.00701`：LOCATION_TYPE：0=global lock，1=port lock，2=active CFG，3=shadow CFG，4=active PERM，5=shadow PERM，6=DFX synthetic。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.00702`：MASTER 仅 PERM 类型有效，其余为零。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.008`：POLICY_PARITY_EN=0 时不实现上述存储保护和注入功能，完整性状态读零，普通安全权限仍完整实现。
- `LRS.SAFE.APB_SECURE_DEMUX.INT.009`：本保护不覆盖任意多 bit 错误、组合译码/比较逻辑故障、日志存储完整性或外部总线传输完整性，不宣称满足特定 ASIL 或安全认证等级。
