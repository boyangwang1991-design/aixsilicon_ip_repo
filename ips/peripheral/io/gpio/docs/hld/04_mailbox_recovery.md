# GPIO AON 恢复策略

## 持久传输槽

采用一槽 request/ack 协议，主域请求标识、冻结命令载荷和未完成状态仅 POR 复位；AON 已执行请求标识和应答只 AON 冷复位。主域 staging、读缓存及软件可见状态允许暖复位。
主暖复位不清除传输身份或稳定载荷。进入恢复后停止接受新命令，继续完成旧请求的应答回收；旧结果不作为新软件命令的 DONE。双方回到空闲一致性后才 READY。
此选择避免在 AON 已执行而主域尚未读到 ACK 时丢失身份，也避免将旧 payload 当新命令重发。

## 原子更新和迟到 ACK

COMMIT 在 AON 检查整个 Bank 的 mode/capability/锁一致性，再更新活动配置；校验失败只返回 ERROR 和完整状态，不部分生效。
TIMEOUT 只结束软件等待预算，不释放传输槽、不撤回命令；BUSY 维持至真实应答。下一合法命令接受才清局部 DONE/TIMEOUT/ERROR，sticky诊断独立清。
主域不能无限等待 AON 而阻塞 APB。AON 停钟可使 READY恢复或命令完成无限推迟，软件应使用独立故障恢复流程。

## 需要 LLD 证明的义务

每个请求最多执行一次；载荷冻结早于跨域接受并保持至返回；暖复位发生在每个握手边界都能排空；冷复位由共同系统契约保证两侧一致。CDC 多位数据须具备稳定窗口约束，RDC恢复不能只靠软件复位。
<!-- HLD_DECISION_META
id: ADR.GPIO.MAILBOX.001
level: HLD
status: proposed
options:
- 主暖复位清传输状态
- 传输身份与载荷POR保持
decision: 采用POR保持传输槽，主暖复位仅恢复软件侧；等待排空再READY
req_ref:
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_DECISION_META -->
