# LRS 恢复核验与委托评审

本次依照用户要求“请根据ip-development-suite，帮我完成看门狗ip的设计流程”，
以及已保存的 [持续授权](continuation_authorization.md) 中
`approve, complete the rest` / `finish the rest, you don't have to ask for permission`，
由 AI 执行恢复核验。这是用户委托检查，不冒称新的人类或独立安全评审。

范围为 watchdog-contract-1.0.0-full-flow-r1 的当前 LRS；保留原契约和
[历史 G0 记录](g0_review.md)。旧快照与当前文件存在差异，不能声称旧哈希仍匹配。
本次重新抽取全部 139 条需求、16 项参数、188 个配置并执行参数语义检查，
检查输出在 build/reports/design/lrs 与 build/reports/quality 中。

核验重点为：APB 接收与 WDT 执行分离；错误访问不服务；停钟时 APB 有界响应；
候选年龄与到期优先级；preset 保留邮箱而 warm 取消未执行命令；配置原子提交；
恢复握手与最终请求保持；三产品档及非法参数拒绝；独立停钟/掉电由系统覆盖。
保留已有外部接口、计时和安全要求，不根据候选 RTL 降低验收要求。

本记录仅确认当前需求可交给 PC/HLD 继续设计；188 项输入检查不是 188 项 RTL
配置执行，不证明功能覆盖、物理冗余、PPA、系统安全认证或发布通过。
GATE_META 中的时间与输入指纹记录本次核验，不能解释成历史批准时间。
