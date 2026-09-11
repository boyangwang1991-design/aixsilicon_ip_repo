# GPIO 全局周期和优先级

| 条件 | 本沿结果 |
|---|---|
| 主复位有效 | 主业务状态恢复默认；不接受APB事务；保持型状态按POR规则处理 |
| APB Setup | 允许CSR前端锁存请求；业务状态不更新 |
| APB Access合法 | 只提交一次，按32-bit字节使能展开掩码；读取沿前状态 |
| APB Access错误 | PREADY=1、PSLVERR=1、PRDATA=0；不更新任何业务目标，访问诊断可更新 |
| W1C与事件同拍 | new=(old & ~clear) | event；新事件优先 |
| 输入前提撤销/输入重配 | 本沿清有效/处理历史，抑制新边沿；不清历史Pending/快照/FIFO |
| sleep进入与数据写同拍 | sleep捕获沿前物理值，正常数据写入独立状态 |
| FIFO flush与事件同拍 | 清旧队列；本沿所有筛选事件计入丢失 |
| 命令超时与ACK同拍 | ACK完成传输；达到预算时的局部超时/故障仍按已到期事件记录；不创建新请求 |

多位输入跨域载荷使用稳定握手。所有短event跨域消费由系统另外桥接；本IP不保证任意窄PAD脉冲被采到。
输入available、output_owned、sleep/safe、strap等主域控制在边沿前满足同步条件；PAD原始输入允许异步。
输入重配置依写语义细分：FILTER_CFG/DEBOUNCE_CFG写总是重建；PIN_CFG输入处理字段实际变化时重建输入；IRQ_MODE被有效字节覆盖则重建IRQ基线，即使编码相同。
