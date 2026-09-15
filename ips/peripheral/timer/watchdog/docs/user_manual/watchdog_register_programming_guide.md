# Watchdog 寄存器编程指南

适用候选版本1.0.0。结构入口为[SystemRDL](../../regs/watchdog.rdl)，字段行为见
[LLD](../lld/index.md)，C常量见 sw/include/watchdog_regs.h；不另维护寄存器全集。
下列地址为IP窗口内字节偏移，数据32位，访问4字节对齐。

| 偏移 | 用途 |
|---|---|
| 0x000 / 0x004 | IP_ID / VERSION，IP_ID=0x57445431 |
| 0x008 / 0x00C | CAPABILITY0 / CAPABILITY1 |
| 0x010 / 0x014 / 0x018 / 0x01C | CMD_STATUS / ISSUED_SEQ / DONE_SEQ / DONE_INFO |
| 0x020 / 0x024 / 0x028 | IRQ / 故障 / 请求汇总 |
| 0x1000 + channel×0x400 | 通道块，仅访问已实现通道 |
| 通道+0x000..0x03C | 十六个 staging 字 |
| 通道+0x040 / 0x044 / 0x048 | UNLOCK / COMMAND / LOCK_SET |
| 通道+0x04C / 0x050 | SERVICE_SELECT / SERVICE |
| 通道+0x054 / 0x058 / 0x05C | IRQ_ENABLE / IRQ_CLEAR / IRQ_TEST |
| 通道+0x060 / 0x064 | 诊断清除 / 受控注入 |
| 通道+0x068 / 0x06C | SNAP_META / SNAP_SEQ |
| 通道+0x140 / 0x144..0x15C | 客户端选择 / 客户端 staging |
| 通道+0x180..0x1B8 | 所选客户端保持快照 |

CAPABILITY0 为通道数减1[4:0]、客户端数减1[10:5]、计数器位宽[17:11]、预分频位宽[22:18]。
CAPABILITY1 [5:0]依次为 token/QA、监督、硬件服务、安全、运行期更新、诊断注入，
[9:8]为同步级数减2。保留位、写掩码按RDL；最大窗口的RAL不表示所有通道已实例化。

## 命令和返回

COMMAND 编码 COMMIT=1、START=2、STOP=3、CANCEL=4、SNAPSHOT=5。
UNLOCK 顺序0xC0DE1234、0x3F21EDCB，每一步等待完成。
双密钥 SERVICE 顺序0xA5C35A3C、0x5A3CA5C3，不能与解锁密钥混用。
busy清零、done有效且DONE_SEQ等于期望序号才接受结果；32位序号按无符号回卷处理。
不能仅凭done位接收历史完成。PENDING_APPLY不表示立即生效，须遵守运行期切换边界。

## C驱动示例

前置：已持有全局互斥，dev回调绑定MMIO/barrier并上报总线错误，授权与配置有效。
budget是轮询次数；该片段仅演示一次服务的超时处理，不能作为无条件喂狗循环。

```c
uint8_t result;
int rc = watchdog_service(&dev, channel, 0, 0, WDT_KEY1, budget, &result);
if (rc == WDT_DRIVER_TIMEOUT) {
    /* 保留 pending_seq，稍后继续同一操作，不能重发KEY1。 */
    rc = watchdog_poll(&dev, budget, &result);
}
/* 仅 rc==WDT_DRIVER_OK 且 result==WDT_RESULT_OK 后，才在期限内发KEY2。
 * TIMEOUT/IO/硬件错误由上层处理，不能继续假定服务成功。 */
```

初始化先直接写 staging 和客户端字段，再 watchdog_unlock，最后
watchdog_submit(..., WDT_COMMAND, WDT_OP_COMMIT, ...)。配置来自真实时间预算，
不能凭示例编造寄存器常数。完成SNAPSHOT并核对SNAP_META/SNAP_SEQ后才读保持镜像；
客户端间接窗口也必须受全局锁保护。
bash scripts/test_driver.sh验证mock总线错误、序号和超时，不替代实际CPU/总线集成测试。
