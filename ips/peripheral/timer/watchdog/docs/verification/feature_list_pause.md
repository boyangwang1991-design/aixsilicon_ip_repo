# 暂停保持与安全连续性：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.PAUSE
name: 暂停保持与安全连续性
description: 暂停保持与安全连续性的可执行正确性证明
priority: must
req_ref:
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

sleep/debug权限组合、各D相位暂停；暂停中服务/配置、取消debug_auth；FLOW/双密钥暂停；暂停期间自身故障和升级。

独立判据：暂停保留C/D/序列/期限/统计；恢复继续原相位；PAUSED服务不排队；故障升级与自身检测始终运行；无隐式期限重载。

风险与边界：暂停来源×授权×通道状态×计时相位；安全/生产默认。

### LRS.LP.WATCHDOG.PWR.001

PAUSE_SLEEP/PAUSE_DEBUG 为 active 配置位，默认均 0。sleep_req 且 PAUSE_SLEEP 可进入 PAUSED；debug_req 且 debug_auth 且 PAUSE_DEBUG 且 !DEBUG_LOCK 可暂停。任一有效暂停源存在则保持暂停，两者均解除后恢复原 BOOT/RUN 状态。

验收：分别、同时施加两个暂停源；任一有效源维持暂停，两者解除才恢复原 BOOT/RUN。

### LRS.LP.WATCHDOG.PWR.002

暂停冻结 C、D、服务序列年龄、客户端 Deadline；不改变 active 配置、令牌及本轮 SEEN/ALIVE。进入/退出不授予新周期、不清故障。PAUSED 拒绝服务，不缓存待恢复执行的服务。

验收：暂停前后周期相位、序列、客户端、token 保持；PAUSED 服务拒绝且恢复后不重放。

### LRS.LP.WATCHDOG.PWR.003

故障升级、自身完整性检查、锁和诊断逻辑不暂停。自身故障在 PAUSED 仍直接升级。由 debug_auth 失效导致暂停撤销时，下一个运行边沿恢复监督。

验收：暂停期间注入自身异常仍升级；debug_auth 撤销后按规定边沿恢复监督。

### LRS.LP.WATCHDOG.PWR.004

sleep 参数切换不另设隐式模式：若需要睡眠专用期限，软件在允许更新的配置中提交新期限并确认其已生效后才能睡眠。禁止以睡眠请求直接重载计数或修改阈值。

验收：sleep 请求本身不重载阈值；睡眠专用期限只能经已生效的配置提交流程启用。

### LRS.LP.WATCHDOG.PWR.005

系统允许无限期暂停时，暂停期间没有时间监督覆盖；若需要暂停时长上限，应由不暂停的其他 WDT 通道或独立电源管理计时器监督。生产安全配置应禁用普通调试冻结。

验收：安全说明披露无限暂停期间无时间覆盖，列明外部上限监督者及生产调试策略。
