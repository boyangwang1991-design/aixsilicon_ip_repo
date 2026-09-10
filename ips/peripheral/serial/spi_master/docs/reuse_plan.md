# 本次资产复用判定

2026-09-10 读取本地 CBB/VIP registry 和各组件实际目录，未修改外部资产。

| 资产 | 实测状态 | 本次处理 |
|---|---|---|
| aixsilicon:cbb:sync_fifo:0.1.0 | implemented；源与 core 存在 | 引用原资产，IMPL=0/OUTPUT_REG=0；TX/RX DATA_W=32，CMD=64；IP 深度参数传给 DEPTH |
| aixsilicon:vip:apb:1.0.0 | developing；gate_status G4/G5 PARTIAL、G6 NOT_RUN | 不能作为独立 G4 已合格证据；本次采用临时自包含 APB 验证驱动，记录升级缺口 |
| SPI VIP | planned | 本次开发可配置 SPI slave BFM 和独立位级检查器 |

FIFO 资产没有同步 clear；IP 包装器注册 clear 请求，再通过原 rst_n 端口清队列。
这是 IP 清除/恢复策略胶水，不复制 FIFO 实现。所有源以只读引用接入，导出副本仅位于 build。
APB/SPI 临时验证组件在对应 VIP 合格后应迁移到 FuseSoC depend。
