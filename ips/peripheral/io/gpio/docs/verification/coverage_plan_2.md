# GPIO 功能覆盖 2

仅对独立checker已核对的采样计数；未实现、未知和失败样本不能计入通过覆盖。

<!-- COVERAGE_META
id: COV.GPIO.AON.001
name: 常开唤醒与命令
type: functional
description: 命令×时钟比×停钟×复位阶段×锁×超时
feature_ref:
- FL.GPIO.AON
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.CAPTURE.001
name: 快照与Strap
type: functional
description: 触发源×有效向量×序号边界×Strap时机
feature_ref:
- FL.GPIO.CAPTURE
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.FIFO.001
name: 事件队列与时间戳
type: functional
description: 占用×POP×事件数×FLUSH×CLEAR_LOST×水位
feature_ref:
- FL.GPIO.FIFO
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.DIAG.001
name: 物理回读诊断
type: functional
description: 驱动状态×消隐边界×失配长度×W1C
feature_ref:
- FL.GPIO.DIAG
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.PARITY.001
name: Parity与安全锁存
type: functional
description: Bank×部分写×注入权限×暖复位×安全输出
feature_ref:
- FL.GPIO.PARITY
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.RESET.001
name: 复位矩阵
type: functional
description: 复位种类×状态类别×事务阶段
feature_ref:
- FL.GPIO.RESET
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.DELIVERY.001
name: 集成与工程签核
type: configuration
description: 文档×配置×EDA阶段×来源哈希
feature_ref:
- FL.GPIO.DELIVERY
applicability:
  expr: 'true'
END_COVERAGE_META -->

