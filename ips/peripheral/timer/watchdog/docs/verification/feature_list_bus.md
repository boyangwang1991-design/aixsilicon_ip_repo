# APB4与寄存器访问：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.BUS
name: APB4与寄存器访问
description: APB4与寄存器访问的可执行正确性证明
priority: must
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.PORTS.001
- LRS.REG.WATCHDOG.ACCESS.001
- LRS.REG.WATCHDOG.IDENTITY.001
design_ref:
- LLD.MOD.WATCHDOG.BUS
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

POR后读ID/能力；逐个实现地址执行访问属性检查；随机读PSTRB；写部分strobes、未对齐、RO、越界与保留位；保持ACCESS直到完成。

独立判据：独立APB monitor计数每笔只接受一次；ACCESS最多2周期；拒绝返回PSLVERR且无状态修改；读WO及保留位为零。

风险与边界：读写×地址类别×strobes×权限×等待周期；错误访问与邮箱忙同拍。

### LRS.INTF.WATCHDOG.BUS.001

仅支持 32-bit 对齐访问；读取 PSTRB 不参与判断。所有有效寄存器写要求 PSTRB=4'b1111；非完整写、越界/未实现地址、写 RO、权限拒绝、保留位非零应在该笔完成时 PSLVERR=1 且不产生状态副作用。读 WO 返回 0。

验收：不对齐、部分写、越界、RO 写、权限拒绝、保留位非零均 PSLVERR 且无请求副作用；WO 读零。

### LRS.INTF.WATCHDOG.BUS.002

APB 访问仅在 PSEL && PENABLE && PREADY 边沿接受一次。常规访问采用固定有限延迟，最多进入 ACCESS 后 2 个 pclk 周期完成；不得等待停住的 wdt_clk 无限拉低 PREADY。

验收：持续 ACCESS 只完成一次，wdt_clk 停止时也在最多 2 个 pclk ACCESS 周期内响应。

### LRS.INTF.WATCHDOG.BUS.003

能定位到有效通道的权限/格式拒绝，通过独立合并型事件握手将 ACCESS_ERROR 送达该通道，不占用命令邮箱、不推进服务协议；连续错误允许合并为一个粘滞事件，不承诺逐次计数。该事件发送状态由 POR 复位，preset_n 不丢弃已经捕获的事件。无有效通道的全局/越界访问只返回 PSLVERR，不伪造通道故障。忙拒绝属于流控，不产生 ACCESS_ERROR。该诊断路径不改变“返回错误的写不能执行其请求操作”的要求。

验收：有效通道错误最终留下 ACCESS_ERROR，preset 不丢已捕获错误；全局越界/忙拒绝不伪造通道事件。

### LRS.INTF.WATCHDOG.PORTS.001

IP 应提供下表所列接口及方向/时钟域语义。APB 为 32-bit little-endian、至少 15-bit 地址；每通道输出宽度随 NUM_CHANNELS，可信来源宽度随 SOURCE_WIDTH。

验收：连接逐项覆盖全部接口；有效通道/客户端/来源索引不得被截断。；未使用输入按对应系统假设固定，不能用普通软件信号替代可信复位/授权来源。；| 接口 | 方向/域 | 语义 |；|---|---|---|；| `pclk`, `preset_n` | 输入/APB | 配置总线时钟与接口复位 |；| `wdt_clk`, `por_n` | 输入/WDT | 独立计时时钟；POR 异步置位、各域同步释放 |；| APB4 `PSEL/PENABLE/PADDR/PWRITE/PWDATA/PSTRB/PPROT` | 输入/APB | 32-bit、little-endian，地址至少 15 bit |；| APB4 `PRDATA/PREADY/PSLVERR` | 输出/APB | 仅在完成传输时采样响应 |；| `access_source_i` | 输入/APB | 可信发起者 ID；与 APB 请求稳定 |；| `cfg_auth_i`, `service_auth_i`, `diag_auth_i` | 输入/APB | 外部授权结果；随该事务锁存 |；| `sleep_req_i`, `debug_req_i`, `debug_auth_i` | 输入/WDT | 电源/调试授权请求，进入 IP 前完成同步 |；| `pause_ack_o[ch]` | 输出/WDT | 通道已进入允许的暂停状态 |；| `warm_reset_evt_i` | 输入/WDT | 可信系统暖复位事件；不是直接清零 WDT 的复位脚 |；| `recovery_done_i[ch]` | 输入/WDT | 可信复位管理器完成恢复的保持型握手请求 |；| `recovery_ack_o[ch]` | 输出/WDT | 接受恢复完成握手；双方回零后才允许下一次握手 |；| `irq_o[ch]` | 输出/APB | 同步到 APB 域的粘滞中断电平 |；| `nmi_req_o[ch]` | 输出/WDT | 粘滞故障请求，接收方负责跨域 |；| `local_reset_req_o[ch]` | 输出/WDT | 通道局部复位保持型请求 |；| `system_reset_req_o` | 输出/WDT | 各通道最终请求及全局致命故障 OR 汇总 |；| `safety_alert_o`, `safe_state_req_o` | 输出/WDT | 安全告警/安全状态保持型请求 |；| `wake_req_o` | 输出/WDT | 预警或故障产生的唤醒请求汇总 |；| `hw_evt_valid/ready/channel/client/type/data/source` | 可选/WDT | 握手事件；valid && ready 仅接收一次 |；| `test_auth_i` | 输入/WDT | 生命周期和测试控制提供的诊断授权 |

### LRS.REG.WATCHDOG.ACCESS.001

IP 应提供本地即时只读信息、staging 配置、保持快照和命令访问四类软件可见寄存器能力。未定义位读零、保留位非零写拒绝；裁剪功能保留地址空间，不挪动其他寄存器。

验收：逐访问类别检查读写/复位/拒绝语义。；不同配置对同一已定义地址保持一致，未实现位置返回规定错误。

### LRS.REG.WATCHDOG.IDENTITY.001

软件应可查询 IP 标识、版本、实际能力、在途命令状态、已发/已完成序号、结果及通道中断/复位/故障汇总。读事务完成状态不得清除完成记录。

验收：读回符合实例能力；命令接收清 EXEC_DONE，完成置位，读不清。；APB 同步拒绝不覆盖上一条 DONE 记录。
