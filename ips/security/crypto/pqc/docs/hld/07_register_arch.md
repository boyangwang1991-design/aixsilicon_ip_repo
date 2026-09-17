# PQC 加速器高层设计：寄存器架构

> 本章是 HLD 的 **Register Architecture 冻结点**：冻结寄存器分组、访问路径、
> configuration activation、status ownership、error/interrupt model、lock/protection
> 与 key-slot 管理窗口。**不含 bit 级字段**——字段结构由 LLD（行为）与 SystemRDL
> （结构）完成。

## 寄存器分组

| Group | 职责 | 典型属性 | Owner Module |
|---|---|---|---|
| ID_VERSION | IP/ABI/微码版本 | RO | `pqc_cmd_frontend` |
| CAPABILITY | 算法/参数集/lane/SCA/SRAM/DMA/key-slot 能力 | RO | `pqc_cmd_frontend` |
| CTRL | enable/abort/zeroize/self-test | RW（受保护） | `pqc_cmd_frontend` |
| STATUS | idle/busy/done/error/locked | RO | `pqc_cmd_frontend` |
| COMMAND | opcode/parameter set/flags/tag | RW（BUSY 锁定） | `pqc_cmd_frontend` |
| DESC | src/dst 地址、长度、权限属性 | RW（BUSY 锁定） | `pqc_cmd_frontend` |
| KEY_HANDLE | slot 与预期类型 | RW（BUSY 锁定） | `pqc_key_slots` |
| CONTEXT_LEN | 0–255 | RW（BUSY 锁定） | `pqc_cmd_frontend` |
| RESULT | verify result / completion tag | RO | `pqc_cmd_frontend` |
| ERROR_CODE | 非敏感错误类别 | RO | `pqc_cmd_frontend` |
| INTR_* | state/enable/test | RW/W1C | `pqc_cmd_frontend` |
| ALERT_* | recoverable/fatal | RO/W1C | `pqc_fault_ctrl` |
| PERF_* | 受策略限制的性能计数器 | RW（清零）/RO | `pqc_cmd_frontend` |
| KEY_SLOT_CTRL | secure-only slot 管理窗口 | RW（特权） | `pqc_key_slots` |

字段、offset、reset value 由 SystemRDL 管理。

## 访问路径

- 控制与状态访问：APB4 slave，32 bit，自然对齐，仅核心域。
- KEY_SLOT_CTRL 与 CTRL 的 zeroize/abort：额外要求特权/安全主体属性。
- 私钥内容不可经普通寄存器路径读出；仅已授权 sequencer 可通过 WORKKEY 材料接口消费，元数据没有材料读回路径。

## Configuration Activation

| 类别 | Activation Model |
|---|---|
| COMMAND/DESC/KEY_HANDLE/CONTEXT_LEN | transaction-boundary：门铃抓取后进入 shadow，BUSY 期间软件写入不影响当前命令 |
| CTRL.enable | write-through，需 Idle |
| CTRL.abort/zeroize | 核心域请求；优先关闭权限并进入安全收尾 |
| INTR enable/state | write-through + W1C |
| PERF 计数器 | idle-only 清零 |

冻结决策：所有命令相关配置采用 **shadow + transactional commit**，而非 write-through。

## Status Ownership

| Status | Owner | Source of Truth |
|---|---|---|
| idle/busy | `pqc_cmd_frontend` | 顶层状态机 |
| done | `pqc_cmd_frontend` | completion write 顺序 |
| error | `pqc_cmd_frontend` | completion status |
| locked | `pqc_fault_ctrl` | fault/lifecycle |
| alert | `pqc_fault_ctrl` | fault 汇聚 |

## Error Reporting Model

- ERROR_CODE 只承载公开诊断分类：配置错误、DMA 错误、熵错误、自检错误、内部故障、
  `INTERNAL_RETRY_EXHAUSTED`。
- **禁止**：KEM 密文有效性字段；ML-DSA 每次拒绝原因字段；任何由秘密值导出的分类。
- completion status 中 `KEM_DECAPS` 对长度正确、无系统故障的密文为 SUCCESS；`DSA_VERIFY` 允许
  公开 `VERIFY_INVALID`。

## Interrupt Model

五类中断：DONE、ERROR、RNG_FAULT、TAMPER、SELF_TEST_FAIL。
每类提供 state（W1C）、enable、test（受测试生命周期约束）三个一致视图。
中断输出为电平，清除通过 W1C 完成。

## Lock / Protection Architecture

| 保护对象 | 保护策略 |
|---|---|
| COMMAND/DESC/KEY_HANDLE/CONTEXT_LEN | BUSY 期间锁定（软件写入忽略或报错） |
| CTRL.zeroize/abort | 特权限定，且可被 fault 抢占 |
| KEY_SLOT_CTRL | secure-only；debug 解锁不开放 |
| ERROR_CODE/ALERT | 只读，W1C 仅限可清除位 |
| PERF 秘密相关字段 | 生产策略下不可读 |

## 软件交互模型

1. 上电：enable → self-test（KAT）→ Idle；失败进入 Locked。
2. 提交：填写 descriptor 与输出 buffer → 写 DESC_ADDR → doorbell。
3. 完成：读 completion record → W1C 清中断 → 可提交下一命令（单 pending）。
4. 中止：写 abort → 硬件在安全边界点停止并清零 → 回到 Idle。
5. 密钥：经 KEY_SLOT_CTRL 分配/销毁，或经 secure mailbox/key manager sideload 导入。

## Key-slot 架构

- handle 编码 `{generation[15:0], owner[7:0], slot[7:0]}`。
- destroy/reallocate 递增 generation；旧 handle 必须失败。
- 操作开始后硬件锁住 slot；fatal/zeroize 可强制抢占。
- 私钥默认不可读；exportable 元数据控制导出资格，且导出必须走外部 key wrap。
- 长期私钥不进普通工作 SRAM。

## 新密钥边界对控制面的约束

KEY_SLOT_CTRL 只管理授权元数据，不承担私钥 byte 导入。CSR handle 是引用而非来源认证；
导入头的可信域与外部 Key Manager 身份来自专用接口。CAPABILITY 只报告真正可执行的
功能；保留参数值不能代替材料、算法或安全功能已经接通的证明。
