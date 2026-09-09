# APB CDC Bridge — LLD 全局约束

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 参数契约

| 参数 | 默认 | 合法范围 | 说明 |
|------|------|----------|------|
| `ADDR_WIDTH` | 32 | 16~64 | 地址位宽 |
| `DATA_WIDTH` | 32 | 8/16/32/64/128 | 数据位宽（%8==0） |
| `USER_WIDTH` | 0 | ≥0 | APB5 预留，V1.0 恒 0 |
| `CDC_IMPL` | HANDSHAKE | HANDSHAKE/ASYNC_FIFO | CDC 实现选择 |
| `SYNC_STAGES` | 2 | ≥2 | 同步器级数 |
| `REQ_DEPTH` | 1 | 1/2 | Request FIFO 深度（仅 FIFO） |
| `RSP_DEPTH` | 1 | 1/2 | Response FIFO 深度（仅 FIFO） |
| `RESET_MODE` | ASYNC | ASYNC | async assert / sync deassert |
| `APB_PROFILE` | APB4 | APB3/APB4 | APB 协议 profile |
| `CDC_MODE` | ASYNC_SAFE | ASYNC_SAFE（SYNC_RATIO 预留） | 时钟关系模式 |

## 2. 非法配置断言（编译期）

```systemverilog
initial begin
  assert (ADDR_WIDTH > 0);
  assert (DATA_WIDTH > 0);
  assert (DATA_WIDTH % 8 == 0);
  assert (SYNC_STAGES >= 2);
  assert (CDC_IMPL inside {HANDSHAKE, ASYNC_FIFO});
  assert (REQ_DEPTH inside {1, 2});
  assert (RSP_DEPTH inside {1, 2});
  assert (APB_PROFILE inside {APB3, APB4});
end
```

> 注：`assert` 属验证构造，RTL 中应以 `generate` + `$error` 或 FuseSoC 参数校验实现；
> 此处在 LLD 记录契约，RTL 实现见 07。

## 3. 时钟/复位约束

- `s_pclk`/`m_pclk` 完全异步（ASYNC_SAFE）。
- `s_presetn`/`m_presetn` 独立，async assert / sync deassert。
- 禁止跨域组合路径；toggle 仅经 2FF 同步。

## 4. PPA 预算（微架构级）

| 指标 | HANDSHAKE | ASYNC_FIFO |
|------|-----------|------------|
| 目标频率 | ≥ 800 MHz（源）/ 800 MHz（目的） | 同左 |
| 存储位 | `2*(ADDR+DATA+DATA/8+4)` 量级 | 增加 FIFO 存储 |
| 同步器数 | 2（req/rsp toggle） | 4（指针/灰度） |
| 动态功耗 | 最低（idle 无翻转） | 略高（FIFO 指针） |
| 延迟 | 2~4 sync 周期 | 相近 |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
