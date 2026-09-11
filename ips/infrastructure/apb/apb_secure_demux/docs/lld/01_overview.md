# 微架构总览

九个 HLD 责任块在 LLD 中逐一承接。物理 RTL 选用顶层 glue、组合译码、组合准入、策略银行、日志、通知、DFX、以及 PeakRDL CSR 模块。FRONTEND 与 ROUTE 在顶层共同管理同一份事务上下文，避免两份 pending 状态失配。CSR wrapper 与生成 CSR 分开，所有特殊状态由所属行为模块管理。

数据通路只容纳一笔事务。SETUP 末沿捕获请求、唯一目标、是否 CSR、主错误、版本、DFX TEST 标记；后续读取这个上下文，不重新判权。在 direct 模式，组合 SETUP 已发往下游；register 模式下游 SETUP 延后一拍。日志写口独立运行，无 ready 回连。

不存在跨时钟队列、取消、flush、posted write、仲裁多个上游或软件复位。除本地成功/失败完成、合法 APB 完成以及可信复位外，不释放事务。

寄存器细化分成权限与命令、日志、中断、DFX、端口策略五组行为；字段结构后续由 SystemRDL 唯一维护。真正 elaboration 的非法配置诊断放在配置检查入口及 verification 下的参数检查 bind，DUT 不依赖仿真系统任务。

最大规模保持完整主体比较，permission 存储采用 NUM_PORTS×NUM_MASTERS×8 位的 active/shadow 两份。端口和主体索引先范围检查再访问，所有循环界限来自正整数参数；FIFO=0 使用 generate 分支，不声明零长数组。
