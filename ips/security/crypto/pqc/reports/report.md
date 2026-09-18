# PQC 加速器统一结论报告

六类 KEM/DSA 数据通路已完成候选集成，算法基线 UVM 11/11、159 条命令通过；最终告警修复的故障/控制 UVM 12/12、模块 UT 45/45 和 lint 通过。综合仍待最终报告，Level 2、技术冻结及 G3–G5 未闭环，当前不可发布。

## 本轮集成和验证（2026-09-18）

使用 ip-development-suite；保留已有工作，未提交或推送。新增 KEM KeyGen、DSA KeyGen、
Pure ML-DSA Sign/Verify 和可信密钥托管，TOP 六类算法调用真实共享 Keccak、POLY、codec、sampler。
私钥仅从 WORKKEY 消费；生成私钥通过可信接口输出，完整身份 custody ACK 后才允许公开结果 DMA。
这属于候选功能集成，不能据此宣称完整密钥生命周期和安全等级闭环。

| 自检查算法用例 | 每 seed 命令数 | 主要覆盖 |
|---|---:|---|
| KEM Encaps | 6 | 三参数集、独立密文/共享秘密 |
| KEM Decaps | 45 | 9 正常、27 首/中/末篡改隐式拒绝、9 背压重复 |
| KEM KeyGen | 9 | 三参数集、独立完整公私钥及托管 |
| DSA KeyGen | 9 | 44/65/87 独立完整公私钥 |
| DSA Verify | 63 | 三参数集、正常/篡改/编码边界等 |
| DSA Sign | 27 | 确定性/hedged/重复，消息 0/137/65537，context 0/1/255 |

另有五项 APB/控制 UVM，用例总数 11、seed=1、算法命令总数 159。
冻结向量来自 kyber-py 1.2.0 和 dilithium-py 1.4.0，仿真没有 Python/C/DPI 密码算法。
Sign 比较完整签名字节和独立 oracle 尝试次数，不仅检查状态；所有输出检查完成顺序及 guard。
算法基线 source-px0msrzs 的完整 UVM 已完成：11/11 通过，159 条算法命令，全部 UVM_ERROR/UVM_FATAL 为 0。
早一份 source-xs9jtd3q 副本 11/11 已通过，但其 word_valid 和 fault RTL 早于最终修复，
不能替代当前 source-px0msrzs 的结果。

算法基线 RTL 副本 45/45 模块 UT 通过，包括 200000 个 DSA reduction 输入、两个 gamma2 的
全部 8380417 个规范系数 HighBits、全部 96 tag 索引及 64 物理页的有效性失效检查。
runner 自身 34/34 测试不计入 DUT 通过数。参数检查 5/5：TINY/BALANCED/THROUGHPUT
合法结构可 elaboration，两项非法参数正确拒绝；这些不是多 lane 功能或吞吐验收。

根 Core 的正式 FuseSoC SpyGlass lint 退出 0：0 Fatal、0 Error、0 未豁免 Warning、5 Info。
原始新增 240 警告分类保存在 lint_review.json；仅对已审查的时钟无关 automatic task、
单进程 FSM、默认/优先级赋值、无符号扩宽及未用输入/快照按文件限定 waiver。
没有豁免锁存器、组合环、越界或综合错误；存储空模块 waiver 仅限 synthesis SRAM 视图。

## 综合前 RTL 审查与边界

- 行为 SRAM 从 synth/lint fileset 排除。工作 SRAM 和 WORKKEY 均使用相同端口的纯存储
  黑盒，DC 日志必须确认恰好两处；ECC、清除、掩码写、授权和有效性元数据仍是实际逻辑。
  黑盒没有真实宏面积和 timing arc，因此不能把结果称为完整 IP 的物理 PPA。
- WORKKEY 内嵌数组改为宏实例，保留原读响应阶段。word_valid 按实际物理页 generate，
  支持末尾部分页；失效优先级不变。64 KiB 配置的 16K 有效位属于安全控制元数据。
- NTT DSA 乘积取模改为 36/27/24 位三次折叠和一次条件减；独立数学边界与 RTL UT 均检查。
  仍是组合乘法/折叠，尚未兑现 LLD 的 lane 流水化，P01 保持 open。
- Sign 去除运行时除法；HighBits 仍有常数除法网络。codec 多份宽常数取模/除法及 Keccak
  两轮组合逻辑需以最终报告判断，不根据源码猜测面积/时序是否达标。
- fault 控制去除吞掉 X 的 case equality；参数 initial/$fatal 用综合 translate_off/on 隔离。
- ML-DSA-87 原每尝试预算不足，改为公开固定 2250000 周期，44/65 保持 1500000；
  max attempts=256，命令预算 750000000。总尝试数可变，不宣称整条 Sign 恒定时延。
- 诊断 SDC 为 10 ns、0.1 ns uncertainty、1 ns I/O delay；entropy/Key Manager/custody/epoch
  接口不再被整体 false path，仅 reset 排除。实际 SoC CDC/RDC 和宏 timing 仍需后续签核。

综合使用 TT 28nm / 1 V / 25 C 标准单元，compile_ultra、4 cores，排除存储宏面积。
source-px0msrzs 的四核综合同样在 30 分钟上限退出 124，没有最终 mapped artifacts；
相同 RTL 已在 source-s_akie3_/pqc 延长至最多两小时继续独立运行。
不将中间映射成本表当最终指标。
早期单核运行 30 分钟超时；另一次低 effort compile 触发 DC internal system error，
其失败日志保留且该实验入口已移除。当前运行若旧 wrapper 因 console.log 无输出误判，
须用只读 check_synth_result.sh 检查真实 DC 日志和 mapped artifacts；不能改写旧日志。

## 门禁与未闭环范围

| Gate | 当前机器状态 |
|---|---|
| G0 | pass |
| G1 | pass |
| G2 | pass |
| G3 | fail |
| G4 | blocked |
| G5 | blocked |

G2 pass 仅表示结构/寄存器一致性；LLD 技术冻结仍 open/false。剩余范围包括 Level 2
秘密数据链、页/表示授权、epoch/撤销、取消/故障/清除、独立冗余检查、HashML-DSA、
完整 AXI4 VIP、覆盖率/RTM/formal、参数功能执行及集成/用户文档。现有 reset/self-test 弱检查不纳入自检查闭环；故障用例已补入真实 tamper/清除检查，结果单独记录。其他弱检查；不得用记录现象的用例签核功能。

## 告警事件集成追加修复

强化旧故障用例后，真实 tamper 揭示 TOP 告警 CSR 的 hwset 未接，软件读回恒零。
已连接 ECC DED/UE、门控 DFT ECC 注入、tamper 和 self-test 对应字段；未把聚合 fatal
误映射成所有分项。剩余 integrity/retry/perf 事件归因仍按 REG-RTL-001 跟踪。

旧参考模型还把告警误当 RO 常零，现按 RDL W1C 及外部 tamper 事件独立预测；不读取 DUT
内部告警作为期望。故障用例检查 DFT gate 关闭、tamper、两次有界清除 ACK、W1C 与
锁定保持，并要求唯一 FAULT_IDLE_PASS。它不覆盖执行中注入、全部故障来源或擦除内容。
修复后正式 FuseSoC lint 已退出 0。独立故障/APB 六用例 × seeds 1/17 共 12/12 通过，45 项模块 UT 全部通过，
UVM_ERROR/UVM_FATAL 均为 0。最终来源分别为 source-d9mlyjan 与 source-rl1kkc0c，RTL 相同。
runner 自身现为 35/35。首次未连 hwset 的失败与随后静态 RM 误期望失败均保留，未豁免。
根目录 UT 为避免修改期间混源而主动取消，不计作通过；最终使用保留 pqc 身份的冻结副本。

## 统一问题表

| ID | 状态 | 问题/处置 | 下一步 |
|---|---|---|---|
| ISSUE-001 | open | 全 IP FuseSoC lint 与参数 elaboration 通过；综合及 CDC/formal 专项仍待闭合 | 保留宏边界并依据最终综合数据处理面积/时序；补安全专项 |
| ISSUE-002 | open | 根 Core 和 RTL filelist 已补入 Decaps 及现存用例，Makefile 已统一调用 runner；UVM VIP 的 FuseSoC depend 接入仍缺 | 08：使用只读资产元数据适配器闭合依赖；不能把本地 VCS 编译等同于完整 FuseSoC UVM target |
| ISSUE-003 | open | 四类追踪矩阵未闭环 | 16：随上游重建四类 trace，逐需求绑定真实验证 |
| ISSUE-004 | open | 六类算法端到端 KAT 已实现；完整 VPLAN、安全负向与覆盖率仍缺 | 扩展完整计划及 closure RTM，不用单 seed KAT 替代签核 |
| ISSUE-005 | closed | 按用户要求已启动不包含行为 SRAM 的诊断综合；不以本轮结果宣称物理 PPA 达标 | 实际宏及 SoC 约束到位后另行进行物理表征 |
| ISSUE-006 | open | 机器 G2 的结构与 CSR 一致性检查通过；完整 LLD 技术项及 VP0 仍未闭环 | 补完整算法/掩码/逐拍调度与验证计划；结构检查不替代技术评审 |
| ISSUE-007 | open | KEM/DSA 六类算法、WORKKEY 消费与生成密钥托管 ACK 已实现候选集成；Level 2 与系统安全仍未闭环 | 完成授权/epoch/撤销/清除/故障和完整安全数据通路验证 |
| SUITE-001 | closed | HLD 必需需求覆盖已补齐，当前投影与来源一致 | 84/84 全需求归属与引用检查通过；不等于 G1 或 RTL 通过 |
| SUITE-002 | open | 27 个 LLD 模块具有 RTL 链接，新数据通路对象已补齐；完整技术冻结仍缺 | 完成掩码、转换、页授权及逐拍性能义务 |
| SUITE-003 | closed | 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过 | 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL |
| SUITE-004 | open | 当前 RTL 冻结副本的 45 项模块 UT 全部通过；完整 G3 模块证据与专项仍待闭合 | 保留源指纹和副本身份，不把 UT 子集等同发布签核 |
| SUITE-005 | closed | TOP 参数 initial/$fatal 已用 synthesis translate_off/on 隔离；三合法、两非法配置验证通过 | 保持非法配置仿真拒绝及综合排除诊断行为 |
| SUITE-006 | open | 集成指南与用户手册缺失 | 17：补 docs/integration 和 docs/user_manual，说明密钥、复位、错误与能力限制 |
| A01 | closed | AXI 读事务仲裁锁定、描述符完成/错误判定、地址快照与门铃防重复已修 | 保留背压、取消排空、异常 RLAST/RRESP、128 B 顺序及 held-doorbell 回归 |
| A02 | closed | CRC final XOR 与 ABI 已修复 | 保留独立 CRC/ABI oracle |
| A03 | open | 六类算法输入、共享计算、输出、completion 与 IRQ 已接通；系统异常退休仍需补齐 | 补故障、取消、超时、撤销并发的端到端检查 |
| A04 | closed | Keccak 多块、padding、空输入、squeeze 已修复 | 保留四种 function、两种轮数及边界背压测试 |
| A05 | closed | SRAM 请求重复受理及共享响应归属已修复 | 保留实际 SRAM 组合测试 |
| A06 | open | 完整 KEM/DSA 密钥、密文、签名算法路径已集成；任意 offset 与全部编码负向仍待覆盖 | 保留独立数学 oracle 并完成完整格式边界 |
| A07 | closed | DSA 旧摘要误接受已修复 | 最终判决完整性测试保留；不等于完整 Verify 算法通过 |
| A08 | closed | DMA 溢出、属性、尾拍和取消排空已修复 | 保留三总线宽度与实际 SRAM、取消背压回归 |
| A09 | closed | IRQ 独立掩码已修复 | 保留 pending/enable 交叉组合回归 |
| A10 | closed | 六方清零完成、超时锁定及 DFT 约束已修复 | 保留全容量清除和分拍 done 测试；总线永久阻塞不得假成功 |
| A11 | open | word_valid 已改成有界物理页 bank；所有 96 tag 索引及 64 物理页失效检查通过，完整授权仍缺 | 补 representation/algo/pset/secret/owner 组合访问校验 |
| A12 | open | 原语与元数据修复不能替代系统安全契约 | 补 SELF_TEST/ZEROIZE 命令、描述符范围/重叠检查及广告功能 |
| P01 | open | NTT lane/bank 详细调度模型已建立，RTL 尚未落实并行硬件 | 实现每 lane 资源及六 batch slot，验证数据与端口时序 |
| HLD-SEC-001 | open | Level 2 架构已审查，完整转换/采样、组合安全与实现验证仍未闭环 | 05/07/验证：完成全秘密数据链；数学模型不代替 RTL/安全验证 |
| HLD-SEC-002 | closed | Sign 时序需求冲突已明确：固定尝试调度、可变总尝试次数和时延 | 决策关闭；RTL 独立检查、预算与时延验证继续按 RTL-SIGN-001 跟踪 |
| HLD-PERF-001 | open | 64-bit 双 share rate 接口与分级周期已详细设计，RTL 尚为 byte 接口 | 完成 G2 后实现并按实际内部等待验证周期 |
| RTL-SIGN-001 | open | 完整 Pure ML-DSA Sign/Verify 候选调度、独立签名与尝试次数检查已实现；独立冗余身份/norm 检查及安全闭环仍缺 | 固定每尝试公开预算，补故障注入、独立结果身份与 Level 2 |
| RTL-RNG-001 | open | RANDOM 租约服务及其与 masked round 的局部组合 UT 已实现；TOP entropy 消费仍未接通 | 将所有秘密客户端接入唯一随机服务，验证完整命令的 quota/身份/清除 |
| HLD-PERF-002 | closed | 用户已批准按安全等级制定预算，原 24/r 不再适用于 Level 2 | Level 2 完整块目标为 ceil(R/8)+1896+2；实际调度、随机预算与实现验证继续按 HLD-SEC-001 跟踪 |
| RTL-CTRL-001 | closed | KEM 输出字节地址错位、第二次 Decaps 计数未清、重复原语发射和清除同拍副作用已修 | 保持全密文位置比较/选择、连续命令与五引擎取消 UT；不等于完整 KEM |
| REG-RTL-001 | open | 生成字段正确不代表外层集成完成；PERF、可信 slot/domain、SELF_TEST 和原子 completion 仍缺 | 实现并验证实际硬件事件、生命周期权限、可信元数据和输出退休顺序 |
| RTL-CLEAR-001 | closed | SRAM 清除同拍响应/tag 泄漏、sweep 期间 tag 发布和 DSA 摘要仅清指针已修 | 保留物理缓存擦除、同拍撤销和非法 DSA 配置的回归；完整双 share/epoch 存储仍未完成 |
| VPLAN-001 | open | 六参数集的 18 种操作/参数组合已进入真实 RTL UVM；全量负向、安全、覆盖率和 VP0 未闭合 | 按完整 VPLAN 补场景，不把候选 KAT 子集当全计划通过 |
| EVIDENCE-001 | open | 算法基线 159 命令已绑定；当前 RTL 仅增加 TOP 告警 hwset，修复回归与基线分开保存 | 保留 alert_delta.json 精确差异与分阶段来源，不补签旧日志 |
| RTL-DECAPS-001 | closed | 已实现 SRAM 写数据、配置锁存、WORKKEY 请求/响应与持续哈希握手；三参数 KAT 和背压通过 | 保留 45 场景回归；超时/撤销/epoch 安全义务另行闭合 |
| RTL-DECAPS-002 | closed | 重建正确私钥偏移、逐 poly 解码/解压/NTT/累积链，原密文页16–17与重加密页20–21隔离 | 保持九组正常及27组隐式拒绝的独立冻结向量；页标签/清除见 A11 |
| RTL-DECAPS-003 | closed | 按 ct_words 全长比较，累积 diff 并用掩码选择 Kprime/Kbar；首/中/末失配与正常均通过 | 保留每向量正常/拒绝同周期检查；不把有限采样结果表述为完整侧信道安全证明 |
| UVM-RUNNER-001 | closed | runner 检查六算法完整标记与真实故障完成标记，35 项自身故障注入测试通过 | runner 测试不计入 DUT 算法通过数 |
| UVM-BUILD-001 | open | 根 Core/filelist/真实 runner 已同步，六算法用例可执行；完整 FuseSoC VIP 依赖和 coverage 仍缺 | 闭合 AXI4 VIP、覆盖采集与参数功能执行 |
| G2-TECH-001 | open | 机器G2 PASS与LLD_GATE_META open/false并存，不能替代完整技术冻结 | 完成剩余FSM/Level2/授权/清除技术评审后按既有用户委托冻结，不重复索取授权 |
| VIP-APB-001 | open | 历史反馈：APB VIP Core缺include路径和config文件，尚未在本轮重验 | 复核VIP仓F-APB-01，验证FuseSoC depend真实接入 |
| VIP-APB-002 | open | 历史反馈：APB env在未配置map时连接predictor导致空指针 | 复核VIP仓F-APB-02，并验证RAL与非RAL场景 |
| VIP-AXI4-001 | open | 历史反馈：AXI4 VIP接口参数不匹配PQC的128-bit/40-bit主机 | 复核VIP仓F-AXI4-01，闭合参数化接口及协议级验证 |
| RTL-REG-002 | closed | TOP 显式驱动 ABI minor=1，独立参考模型恢复 RDL 期望；严格读回检查双 seed 通过 | 保持参考模型和生成 RDL 契约一致，不采纳错误 DUT 实测值作为期望 |
| RTL-APB-002 | closed | 恢复0x2F0/0x3FC的普通及特权访问，当前 DUT 返回错误并继续服务后续访问 | 继续完整地址空间和并发/忙态保护验证；本结果不是 AXI/APB 全协议覆盖 |
| RTL-CMD-001 | open | 六类算法正常完成和 KEM 隐式拒绝已接通；全异常、非法和控制命令尚未闭合 | 验证取消、故障、超时有界完成及 SELF_TEST/ZEROIZE |
| UVM-KEY-001 | closed | 纠正安全特权 PPROT=001，覆盖全部8组合、拒绝读零与无写副作用及只读元数据 | 本结果只覆盖 CSR 窗口，不替代可信密钥域/epoch/生命周期验证 |
| RTL-SRAM-SYNTH-001 | closed | 工作 SRAM 与 WORKKEY 均替换为纯存储黑盒综合视图，DC 实际确认恰好两处；ECC/控制仍综合 | 后续绑定真实宏模型；禁止行为数组回流综合 |
| RTL-ARITH-001 | closed | Sign 运行时除数改为常数选择；NTT 46 位 DSA 取模改为有界三次折叠 | 保留全域 HighBits 和 200000 个取模边界/随机比较；性能流水化按 P01 跟踪 |
| RTL-FAULT-X-001 | closed | 删除以 case equality 吞掉未知故障的非硬件语义，使用普通 OR；已知故障压过未知输入的 UT 通过 | 保留 RTL 和综合语义一致的故障优先级检查 |
| RTL-SIGN-BUDGET-001 | closed | ML-DSA-87 每尝试预算从不足的 1500000 调整到 2250000；44/65 保持 1500000 | 保持固定公开每尝试周期、独立 oracle 尝试数与错误 IRQ 立即失败 |
| SYNTH-PERF-001 | open | Sign/codec 仍存在多份常数除法网络；映射慢，尚不能根据中间成本表认定最终面积或 WNS | 读取最终映射报告再处理窄位宽/资源共享/流水化，保留失败日志 |
| SYNTH-FLOW-001 | closed | 综合结果校验改读 DC 实际 synth.log 及完整 mapped artifacts，避免 Edalize 隐藏 stdout 导致误判 | 执行成功不代表 timing/DRC/G3 通过；旧 wrapper 结果不修改 |
| RTL-ALERT-001 | closed | TOP source-specific ECC/tamper/selftest 告警 hwset 已接；故障/控制 UVM 12/12、模块 UT 45/45、lint 通过 | 继续独立跟踪其余告警来源和执行中故障注入，不将 idle 子集扩为全安全签核 |

## 证据与复现

运行入口见 [验证说明](../verification/sim/README.md)。证据全部在 build 下并绑定 SHA-256；
source-px0msrzs 是算法与综合基线。当前 RTL 唯一差异是 TOP 的四个告警字段 hwset
连接，完整差异由 alert_delta.json 核验；算术、调度、时钟与存储 RTL 均不变。当前 RTL
与 source-rl1kkc0c/pqc 一致；source-d9mlyjan/pqc 仅进一步修正验证参考模型。副本目录旧名 ip 导致模块 UT 元数据 ip_name=ip，
不得手改为 pqc 或直接冒充根 Gate 结果；未来 freezer 已保留 pqc 目录名。
历史 timescale、UT marker、隐式 net、越界切片、Sign 预算、低 effort DC 崩溃及超时均保留。
报告哈希提取只证明内容与运行证据一致，不代表发布通过。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ip_summary
ip_name: pqc
status: blocked
conclusion: 六类 KEM/DSA 数据通路已完成候选集成，算法基线 UVM 11/11、159 条命令通过；最终告警修复的故障/控制 UVM 12/12、模块
  UT 45/45 和 lint 通过。综合仍待最终报告，Level 2、技术冻结及 G3–G5 未闭环，当前不可发布。
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
  summary: 全 IP FuseSoC lint 与参数 elaboration 通过；综合及 CDC/formal 专项仍待闭合
  next_action: 保留宏边界并依据最终综合数据处理面积/时序；补安全专项
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
  summary: 六类算法端到端 KAT 已实现；完整 VPLAN、安全负向与覆盖率仍缺
  next_action: 扩展完整计划及 closure RTM，不用单 seed KAT 替代签核
- id: ISSUE-005
  status: closed
  summary: 按用户要求已启动不包含行为 SRAM 的诊断综合；不以本轮结果宣称物理 PPA 达标
  next_action: 实际宏及 SoC 约束到位后另行进行物理表征
- id: ISSUE-006
  status: open
  summary: 机器 G2 的结构与 CSR 一致性检查通过；完整 LLD 技术项及 VP0 仍未闭环
  next_action: 补完整算法/掩码/逐拍调度与验证计划；结构检查不替代技术评审
- id: ISSUE-007
  status: open
  summary: KEM/DSA 六类算法、WORKKEY 消费与生成密钥托管 ACK 已实现候选集成；Level 2 与系统安全仍未闭环
  next_action: 完成授权/epoch/撤销/清除/故障和完整安全数据通路验证
- id: SUITE-001
  status: closed
  summary: HLD 必需需求覆盖已补齐，当前投影与来源一致
  next_action: 84/84 全需求归属与引用检查通过；不等于 G1 或 RTL 通过
- id: SUITE-002
  status: open
  summary: 27 个 LLD 模块具有 RTL 链接，新数据通路对象已补齐；完整技术冻结仍缺
  next_action: 完成掩码、转换、页授权及逐拍性能义务
- id: SUITE-003
  status: closed
  summary: 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过
  next_action: 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL
- id: SUITE-004
  status: open
  summary: 当前 RTL 冻结副本的 45 项模块 UT 全部通过；完整 G3 模块证据与专项仍待闭合
  next_action: 保留源指纹和副本身份，不把 UT 子集等同发布签核
- id: SUITE-005
  status: closed
  summary: TOP 参数 initial/$fatal 已用 synthesis translate_off/on 隔离；三合法、两非法配置验证通过
  next_action: 保持非法配置仿真拒绝及综合排除诊断行为
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
  summary: 六类算法输入、共享计算、输出、completion 与 IRQ 已接通；系统异常退休仍需补齐
  next_action: 补故障、取消、超时、撤销并发的端到端检查
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
  summary: 完整 KEM/DSA 密钥、密文、签名算法路径已集成；任意 offset 与全部编码负向仍待覆盖
  next_action: 保留独立数学 oracle 并完成完整格式边界
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
  summary: word_valid 已改成有界物理页 bank；所有 96 tag 索引及 64 物理页失效检查通过，完整授权仍缺
  next_action: 补 representation/algo/pset/secret/owner 组合访问校验
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
  summary: 完整 Pure ML-DSA Sign/Verify 候选调度、独立签名与尝试次数检查已实现；独立冗余身份/norm 检查及安全闭环仍缺
  next_action: 固定每尝试公开预算，补故障注入、独立结果身份与 Level 2
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
  summary: 六参数集的 18 种操作/参数组合已进入真实 RTL UVM；全量负向、安全、覆盖率和 VP0 未闭合
  next_action: 按完整 VPLAN 补场景，不把候选 KAT 子集当全计划通过
- id: EVIDENCE-001
  status: open
  summary: 算法基线 159 命令已绑定；当前 RTL 仅增加 TOP 告警 hwset，修复回归与基线分开保存
  next_action: 保留 alert_delta.json 精确差异与分阶段来源，不补签旧日志
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
  summary: runner 检查六算法完整标记与真实故障完成标记，35 项自身故障注入测试通过
  next_action: runner 测试不计入 DUT 算法通过数
- id: UVM-BUILD-001
  status: open
  summary: 根 Core/filelist/真实 runner 已同步，六算法用例可执行；完整 FuseSoC VIP 依赖和 coverage 仍缺
  next_action: 闭合 AXI4 VIP、覆盖采集与参数功能执行
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
  summary: 六类算法正常完成和 KEM 隐式拒绝已接通；全异常、非法和控制命令尚未闭合
  next_action: 验证取消、故障、超时有界完成及 SELF_TEST/ZEROIZE
- id: UVM-KEY-001
  status: closed
  summary: 纠正安全特权 PPROT=001，覆盖全部8组合、拒绝读零与无写副作用及只读元数据
  next_action: 本结果只覆盖 CSR 窗口，不替代可信密钥域/epoch/生命周期验证
- id: RTL-SRAM-SYNTH-001
  status: closed
  summary: 工作 SRAM 与 WORKKEY 均替换为纯存储黑盒综合视图，DC 实际确认恰好两处；ECC/控制仍综合
  next_action: 后续绑定真实宏模型；禁止行为数组回流综合
- id: RTL-ARITH-001
  status: closed
  summary: Sign 运行时除数改为常数选择；NTT 46 位 DSA 取模改为有界三次折叠
  next_action: 保留全域 HighBits 和 200000 个取模边界/随机比较；性能流水化按 P01 跟踪
- id: RTL-FAULT-X-001
  status: closed
  summary: 删除以 case equality 吞掉未知故障的非硬件语义，使用普通 OR；已知故障压过未知输入的 UT 通过
  next_action: 保留 RTL 和综合语义一致的故障优先级检查
- id: RTL-SIGN-BUDGET-001
  status: closed
  summary: ML-DSA-87 每尝试预算从不足的 1500000 调整到 2250000；44/65 保持 1500000
  next_action: 保持固定公开每尝试周期、独立 oracle 尝试数与错误 IRQ 立即失败
- id: SYNTH-PERF-001
  status: open
  summary: Sign/codec 仍存在多份常数除法网络；映射慢，尚不能根据中间成本表认定最终面积或 WNS
  next_action: 读取最终映射报告再处理窄位宽/资源共享/流水化，保留失败日志
- id: SYNTH-FLOW-001
  status: closed
  summary: 综合结果校验改读 DC 实际 synth.log 及完整 mapped artifacts，避免 Edalize 隐藏 stdout 导致误判
  next_action: 执行成功不代表 timing/DRC/G3 通过；旧 wrapper 结果不修改
- id: RTL-ALERT-001
  status: closed
  summary: TOP source-specific ECC/tamper/selftest 告警 hwset 已接；故障/控制 UVM 12/12、模块
    UT 45/45、lint 通过
  next_action: 继续独立跟踪其余告警来源和执行中故障注入，不将 idle 子集扩为全安全签核
evidence:
- path: build/reports/quality/quality.yaml
  sha256: bec1eae8416237d30f8947beaa5dfef8f2041bcfef4d86c6f66917ebcece4362
- path: build/reports/quality/trace_matrix.md
  sha256: b06300d335cc95b2c05a5e033370b37b798180be64e90ac42d734ca8269de336
- path: build/dsa_integration/package_review.json
  sha256: f3ca27eb8c27716c26f31796522e62f2caea9e19c758f1a618ec5e0fc5aa1655
- path: build/dsa_integration/trace_review.log
  sha256: 5ee407f4f7b2141d7f4f33ff8c49294ccd8d8009f63d961e6b5044bb32a6da14
- path: build/dsa_integration/lint_review.json
  sha256: 1285237cec78996631bc85639e0d0afee2a07b0db9ca100527f618229f62fb61
- path: build/dsa_integration/parameter_elab_fixed/results.json
  sha256: 9af4e6d05bf9260a49bbe433e44bd5e222761678885d8fc1696204c37605f577
- path: build/dsa_integration/runner_pytest.xml
  sha256: 42ae8172d1b9a894d13e81d1bda799db6ae77beb8d9db0c1d4f951e7cd46b979
- path: build/rtl/review_lint_root/driver.log
  sha256: b90b8b86416b8550aa9fff1ceff7a97257312505a1682e86a02fe8bd3102e96d
- path: build/rtl/review_lint_root/exit_code.txt
  sha256: 9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa
- path: build/rtl/review_lint_root/inputs.before.sha256
  sha256: c044aa5096c9abf75c4fa08fe72648ec0eb93b671945b35dfb42f6b821fdac21
- path: build/rtl/review_lint_root/inputs.after.sha256
  sha256: c044aa5096c9abf75c4fa08fe72648ec0eb93b671945b35dfb42f6b821fdac21
- path: build/frozen/source-px0msrzs/source_manifest.json
  sha256: 896e2d5d46be88a1f82764e22e29240f51ed8a24fa38f38a2d7b22d99689135c
- path: build/frozen/source-px0msrzs/ip/build/reports/quality/module_ut_summary.md
  sha256: 28e6fa6101b9d94138e2cdcf39c1feefe84a03fba48a285f3c9275813b4b1098
- path: build/frozen/source-px0msrzs/ip/build/dsa_integration/final_ut_driver.log
  sha256: 39c5338b99d06538653dd699f47e659058912195084b1a0a1332b6e324950ba3
- path: build/frozen/source-px0msrzs/ip/build/dsa_integration/final_uvm.json
  sha256: bd9716bf220cb06e48ff4aeed417a02a67db70e52bec0c64cb724eede6db0f37
- path: build/frozen/source-px0msrzs/ip/build/sim/uvm/run-myr2tljw/junit.xml
  sha256: 3650c5e81978911c1d236a1f226ae53b0f47af73ee9085176ebe1c99291a2e3b
- path: build/frozen/source-px0msrzs/ip/build/sim/uvm/run-myr2tljw/inputs.before.json
  sha256: 743b9cb0be845fa9259e77dd77b227d96f189f8095b538cdd7d4bd660921686d
- path: build/frozen/source-px0msrzs/ip/build/sim/uvm/run-myr2tljw/inputs.after.json
  sha256: 743b9cb0be845fa9259e77dd77b227d96f189f8095b538cdd7d4bd660921686d
- path: build/dsa_integration/final_functional_review.json
  sha256: d457061639c57fbc3f58d80b81ac78513132ff49b9651877a7dffea0e043b1c9
- path: build/dsa_integration/fault_runner_pytest.xml
  sha256: 23056f58a6db57067d4519d86d0eb3648feb4eda3244cd53b9b24504cfc5173a
- path: build/dsa_integration/alert_delta.json
  sha256: eca73bcfd3c846e92c76a881c9597219dcbadc22121842ca37ad085c21112962
- path: build/dsa_integration/root_final_ut_cancelled.txt
  sha256: f1b981ceb128f1f5e455f75f9a1f6f06367b96d148ca6d5de0f931196d1b72da
- path: build/frozen/source-rl1kkc0c/pqc/build/rtl/alert_lint/driver.log
  sha256: 3246b8d0df76154d7c5f8b1630bb32c7c7ff48c99b342593785cd2ca792322c8
- path: build/frozen/source-rl1kkc0c/pqc/build/rtl/alert_lint/exit_code.txt
  sha256: 9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa
- path: build/frozen/source-d9mlyjan/pqc/build/dsa_integration/alert_uvm.json
  sha256: af4b4d714c1304a6288007c8ad04660fcec9dedbcfaa1dcbdb464f73f0edcab7
- path: build/frozen/source-d9mlyjan/pqc/build/sim/uvm/run-nivuxc8a/junit.xml
  sha256: 57f536ffec517de1c51f9d933205aa34979c1a0ee58b36d9569c5ed76461bf8e
- path: build/frozen/source-rl1kkc0c/pqc/build/reports/quality/module_ut_summary.md
  sha256: 850217b3179da0f10892e8d4e5bb7d9a923fc852766f73086c78112899c20bf4
- path: build/frozen/source-rl1kkc0c/pqc/build/dsa_integration/alert_ut_driver.log
  sha256: 53cbe626f393b952a53fcfc374c53810edfed9cd69b876d4b7005d3166892561
- path: build/frozen/source-rl1kkc0c/source_manifest.json
  sha256: 53d9d0df0cd375a201accce078daad27a166b57cdba343312dcd5f79c98afa96
- path: build/frozen/source-d9mlyjan/source_manifest.json
  sha256: b562afe7f4c9fd29adb7d274342d84caffc6002c1e5242ef0949b48ec862583f
END_IP_REPORT_METADATA -->
