# 软件密钥与令牌服务：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.SERVICE
name: 软件密钥与令牌服务
description: 软件密钥与令牌服务的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.SEC.WATCHDOG.TOKEN.001
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

遍历SINGLE/DUAL/TOKEN/QA；密钥首笔、重复首笔、错第二笔、无首笔；SEQ_LIMIT前/当拍/后；旧token重放、错source、读取challenge。

独立判据：独立常量/LFSR/QA算术与序列时间表判定；只有完整合法完成贡献；拒绝不刷新、不换token；首笔及无关读写不改变计时。

风险与边界：算法×结果×序列边界×窗口；令牌每客户端独立。

### LRS.FUNC.WATCHDOG.SRV.001

所有软件服务通过 SERVICE 命令，运行计数只读。一次服务由 `client_id/op/source/data` 和硬件生成的完成序号关联。来源来自可信侧带，不使用软件可写寄存器替代。

验收：运行计数不可软件写入；服务完成记录对应 client/op/可信 source 和硬件序号。

### LRS.FUNC.WATCHDOG.SRV.002

只有完整合法服务才可刷新计数；读取状态、第一笔密钥、IRQ 清除、配置写入不得刷新。RUN/BOOT 之外服务返回 BAD_STATE，PAUSED 返回 PAUSED；不因此产生服务协议故障。

验收：逐项施加非完整服务操作，周期起点均不变化；非运行态返回规定状态码且不虚构协议故障。

### LRS.FUNC.WATCHDOG.SRV.003

服务来源不匹配、权限拒绝、错误写宽度属于访问错误，不推进服务序列也不自动停止计时。密钥错误、顺序错误、有效序列超时属于监督故障类别，按 FAULT_POLICY 处理。

验收：来源/权限/写宽拒绝不推进序列；错密钥、乱序和序列超时按配置的故障策略响应。

### LRS.FUNC.WATCHDOG.SRV.004

服务序列时间以未分频 wdt_clk 周期计，定义第一笔在边沿 e0 完成，第二笔允许在 `1 <= e-e0 <= SEQ_LIMIT`；在 `e-e0=SEQ_LIMIT` 无合法完成即置序列超时。暂停期间冻结序列年龄。SEQ_LIMIT 必须大于 0，主监督期限优先。

验收：第二笔在 e0+1 和 e0+SEQ_LIMIT 接受；边界无合法完成即超时，暂停冻结年龄，主到期优先。

### LRS.FUNC.WATCHDOG.SRV.005

SINGLE_KEY/DUAL_KEY 为必选。DUAL_KEY 第二笔没有第一笔、第一笔重复、第二笔值错误均置 BAD_KEY_SEQUENCE，并清空该客户端未完成序列。无关合法寄存器读写不打断序列，主计时继续。

验收：正确单/双密钥完成；第二笔先到、重复第一笔、错误第二笔均触发 BAD_KEY_SEQUENCE。

### LRS.FUNC.WATCHDOG.SRV.006

TOKEN/QA 为可裁剪功能；每客户端状态独立。启动时 `token = 0x1D872B41 XOR (channel_id<<8) XOR client_id`，channel/client 从 0 编号，运算按 32 bit；若结果为 0 则取 1。

验收：逐通道/客户端核对 32-bit 初始种子和零值替换；裁剪配置拒绝 TOKEN/QA。

### LRS.FUNC.WATCHDOG.SRV.007

定义 `next(x) = (x >> 1) XOR ((x & 1) ? 0x80200003 : 0)`。TOKEN 模式期望值为 token；QA 模式 challenge=token，响应为 `ROL32(token,7) XOR 0x6D2B79F5 XOR (channel_id<<8) XOR client_id`。每个被接受的完整客户端服务后更新 token=next(token)，错误服务不更新；暂停/读取不更新。该算法仅为确定性的执行/重放错误检测，不提供密码学认证。

验收：使用已知种子独立计算 next/ROL32 响应；成功更新一次，错误、暂停、读取均不更新。

### LRS.FUNC.WATCHDOG.SRV.008

TOKEN/QA 的当前值通过 SNAPSHOT 的客户端表读取，读取不产生新挑战。跨轮旧值必须失败；系统重启后种子会重复，不宣称跨启动防重放。服务完成反馈提供该客户端新 token 的可读快照途径。

验收：同一轮多次快照读取挑战不变化；跨轮旧响应拒绝，复位后种子重复不解释为安全认证。

### LRS.FUNC.WATCHDOG.SRV.009

软件必须等待上一条服务结果后才发下一条。驱动不得因等待超时盲目重发；应读取最终执行序号和结果。窗口服务按 WDT 域完整服务完成边沿判断。

验收：驱动等待超时后查询最终序号而不重复发送；服务判定以 WDT 域完成边沿为准。

### LRS.SEC.WATCHDOG.TOKEN.001

TOKEN/QA 仅用于确定性执行与重放错误检测，不提供密码学认证或跨启动防重放保证。

验收：文档明确固定重启种子和威胁边界；跨轮旧 token 拒绝。
