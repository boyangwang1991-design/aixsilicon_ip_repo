# 静态、复位与综合告警评审

SpyGlass X-2025.06 对最终 RTL：0 Fatal、0 Error、150 Warning、5 Info；没有应用工具 waiver。报告源为 build/rtl/lint_spyglass/spyglass-1/consolidated_reports/spi_master_top_lint_lint_rtl/moresimple.rpt。此文是本次作者的技术分析，不虚构独立审查签名。

| 规则 | 数量 | 分析 |
|---|---:|---|
| W415a | 91 | 组合默认赋值后按解码/优先级覆盖。大多数来自 PeakRDL 的 readback/mask；engine 的默认 next-state、选中 CS 和 stop 优先级有意覆盖。无多 always driver |
| W424 | 18 | engine 自动 void function 修改本 always_comb 的 next-state/output。仅一个调用上下文；VCS/SpyGlass/DC 均已执行。此结构避免无参 task 的敏感列表遗漏；后续可改纯函数返回 struct 改善可读性 |
| W528 | 15 Warning + 1 Info | 生成的只读 decode 和 WO 存储镜像不被消费；wrapper 在成功 ACCESS 沿直接处理当前数据。不能用滞后一拍的 WO 值处理副作用 |
| W287b | 9 | CBB rd_valid 在组合头模式不需要；PeakRDL passthrough ack/stall/error 不用作 APB ready，wrapper 已做完整地址/访问/运行态校验，不产生等待 |
| W240 | 1 Warning + 1 Info | PPROT 按合同全部忽略，8 种值动态测试通过 |
| SYNTH_5064 | 10 | 原 CBB SVA 被综合忽略；仿真保留并启用 |
| STARC05-1.3.1.3 | 5 | reset 同时屏蔽 FIFO RAM 写使能，防止清除窗口写入。clear_q/soft_reset_q 均由 PCLK 触发；系统 PRESETn 解除必须同步。布局需检查 recovery/removal，此处未宣称 RDC 工具签核完成 |
| STARC05-2.2.3.3 | 1 | reset 对 packed q 先清零、再将 cs_n 置全 1；同一 always_ff，后赋值优先，无功能歧义 |
| 信息 | 3 | enableSV 被 enableSV09 覆盖、top 检测、elaboration summary |

DC 三种配置全部完成，无 violated constraints。check_design 的未连接端口来自 PPROT、命令保留位和算术进位；常量/短接输出来自生成 CSR reset/read-only 值；PRESETn 到 PREADY feedthrough 是复位期拉低 ready 的显式设计。报告无 latch、未解析 cell 或多驱动错误。

时钟/复位结构审查：手写 RTL 仅 PCLK 正沿触发；SCLK 是寄存输出而非内部时钟，无组合门控。FIFO 数据 RAM 不全量复位。MISO 保持源同步返回路径，SDC 未 false-path MISO；外部 3 ns 返回延迟有仿真检查。完整专用 CDC/RDC、形式证明及布局后的复位时序不在已完成工具证据中，不能由 lint 零错误替代。
