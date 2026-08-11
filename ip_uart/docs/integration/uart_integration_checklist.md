# UART 集成检查清单

> 集成 UART IP 到 SoC 时的逐项检查表。

## 总线集成

- [ ] TL-UL 接入：`tl_i`/`tl_o` 连接正确，含完整性字段（a_user）生成
- [ ] APB 接入：PSEL/PENABLE/PWRITE/PADDR/PWDATA/PSTRB/PRDATA/PREADY/PSLVERR 连接正确
- [ ] 地址译码正确（寄存器偏移见寄存器手册）

## 时钟复位

- [ ] `clk_i` 接入系统时钟
- [ ] `rst_ni` 接入复位，低有效、异步复位同步释放
- [ ] 复位释放后寄存器回默认值、FIFO 清空

## 串行 IO

- [ ] `cio_rx_i` 来自引脚/IO mux
- [ ] `cio_tx_o` 输出到引脚/IO mux
- [ ] `cio_tx_en_o` 恒为 1（驱动器使能）

## 中断

- [ ] 9 个中断 `intr_*_o` 连接到中断控制器
- [ ] 中断极性为高电平有效
- [ ] INTR_ENABLE 使能后中断可达

## Alert

- [ ] `alert_tx_o[0]` 连接到 alert 收集器（fatal_fault）
- [ ] `alert_rx_i` 正确 tie-off（未接用 ALERT_RX_DEFAULT）
- [ ] ALERT_TEST 注入可触发 alert_tx_o

## 未使用端口

- [ ] `racl_policies_i` 在 EnableRacl=0 时接 `'0`
- [ ] `racl_error_o`/`lsio_trigger_o` 悬空

## 集成验证

- [ ] 寄存器读写（TL-UL 与 APB 路径）功能正常
- [ ] TX/RX 回环数据正确
- [ ] lint/elab/synth 检查通过
