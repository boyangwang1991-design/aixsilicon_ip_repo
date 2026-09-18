# PQC 加速器统一结论报告

Decaps 串行算法链与隐式拒绝已修复，当前自检查 UVM 子集 14/14 通过；整个 PQC 的完整 KEM/DSA、Level 2、G2 技术冻结及 G3–G5 仍未闭环，当前不可发布。

## 本轮实现与真实验证（2026-09-18）

继续使用 ip-development-suite，并保留接手时已有改动；没有提交或推送。
按现有委托完成候选实现与验证，不把机器结构 PASS 视作技术冻结。

- 重写 `pqc_kem_decaps.sv` 的串行调度：私钥分段读取、逐多项式解码/解压、NTT 与累积、
  消息恢复、H(ek) 校验、G、完整重加密、J(z||received_ct)、全长比较和掩码选择。
  TOP 接通 hash ready 和 Decaps completion DMA；正常及拒绝均返回32B共享秘密。
- 每 seed 45 条 Decaps 命令：ML-KEM-512/768/1024各三组独立正常向量、每组首/中/末
  字节篡改共27组、九组正常向量背压重复。oracle 是离线 kyber-py 1.2.0；拒绝秘密另以
  SHAKE256(z||corrupted_ct)交叉检查后冻结。仿真无 Python/C/DPI 密码算法。
- 检查每个输出/完成字节恰好写一次、完整 completion、外部访问范围、guard、
  输出 B 响应→completion→B 响应→IRQ 顺序。同一向量正常/三种拒绝的 completion
  周期在相同外部服务条件下相等；仅是有限场景检查，不宣称完整恒时/侧信道证明。
- 修复 TOP 的 ABI minor 硬件赋值及参考模型错误期望；恢复高地址负向检查。
  安全特权访问编码由错误的100改为001，检查全部8种PPROT组合、拒绝读零、写无副作用、
  只读元数据。中断测试在 INTR_TEST 没置位时现在会报错。
- 根 Core 与 RTL filelist 补入 Decaps，Makefile 调用唯一 runner，默认明确 seed；
  不再调用不存在的模板用例或声称提供未实现的 coverage。
- LLD/验证 Markdown 通过 owning extractor 投影；22个模块的 LLD→RTL seed 已补齐。
  trace builder 只接受模块粒度，首次提交 FSM 粒度被拒的日志也保留，最终按模块重建。

最终从 `verification/sim` 执行 `make regress`：7个测试×seeds 1、17，**14/14通过**，
VCS/UVM 1.2，退出0，UVM_ERROR/UVM_FATAL均0，输入集合前后一致。
其中 Decaps 共90命令、Encaps共12组KAT；另外五个测试为 command smoke、严格寄存器、
地址错误/idle编程、密钥窗口权限和中断W1C。这是已实现自检查子集，不是 G4 全量通过。
全部模块UT由根 FuseSoC Core 重跑：**40项，整体 pass**。
runner故障注入pytest **28/28通过**，不计入DUT通过数。

最终 Decaps SpyGlass lint：0 Error/Fatal、41 Warning、5 Info，退出0，无waiver。
警告包括33条task更新外层状态、4条未使用entropy输入、2条未使用寄存器、
异步reset用于同步门控和单进程FSM各1条；局部lint不等于全IP综合/CDC签核。
前一轮严格APB回归4/5通过，失败是参考模型仍期望旧ABI值；修复后再编译并通过上述最终回归。
首次六KAT和中间10/10结果只对应各自输入；本报告当前结果绑定最终build，不给旧日志补签。

## 门禁与明确限制

| Gate | 当前机器输出 | 技术解释 |
|---|---|---|
| G0 | pass | 需求来源检查 |
| G1 | pass | 架构来源检查 |
| G2 | pass | LLD仍open/false；结构PASS不等于完整技术冻结 |
| G3 | fail | 以当前质量检查及缺口为准，不以局部lint或UT代替全量签核 |
| G4 | blocked | 全计划、参数执行、覆盖、closure RTM及formal/RAL仍未闭合 |
| G5 | blocked | 前置及集成/用户交付文档仍缺，当前不可发布 |

完整 KEM KeyGen 与 DSA、Level 2 秘密数据链、页标签/权限、epoch/撤销、完整清除和失败退休
仍须实现与验证。SCA_LEVEL=1 的算术KAT通过不构成任何安全等级认证。
APB VIP从资产仓只读引用；AXI DMA当前是有背压的内存响应器，尚未接入完整AXI4 VIP。
FuseSoC模块UT可运行不等于UVM依赖闭包已完成。现存reset/self-test、fault测试仍有弱检查，
未纳入本轮自检查通过计数；后续必须恢复严格检查，不得用记录现象的用例签核功能。

## 统一问题表

| ID | 状态 | 问题/处置 | 下一步 |
|---|---|---|---|
| ISSUE-001 | open | RTL 检查与专项证据未闭环 | 09：上游通过后补 FuseSoC lint/elab/综合适用检查及 CDC/formal 证据 |
| ISSUE-002 | open | 根 Core 和 RTL filelist 已补入 Decaps 及现存用例，Makefile 已统一调用 runner；UVM VIP 的 FuseSoC depend 接入仍缺 | 08：使用只读资产元数据适配器闭合依赖；不能把本地 VCS 编译等同于完整 FuseSoC UVM target |
| ISSUE-003 | open | 四类追踪矩阵未闭环 | 16：随上游重建四类 trace，逐需求绑定真实验证 |
| ISSUE-004 | open | UVM、覆盖率与端到端 KAT 缺失 | 10–15：构建独立 RM、六参数集 KAT、接口负向回归与覆盖闭环 |
| ISSUE-005 | closed | 本轮不以物理 PPA 表征作为验收条件 | 遵照用户指令完成代码结构分析；不宣称物理指标达标 |
| ISSUE-006 | open | 机器 G2 的结构与 CSR 一致性检查通过；完整 LLD 技术项及 VP0 仍未闭环 | 补完整算法/掩码/逐拍调度与验证计划；结构检查不替代技术评审 |
| ISSUE-007 | open | 完整 KEM/DSA 算法、Key RAM 消费及托管未实现 | 03/05/07：冻结架构与时序后补全安全数据通路，六参数集 RTL KAT 验收 |
| SUITE-001 | closed | HLD 必需需求覆盖已补齐，当前投影与来源一致 | 84/84 全需求归属与引用检查通过；不等于 G1 或 RTL 通过 |
| SUITE-002 | open | 22 个 LLD 模块已建立静态 RTL 链接；完整算法、转换、页授权与掩码集成仍缺 | 继续完成 KeyGen/DSA/Level2；静态链接不等于实现完整性 |
| SUITE-003 | closed | 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过 | 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL |
| SUITE-004 | open | 当前根 Core 全量模块 UT 已重跑，结果 pass，共 40 项；完整模块映射与新增算法专项仍需补齐 | 以本轮 module_ut_summary 为准，不能替代完整 G3 或当前端到端算法测试 |
| SUITE-005 | open | 参数 initial/$fatal 被工作区审计识别为 RTL 中仅仿真构造 | 07/09/19：把参数校验放入合法 elaboration/验证入口并保持非法配置拒绝 |
| SUITE-006 | open | 集成指南与用户手册缺失 | 17：补 docs/integration 和 docs/user_manual，说明密钥、复位、错误与能力限制 |
| A01 | closed | AXI 读事务仲裁锁定、描述符完成/错误判定、地址快照与门铃防重复已修 | 保留背压、取消排空、异常 RLAST/RRESP、128 B 顺序及 held-doorbell 回归 |
| A02 | closed | CRC final XOR 与 ABI 已修复 | 保留独立 CRC/ABI oracle |
| A03 | open | 真实 Encaps/Decaps 的输入、算法、输出、completion 与 IRQ 链已由 KAT 验证；其他命令及失败退休仍缺 | 补 KeyGen/DSA 和故障、取消、超时的端到端检查 |
| A04 | closed | Keccak 多块、padding、空输入、squeeze 已修复 | 保留四种 function、两种轮数及边界背压测试 |
| A05 | closed | SRAM 请求重复受理及共享响应归属已修复 | 保留实际 SRAM 组合测试 |
| A06 | open | codec 数学及固定 256 系数 packing 已修，完整格式/offset 尚缺 | 补任意 bit offset、长度上限、完整密钥/签名编码 |
| A07 | closed | DSA 旧摘要误接受已修复 | 最终判决完整性测试保留；不等于完整 Verify 算法通过 |
| A08 | closed | DMA 溢出、属性、尾拍和取消排空已修复 | 保留三总线宽度与实际 SRAM、取消背压回归 |
| A09 | closed | IRQ 独立掩码已修复 | 保留 pending/enable 交叉组合回归 |
| A10 | closed | 六方清零完成、超时锁定及 DFT 约束已修复 | 保留全容量清除和分拍 done 测试；总线永久阻塞不得假成功 |
| A11 | open | SRAM 容量和 word 有效性已修，完整请求标签授权尚缺 | 补 representation/algo/pset/secret/owner 分配与访问校验 |
| A12 | open | 原语与元数据修复不能替代系统安全契约 | 补 SELF_TEST/ZEROIZE 命令、描述符范围/重叠检查及广告功能 |
| P01 | open | NTT lane/bank 详细调度模型已建立，RTL 尚未落实并行硬件 | 实现每 lane 资源及六 batch slot，验证数据与端口时序 |
| HLD-SEC-001 | open | Level 2 架构已审查，完整转换/采样、组合安全与实现验证仍未闭环 | 05/07/验证：完成全秘密数据链；数学模型不代替 RTL/安全验证 |
| HLD-SEC-002 | closed | Sign 时序需求冲突已明确：固定尝试调度、可变总尝试次数和时延 | 决策关闭；RTL 独立检查、预算与时延验证继续按 RTL-SIGN-001 跟踪 |
| HLD-PERF-001 | open | 64-bit 双 share rate 接口与分级周期已详细设计，RTL 尚为 byte 接口 | 完成 G2 后实现并按实际内部等待验证周期 |
| RTL-SIGN-001 | open | DSA op/pset 快照、单未决原语和取消已修；独立 norm/ct0 检查及完整调度仍缺 | 补独立检查身份与结果 bank，并以完整 Sign/Verify RTL KAT 验收 |
| RTL-RNG-001 | open | RANDOM 租约服务及其与 masked round 的局部组合 UT 已实现；TOP entropy 消费仍未接通 | 将所有秘密客户端接入唯一随机服务，验证完整命令的 quota/身份/清除 |
| HLD-PERF-002 | closed | 用户已批准按安全等级制定预算，原 24/r 不再适用于 Level 2 | Level 2 完整块目标为 ceil(R/8)+1896+2；实际调度、随机预算与实现验证继续按 HLD-SEC-001 跟踪 |
| RTL-CTRL-001 | closed | KEM 输出字节地址错位、第二次 Decaps 计数未清、重复原语发射和清除同拍副作用已修 | 保持全密文位置比较/选择、连续命令与五引擎取消 UT；不等于完整 KEM |
| REG-RTL-001 | open | 生成字段正确不代表外层集成完成；PERF、可信 slot/domain、SELF_TEST 和原子 completion 仍缺 | 实现并验证实际硬件事件、生命周期权限、可信元数据和输出退休顺序 |
| RTL-CLEAR-001 | closed | SRAM 清除同拍响应/tag 泄漏、sweep 期间 tag 发布和 DSA 摘要仅清指针已修 | 保留物理缓存擦除、同拍撤销和非法 DSA 配置的回归；完整双 share/epoch 存储仍未完成 |
| VPLAN-001 | open | 真实RTL与冻结KAT的完整UVM计划已抽取；12个测试入口尚未实现 | 闭合LLD及VP0、冻结向量、实现平台与计算链，执行六参数18操作及全量负向/安全回归 |
| EVIDENCE-001 | open | 当前 Decaps/Encaps/APB UVM 与模块 UT 已重新绑定最终源码；历史证据不补签，其他阶段仍不完整 | 补全当前配置、覆盖、形式与全命令证据 |
| RTL-DECAPS-001 | closed | 已实现 SRAM 写数据、配置锁存、WORKKEY 请求/响应与持续哈希握手；三参数 KAT 和背压通过 | 保留 45 场景回归；超时/撤销/epoch 安全义务另行闭合 |
| RTL-DECAPS-002 | closed | 重建正确私钥偏移、逐 poly 解码/解压/NTT/累积链，原密文页16–17与重加密页20–21隔离 | 保持九组正常及27组隐式拒绝的独立冻结向量；页标签/清除见 A11 |
| RTL-DECAPS-003 | closed | 按 ct_words 全长比较，累积 diff 并用掩码选择 Kprime/Kbar；首/中/末失配与正常均通过 | 保留每向量正常/拒绝同周期检查；不把有限采样结果表述为完整侧信道安全证明 |
| UVM-RUNNER-001 | closed | 已加入实际用例、双算法完成标记、输入集合/VIP/二进制变化拒绝、独立目录和编译失败证据 | 保留28项runner故障注入测试；它们不是DUT/UVM算法通过数 |
| UVM-BUILD-001 | open | 旧模板 Makefile 已替换为真实 runner，Core 源清单已同步；全计划回归、覆盖采集与 VIP 依赖仍缺 | 闭合 FuseSoC UVM 依赖、AXI4 VIP、coverage、六参数18操作和配置执行 |
| G2-TECH-001 | open | 机器G2 PASS与LLD_GATE_META open/false并存，不能替代完整技术冻结 | 完成剩余FSM/Level2/授权/清除技术评审后按既有用户委托冻结，不重复索取授权 |
| VIP-APB-001 | open | 历史反馈：APB VIP Core缺include路径和config文件，尚未在本轮重验 | 复核VIP仓F-APB-01，验证FuseSoC depend真实接入 |
| VIP-APB-002 | open | 历史反馈：APB env在未配置map时连接predictor导致空指针 | 复核VIP仓F-APB-02，并验证RAL与非RAL场景 |
| VIP-AXI4-001 | open | 历史反馈：AXI4 VIP接口参数不匹配PQC的128-bit/40-bit主机 | 复核VIP仓F-AXI4-01，闭合参数化接口及协议级验证 |
| RTL-REG-002 | closed | TOP 显式驱动 ABI minor=1，独立参考模型恢复 RDL 期望；严格读回检查双 seed 通过 | 保持参考模型和生成 RDL 契约一致，不采纳错误 DUT 实测值作为期望 |
| RTL-APB-002 | closed | 恢复0x2F0/0x3FC的普通及特权访问，当前 DUT 返回错误并继续服务后续访问 | 继续完整地址空间和并发/忙态保护验证；本结果不是 AXI/APB 全协议覆盖 |
| RTL-CMD-001 | open | Encaps/Decaps 正常和合法长度拒绝路径均已完成并退休；全命令及异常路径仍缺 | 验证其他支持操作、非法操作、取消、故障、超时有界完成 |
| UVM-KEY-001 | closed | 纠正安全特权 PPROT=001，覆盖全部8组合、拒绝读零与无写副作用及只读元数据 | 本结果只覆盖 CSR 窗口，不替代可信密钥域/epoch/生命周期验证 |

## 复现与证据

运行方式见 [验证入口](../verification/sim/README.md)，设计见 [Decaps LLD](../docs/lld/03_kemseq_decaps.md)，
用例义务见 [Decaps测试矩阵](../docs/verification/test_matrix_decaps.md)。所有日志、构建指纹、JUnit、
摘要均在被忽略的build目录；重新检出须重跑。报告提取校验仅证明报告与证据一致，不代表发布门禁通过。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ip_summary
ip_name: pqc
status: blocked
conclusion: Decaps 串行算法链与隐式拒绝已修复，当前自检查 UVM 子集 14/14 通过；整个 PQC 的完整 KEM/DSA、Level 2、G2
  技术冻结及 G3–G5 仍未闭环，当前不可发布。
gates:
  G0: pass
  G1: pass
  G2: pass
  G3: fail
  G4: blocked
  G5: blocked
findings:
- id: ISSUE-001
  status: open
  summary: RTL 检查与专项证据未闭环
  next_action: 09：上游通过后补 FuseSoC lint/elab/综合适用检查及 CDC/formal 证据
- id: ISSUE-002
  status: open
  summary: 根 Core 和 RTL filelist 已补入 Decaps 及现存用例，Makefile 已统一调用 runner；UVM VIP 的
    FuseSoC depend 接入仍缺
  next_action: 08：使用只读资产元数据适配器闭合依赖；不能把本地 VCS 编译等同于完整 FuseSoC UVM target
- id: ISSUE-003
  status: open
  summary: 四类追踪矩阵未闭环
  next_action: 16：随上游重建四类 trace，逐需求绑定真实验证
- id: ISSUE-004
  status: open
  summary: UVM、覆盖率与端到端 KAT 缺失
  next_action: 10–15：构建独立 RM、六参数集 KAT、接口负向回归与覆盖闭环
- id: ISSUE-005
  status: closed
  summary: 本轮不以物理 PPA 表征作为验收条件
  next_action: 遵照用户指令完成代码结构分析；不宣称物理指标达标
- id: ISSUE-006
  status: open
  summary: 机器 G2 的结构与 CSR 一致性检查通过；完整 LLD 技术项及 VP0 仍未闭环
  next_action: 补完整算法/掩码/逐拍调度与验证计划；结构检查不替代技术评审
- id: ISSUE-007
  status: open
  summary: 完整 KEM/DSA 算法、Key RAM 消费及托管未实现
  next_action: 03/05/07：冻结架构与时序后补全安全数据通路，六参数集 RTL KAT 验收
- id: SUITE-001
  status: closed
  summary: HLD 必需需求覆盖已补齐，当前投影与来源一致
  next_action: 84/84 全需求归属与引用检查通过；不等于 G1 或 RTL 通过
- id: SUITE-002
  status: open
  summary: 22 个 LLD 模块已建立静态 RTL 链接；完整算法、转换、页授权与掩码集成仍缺
  next_action: 继续完成 KeyGen/DSA/Level2；静态链接不等于实现完整性
- id: SUITE-003
  status: closed
  summary: 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过
  next_action: 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL
- id: SUITE-004
  status: open
  summary: 当前根 Core 全量模块 UT 已重跑，结果 pass，共 40 项；完整模块映射与新增算法专项仍需补齐
  next_action: 以本轮 module_ut_summary 为准，不能替代完整 G3 或当前端到端算法测试
- id: SUITE-005
  status: open
  summary: 参数 initial/$fatal 被工作区审计识别为 RTL 中仅仿真构造
  next_action: 07/09/19：把参数校验放入合法 elaboration/验证入口并保持非法配置拒绝
- id: SUITE-006
  status: open
  summary: 集成指南与用户手册缺失
  next_action: 17：补 docs/integration 和 docs/user_manual，说明密钥、复位、错误与能力限制
- id: A01
  status: closed
  summary: AXI 读事务仲裁锁定、描述符完成/错误判定、地址快照与门铃防重复已修
  next_action: 保留背压、取消排空、异常 RLAST/RRESP、128 B 顺序及 held-doorbell 回归
- id: A02
  status: closed
  summary: CRC final XOR 与 ABI 已修复
  next_action: 保留独立 CRC/ABI oracle
- id: A03
  status: open
  summary: 真实 Encaps/Decaps 的输入、算法、输出、completion 与 IRQ 链已由 KAT 验证；其他命令及失败退休仍缺
  next_action: 补 KeyGen/DSA 和故障、取消、超时的端到端检查
- id: A04
  status: closed
  summary: Keccak 多块、padding、空输入、squeeze 已修复
  next_action: 保留四种 function、两种轮数及边界背压测试
- id: A05
  status: closed
  summary: SRAM 请求重复受理及共享响应归属已修复
  next_action: 保留实际 SRAM 组合测试
- id: A06
  status: open
  summary: codec 数学及固定 256 系数 packing 已修，完整格式/offset 尚缺
  next_action: 补任意 bit offset、长度上限、完整密钥/签名编码
- id: A07
  status: closed
  summary: DSA 旧摘要误接受已修复
  next_action: 最终判决完整性测试保留；不等于完整 Verify 算法通过
- id: A08
  status: closed
  summary: DMA 溢出、属性、尾拍和取消排空已修复
  next_action: 保留三总线宽度与实际 SRAM、取消背压回归
- id: A09
  status: closed
  summary: IRQ 独立掩码已修复
  next_action: 保留 pending/enable 交叉组合回归
- id: A10
  status: closed
  summary: 六方清零完成、超时锁定及 DFT 约束已修复
  next_action: 保留全容量清除和分拍 done 测试；总线永久阻塞不得假成功
- id: A11
  status: open
  summary: SRAM 容量和 word 有效性已修，完整请求标签授权尚缺
  next_action: 补 representation/algo/pset/secret/owner 分配与访问校验
- id: A12
  status: open
  summary: 原语与元数据修复不能替代系统安全契约
  next_action: 补 SELF_TEST/ZEROIZE 命令、描述符范围/重叠检查及广告功能
- id: P01
  status: open
  summary: NTT lane/bank 详细调度模型已建立，RTL 尚未落实并行硬件
  next_action: 实现每 lane 资源及六 batch slot，验证数据与端口时序
- id: HLD-SEC-001
  status: open
  summary: Level 2 架构已审查，完整转换/采样、组合安全与实现验证仍未闭环
  next_action: 05/07/验证：完成全秘密数据链；数学模型不代替 RTL/安全验证
- id: HLD-SEC-002
  status: closed
  summary: Sign 时序需求冲突已明确：固定尝试调度、可变总尝试次数和时延
  next_action: 决策关闭；RTL 独立检查、预算与时延验证继续按 RTL-SIGN-001 跟踪
- id: HLD-PERF-001
  status: open
  summary: 64-bit 双 share rate 接口与分级周期已详细设计，RTL 尚为 byte 接口
  next_action: 完成 G2 后实现并按实际内部等待验证周期
- id: RTL-SIGN-001
  status: open
  summary: DSA op/pset 快照、单未决原语和取消已修；独立 norm/ct0 检查及完整调度仍缺
  next_action: 补独立检查身份与结果 bank，并以完整 Sign/Verify RTL KAT 验收
- id: RTL-RNG-001
  status: open
  summary: RANDOM 租约服务及其与 masked round 的局部组合 UT 已实现；TOP entropy 消费仍未接通
  next_action: 将所有秘密客户端接入唯一随机服务，验证完整命令的 quota/身份/清除
- id: HLD-PERF-002
  status: closed
  summary: 用户已批准按安全等级制定预算，原 24/r 不再适用于 Level 2
  next_action: Level 2 完整块目标为 ceil(R/8)+1896+2；实际调度、随机预算与实现验证继续按 HLD-SEC-001 跟踪
- id: RTL-CTRL-001
  status: closed
  summary: KEM 输出字节地址错位、第二次 Decaps 计数未清、重复原语发射和清除同拍副作用已修
  next_action: 保持全密文位置比较/选择、连续命令与五引擎取消 UT；不等于完整 KEM
- id: REG-RTL-001
  status: open
  summary: 生成字段正确不代表外层集成完成；PERF、可信 slot/domain、SELF_TEST 和原子 completion 仍缺
  next_action: 实现并验证实际硬件事件、生命周期权限、可信元数据和输出退休顺序
- id: RTL-CLEAR-001
  status: closed
  summary: SRAM 清除同拍响应/tag 泄漏、sweep 期间 tag 发布和 DSA 摘要仅清指针已修
  next_action: 保留物理缓存擦除、同拍撤销和非法 DSA 配置的回归；完整双 share/epoch 存储仍未完成
- id: VPLAN-001
  status: open
  summary: 真实RTL与冻结KAT的完整UVM计划已抽取；12个测试入口尚未实现
  next_action: 闭合LLD及VP0、冻结向量、实现平台与计算链，执行六参数18操作及全量负向/安全回归
- id: EVIDENCE-001
  status: open
  summary: 当前 Decaps/Encaps/APB UVM 与模块 UT 已重新绑定最终源码；历史证据不补签，其他阶段仍不完整
  next_action: 补全当前配置、覆盖、形式与全命令证据
- id: RTL-DECAPS-001
  status: closed
  summary: 已实现 SRAM 写数据、配置锁存、WORKKEY 请求/响应与持续哈希握手；三参数 KAT 和背压通过
  next_action: 保留 45 场景回归；超时/撤销/epoch 安全义务另行闭合
- id: RTL-DECAPS-002
  status: closed
  summary: 重建正确私钥偏移、逐 poly 解码/解压/NTT/累积链，原密文页16–17与重加密页20–21隔离
  next_action: 保持九组正常及27组隐式拒绝的独立冻结向量；页标签/清除见 A11
- id: RTL-DECAPS-003
  status: closed
  summary: 按 ct_words 全长比较，累积 diff 并用掩码选择 Kprime/Kbar；首/中/末失配与正常均通过
  next_action: 保留每向量正常/拒绝同周期检查；不把有限采样结果表述为完整侧信道安全证明
- id: UVM-RUNNER-001
  status: closed
  summary: 已加入实际用例、双算法完成标记、输入集合/VIP/二进制变化拒绝、独立目录和编译失败证据
  next_action: 保留28项runner故障注入测试；它们不是DUT/UVM算法通过数
- id: UVM-BUILD-001
  status: open
  summary: 旧模板 Makefile 已替换为真实 runner，Core 源清单已同步；全计划回归、覆盖采集与 VIP 依赖仍缺
  next_action: 闭合 FuseSoC UVM 依赖、AXI4 VIP、coverage、六参数18操作和配置执行
- id: G2-TECH-001
  status: open
  summary: 机器G2 PASS与LLD_GATE_META open/false并存，不能替代完整技术冻结
  next_action: 完成剩余FSM/Level2/授权/清除技术评审后按既有用户委托冻结，不重复索取授权
- id: VIP-APB-001
  status: open
  summary: 历史反馈：APB VIP Core缺include路径和config文件，尚未在本轮重验
  next_action: 复核VIP仓F-APB-01，验证FuseSoC depend真实接入
- id: VIP-APB-002
  status: open
  summary: 历史反馈：APB env在未配置map时连接predictor导致空指针
  next_action: 复核VIP仓F-APB-02，并验证RAL与非RAL场景
- id: VIP-AXI4-001
  status: open
  summary: 历史反馈：AXI4 VIP接口参数不匹配PQC的128-bit/40-bit主机
  next_action: 复核VIP仓F-AXI4-01，闭合参数化接口及协议级验证
- id: RTL-REG-002
  status: closed
  summary: TOP 显式驱动 ABI minor=1，独立参考模型恢复 RDL 期望；严格读回检查双 seed 通过
  next_action: 保持参考模型和生成 RDL 契约一致，不采纳错误 DUT 实测值作为期望
- id: RTL-APB-002
  status: closed
  summary: 恢复0x2F0/0x3FC的普通及特权访问，当前 DUT 返回错误并继续服务后续访问
  next_action: 继续完整地址空间和并发/忙态保护验证；本结果不是 AXI/APB 全协议覆盖
- id: RTL-CMD-001
  status: open
  summary: Encaps/Decaps 正常和合法长度拒绝路径均已完成并退休；全命令及异常路径仍缺
  next_action: 验证其他支持操作、非法操作、取消、故障、超时有界完成
- id: UVM-KEY-001
  status: closed
  summary: 纠正安全特权 PPROT=001，覆盖全部8组合、拒绝读零与无写副作用及只读元数据
  next_action: 本结果只覆盖 CSR 窗口，不替代可信密钥域/epoch/生命周期验证
evidence:
- path: build/reports/quality/quality.yaml
  sha256: 68295f8f64f2643f1a60bc864c35d207f0869c634a99c5d0f5bdbc9e451b0c51
- path: build/reports/quality/trace_matrix.md
  sha256: 0842f6b37d5a9cad28e0abc9e20cf3b747dbfc7075778865bfc9f76bbb81036a
- path: build/reports/quality/module_ut_summary.md
  sha256: c099a3a0e05d4d609d7bcce954b0186024f2fd306e5f532a96f1ed61b9ae3e68
- path: build/decaps_repair/final_ut_driver.log
  sha256: adc3043c6e151834664fbb02ab2f5ccfb04ce430fba24b31e9124536cb7d9ca5
- path: build/decaps_repair/final_uvm_driver.log
  sha256: c75df50e41d19ab625209d8ce4199d9b2b034c1ccfba3ac69e0bb10f59e31cbb
- path: build/sim/uvm/run-kp8otz4o/summary.json
  sha256: dcff0c2d128354294fd058165e83a432b0f7ec2b5be6050f989f246a78d2a595
- path: build/sim/uvm/run-kp8otz4o/junit.xml
  sha256: ea0c286c9102586f5d8ebc840d0c227380df18de8f7ac06203515b0c2de36d4c
- path: build/decaps_repair/runner_pytest.xml
  sha256: b2cd403b1c03e73ea6b032312ba71c9cf26766cab6bfccb4e78e61d9fcd77198
- path: build/decaps_repair/lint_final_report.md
  sha256: 94290d1a93180add0b4fa015814b3f7e5a9531956ac761bc49bfecf660d088d5
- path: build/decaps_repair/lint_final_driver.log
  sha256: 84ef185011164c84f46943f5b759f88c2ca087ead2a9f97dd59457e7803cc85e
- path: build/decaps_repair/lint_counts.json
  sha256: 57d666def8ee3a54b4a4d9bcc96d0dccfdae01d204bd227440b76f84eeba0a88
- path: build/decaps_repair/trace_final.log
  sha256: fb6ce3bfe1077f23a7d3583288032735931f9d67e1f7b081b193180ae48a5474
- path: build/decaps_repair/extract_lld_final.log
  sha256: 8fc9abd631d2515c6176ce9f4dc1fa886c9d816e7b8ce193beb261ec462c9f69
- path: build/decaps_repair/quality_final.log
  sha256: 4336a8ec5d9816c9040ee94aef7f1ed1103f46b9a3da7086e1032865fb0e80d3
- path: build/decaps_repair/audit_final.log
  sha256: 0b8ff613dce120ab7e579a2e67a55546b234e5676c4591868490b8ce7e2b3e0f
- path: build/decaps_repair/package_check.json
  sha256: cc405657cb14527a72a34487f19af6eaa55117e86de1790777e7bca4aedface0
END_IP_REPORT_METADATA -->
