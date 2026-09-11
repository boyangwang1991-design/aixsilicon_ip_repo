# Watchdog：APB 访问行为

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.INTF.WATCHDOG.BUS.001

<!-- LRS_META
id: LRS.INTF.WATCHDOG.BUS.001
category: INTF
feature: bus
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-BUS-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

仅支持 32-bit 对齐访问；读取 PSTRB 不参与判断。所有有效寄存器写要求 PSTRB=4'b1111；非完整写、越界/未实现地址、写 RO、权限拒绝、保留位非零应在该笔完成时 PSLVERR=1 且不产生状态副作用。读 WO 返回 0。

#### Acceptance Criteria

- 不对齐、部分写、越界、RO 写、权限拒绝、保留位非零均 PSLVERR 且无请求副作用；WO 读零。

## LRS.INTF.WATCHDOG.BUS.002

<!-- LRS_META
id: LRS.INTF.WATCHDOG.BUS.002
category: INTF
feature: bus
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-BUS-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

APB 访问仅在 PSEL && PENABLE && PREADY 边沿接受一次。常规访问采用固定有限延迟，最多进入 ACCESS 后 2 个 pclk 周期完成；不得等待停住的 wdt_clk 无限拉低 PREADY。

#### Acceptance Criteria

- 持续 ACCESS 只完成一次，wdt_clk 停止时也在最多 2 个 pclk ACCESS 周期内响应。

## LRS.INTF.WATCHDOG.BUS.003

<!-- LRS_META
id: LRS.INTF.WATCHDOG.BUS.003
category: INTF
feature: bus
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-BUS-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

能定位到有效通道的权限/格式拒绝，通过独立合并型事件握手将 ACCESS_ERROR 送达该通道，不占用命令邮箱、不推进服务协议；连续错误允许合并为一个粘滞事件，不承诺逐次计数。该事件发送状态由 POR 复位，preset_n 不丢弃已经捕获的事件。无有效通道的全局/越界访问只返回 PSLVERR，不伪造通道故障。忙拒绝属于流控，不产生 ACCESS_ERROR。该诊断路径不改变“返回错误的写不能执行其请求操作”的要求。

#### Acceptance Criteria

- 有效通道错误最终留下 ACCESS_ERROR，preset 不丢已捕获错误；全局越界/忙拒绝不伪造通道事件。

