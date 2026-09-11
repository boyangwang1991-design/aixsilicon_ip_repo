# Watchdog：端口级集成合同

## LRS.INTF.WATCHDOG.PORTS.001

<!-- LRS_META
id: LRS.INTF.WATCHDOG.PORTS.001
category: INTF
feature: ports
priority: P0
status: active
source_ref:
- watchdog_contract.md:§4
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

IP 应提供下表所列接口及方向/时钟域语义。APB 为 32-bit little-endian、至少 15-bit 地址；每通道输出宽度随 NUM_CHANNELS，可信来源宽度随 SOURCE_WIDTH。

#### Acceptance Criteria

- 连接逐项覆盖全部接口；有效通道/客户端/来源索引不得被截断。
- 未使用输入按对应系统假设固定，不能用普通软件信号替代可信复位/授权来源。

| 接口 | 方向/域 | 语义 |
|---|---|---|
| `pclk`, `preset_n` | 输入/APB | 配置总线时钟与接口复位 |
| `wdt_clk`, `por_n` | 输入/WDT | 独立计时时钟；POR 异步置位、各域同步释放 |
| APB4 `PSEL/PENABLE/PADDR/PWRITE/PWDATA/PSTRB/PPROT` | 输入/APB | 32-bit、little-endian，地址至少 15 bit |
| APB4 `PRDATA/PREADY/PSLVERR` | 输出/APB | 仅在完成传输时采样响应 |
| `access_source_i` | 输入/APB | 可信发起者 ID；与 APB 请求稳定 |
| `cfg_auth_i`, `service_auth_i`, `diag_auth_i` | 输入/APB | 外部授权结果；随该事务锁存 |
| `sleep_req_i`, `debug_req_i`, `debug_auth_i` | 输入/WDT | 电源/调试授权请求，进入 IP 前完成同步 |
| `pause_ack_o[ch]` | 输出/WDT | 通道已进入允许的暂停状态 |
| `warm_reset_evt_i` | 输入/WDT | 可信系统暖复位事件；不是直接清零 WDT 的复位脚 |
| `recovery_done_i[ch]` | 输入/WDT | 可信复位管理器完成恢复的保持型握手请求 |
| `recovery_ack_o[ch]` | 输出/WDT | 接受恢复完成握手；双方回零后才允许下一次握手 |
| `irq_o[ch]` | 输出/APB | 同步到 APB 域的粘滞中断电平 |
| `nmi_req_o[ch]` | 输出/WDT | 粘滞故障请求，接收方负责跨域 |
| `local_reset_req_o[ch]` | 输出/WDT | 通道局部复位保持型请求 |
| `system_reset_req_o` | 输出/WDT | 各通道最终请求及全局致命故障 OR 汇总 |
| `safety_alert_o`, `safe_state_req_o` | 输出/WDT | 安全告警/安全状态保持型请求 |
| `wake_req_o` | 输出/WDT | 预警或故障产生的唤醒请求汇总 |
| `hw_evt_valid/ready/channel/client/type/data/source` | 可选/WDT | 握手事件；valid && ready 仅接收一次 |
| `test_auth_i` | 输入/WDT | 生命周期和测试控制提供的诊断授权 |
