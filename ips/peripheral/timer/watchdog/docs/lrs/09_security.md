# Watchdog：访问权限与安全边界

## LRS.SEC.WATCHDOG.AUTH.001

<!-- LRS_META
id: LRS.SEC.WATCHDOG.AUTH.001
category: SEC
feature: auth
priority: P0
status: active
source_ref:
- watchdog_contract.md:§4、WDT-SRV-003、WDT-SUP-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

配置、服务、诊断和测试权限应来自可信外部控制，并随事务捕获。软件可写 client/source 索引不得充当身份授权；拒绝访问不得刷新监督。

#### Acceptance Criteria

- 逐类撤销授权确认拒绝且不改变运行周期。
- 集成说明列出可信侧带和外部访问控制责任，APB PPROT 不被宣称为通用 Master ID。

## LRS.SEC.WATCHDOG.TOKEN.001

<!-- LRS_META
id: LRS.SEC.WATCHDOG.TOKEN.001
category: SEC
feature: token
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-007、WDT-SRV-008
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

TOKEN/QA 仅用于确定性执行与重放错误检测，不提供密码学认证或跨启动防重放保证。

#### Acceptance Criteria

- 文档明确固定重启种子和威胁边界；跨轮旧 token 拒绝。

