# 参考模型、checker和观测契约

## 唯一功能判据

`verification/env/watchdog_reference_model.sv` 是UVM功能期望的唯一入口。它消费monitor记录的已接受事务、WDT边沿、可信复位/暂停/恢复事件。
模型维护每通道配置版本、绝对周期起点、客户端事件历史、服务协议、故障/升级及快照代际。
普通计时从起点和暂停区间推导floor(active_cycles/(P+1))；FLOW期限用独立时间戳；ALIVE按固定区间分桶；GROUP用集合差。
不复制RTL q/n赋值顺序，不读取DUT计数/状态作为期望，也不调用watchdog_pkg的validate_config/response生成预期。
配置合法性按LRS规则独立实现；QA使用规范固定运算和已知向量；优先级以事件表归约。
只在服务窗口、取消、快照及安全延迟需要的地方使用边沿精度。

## 输入及比较路径

| 观测源 | 模型输入 | Checker比较 |
|---|---|---|
| APB monitor | SETUP与接受边沿、地址/属性/可信侧带、读回/PSLVERR | RDL属性、固定延迟、拒绝无副作用、staging及即时状态 |
| mailbox执行monitor | 接受序号与执行/取消边沿 | 对照APB接受队列恰一次，原子负载与结果/序号匹配 |
| WDT边沿monitor | 时钟、HW valid/ready、warm/recovery/pause | 仲裁顺序、每通道周期与恢复资格 |
| 输出monitor | IRQ/NMI/reset/safety/wake/ack | 逐边沿检查请求、保持与清除；IRQ允许pclk同步延迟 |
| 快照读回 | SNAP_SEQ与全客户端表 | 与模型捕获的一代post-update镜像逐字段比较 |
| 故障注入monitor | 已施加的故障位置和可观测时点 | 2周期诊断上界、真实输出、FIRST/test context |

mailbox monitor可通过bind观察内部执行脉冲，但其期望只能来自APB/HW输入队列，不能拿DUT result作预期。
Scoreboard保留expected/actual transaction和完整上下文，mismatch立即UVM_ERROR；check_phase要求没有遗留预期/实际项。
停钟测试明确保留一条pending直到恢复或可信取消，不把全局drain检查关闭。

## RAL

PeakRDL UVM输出是寄存器地址/访问属性唯一RAL源。frontdoor适配APB item，显式predictor只消费monitor已完成成功访问。
关闭重复auto_predict。RO快照/状态用模型显式预测，不以常规寄存器mirror假定实时运行状态。
WO返回零不写镜像；staging reset由实例DEFAULT_CFG生成预测，不把RDL默认结构值误用于所有实例。
全表SNAPSHOT、CMD序号和W1C set优先使用专用checker；禁止backdoor写运行计数来构造正常功能场景。

## RM自身验证

以手算已知向量验证P=0/1的精确到期、窗口上下界、QA、双密钥inclusive边界、ALIVE边界桶、FLOW deadline、set/clear优先。
用故意改错的结果喂给scoreboard，确认每类关键输出能报错；保留负向self-test日志，不能仅证明模型可编译。
软件mock、静态网表和PDK检查是独立辅助证明，不能代替功能UVM oracle。
