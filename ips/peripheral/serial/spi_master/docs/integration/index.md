# 集成文档

[完整集成指南](../integration.md) 是 IO/时钟/复位、APB 窗口、IRQ、Pad/pinmux、软件并发和约束预算的当前说明。

本候选实现只有 PCLK 域；PRESETn 异步断言、系统同步解除。必须将 MISO 按外部源同步返回路径进行时序预算，不使用异步输入 false path。布局后的本域功能 clear/reset recovery/removal 仍需检查。约束文件仅供已报告的 28nm 表征使用。
