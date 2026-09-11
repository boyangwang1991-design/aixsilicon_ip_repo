# Watchdog：G2 检查与实现差异

<!-- LLD_GATE_META
gate: G2
status: pass
microarchitecture_freeze: true
register_freeze: true
approvals:
  architecture: user_authorized
  rtl: user_authorized
  verification: user_authorized
approval_ref: reports/full_flow/continuation_authorization.md
END_LLD_GATE_META -->

## 设计与现有候选的差异清单

| ID | 当前发现 | 处置 |
|---|---|---|
| LLD.DIFF.SAFETY_ACCEPT | 现有服务保护只复制KEY1比较，未独立覆盖完整accepted/refresh谓词 | RTL阶段实现独立资格和refresh控制；按本LLD而非旧代码验收 |
| LLD.DIFF.FINAL_HOLD | 现有输出直接来自q.final_req，缺少独立于普通n选择链的保持寄存器 | 按SAFETY.FINAL_REQUEST增加独立锁存及网表证明 |
| LLD.DIFF.REG_CPU | 现有passthrough+APB包装需与02要求的CPU接口适配核对 | apb4-flat正式生成并经VCS编译；两个异步时钟APB回归通过 |
| LLD.DIFF.COMMIT_PRIORITY | 现有RUN分支有将先前UNSUPPORTED结果覆盖成BAD_CONFIG的赋值路径 | 按配置校验/状态/锁优先级统一结果并验证整组拒绝 |
| LLD.DIFF.ARB_CANCEL | 取消抢占时CBB grant_ack固定1可能在未消费硬件事件时更新指针 | 已核对组合模式忽略ack；取消窗口屏蔽req_i，旁路取消，正常请求再轮换 |

设计关注点：所有FSM转移/非法态、候选年龄边界、参数裁剪、reset与握手四阶段、
同拍多原因、set/clear碰撞、完整服务双路径及final保持独立性。这里只定义应观察行为，
不编写testcase/coverage；06负责将其转为验证方案。

用户持续授权见 [授权记录](../../reports/full_flow/continuation_authorization.md)。
正式 CSR 生成/编译清单及字段检查见 [寄存器检查](../../reports/quality/register_check.md)、
[LLD 检查](../../reports/quality/lld_check.md)。原生 APB4 两个异步时钟配置回归均通过，
日志见 reports/full_flow/g2_apb4_regression.log。G2 是设计与寄存器基线交接；上表其他 RTL 差异仍由后续实现和验证闭合。
