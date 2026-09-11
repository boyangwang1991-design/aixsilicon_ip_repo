# 硬件服务与公平仲裁：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.HW_EVENT
name: 硬件服务与公平仲裁
description: 硬件服务与公平仲裁的可执行正确性证明
priority: must
req_ref:
- LRS.INTF.WATCHDOG.IF.003
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.PERF.WATCHDOG.COMMAND.001
- LRS.CONS.WATCHDOG.NFR.003
design_ref:
- LLD.MOD.WATCHDOG.DISPATCH
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

软件/硬件路径各运行；持续硬件valid与邮箱竞争；valid等待期间跨过窗口边界；warm取消时保持硬件事件；未支持配置访问。

独立判据：轮询事务模型每WDT边沿最多消费一个；硬件ready前保持；以执行边沿判窗口；未消费不推进仲裁；可见命令无竞争≤2、有竞争≤3周期。

风险与边界：请求组合×轮询顺序×取消窗口×通道；硬件能力开/关。

### LRS.INTF.WATCHDOG.IF.003

任意异步输入必须由集成层同步或握手，禁止异步脉冲直接接入。硬件事件基础接口仅接受 wdt_clk 同域输入；其他域使用外部无丢失事件桥，不直接接裸脉冲。

验收：接口连接审查确认异步输入有同步或完整握手，跨域硬件事件不使用裸脉冲。

### LRS.FUNC.WATCHDOG.SRV.010

每通道 SERVICE_PATH 为 SOFTWARE 或 HARDWARE，运行中锁定，避免两个来源互相替代。硬件事件采用同一客户端/来源校验和监督状态；在硬件路径下 `data` 提交服务密钥/响应，FLOW 的 START/STEP/END 使用 type/data。

验收：硬件/软件路径不互相替代；硬件客户端、来源和 FLOW 事件遵循相同合法性检查。

### LRS.FUNC.WATCHDOG.SRV.011

APB 命令与硬件事件同拍竞争时采用轮询仲裁，每 wdt_clk 最多执行一个状态修改命令；运行计时不受仲裁反压影响。硬件 valid 在 ready 前必须保持负载稳定。超过窗口的事件即使早先拉高 valid 也不能成功。

验收：连续两来源竞争均获服务且单拍最多执行一项；ready 前负载稳定，过期排队事件仍失败。

### LRS.PERF.WATCHDOG.COMMAND.001

APB ACCESS 响应至多 2 个 pclk 周期；命令在 WDT 域可见后，无竞争至多 2 个、有持续硬件竞争至多 3 个 WDT 周期内执行。两域持续运行时的总服务延迟应包含 CDC 和仲裁。

验收：检查总线与命令执行两个不同上界；停 wdt_clk 时仍满足 APB 响应界而不虚构执行完成。

### LRS.CONS.WATCHDOG.NFR.003

无硬件事件竞争时，合法 mailbox 命令进入 WDT 域可见后最多2个 wdt_clk 周期内执行；有持续硬件事件竞争时最多3个周期。快照与配置提交为一个原子操作，不可循环扫描数十拍后对外声称同拍快照/提交。

验收：命令可见至执行在无竞争时至多 2 拍、有持续事件竞争时至多 3 拍，原子快照/提交无跨拍撕裂。
