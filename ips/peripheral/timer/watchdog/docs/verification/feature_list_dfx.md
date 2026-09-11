# 诊断测试和中断路径：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.DFX
name: 诊断测试和中断路径
description: 诊断测试和中断路径的可执行正确性证明
priority: must
req_ref:
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

IRQ_TEST与IRQ_ENABLE/W1C；短期限超时自检；注入使能/权限/锁/解锁条件；TEST_CONTEXT在同拍FIRST捕获；生产裁剪。

独立判据：IRQ_TEST仅置专用位，不喂狗也不证明超时比较；测试故障走真实请求；TEST_CONTEXT正确；生产未支持访问拒绝且无副作用。

风险与边界：测试类别×授权×实例×IRQ屏蔽；真实故障与测试并发。

### LRS.DFX.WATCHDOG.TST.001

DIAG_INJECT_EN=1 且 test_auth、配置诊断授权、未 DIAG_LOCK、解锁额度有效时，允许注入：主计数位翻转、分频位翻转、阈值副本翻转、状态非法编码、单比较路径翻转、服务判定完整性错误。注入选择由 FAULT_INJECT 命令数据定义，单次消费，不能持续压制真实故障。

验收：六类真实注入分别经过全部授权条件，逐一撤销条件时禁止；单次命令仅注入一次。

### LRS.DFX.WATCHDOG.TST.002

注入后必须经过真实故障检测和真实告警锁存路径；默认不屏蔽最终复位请求。若测试平台需防止实际复位，旁路由外部测试环境实现，并记录这不等于已测试真实系统执行链。

验收：注入经过真实检测/告警路径且默认最终请求不屏蔽；外部旁路须在结果中披露。

### LRS.DFX.WATCHDOG.TST.003

IRQ_TEST 仅测试中断通路，置单独测试状态，不推进监督计数、不证明超时比较器覆盖。超时自检通过专用未承担生产监督的通道配置短期限并停止服务完成，不提供运行中任意写 C 的后门。

验收：IRQ_TEST 仅产生测试事件；短期限不服务可触发真实超时；无运行计数写后门。

### LRS.DFX.WATCHDOG.TST.004

诊断测试事件标记 TEST_CONTEXT；真实故障位仍置位，FIRST_FAULT 应记录当时测试上下文。生产配置可彻底裁剪注入入口；scan/test 模式及生命周期要求须在集成文档列出。

验收：测试事件有 TEST_CONTEXT 且真实故障位照常置位；生产裁剪实例无法访问注入功能。
