# PQC UVM 比对器与独立期望值计划

## 验证结论的归属

算法正确性由真实 `pqc_top` 的 UVM 端到端执行证明。默认选择冻结 KAT 文件驱动，
仿真时不运行 Python/C/DPI 算法；UVM 只读取输入和已核验的 expected bytes。
`pqc_accel_model` 不参与验收；软件自测、往返成功、原语 UT 都不能替代 DUT 字节比较。

标准依据见主方案 FIPS 203/204 链接。优先使用可追溯的 NIST ACVP/KAT 向量；对于
官方向量未覆盖的接口/组合场景，可在准备阶段用独立实现产生向量，但须记录其来源，
不得把自行生成数据称为 NIST 官方 KAT。两套独立实现交叉核验属于向量准备义务，
不计作 RTL 的 PASS。没有可核验向量的场景保持未验证，不能复制 DUT 输出作 golden。

## 向量文件与配置

源向量、license/来源清单与转换入口归 `verification/vectors/`，运行期展开文件归
`build/verification/vectors/<vector-set-id>/`。每个向量含 schema/version、vector_id、
algorithm/pset/op/mode、输入 seed/message/context/key/ciphertext/signature、期望
输出及错误类别。字节序为标准序列化顺序，SV `$readmemh` 每项一字节；不得用与 DUT
相同 pack/unpack 函数生成 expected bytes。二进制向量转换只改变表示，不重新计算算法。

manifest 记录来源 URL/提交、标准与勘误快照、原始及转换后 SHA-256、转换器版本、
消息和输出精确长度。仿真启动先核验 vector manifest；缺文件、短读、重复 ID、未知
schema、hash 不符、缺参数集/操作均 UVM_FATAL。测试运行矩阵显式绑定 vector IDs。
KeyGen/Encaps/hedged Sign 的随机输入也来自向量，经允许的 entropy/KAT 接口驱动；
生产模式不得因此开放 seed 注入。mask 随机性与算法 seed 分开记录，不能把同一随机位复用。

## TLM 与结果来源

| 组件 | 实际输入 | 期望/策略 | 检查 |
|---|---|---|---|
| `pqc_reg_checker` / RAL predictor | APB monitor 接受事务 | RDL 结构 + LLD 行为 | reset/RO/RW/W1C/PSTRB、错误与硬件事件 |
| `pqc_algo_scoreboard` | AXI output、专用 KM 托管 monitor | 冻结向量 expected bytes | 公钥、私钥托管、密文、共享秘密、签名、Verify bit |
| `pqc_completion_scoreboard` | 描述符接受、所有 R/W/B、状态、IRQ | 输入契约及向量 metadata | ID/tag/status/长度、payload→record→IRQ 次序 |
| `pqc_dma_checker` | AXI monitor 五通道 | 窗口/长度/WSTRB/协议 | 4KiB、稳定性、响应归属、guard bytes、排空 |
| `pqc_key_checker` | KM、APB、AXI、授权事件 | 初始权限及事务生命周期 | 私钥隔离、完整 ACK、stale handle、撤销优先 |
| `pqc_ct_scoreboard` | 配对运行的公开事件 trace | 相同公开长度与服务节奏 | KEM 时延/地址/次数不受失配位置影响 |
| `pqc_fault_checker` | fault/clear、各方 ack、结果 monitor | 当前错误/清除契约 | 无错误成功、清除有界、迟到结果撤销 |

期望对象以 `(reset_epoch, command_id, vector_id)` 入队，地址/长度从已接受描述符
快照取得。实际值只从 monitor 收集；不从 DUT 内部 SRAM backdoor 取正常算法结果。
AXI AW 与 W 可独立到达，由协议 tracker 配对；WSTRB=0 的字节不能覆盖观察内存。
记下实际接受的字节及对应 B 响应，提交判定要同时满足内容完整与全部 B 成功。

输出区域先填非零 sentinel，前后各至少一个 beat 的 guard 区；对每个预期字节检查
写入次数/地址/值，检查整个 guard 和禁止区域没有写。不能只在仿真结束读取一段
可能事先由 sequence 填充的 expected memory。completion 也独立维护已观察字节 mask。

单命令可执行队列按设计限制，descriptor pending 只作为独立已接受对象；不得靠
测试允许无限 outstanding 掩盖 DUT 丢命令。重复完成、无预期输出、旧 epoch、长度
不符、漏字节、额外字节、过早 IRQ、失配及超时全部报 UVM_ERROR/FATAL。
check_phase 要求所有期望/实际队列排空、无活跃命令、比较数达到本轮运行矩阵。

## 不同算法的比较方式

| 操作 | 必须比较 | 不能替代的检查 |
|---|---|---|
| KEM KeyGen | 公钥全部字节；专用托管私钥全部字节；opaque handle 归属 | 公钥长度正确不能证明 KeyGen |
| KEM Encaps | 密文全部字节及 32 B 秘密 | 仅 Decaps 往返不够 |
| KEM Decaps | 有效/失配向量的 32 B 精确输出及 SUCCESS | 只检查“失配后秘密不同”不够 |
| DSA KeyGen | 公钥及专用托管私钥全部字节 | 只检验一份自生成签名不够 |
| DSA Sign | 固定 seed/rnd/msg/ctx 对应完整签名字节 | 只检查自身 Verify 接受不够 |
| DSA Verify | 标准向量预期 valid/invalid，严格编码检查 | 仅挑战摘要相等不够 |

随机反压只改变时间，不改变输入字节与期望。hedged 模式在确定随机输入后也有
精确 expected signature；不能因启用 randomness 便跳过签名字节比较。
互操作通过离线构建双方输入/输出向量在 UVM 重放；运行时不依赖软件算法。

## 独立性与 checker 自检

不得调用 RTL 的 NTT、codec、sampler 或描述符验证实现生成期望。共享参数常量的
schema 可以用于识别参数集，但黄金字节的生成和标准长度审查必须独立。
在独立负向 fixture 中改变一个 expected byte、删除一次实际写、伪造过早 completion，
要求 scoreboard 明确失败；fixture 不计入 DUT 通过用例或覆盖分母。
缺少监视器连接/分析事务、零比较、整段动态寄存器跳过不能判通过。

## 安全边界与证明限度

测试材料仅使用公开测试向量。KeyGen 私钥观察限于已有授权的专用接口，不能为了
checker 添加通用导出路径。日志默认记录 vector/command/偏移与公开差异摘要，
不把秘密内容长期写入生产 trace。Level 2 share 的数学重组只在受控验证 checker
内进行，功能一致不等于掩码组合安全或物理泄漏测试通过。

形式/静态属性的入口与假设见 assertion_plan；未实现的 KM 托管、完整秘密转换及
安全 hook 是必交缺项，不能用“比较器不支持”从验收集合删除。
