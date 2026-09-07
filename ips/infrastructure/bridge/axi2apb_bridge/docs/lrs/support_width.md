# 支持宽度 - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档的一部分。

## 支持宽度矩阵

| AXI_DATA_WIDTH | APB_DATA_WIDTH | 模式 | 说明 |
|---|---|---|---|
| 32 | 32 | Same | 1 AXI Beat → 1 APB Transfer |
| 64 | 32 | Wide-to-Narrow | 1 AXI Beat → ≤2 APB Sub-Transfers |
| 128 | 32 | Wide-to-Narrow | 1 AXI Beat → ≤4 APB Sub-Transfers |
| 64 | 64 | Same | 1 AXI Beat → 1 APB Transfer |
| 128 | 64 | Wide-to-Narrow | 1 AXI Beat → ≤2 APB Sub-Transfers |
| 32 | 64 | Narrow-to-Wide | 1 AXI Beat → 1 APB Transfer（lateral lane 选择） |

> V1.0 仅支持合法 Power-of-Two width ratio，Little Endian，无 Endian Conversion。