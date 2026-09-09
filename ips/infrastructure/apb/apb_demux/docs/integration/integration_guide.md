# APB Demux 集成指南

> **IP Name**: `apb_demux`
> **VLNV**: `aixsilicon:ip:apb_demux:1.0.0`
> **版本**: 1.0.0

---

## 1. 集成概览

APB Demux（1→N APB Router）将 1 个上游 APB 访问端口按地址空间路由至 N 个
下游 APB Slave。典型集成位置：SoC Peripheral Bus / X2P Bridge 后级 APB
fanout / APB 子系统分层互联。

## 2. 参数配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `NUM_SLAVES` | 4 | 下游端口数量（1/2/4/8/16，建议 ≤32） |
| `ADDR_WIDTH` | 32 | 地址位宽 |
| `DATA_WIDTH` | 32 | 数据位宽（8/16/32/64/128） |
| `APB_PROFILE` | 1 | 1=APB4, 0=APB3 |
| `ADDR_REMAP_ENABLE` | 0 | 是否静态地址 remap |
| `TIMEOUT_ENABLE` | 0 | 是否使能 timeout |
| `TIMEOUT_CYCLES` | 16 | timeout 周期数 |
| `OUTPUT_REGISTER` | 0 | 是否插入响应寄存器 |
| `BASE_ADDR[N]` | - | 每端口基地址数组 |
| `ADDR_MASK[N]` | - | 每端口地址掩码数组 |

## 3. 实例化示例

```systemverilog
apb_demux_top #(
    .NUM_SLAVES       (4),
    .ADDR_WIDTH       (32),
    .DATA_WIDTH       (32),
    .APB_PROFILE      (1),
    .ADDR_REMAP_ENABLE(0),
    .TIMEOUT_ENABLE   (0),
    .TIMEOUT_CYCLES   (16),
    .OUTPUT_REGISTER  (0),
    .BASE_ADDR('{32'h4000_0000, 32'h4000_1000, 32'h4000_2000, 32'h4000_3000}),
    .ADDR_MASK('{32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000})
) u_demux (
    .pclk   (pclk),
    .presetn(presetn),
    .paddr  (paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
    .pwdata (pwdata), .pstrb(pstrb), .pprot(pprot),
    .prdata (prdata), .pready(pready), .pslverr(pslverr),
    .m_paddr(m_paddr), .m_psel(m_psel), .m_penable(m_penable), .m_pwrite(m_pwrite),
    .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
    .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr)
);
```

## 4. 地址映射规则

- 每个下游端口地址窗口由 `BASE_ADDR[i]` 与 `ADDR_MASK[i]` 定义；
- 命中条件：`(PADDR & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])`；
- 地址窗口**不得重叠**（配置校验脚本检查）；
- 推荐 power-of-two 窗口且基地址对齐。

## 5. FuseSoC 集成

```bash
fusesoc --cores-root=<ip_repo> run --target=elab aixsilicon:ip:apb_demux:1.0.0
```

IP 依赖 `aixsilicon:vip:apb:1.0.0`（验证环境，只读引用）。

## 6. 集成约束

| 约束 | 说明 |
|------|------|
| 单时钟域 | 所有端口共享 `PCLK`，无 CDC |
| 复位 | `PRESETn` 低有效 |
| Decode Miss | 未命中地址返回 `PREADY=1, PSLVERR=1, PRDATA=0` |
| 跨时钟 | 需独立 APB CDC Bridge |

## 7. 时钟/复位/电源

- 时钟：单 `PCLK`；
- 复位：单 `PRESETn`（低有效，async assert / sync deassert）；
- 电源：无独立电源域，`PD_ALWAYS_ON`。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 17-documentation*
