# Watchdog：服务算法与硬件事件

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.SRV.006

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.006
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

TOKEN/QA 为可裁剪功能；每客户端状态独立。启动时 `token = 0x1D872B41 XOR (channel_id<<8) XOR client_id`，channel/client 从 0 编号，运算按 32 bit；若结果为 0 则取 1。

#### Acceptance Criteria

- 逐通道/客户端核对 32-bit 初始种子和零值替换；裁剪配置拒绝 TOKEN/QA。

## LRS.FUNC.WATCHDOG.SRV.007

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.007
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

定义 `next(x) = (x >> 1) XOR ((x & 1) ? 0x80200003 : 0)`。TOKEN 模式期望值为 token；QA 模式 challenge=token，响应为 `ROL32(token,7) XOR 0x6D2B79F5 XOR (channel_id<<8) XOR client_id`。每个被接受的完整客户端服务后更新 token=next(token)，错误服务不更新；暂停/读取不更新。该算法仅为确定性的执行/重放错误检测，不提供密码学认证。

#### Acceptance Criteria

- 使用已知种子独立计算 next/ROL32 响应；成功更新一次，错误、暂停、读取均不更新。

## LRS.FUNC.WATCHDOG.SRV.008

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.008
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-008
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

TOKEN/QA 的当前值通过 SNAPSHOT 的客户端表读取，读取不产生新挑战。跨轮旧值必须失败；系统重启后种子会重复，不宣称跨启动防重放。服务完成反馈提供该客户端新 token 的可读快照途径。

#### Acceptance Criteria

- 同一轮多次快照读取挑战不变化；跨轮旧响应拒绝，复位后种子重复不解释为安全认证。

## LRS.FUNC.WATCHDOG.SRV.009

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.009
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-009
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件必须等待上一条服务结果后才发下一条。驱动不得因等待超时盲目重发；应读取最终执行序号和结果。窗口服务按 WDT 域完整服务完成边沿判断。

#### Acceptance Criteria

- 驱动等待超时后查询最终序号而不重复发送；服务判定以 WDT 域完成边沿为准。

## LRS.FUNC.WATCHDOG.SRV.010

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.010
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-010
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每通道 SERVICE_PATH 为 SOFTWARE 或 HARDWARE，运行中锁定，避免两个来源互相替代。硬件事件采用同一客户端/来源校验和监督状态；在硬件路径下 `data` 提交服务密钥/响应，FLOW 的 START/STEP/END 使用 type/data。

#### Acceptance Criteria

- 硬件/软件路径不互相替代；硬件客户端、来源和 FLOW 事件遵循相同合法性检查。

## LRS.FUNC.WATCHDOG.SRV.011

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.011
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-011
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

APB 命令与硬件事件同拍竞争时采用轮询仲裁，每 wdt_clk 最多执行一个状态修改命令；运行计时不受仲裁反压影响。硬件 valid 在 ready 前必须保持负载稳定。超过窗口的事件即使早先拉高 valid 也不能成功。

#### Acceptance Criteria

- 连续两来源竞争均获服务且单拍最多执行一项；ready 前负载稳定，过期排队事件仍失败。

