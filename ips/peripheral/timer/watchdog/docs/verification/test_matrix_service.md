# 软件密钥与令牌服务：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.SERVICE.001
name: service
type: boundary
description: 软件密钥与令牌服务
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_service.sv
feature_ref:
- FL.WATCHDOG.SERVICE
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.SEC.WATCHDOG.TOKEN.001
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 遍历SINGLE/DUAL/TOKEN/QA；密钥首笔、重复首笔、错第二笔、无首笔；SEQ_LIMIT前/当拍/后；旧token重放、错source、读取challenge。
expected_result:
- 独立常量/LFSR/QA算术与序列时间表判定；只有完整合法完成贡献；拒绝不刷新、不换token；首笔及无关读写不改变计时。
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

Checker：独立常量/LFSR/QA算术与序列时间表判定；只有完整合法完成贡献；拒绝不刷新、不换token；首笔及无关读写不改变计时。

覆盖采样：算法×结果×序列边界×窗口；令牌每客户端独立。
