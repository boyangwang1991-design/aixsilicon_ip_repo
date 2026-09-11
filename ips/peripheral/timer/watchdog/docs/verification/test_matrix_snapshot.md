# 全表原子快照：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.SNAPSHOT.001
name: snapshot
type: register
description: 全表原子快照
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_snapshot.sv
feature_ref:
- FL.WATCHDOG.SNAPSHOT
req_ref:
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 随机更新各客户端后SNAPSHOT；W64跨低字回卷；计时/服务/故障同拍快照；改变客户端选择器；停WDT读取旧镜像；preset保留上次成功快照，仅复位选择器及接口输出镜像。
expected_result:
- 命令执行边沿之后的模型状态生成整表期望；高低字、token、版本、序号同一代；普通读不更新；SNAP_VALID=0全镜像零。
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

Checker：命令执行边沿之后的模型状态生成整表期望；高低字、token、版本、序号同一代；普通读不更新；SNAP_VALID=0全镜像零。

覆盖采样：通道/客户端端点×快照并发事件×时钟比；保持到下一成功快照。
