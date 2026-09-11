# Checker 与独立参考模型

UVM RM 是IP功能验收唯一参考模型。输入为受校验实例参数、上游monitor的SETUP及完成记录、下游monitor的实际响应、可信reset/DFX授权和受控故障注入描述。RM独立维护active/shadow、锁、版本、日志/快照/FIFO、raw/mask、DFX状态与统计，不从DUT读回策略作为预计值，也不将生成CSR RTL当权限oracle。

SETUP预测自然准入、DFX叠加、目标、错误和版本；周期checker监控第一个下游SETUP是否已经有非法选择。完成时scoreboard对比响应、端口、原地址、身份、PRDATA/PSLVERR及恰好一次副作用。read-clear和write-trigger外设模型独立记录访问次数：仅比较上游读零不能证明拒绝无副作用。

RM每个pclk按沿前状态计算候选，再按LLD定义处理清除/POP/新事件、饱和计数和序列/时间戳。monitor使用clocking block采样约定；不得让软件完成事务和故障注入回调的调度顺序决定预期优先级。日志checker比较全部8字及有效字段清零，FIRST/LAST各维护独立快照。FIFO队头读取不让模型隐式弹出。

RAL使用本次实例RDL生成的UVM模型，访问属性/复位值由结构事实源提供；特殊状态的预测由RM控制，关闭自动镜像预测以避免W1C/命令被预测两次。非法/未授权访问必须保持目标镜像，审计状态由其独立模型更新。nonzero reset fixture检验配置维度与复位值绑定。

完整性故障由verification层受控force/deposit、随后按约定release实施。故障清单独立记录原始位、持续时间和期望位置；禁止仅通过DFX合成FATAL替代真实保护位翻转。故障位置观察可用层次引用，但不以DUT的FATAL输出代替RM的预期故障判断。

形式环境对合法静态配置、可信复位释放及输入APB稳定性作必要假设。四项必需安全性质单独报告proved/failed/inconclusive、参数范围、归纳深度和假设。若只在小配置穷尽，必须给出参数化推广证明或继续覆盖全支持范围；不得用小配置结果声称最大实例已证明。

系统证据checker需要受控协议版本、X2P输入/输出事务关联、路径/别名保护和可信来源实证；仅IP级回环不能证明无系统旁路。PPA checker绑定真实库/SDC及四点原始报告，不能编造数值。缺失输入为失败/阻塞，不输出静态PASS。
