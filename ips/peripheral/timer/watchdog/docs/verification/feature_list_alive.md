# 固定周期存活监督：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.ALIVE
name: 固定周期存活监督
description: 固定周期存活监督的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.SUP.004
- LRS.FUNC.WATCHDOG.SUP.005
- LRS.FUNC.WATCHDOG.SUP.006
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

MIN/MAX事件计数边界与溢出；TIMEOUT当拍服务；BOOT首周期；PRETIMEOUT时部分客户端欠报；持续高速报到。

独立判据：按固定边沿窗口分桶，边界先评价旧桶；合格自动换周期；边界事件返回EPOCH_BOUNDARY且不计入；欠报/过报准确记录。

风险与边界：计数MIN-1/MIN/MAX/MAX+1×边界事件×BOOT/RUN；饱和。

### LRS.FUNC.WATCHDOG.SUP.004

ALIVE 使用固定观测周期 TIMEOUT，不接受由窗口大小决定的提前刷新；WIN_EN 必须为 0。每客户端每次完整服务增加 16-bit 饱和事件数，MIN_ALIVE/MAX_ALIVE 满足 `1 <= MIN <= MAX <= 65535`。超过 MAX 当拍产生 ALIVE_OVERFLOW。

验收：ALIVE 配置禁止窗口；MIN/MAX 取 1 和 65535 边界，超过 MAX 当拍告警。

### LRS.FUNC.WATCHDOG.SUP.005

`A=TIMEOUT` 边沿先对刚结束的周期统计进行评估：全部必需客户端计数满足范围则自动刷新周期、清零统计；否则 ALIVE_MISSING 故障并记录不足客户端。该边沿新到来的服务拒绝为 EPOCH_BOUNDARY，不归前后任一周期、不形成额外故障，调用方需下一拍重试。该规则是 ALIVE 对普通“TIMEOUT 必故障”的唯一例外。

验收：周期边界先评价旧计数；健康时刷新、缺失时故障；边界新服务返回 EPOCH_BOUNDARY 且不计入任一周期。

### LRS.FUNC.WATCHDOG.SUP.006

ALIVE 周期中 PRETIMEOUT 到期只在当时尚有客户端未达 MIN 时产生预警。BOOT 周期使用 BOOT_TIMEOUT 作为首个固定观测周期，成功后转 RUN。固定时间检查能够发现软件过快报到，不能被高频服务无限推迟检查。

验收：ALIVE 仅缺少 MIN 时预警；BOOT 首周期成功转 RUN；持续高频服务不能推迟周期评价。
