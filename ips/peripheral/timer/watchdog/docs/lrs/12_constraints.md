# Watchdog：集成、时限和多视图交付约束

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.CONS.WATCHDOG.NFR.001

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.001
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

IP 应兼容声明的同步时钟及复位集成方式，可综合且不得产生非预期锁存或未声明的新时钟；具体时钟使能和复位电路由 HLD/LLD 定义。

#### Acceptance Criteria

- 综合/静态检查无非预期锁存和组合生成时钟；时钟/复位使用范围可审查。

## LRS.CONS.WATCHDOG.NFR.002

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.002
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-002
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

从命令接收至执行的 CDC 固定延迟和最大仲裁延迟必须在架构文档中给出，以 pclk/wdt_clk 周期表达。只在两个时钟持续运行的假设下给出该上界；不得承诺停钟后仍有有限命令完成时间。

#### Acceptance Criteria

- 架构给出两个时钟持续时的 CDC/仲裁上界与计量单位；停止任一时钟不承诺有限完成。

## LRS.CONS.WATCHDOG.NFR.003

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.003
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

无硬件事件竞争时，合法 mailbox 命令进入 WDT 域可见后最多2个 wdt_clk 周期内执行；有持续硬件事件竞争时最多3个周期。快照与配置提交为一个原子操作，不可循环扫描数十拍后对外声称同拍快照/提交。

#### Acceptance Criteria

- 命令可见至执行在无竞争时至多 2 拍、有持续事件竞争时至多 3 拍，原子快照/提交无跨拍撕裂。

## LRS.CONS.WATCHDOG.NFR.004

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.004
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-004
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

通道计时和升级不得受 APB backpressure、长读操作、客户端数或诊断访问影响。配置及客户端存储可按参数裁剪；不以共享轮询计数方案牺牲检测时限。

#### Acceptance Criteria

- 改变通道/客户端规模及 APB 背压时，独立计时和升级到期边沿保持规定期限。

## LRS.CONS.WATCHDOG.NFR.005

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.005
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-005
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

PPA 无通用工艺无关数值门限。交付应报告 STANDARD单通道、SAFETY单通道、SUPERVISOR代表配置的面积/时序/功耗条件，包含工艺、库、时钟、活动假设及冗余开销；不虚构频率或门数达标。

#### Acceptance Criteria

- 三个产品配置分别有真实库/工艺/时钟/活动假设及面积时序功耗原报告；无资料则不得签核。

## LRS.CONS.WATCHDOG.NFR.006

<!-- LRS_META
id: LRS.CONS.WATCHDOG.NFR.006
category: CONS
feature: nfr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-NFR-006
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

RTL、寄存器头文件、驱动常量、验证RAL和能力元数据必须使用同一配置定义生成/核对，防止模式、位宽与寄存器地图不一致。无需强制使用某一种RTL生成语言。

#### Acceptance Criteria

- RTL/CSR 头/驱动/RAL/能力对同一参数定义检查一致，不允许地址、宽度或模式漂移。

