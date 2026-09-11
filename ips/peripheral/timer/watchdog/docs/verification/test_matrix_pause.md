# 暂停保持与安全连续性：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.PAUSE.001
name: pause
type: low_power
description: 暂停保持与安全连续性
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_pause.sv
feature_ref:
- FL.WATCHDOG.PAUSE
req_ref:
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- sleep/debug权限组合、各D相位暂停；暂停中服务/配置、取消debug_auth；FLOW/双密钥暂停；暂停期间自身故障和升级。
expected_result:
- 暂停保留C/D/序列/期限/统计；恢复继续原相位；PAUSED服务不排队；故障升级与自身检测始终运行；无隐式期限重载。
timeout_policy: 仿真10ms/1000000 WDT边沿，进程600秒；静态每配置1800秒，超时失败
config_ref:
- CFGSET.WATCHDOG.STANDARD
- CFGSET.WATCHDOG.SAFETY
- CFGSET.WATCHDOG.SUPERVISOR
- CFGSET.WATCHDOG.PC_MATRIX
applicability:
  expr: 'true'
END_TESTCASE_META -->

各子场景以独立scenario名称记录运行配置、seed、刺激、预期与实际；任一子场景失败则整个TC失败。

UVM factory注册类名必须等于文件名stem；不得以空run_phase或调用只有打印PASS的任务充当执行。

Checker：暂停保留C/D/序列/期限/统计；恢复继续原相位；PAUSED服务不排队；故障升级与自身检测始终运行；无隐式期限重载。

覆盖采样：暂停来源×授权×通道状态×计时相位；安全/生产默认。
