# APB Demux 用户手册

> **IP Name**: `apb_demux`
> **VLNV**: `aixsilicon:ip:apb_demux:1.0.0`
> **版本**: 1.0.0

---

## 1. IP 简介

APB Demux（1→N APB Router）是一个参数化 APB 互联 IP，将一个上游 APB 访问
端口按地址空间路由至 N 个下游 APB Slave。核心能力：

- 地址译码 + PSEL one-hot 生成；
- 请求信号 fanout；
- 响应 mux + PSLVERR 透传；
- Decode Miss 错误响应；
- 可选 remap / timeout / response register；
- APB3 / APB4。

## 2. 功能行为

### 2.1 正常访问

- 命中某端口时，该端口 `M_PSEL=1`，其余端口 `M_PSEL=0`；
- 请求信号广播至所有下游；
- 选中端口 `PRDATA/PREADY/PSLVERR` 返回上游。

### 2.2 Wait-state

- 下游 `PREADY=0` 时保持 ACCESS phase；
- wait 期间 selection 与响应源稳定。

### 2.3 Decode Miss

- 未命中地址返回 `PREADY=1, PSLVERR=1, PRDATA=0`，立即结束。

### 2.4 PSLVERR

- 下游 error 透传上游，不屏蔽。

## 3. 配置

通过编译期参数配置（见集成指南 §2）。配置合法性由
`scripts/check_config.py` 校验。

```bash
uv run python scripts/check_config.py \
  --num-slaves 4 --addr-width 32 --data-width 32 \
  --base-addr 0x40000000,0x40001000,0x40002000,0x40003000 \
  --addr-mask 0xfffff000,0xfffff000,0xfffff000,0xfffff000
```

## 4. 验证运行

```bash
# 编译
make -C verification/sim compile
# smoke
make -C verification/sim smoke
# 全回归
make -C verification/sim regression
# 单用例
make -C verification/sim run TEST=tc_sanity SEED=1
```

验证环境复用 `aixsilicon:vip:apb:1.0.0`（只读引用）。

## 5. 不支持的边界

- Multiple upstream masters / arbitration；
- CDC / Async APB（独立 APB CDC Bridge 承担）；
- QoS / Security / Firewall；
- Runtime programmable address map。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 17-documentation*
