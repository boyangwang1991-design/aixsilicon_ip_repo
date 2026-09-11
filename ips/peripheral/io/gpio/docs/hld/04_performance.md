# GPIO 性能与资源预算

每项时延是协议/功能预算；目标库、频率与角落未提供，因此不填虚构MHz、面积或功耗。LLD应给出精确周期表并证明满足本预算。

## APB

零等待Access；连续事务至少每2个pclk完成一次。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.APB
metric: throughput
target: 零等待Access；连续事务至少每2个pclk完成一次
allocated_to:
- HLD.MOD.GPIO.APB
req_ref:
- LRS.REG.GPIO.BUS001.001
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## OUTPUT

一次合法APB完成边沿更新数字OUT/OE，无额外时钟延迟。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.OUTPUT
metric: latency
target: 一次合法APB完成边沿更新数字OUT/OE，无额外时钟延迟
allocated_to:
- HLD.MOD.GPIO.OUTPUT
req_ref:
- LRS.FUNC.GPIO.OUT007.001
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## INPUT

稳定输入上界=(SYNC_STAGES+4+K_eff+D_eff*(DIV+1))*Tclk。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.INPUT
metric: latency
target: 稳定输入上界=(SYNC_STAGES+4+K_eff+D_eff*(DIV+1))*Tclk
allocated_to:
- HLD.MOD.GPIO.INPUT
req_ref:
- LRS.FUNC.GPIO.FLT006.001
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## FIFO

EVENT_FIFO_DEPTH条128-bit记录，每pclk最多接收1条，满+POP可交换。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.FIFO
metric: capacity
target: EVENT_FIFO_DEPTH条128-bit记录，每pclk最多接收1条，满+POP可交换
allocated_to:
- HLD.MOD.GPIO.FIFO
req_ref:
- LRS.FUNC.GPIO.EVT003.001
- LRS.FUNC.GPIO.EVT003.002
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## PARITY

存储parity故障在1个运行主时钟周期内检测。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.PARITY
metric: latency
target: 存储parity故障在1个运行主时钟周期内检测
allocated_to:
- HLD.MOD.GPIO.DIAG
req_ref:
- LRS.SAFE.GPIO.DIAG005.001
- LRS.SAFE.GPIO.DIAG005.002
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## AON_TIMEOUT

主时钟计数预算16..16777215，超时不释放BUSY。

<!-- HLD_PERF_META
id: HLD.PERF.GPIO.AON_TIMEOUT
metric: latency
target: 主时钟计数预算16..16777215，超时不释放BUSY
allocated_to:
- HLD.MOD.GPIO.MAILBOX
req_ref:
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
applicability:
  expr: 'true'
END_HLD_PERF_META -->

## 综合规划

至少覆盖N_GPIO=8/32/128、最小裁剪和完整增强配置，分别报告面积、关键路径、动态功耗估计与AON成本。128路IRQ与Bank读回采用分层平衡结构；单写事件选择允许树形最小编号选择。不可因未运行最大配置而推断已达标。
