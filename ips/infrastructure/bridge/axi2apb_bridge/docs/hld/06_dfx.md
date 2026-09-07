# 06. 软件/可测性/约束设计 `[可选]`

> 对应原章节：13. 软件可见行为、14. Debug 信号、15. 时序/面积约束

---

## 13. 软件可见行为

X2P 无寄存器，软件仅通过 AXI 读写在协议级与 APB 外设交互，无 IP 自身软件接口。

## 14. Debug 信号

- X2P 不定义仿真专用 debug 接口；关键状态可通过 AXI R/B 响应与 APB PREADY/PSLVERR 观测。

## 15. 时序/面积约束

| 约束 | 说明 |
|---|---|
| 参数裁剪 | 关闭功能 generate-out（AXI4-Lite 无 ID/burst/WRAP；SYNC 无 CDC；同宽无 width engine） |
| Way 面积 | 主要来自 request buffers、CDC buffers、read assembly、outstanding metadata |
| 时钟约束 | clk_axi/clk_apb 独立约束；ASYNC 的 async FIFO 跨域路径 false path 由 CDC 工具标记 |