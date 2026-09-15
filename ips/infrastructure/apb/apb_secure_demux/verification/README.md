# APB Secure Demux 验证源码

仿真入口为 [sim/Makefile](sim/Makefile)，编译文件及外部 VIP/CBB 依赖由 IP 根目录 FuseSoC core 管理。上游身份通过项目 sequence 与 APB 事务同步驱动；环境级复位在 driver 中止当前项后清理 sequencer。独立 RM 根据输入契约建模，逐周期 checker 检查 SETUP 准入、响应、身份及隔离；目标模型只在完成边沿执行副作用。

候选 APB VIP 只负责协议激励、响应时序和被动监测，其 SETUP 更新的内存不作为副作用 oracle。原始日志、哈希快照和覆盖库只在 build/。人工结论、验证范围及所有未闭环项目见 [统一报告](../reports/report.md)。
