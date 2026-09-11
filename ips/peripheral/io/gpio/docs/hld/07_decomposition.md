# GPIO 交给 LLD 的工作包

| 工作包 | 责任对象 | 必须冻结的行为与检查 |
|---|---|---|
| APB/CSR | APB、REG、SECURITY | 全地址合法性矩阵、PSTRB与命令、锁/权限/能力检查顺序、无部分提交、生成CSR零等待兼容 |
| 输入/IRQ | INPUT、IRQ | 各阶段精确采样周期、首次valid、重配置写语义、Bank节拍、边沿/电平与清除竞争 |
| 输出/低功耗 | OUTPUT | 正常译码、sleep捕获沿前值、safe优先与解除、reset/capability/ownership最终门控 |
| AON | MAILBOX、AON | 请求载荷保持、原子COMMIT、晚ACK、暖复位排空、AON锁与错误回报的精确时序 |
| 捕获 | CAPTURE | 同拍合并、SEQ回绕、Strap全部有效条件、过早与重复请求 |
| 队列 | FIFO | 最小pin选择、128-bit编码、满空POP/PUSH、FLUSH、饱和丢失、时间戳高位锁存 |
| 安全 | DIAG、SECURITY | 消隐重启、失配阈值、parity部分写与注入、暖复位期间校验屏蔽与故障保持 |

具体RTL文件映射、状态编码、逐字段行为以及SystemRDL生成属于LLD/02阶段。
参数配置不得增加未在LRS/PC声明的新旋钮；可选功能裁剪必须保留正确的软件地址与能力读回。
