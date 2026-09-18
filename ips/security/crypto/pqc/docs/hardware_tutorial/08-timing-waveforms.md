# 8. 从波形读懂“正在算”和“已经完成”

[教学手册目录](index.md) · 下一章：[数据表示与位宽](09-data-representations.md)

算法公式不描述时钟。RTL 还要决定每一拍谁提供数据、谁能接收、何时允许覆盖缓冲区。本章表格均表示在对应上升沿采样的值；周期号是教学示例，不是实测波形。

## ready/valid：握手成功才前进

`fire = valid && ready`。发送方有数据时拉高 valid；遇到 ready=0，应保持数据及其 last/tag 等附属字段，直到接收成功或明确取消。接收方不应把“看见 valid”误当成已消费。

| 上升沿 | valid | ready | data | 发生什么 |
|---|---|---|---|---|
| 0 | 1 | 0 | A | A 等待 |
| 1 | 1 | 0 | A | A 仍保持 |
| 2 | 1 | 1 | A | 消费 A 一次 |
| 3 | 1 | 1 | B | 消费 B 一次 |
| 4 | 0 | 1 | 无意义 | 不消费 |

可把这五拍手工输入[bridge_demo.py](../examples/bridge_demo.py)的握手实验，检查输出只有 A、B。AXI 各通道都有自己的握手；AW 握手不能代替 W 握手，W 最后一拍也不能代替 B 响应。

## start/done 不是同一套握手

当前 Encaps 子序列器用 `PSTART → PWAIT`、`CSTART → CWAIT` 启动多项式和 codec 引擎。start 是一次启动脉冲，随后等待 done；它没有通用的 start_ready 握手。父序列器必须在资源可用时启动，而不是依赖 start 一直拉高来“总有一天被接收”。

```text
上升沿              0       1        2 ... N       N+1
父状态             PSTART  PWAIT     PWAIT          后继状态
start                1       0        0               0
done                 0       0        1（完成拍）      0
```

表中的 N 可因存储等待而变化。busy 若由具体模块提供，表示占用状态；不能把 `!busy` 普遍解释成“成功完成”，因为复位、错误或取消也可能让模块停止。

## SRAM 的 ready 表示响应

[secure SRAM 控制器](../../rtl/pqc_secure_sram_ctrl.sv)明确区分请求接受与下一周期响应：端口被仲裁授予且权限有效时接受，随后返回 ready/rdata。主机保持 req 和地址，直到采样 ready；控制器在响应周期抑制同一 held request 的重复接受。

| 阶段 | 主机 | 控制器 | 读数据是否可用 |
|---|---|---|---|
| 等待仲裁 | req=1，地址稳定 | 尚未 grant | 否 |
| 请求被接受 | 继续保持请求 | 锁存端口归属及地址 | 不能据此提前使用 |
| 下一周期响应 | 采样 ready，读 rdata；随后进入下一状态 | ready=1，返回该请求结果 | 是 |
| 无效页/越界/清零期间 | 等待正常完成路径之外的处理 | access_denied，而非正常 ready | 否，走错误处理 |

不要把此处的 req/ready 机械等同于“每拍 valid&&ready 都能接收一个新请求”的流接口。主机与仲裁器各自的协议约定必须一起阅读。硬化成 SRAM macro 后还需重新核查响应延迟约定。

## 背压怎样向上游传播

Encaps 的采样链是 `Keccak → 字节流 → Sampler → SRAM`。当采样器不能继续接收，hash 输出需保持。取够系数后 `sampler_done` 被记入 `sample_seen`，剩余 SHAKE 输出可以被排空。父状态同时等待采样和 hash 完成，不能只看到 sampler_done 就复用 Keccak。

调试时依次看 hash_out_valid、hash_out_ready、sampler_ready、mem_req、mem_ready。若数据没前进，先判断它在等待下游，还是控制器漏发请求。不要仅凭“连续十拍没变化”判死锁；先查设计允许的等待和 timeout。

## 取消与命令完成

复位、clear、撤销或 fatal 会改变当前工作的有效性。检查取消波形要问：是否停止新请求？已经接受的 AXI 事务如何结束？旧响应是否会污染下一条命令？秘密暂存何时清零？这些是不同检查点，不能用一个 clear 脉冲证明全部成立。阅读[引擎取消 UT](../../verification/unit_test/ut_pqc_engine_cancel.sv)与[DMA 取消 UT](../../verification/unit_test/ut_pqc_dma_cancel.sv)。

正常成功链为：计算结束 → 结果搬出并收齐所需写响应 → completion 写入并得到响应 → 允许软件观察完成/中断。多拍输出可能已经部分进入系统内存，因此错误路径不能承诺所有写入回滚。软件以成功 completion 判断结果有效，不能靠输出缓冲区“已经变化”。

检查题：valid=1、ready=0 的三拍算三个字节吗？不算，零字节。SRAM ready 与 AXI WREADY 能套用同一张波形吗？不能，前者在本模块表示已接受请求的响应，后者参与写数据通道的当拍接受。
