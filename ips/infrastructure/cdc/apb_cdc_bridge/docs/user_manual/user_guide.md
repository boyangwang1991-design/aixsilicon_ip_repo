# APB CDC Bridge 用户手册

> **IP**: `apb_cdc_bridge` | **版本**: 1.0.0 | **日期**: 2026-09-07

## 1. 简介

APB CDC Bridge 是双时钟域、单事务、协议保持型 APB 跨时钟桥。上游 APB 事务被
捕获 → CDC 传输（HANDSHAKE 默认 / ASYNC_FIFO 可选）→ 下游 APB 重新生成 →
响应（PRDATA/PSLVERR/completion）返回。

## 2. 特性

- APB3/APB4 支持（PSTRB/PPROT 可裁剪）
- HANDSHAKE（默认，LOW_AREA）/ ASYNC_FIFO（BUFFERED）双实现
- SYNC_STAGES 可配置（2/3）
- 完全异步 / 快慢 / 同频异相 / 同源同步异频
- 独立复位（async assert / sync deassert）
- 时钟暂停兼容（pending 保持，恢复后继续）

## 3. 使用示例

```systemverilog
apb_cdc_bridge_top #(
  .ADDR_WIDTH (32),
  .DATA_WIDTH (32),
  .CDC_IMPL   (0),      // HANDSHAKE
  .SYNC_STAGES(2),
  .APB_PROFILE(1)       // APB4
) u_bridge (
  .s_pclk(s_pclk), .s_presetn(s_presetn),
  .s_psel(s_psel), .s_penable(s_penable), .s_paddr(s_paddr),
  .s_pwrite(s_pwrite), .s_pwdata(s_pwdata), .s_pstrb(s_pstrb), .s_pprot(s_pprot),
  .s_prdata(s_prdata), .s_pready(s_pready), .s_pslverr(s_pslverr),
  .m_pclk(m_pclk), .m_presetn(m_presetn),
  .m_psel(m_psel), .m_penable(m_penable), .m_paddr(m_paddr),
  .m_pwrite(m_pwrite), .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
  .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr)
);
```

## 4. 行为说明

- **单事务**：任一时刻一个跨桥事务；上游 PREADY 仅在下游完成或本地确定错误时拉高。
- **快→慢**：上游保持 PREADY=0 直至跨桥完成（合法 wait-state）。
- **慢→快**：下游快速 SETUP/ACCESS，最小化 CDC 延迟。
- **Reset**：任一侧 reset 可中止进行中事务；reset 后无 stale transfer。

## 5. 性能

| 配置 | 同步器数 | 存储 | 延迟 |
|------|---------|------|------|
| HANDSHAKE | 2（req/rsp toggle） | 1 req + 1 rsp reg | ~2*SYNC_STAGES+2 周期 |
| ASYNC_FIFO | 4（灰度指针） | FIFO（depth*width） | 相近 |

## 6. 限制

- 不支持 burst / multiple outstanding / 宽度转换 / 地址译码（Out of Scope）。
- CDC_MODE=SYNC_RATIO 为预留，V1.0 不实现（默认 ASYNC_SAFE）。
