# GPIO 功能覆盖 1

仅对独立checker已核对的采样计数；未实现、未知和失败样本不能计入通过覆盖。

<!-- COVERAGE_META
id: COV.GPIO.CONFIG.001
name: 配置与裁剪
type: functional
description: 宽度×能力×可选功能×越界地址
feature_ref:
- FL.GPIO.CONFIG
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.APB.001
name: APB事务与错误
type: functional
description: 方向×PSTRB×权限×地址类别×错误原因
feature_ref:
- FL.GPIO.APB
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.INPUT.001
name: 输入有效性
type: functional
description: 初始值×相位×同步深度×有效性原因
feature_ref:
- FL.GPIO.INPUT
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.FILTER.001
name: 滤波与去抖
type: functional
description: K×D×DIV边界×短脉冲×重配置时刻
feature_ref:
- FL.GPIO.FILTER
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.OUTPUT.001
name: 输出原子更新
type: functional
description: 原子操作×mask边界×能力×拥有权×开漏×反相
feature_ref:
- FL.GPIO.OUTPUT
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.IRQ.001
name: 中断与方向事件
type: functional
description: 模式×有效性×DETECT×ENABLE×清除竞争×分组
feature_ref:
- FL.GPIO.IRQ
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.SECURITY.001
name: 锁与访问策略
type: functional
description: 锁种类×别名×mask×权限×暖复位
feature_ref:
- FL.GPIO.SECURITY
applicability:
  expr: 'true'
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.GPIO.LOWPOWER.001
name: 休眠和安全覆盖
type: functional
description: 模式×同拍写×safe×owned×停钟
feature_ref:
- FL.GPIO.LOWPOWER
applicability:
  expr: 'true'
END_COVERAGE_META -->

