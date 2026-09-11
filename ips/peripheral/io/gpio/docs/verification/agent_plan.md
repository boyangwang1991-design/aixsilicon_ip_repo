# GPIO Agent计划

APB active master驱动setup/access、PSTRB/PPROT，支持连续PSEL下背靠背；passive monitor确认协议并将完成事务发送给RM。GPIO active driver产生异步PAD输入和主域同步available/owned/低功耗控制；AON driver拥有独立时钟、可停钟，available遵循AON同步前提。monitor不复用driver的预期结果。

依据当前复用成熟度审计，APB VIP仍developing且G4/G5 PARTIAL，GPIO VIP planned，采用IP内临时UVM agent并记录复用gap；不复制VIP资产仓源码。后续合格VIP以FuseSoC depend替换。

reset agent负责冷复位双域和主暖复位；供电只使用数字隔离/retention抽象，不能以数字仿真声称PAD电气签核。scoreboard在未完成事务清退、命令编号对账后才允许test结束；所有analysis队列为空且无未核对结果。
