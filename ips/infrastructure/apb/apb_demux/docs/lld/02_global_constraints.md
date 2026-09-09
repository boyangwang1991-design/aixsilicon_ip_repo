# APB Demux — LLD 全局约束

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟/复位

- 单一 `PCLK` 时钟域；
- 单一 `PRESETn` 低有效异步复位（可综合为同步复位释放）；
- 无 CDC / RDC 路径。

## 2. 参数约束

- `NUM_SLAVES >= 1`；
- `ADDR_WIDTH >= 1`；
- `DATA_WIDTH` 为 8/16/32/64/128（推荐）；
- `BASE_ADDR[i]`/`ADDR_MASK[i]` 数组长度 == `NUM_SLAVES`；
- 地址窗口不重叠；
- `TIMEOUT_ENABLE=1` 时 `TIMEOUT_CYCLES > 0`；
- 地址对齐：power-of-two size，base 对齐。

## 3. 协议约束

- 不得改变 APB SETUP/ACCESS 两相语义；
- `M_PENABLE` 不得在 `M_PSEL=0` 时有效；
- Decode Miss 立即响应，禁止无限等待。

## 4. 复位约束

- 复位期间所有 `M_PSEL[i]=0`；
- Timeout counter 复位清零；
- Response register 复位无效。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
