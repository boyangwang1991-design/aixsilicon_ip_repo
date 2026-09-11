# Watchdog：服务算法与硬件事件

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.SRV.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.001
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

所有软件服务通过 SERVICE 命令，运行计数只读。一次服务由 `client_id/op/source/data` 和硬件生成的完成序号关联。来源来自可信侧带，不使用软件可写寄存器替代。

#### Acceptance Criteria

- 运行计数不可软件写入；服务完成记录对应 client/op/可信 source 和硬件序号。

## LRS.FUNC.WATCHDOG.SRV.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.002
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

只有完整合法服务才可刷新计数；读取状态、第一笔密钥、IRQ 清除、配置写入不得刷新。RUN/BOOT 之外服务返回 BAD_STATE，PAUSED 返回 PAUSED；不因此产生服务协议故障。

#### Acceptance Criteria

- 逐项施加非完整服务操作，周期起点均不变化；非运行态返回规定状态码且不虚构协议故障。

## LRS.FUNC.WATCHDOG.SRV.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.003
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

服务来源不匹配、权限拒绝、错误写宽度属于访问错误，不推进服务序列也不自动停止计时。密钥错误、顺序错误、有效序列超时属于监督故障类别，按 FAULT_POLICY 处理。

#### Acceptance Criteria

- 来源/权限/写宽拒绝不推进序列；错密钥、乱序和序列超时按配置的故障策略响应。

## LRS.FUNC.WATCHDOG.SRV.004

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.004
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

服务序列时间以未分频 wdt_clk 周期计，定义第一笔在边沿 e0 完成，第二笔允许在 `1 <= e-e0 <= SEQ_LIMIT`；在 `e-e0=SEQ_LIMIT` 无合法完成即置序列超时。暂停期间冻结序列年龄。SEQ_LIMIT 必须大于 0，主监督期限优先。

#### Acceptance Criteria

- 第二笔在 e0+1 和 e0+SEQ_LIMIT 接受；边界无合法完成即超时，暂停冻结年龄，主到期优先。

## LRS.FUNC.WATCHDOG.SRV.005

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.SRV.005
category: FUNC
feature: srv
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SRV-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

SINGLE_KEY/DUAL_KEY 为必选。DUAL_KEY 第二笔没有第一笔、第一笔重复、第二笔值错误均置 BAD_KEY_SEQUENCE，并清空该客户端未完成序列。无关合法寄存器读写不打断序列，主计时继续。

#### Acceptance Criteria

- 正确单/双密钥完成；第二笔先到、重复第一笔、错误第二笔均触发 BAD_KEY_SEQUENCE。

