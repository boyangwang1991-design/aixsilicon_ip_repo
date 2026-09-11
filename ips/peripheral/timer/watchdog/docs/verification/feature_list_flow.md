# 线性流程与独立期限：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.FLOW
name: 线性流程与独立期限
description: 线性流程与独立期限的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.SUP.007
- LRS.FUNC.WATCHDOG.SUP.008
- LRS.FUNC.WATCHDOG.SUP.009
- LRS.FUNC.WATCHDOG.SUP.010
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

START/STEP/END完整流程，跳步倒序重复及未开始END；多客户端交错；DEADLINE_MIN/MAX边界、暂停和主TIMEOUT先后。

独立判据：独立预期检查点列表与绝对WDT时间戳检查顺序；END满足MIN≤elapsed<MAX及主窗口才完成；先到期限优先且同拍原因全保留。

风险与边界：step首/中/末×错误类别×deadline边界×主窗口。

### LRS.FUNC.WATCHDOG.SUP.007

FLOW 为每客户端定义线性检查点 `0..LAST_STEP`，LAST_STEP 为 1～255。START(data=0) 开启该客户端本轮流程；之后 STEP 必须严格递增至 LAST_STEP-1；END(data=LAST_STEP) 结束。LAST_STEP=1 时 START 后直接 END。该模式不使用密钥服务，SERVICE_MODE 必须设 0，采用来源授权和检查点检查。

验收：LAST_STEP=1 和 255 均符合 START/STEP/END 定义；FLOW 禁止非 SINGLE_KEY 编码配置。

### LRS.FUNC.WATCHDOG.SUP.008

每客户端 START 在本轮只允许一次；重复、跳步、倒序、未 START 的 END 均为 FLOW_SEQUENCE。START/STEP 可在主窗口前发生，但 END 必须满足主窗口，否则 EARLY_SERVICE。所有必需客户端 END 后刷新通道。

验收：重复/跳步/倒序/未 START 的 END 触发 FLOW_SEQUENCE；早 END 失败；最后完成才刷新。

### LRS.FUNC.WATCHDOG.SUP.009

独立未分频 W-bit deadline 计数从 START 边沿置零，下一个边沿起递增。END 必须满足 `DEADLINE_MIN <= elapsed < DEADLINE_MAX`，MAX>MIN；到达 MAX 边沿时，Deadline 超时优先于 END。PAUSED 冻结；其他客户端服务不延后该期限。

验收：END 在 MIN 接受、MAX 拒绝；暂停冻结 Deadline；其他客户端活动不能延期。

### LRS.FUNC.WATCHDOG.SUP.010

完整完成前主 TIMEOUT 仍有约束；两类期限先到先故障。FLOW 仅覆盖配置的线性检查点顺序及时间，不声称完整控制流或数据正确性验证。

验收：主超时与 Deadline 任一先到均故障；声明 FLOW 只保证指定线性检查点与时间条件。
