# Watchdog：性能及时限

## LRS.PERF.WATCHDOG.TIME.001

<!-- LRS_META
id: LRS.PERF.WATCHDOG.TIME.001
category: PERF
feature: time
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-005、WDT-SUP-005
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

连续 wdt_clk 且无暂停/恢复时，普通/窗口监督精确在 TIMEOUT*(P+1) 周期到期；ALIVE 以同一期限评价完整周期健康条件。

#### Acceptance Criteria

- 从周期开始逐拍比较精确边界，最后合法服务边沿与到期边沿严格区分。

## LRS.PERF.WATCHDOG.COMMAND.001

<!-- LRS_META
id: LRS.PERF.WATCHDOG.COMMAND.001
category: PERF
feature: command
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-BUS-002、WDT-NFR-002、WDT-NFR-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

APB ACCESS 响应至多 2 个 pclk 周期；命令在 WDT 域可见后，无竞争至多 2 个、有持续硬件竞争至多 3 个 WDT 周期内执行。两域持续运行时的总服务延迟应包含 CDC 和仲裁。

#### Acceptance Criteria

- 检查总线与命令执行两个不同上界；停 wdt_clk 时仍满足 APB 响应界而不虚构执行完成。

## LRS.PERF.WATCHDOG.SAFETY.001

<!-- LRS_META
id: LRS.PERF.WATCHDOG.SAFETY.001
category: PERF
feature: safety
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SAF-005
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

对已定义且已激活的数字比较/编码异常，安全配置应在可观测边沿起最多 2 个 WDT 周期产生安全/最终请求。

#### Acceptance Criteria

- 逐诊断路径测量最坏检测时间；系统请求后安全状态实际到达时间另行预算。

