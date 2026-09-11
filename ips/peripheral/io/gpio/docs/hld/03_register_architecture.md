# GPIO 寄存器架构

地址与字段结构由 contract §15 进入 SystemRDL；本册只冻结分组、访问和状态所有权。

## CONTROL

GLOBAL_LOCK、输入/输出使能、FIFO控制与命令；状态由所属功能模块提供。合法APB完成时生效，AON命令转跨域握手。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.CONTROL
type: register_architecture
policy: 合法APB完成时生效，AON命令转跨域握手
register_group: CONTROL
description: GLOBAL_LOCK、输入/输出使能、FIFO控制与命令；状态由所属功能模块提供
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## CONFIG

逐引脚模式、滤波/去抖、分组、访问策略与锁。普通写立即生效；输入重配置有历史重建，输出模式须OE关闭，sleep期间模式不可改。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.CONFIG
type: register_architecture
policy: 普通写立即生效；输入重配置有历史重建，输出模式须OE关闭，sleep期间模式不可改
register_group: CONFIG
description: 逐引脚模式、滤波/去抖、分组、访问策略与锁
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## STATUS

身份/能力、输入视图、快照、Strap、FIFO头和AON完整读回。主域读沿前值；快照冻结；AON读缓存只在完整应答时更新。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.STATUS
type: register_architecture
policy: 主域读沿前值；快照冻结；AON读缓存只在完整应答时更新
register_group: STATUS
description: 身份/能力、输入视图、快照、Strap、FIFO头和AON完整读回
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## IRQ

Pending、Enable、方向记录、测试与分组。检测/输出分离、置位优先、独立显式清除。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.IRQ
type: register_architecture
policy: 检测/输出分离、置位优先、独立显式清除
register_group: IRQ
description: Pending、Enable、方向记录、测试与分组
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## ERROR

访问首故障、FIFO丢失/溢出、水位、AON错误/超时。sticky与实时源分开，清除粒度遵循各源；新故障优先。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.ERROR
type: register_architecture
policy: sticky与实时源分开，清除粒度遵循各源；新故障优先
register_group: ERROR
description: 访问首故障、FIFO丢失/溢出、水位、AON错误/超时
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## SAFETY

诊断使能/Pending/测试与parity注入、安全请求。诊断正常主复位；parity安全请求只POR清除。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.SAFETY
type: register_architecture
policy: 诊断正常主复位；parity安全请求只POR清除
register_group: SAFETY
description: 诊断使能/Pending/测试与parity注入、安全请求
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: 'true'
END_HLD_POLICY_META -->

## AON_STAGE

每Bank暂存/命令和活动配置读回。BUSY空闲才可改暂存；COMMIT原子更新；SNAPSHOT/CLEAR/LOCK独立语义。

<!-- HLD_POLICY_META
id: HLD.REGARCH.GPIO.AON_STAGE
type: register_architecture
policy: BUSY空闲才可改暂存；COMMIT原子更新；SNAPSHOT/CLEAR/LOCK独立语义
register_group: AON_STAGE
description: 每Bank暂存/命令和活动配置读回
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_POLICY_META -->

## CSR实现约束

PeakRDL 结构生成与功能模块状态 owner 分离；读值必须沿前可见并保持 PREADY=1，后续 LLD/生成参数需要证明生成接口不额外插入 APB 等待。命令、掩码别名与所有写入口统一接受 APB 原子性检查。
