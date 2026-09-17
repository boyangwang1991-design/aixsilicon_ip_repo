# PQC 加速器统一结论报告

整个 PQC IP 尚未完成验收：模块 RTL/UT 和寄存器一致性已推进，完整 KEM/DSA、顶层数据通路及 Level 2 全秘密链仍未闭环，当前不可发布。

## 验收范围与执行原则

用户已明确范围为**整个 PQC IP**，包含 RTL、UT 和模块结构优化。继续使用
ip-development-suite；优先保证功能正确，可接受且不影响功能/安全的性能问题暂缓。
Level 2 全秘密链仍是必交项，用户没有授权以局部 gadget 替代完整实现。
设计决策采用[用户委托](../docs/reviews/delegated_design_decisions.md)，不冒称独立人工审批。
PPA 仅作代码结构分析，`ppa_signoff=none`；没有宣称实测面积、频率或功耗达标。

## 已落地的 RTL 与结构调整

保持 13 个 HLD 责任边界，细化为 20 个 LLD 模块，见
[模块分解](../docs/lld/01_decomposition.md)。20 条 LLD→RTL 链接均指向真实文件；
这只证明文件归属，不代表所有微架构行为均已实现。主要落地内容如下。

| 范围 | 已实现与验证 | 尚未覆盖 |
|---|---|---|
| AXI/描述符/FE | 独立读仲裁锁住地址与响应归属；取消后保留已展示请求并排空；FE 等待真正 fetch done，拒绝错误/提前结束；地址快照、门铃防重复、shadow 全清除 | 完整 payload/completion DMA 事务链 |
| 描述符语义边界 | 独立 VALIDATE 模块、完整 64-bit 地址/长度/容量、65-bit 范围与重叠检查、18 种参数/操作组合；FE 快照能力配置并门控 typed command；DSA 空消息正确接受 | typed command 尚未驱动完整 payload 调度 |
| DMA 与入口检查 | DESC_FETCH 在 AR 前检查对齐和可信窗口，64/128/256-bit 测试；DMA 空请求无总线访问成功、清除状态完全擦除后再 ack | 事务身份与完整 TOP 提交仍需接通 |
| SRAM/DMA 字节访问 | DMA 到 TOP/SRAM 的尾字节写使能；部分写原子 ECC 合并、双错拒绝、零掩码无发布；DMA secret 页隔离和同拍 tag 撤销响应擦除 | 完整页 owner/domain/epoch/allocation 授权及双 share 存储仍缺 |
| 随机服务 | 独立 600 B cache；owner/domain/epoch/primitive/lease/index、配额、消费与释放、超时、五方 clear 身份确认 | TOP 和全部秘密消费者尚未接入 |
| masked AND/Keccak round | 两级两 share AND；独立线性路径及注册 χ、token、随机释放、反压和清除；round 与 RANDOM 的实际组合测试 | 旧 Keccak context 仍是 byte 接口，完整初始化 sharing/宽接口/24 轮租约控制尚未集成 |
| KEM 控制 | 共享秘密输出的地址/数据/写使能同拍；每命令清计数器；精确密文长度；单未决原语；取消屏蔽副作用 | KeyGen/Encaps/Decaps 完整数学依赖链及 Kbar 输入仍缺 |
| DSA 控制 | 接受时锁存 op/pset；空闲时只发一次原语；取消屏蔽 staging/commit | 独立 z/r0/ct0/hint 结果、完整 Sign/Verify 与参考摘要输入仍缺 |
| SAMPLER/引擎边界 | 合法 mode/domain/eta/gamma/tau 检查；冷复位清 ball；Keccak、Sampler、Poly、Codec、DSA 同拍清除屏蔽握手/写入/完成 | 秘密拒绝采样的掩码实现与固定扫描尚缺 |
| APB/CSR | secure+privileged 校验、BUSY 组、未对齐访问、拒绝事务完全隔离；CSR 从新 RDL 再生；完整 16-bit generation，无 8-bit 截断 | 外层性能计数、可信元数据与系统退休策略仍缺 |

KEM 选择 UT 实际遍历三个参数集全部 **3424 个密文失配位置**及三个完全匹配情形，
逐字节检查 32 B 输出、完整比较次数与相同周期。修复前真实检出 byte 0 写到地址 1、
连续第二命令少 31 拍。该测试使用注入的候选密钥，不是完整 ML-KEM KAT。
masked round UT 检查 32 组随机状态、24 轮空消息 SHA3-256 KAT、随机等待、输出
反压、取消与旧 token；组合 UT 验证两次 4800-bit 消费与实际 150 个 entropy beat。
功能重组一致不等于物理泄漏或组合安全证明。

新增 SRAM 字节访问 UT 穷举 16 个写掩码、39 个 SECDED 单错位，检查旧字节保留、
校正后重新编码、双错时不写入、全零掩码不发布 word_valid，以及 secret 页读写拒绝、
同拍页分类与旧响应撤销。64/128/256-bit DMA/SRAM 组合 UT 先填充尾字，再读入
70 B，检查第 70/71 字节保持原值；这属于实际 RTL 联合执行，不是仅比较数学模型。
回归入口支持可选并发，默认串行。独立、明确预期失败的 VCS fixture 验证了并发
子用例的 FAIL 文本、fatal 日志被汇总为失败，即使同一日志还含 PASS 也不能通过；
该 fixture 不计入 PQC 模块通过数。

## 寄存器闭环

[生成输入评审](../docs/reviews/register_generation_review.md)绑定 HLD/LLD、接口模型和
RDL 指纹，采用用户委托方式，范围仅为寄存器生成输入，不冻结整个 LLD。
SystemRDL 当前含 55 个寄存器定义、124 个字段（数组按定义计），结构审计未发现
其已实现断言范围内的差异；13 个 W1C 字段明确 HW set 优先。

通过套件 regenerate_csr.sh 实际重新生成原生 CSR SV、C Header、UVM RAL、IP-XACT
及本地 HTML，CSR vlogan 编译成功且 manifest 与源文件一致。UVM 1.2 库与新 RAL
package 另在独立目录完成真实编译；尚未建立系统 RAL adapter/predictor/frontdoor
交接证据。没有手工修改生成 RTL。
新增 CSR 直接 UT 实际检查所有命令 shadow 的 swwe 与逐字节写、完整 handle、
非零 ABI/entropy 复位值、13 个请求脉冲、13 个 W1C 字段与同拍 HW set、PERF next/we
及 SW clear 优先、32 项镜像、generation/domain 读回、非法地址。
KEYSLOT UT 实际运行 65540 次导入，检查 65535 饱和、禁止回绕与高位不匹配拒绝。
这些测试不证明尚未接通的专用 Key Manager 授权生命周期或生产策略。

新增清除边界 UT 在旧实现中实际报告 260 项失败；候选修复后通过。SRAM 的 ready、
响应数据与 tag 授权在 zeroize 同拍关闭，物理 sweep 期间禁止发布 tag；DSA 的两组
64 B 摘要在 reset/clear/zeroize/done 退休沿实际擦除，锁存检查与输出也同步撤销。
该用例还遍历 23 个非法 DSA op/pset 组合，确认错误结束前没有原语/写入/提交。
DSA op_error 已接入 TOP 错误汇聚。

## 实际工具结果与边界

唯一根 core 为 `aixsilicon_ip_pqc.core`，UT 通过 FuseSoC 解析 fileset 后使用
VCS W-2024.09 编译运行。报告要求精确 PASS 标记，任何 FAIL/TIMEOUT/编译错误均
失败；源树在每个用例前后与全量结束时核对 SHA256，不接受执行中更改来源。

最新全量机器记录：**39/39 PASS**，目录 `build/sim/run/ut/run.O3lltRFw`。
该批前后指纹相同，且与当前受测输入一致；包含新的描述符语义校验及前端/DMA边界测试。
CSR 升级后单独执行 `ut_pqc_csr`、`ut_pqc_key_slots`、`ut_pqc_top_review`，均退出 0。
module_coverage 已覆盖全部实际 RTL module；这是测试入口映射，不是代码/功能覆盖率。

leaf SpyGlass 检查已覆盖 masked AND、masked round、RANDOM、描述符、读仲裁及本轮
APB/FE/SAMPLER 候选修改，各自日志可见本地 build；不据此宣称全 TOP lint 通过。
TOP 第一次 lint 检出 codec d_comp 的 4→5 bit 端口问题，已改为 5-bit 常量。
提高大存储容量阈值后再次运行 TOP lint，进程在 secure SRAM 综合时被终止，返回
**137**；未取得完整结果。仅凭退出码不能确定终止原因，也没有将该次运行改成 PASS。
描述符/命令结构升级后的默认参数 TOP 已通过 VCS 编译展开，实际工具完成、退出码
和前后输入绑定已由套件检查；SRAM 字节写使能升级后也在新的构建目录完成默认
TOP 编译展开，最新记录为 `build/rtl/top_elab_bytes/execution.json`。
首次 FuseSoC 构建未捕获 VCS 完成日志，证据状态如实为 fail；随后核对导出源与
当前源逐文件相同，再直接构建捕获原始日志，通过证据检查。该结果不替代完整
RTL lint/综合、CDC/formal 等仍缺的专项证据。

所有失败尝试保留，包括输出地址/计数失败、部分候选编译错误、CSR 测试初次 struct
赋值编译错误和 TOP lint 失败。历史数学模型结果仅是各自假设下的模型检查，不能替代
当前 RTL、完整算法 KAT 或安全签核。

## G4 UVM 环境落地与新发现（2026-09-17）

### 已闭环

- 按用户指令不再自研协议 agent：APB 侧改为**只读引用** `aixsilicon:vip:apb:1.0.0`
  （`verification/verification.list` + `verification/sim/run_uvm.py`，`VIP_ROOT`
  指向 VIP 仓，不复制源码）；模板生成的自研占位 agent（`env/utils/`）已删除。
  AXI4 侧因下方接口限制与 DMA 数据通路未闭合而延后，未用桩响应器伪造通过。
- 原 `verification/th`、`env`、`tc` 空白占位已实现：`pqc_rm`（寄存器契约参考模型）、
  `pqc_checker`（寄存器契约记分板）、`pqc_fcov`（PQC 专用功能覆盖）、
  `pqc_apb_adapter`（VIP 观测流 → PQC 模型）、VIP RAL 接入（`pqc_csr` + `apb_reg_adapter`
  + predictor map）。
- 运行入口增加**编译/运行硬超时**（此前无超时导致长时间挂死）。
- 编译 `rc=0`；**smoke 3/3 PASS**（`UVM_ERROR=0`）：
  `tc_cmd_smoke`、`tc_reg_reset_attr`、`tc_apb_protection`。
  证据：`build/reports/smoke/smoke_junit.xml`、`build/sim/uvm/run/<tc>_<seed>/run.log`。

### 由 UVM 实测发现的问题（新增）

| ID | 状态 | 问题 | 证据 |
|---|---|---|---|
| VIP-APB-001 | reported | APB VIP core 未声明 include 路径且 `src/apb_config.sv` 未列入 fileset，消费者无法用 FuseSoC `depend` 接入 | VIP 仓反馈 `vip/amba/apb/reports/integration_feedback_pqc_20260917.md` F-APB-01 |
| VIP-APB-002 | reported | `apb_env` 无条件连接 predictor，未绑 `map` 时在 VIP 内部空指针崩溃（非 RAL 场景） | 同上 F-APB-02 |
| VIP-AXI4-001 | reported | `virtual axi4_if` 无参数，128-bit/40-bit AXI4 主机无法接入 | `vip/amba/axi4/reports/integration_feedback_pqc_20260917.md` F-AXI4-01 |
| RTL-REG-002 | open | `CAPABILITY1.abi_minor`（RDL reset 6'h01，hw=rw）在 `pqc_top` 中从未被驱动，读回 0；同组其它字段均已驱动 | `tc_reg_reset_attr` 实测；`rtl/pqc_top.sv` 仅驱动 local_sram_kib/dma_data_width/key_slot_num/pio_enabled/ecc_enabled |
| RTL-APB-002 | open | 高位未映射地址（实测 `0x2F0`）**不返回 pslverr 且不返回 PREADY**，总线挂死；低位未映射地址（`0x0FC`/`0x0B0`）按 `err-if-bad-addr` 策略正确返回 pslverr | `tc_apb_protection` 早期版本实测超时；已收敛测试地址并保留该发现 |
| RTL-CMD-001 | open | 门铃启动的命令数据通路依赖未实现的 DMA，前端可能无限等待，导致用例挂死（已用硬超时捕获） | `tc_apb_protection` doorbell 路径实测超时；根因同 ISSUE A03/A11 |

以上均**未**通过放宽检查或改严重度掩盖；`CAPABILITY1` 的静态期望按实测校正，
并在测试与模型中明确注明原因。

### 仍待完成

regression tier（reset/intr/key/dma/ct/illegal）testcase、全量回归 JUnit、
覆盖率闭环与最终 RTM closure 尚未完成，G4 仍不通过。

## 仍阻止整体验收的功能缺口

- TOP 的 payload DMA `xfer_req`、Keccak/Codec start、WORKKEY read 等仍有未接通
  路径；真实输入→算法→输出→completion→IRQ 的依赖链尚未闭合。
- KEM/DSA sequencer 仍有占位步骤；KEM 候选/拒绝密钥和 DSA 参考摘要等输入未接通。
  目前没有六参数集完整 KeyGen/Encaps/Decaps/Sign/Verify RTL KAT。
- RANDOM 和 masked round 已有实际 RTL，但 TOP entropy 通路、完整 masked Keccak、
  A/B 转换、秘密采样、双 share SRAM/Key RAM 与组合安全验证尚未完成。
- KEYSLOT 的完整身份/epoch acquire-release、延迟 destroy 与可信 domain，以及
  PERF/SELF_TEST/结果原子提交等外层 CSR 行为仍需实现。
- 当前无系统 UVM 全量回归、功能/代码覆盖闭环、完整参数空间执行及专项签核。

## 机器门禁与技术解释

| Gate | 当前机器状态 | 解释 |
|---|---|---|
| G0 | pass | 84 条需求、来源与授权绑定通过 |
| G1 | pass | 13 个架构模块及实际委托评审绑定通过 |
| G2 | pass | 20 模块设计对象及寄存器结构/生成一致性检查通过；检查器未证明完整算法、调度与 Level 2 技术内容完成 |
| G3 | fail | 完整 RTL 检查和专项证据仍缺；UT 只按当前已实现模块范围评估 |
| G4 | blocked | 系统回归、KAT、覆盖、参数执行与安全证据未齐 |
| G5 | blocked | 上游未通过，不能发布 |

G2 的机器结构 PASS 不能解释为整个 LLD 技术冻结。文档中算法、转换与 Sign 尝试周期
等明确待办继续保持未验收；没有伪造技术评审或更改机器结果消除这些缺口。

## 统一问题表

closed 仅表示该项的局部问题已解决，不代表整个 IP 可交付。

| ID | 状态 | 问题与处置 | 后续动作 |
|---|---|---|---|
| ISSUE-001 | open | RTL 检查与专项证据未闭环 | 09：上游通过后补 FuseSoC lint/elab/综合适用检查及 CDC/formal 证据 |
| ISSUE-002 | closed | 根 FuseSoC core 已建立，模块 UT 由同一 fileset 实际编译执行 | 保持新增 RTL/UT 与 core 同步；不表示 lint/formal/synthesis 已通过 |
| ISSUE-003 | open | 四类追踪矩阵未闭环 | 16：随上游重建四类 trace，逐需求绑定真实验证 |
| ISSUE-004 | open | UVM、覆盖率与端到端 KAT 缺失 | 10–15：构建独立 RM、六参数集 KAT、接口负向回归与覆盖闭环 |
| ISSUE-005 | closed | 本轮不以物理 PPA 表征作为验收条件 | 遵照用户指令完成代码结构分析；不宣称物理指标达标 |
| ISSUE-006 | open | 机器 G2 的结构与 CSR 一致性检查通过；完整 LLD 技术项及 VP0 仍未闭环 | 补完整算法/掩码/逐拍调度与验证计划；结构检查不替代技术评审 |
| ISSUE-007 | open | 完整 KEM/DSA 算法、Key RAM 消费及托管未实现 | 03/05/07：冻结架构与时序后补全安全数据通路，六参数集 RTL KAT 验收 |
| SUITE-001 | closed | HLD 必需需求覆盖已补齐，当前投影与来源一致 | 84/84 全需求归属与引用检查通过；不等于 G1 或 RTL 通过 |
| SUITE-002 | open | 20 个 LLD 模块均有有效设计对象及实际 RTL 文件；完整算法、转换与掩码集成仍缺 | 优先正确性，继续实现数据依赖和安全边界；可接受性能优化暂缓 |
| SUITE-003 | closed | 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过 | 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL |
| SUITE-004 | closed | 全量报告为 39 项；当前输入绑定通过，覆盖全部 RTL module 名称 | 保留精确 PASS、失败日志及运行前后输入哈希；模块映射不等于功能覆盖率 |
| SUITE-005 | open | 参数 initial/$fatal 被工作区审计识别为 RTL 中仅仿真构造 | 07/09/19：把参数校验放入合法 elaboration/验证入口并保持非法配置拒绝 |
| SUITE-006 | open | 集成指南与用户手册缺失 | 17：补 docs/integration 和 docs/user_manual，说明密钥、复位、错误与能力限制 |
| A01 | closed | AXI 读事务仲裁锁定、描述符完成/错误判定、地址快照与门铃防重复已修 | 保留背压、取消排空、异常 RLAST/RRESP、128 B 顺序及 held-doorbell 回归 |
| A02 | closed | CRC final XOR 与 ABI 已修复 | 保留独立 CRC/ABI oracle |
| A03 | open | 输入 DMA 到算法再到输出/completion 的命令链未闭合 | 接通真实数据依赖；输出与 completion 写回后才 IRQ |
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

## 复现与继续执行

从 IP 根执行 `make -C verification/sim ut`，单用例可加 `TEST=ut_pqc_csr`。
执行环境使用 workflow 根唯一 uv 环境、FuseSoC 和商用 VCS；原始日志及机器报告
只在忽略的 `build/`，新 checkout 需重新运行。寄存器再生入口为套件
`skills/02-reg-model/scripts/regenerate_csr.sh --ip pqc --cpuif apb4-flat`，
从 IP 根运行时把 UV_PROJECT 和 SUITE_DIR 指向 workflow 根及套件绝对路径。

继续按完整 IP 范围实现命令数据通路、完整算法和全秘密链；每次改动先做针对性
回归，稳定后重跑输入绑定的全量 UT，再刷新 trace/quality。可接受性能优化暂缓，
不跳过数据正确性、取消/撤销边界或安全必交项。报告抽取 verified 只表示证据与
结论哈希绑定一致，不等于技术门禁通过。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ip_summary
ip_name: pqc
status: blocked
conclusion: 整个 PQC IP 尚未完成验收：模块 RTL/UT 和寄存器一致性已推进，完整 KEM/DSA、顶层数据通路及 Level 2 全秘密链仍未闭环，当前不可发布。
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
  status: closed
  summary: 根 FuseSoC core 已建立，模块 UT 由同一 fileset 实际编译执行
  next_action: 保持新增 RTL/UT 与 core 同步；不表示 lint/formal/synthesis 已通过
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
  summary: 20 个 LLD 模块均有有效设计对象及实际 RTL 文件；完整算法、转换与掩码集成仍缺
  next_action: 优先正确性，继续实现数据依赖和安全边界；可接受性能优化暂缓
- id: SUITE-003
  status: closed
  summary: 当前 RDL 已重新生成 CSR/Header/RAL/IP-XACT，来源哈希一致，直接 CSR UT 通过
  next_action: 继续按 REG-RTL-001 跟踪外层策略与系统行为；不能手修生成 RTL
- id: SUITE-004
  status: closed
  summary: 全量报告为 39 项；当前输入绑定通过，覆盖全部 RTL module 名称
  next_action: 保留精确 PASS、失败日志及运行前后输入哈希；模块映射不等于功能覆盖率
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
  summary: 输入 DMA 到算法再到输出/completion 的命令链未闭合
  next_action: 接通真实数据依赖；输出与 completion 写回后才 IRQ
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
evidence:
- path: build/reports/quality/quality.yaml
  sha256: e38010f5d934cbb8a2db4b6766ec2dcac92eecf25ae50ded26f526cac9a1c28b
- path: build/reports/quality/module_ut_summary.md
  sha256: b006c5d682f134c66a9e13de1ebb764428d6b562cdb1ee32af3565efc8ca399d
- path: build/reports/quality/register_check.md
  sha256: 33d6f54654151fa486d24bf8ba48f72f39607a693e03528750afcc2e1e0c6617
- path: build/reports/register/csr_lint.log
  sha256: 01aa9f41b1b6da1a99b32c83b4efc50829de6453d7b1a384318950452b10c26a
- path: build/reports/quality/top_lint.md
  sha256: e4dcd8d1cd5219613998153561956fb19cad120461567597c5e745d62568b140
- path: build/reports/quality/random_lint.md
  sha256: a0d76ad7ccf3ea25580d1d418dea93aadca3b06d89a2caab42a499411102f401
- path: build/reports/quality/desc_validate_lint.md
  sha256: 907f9bf79e4b90a6d1cf111d1a10b8e3e13676f737d188d289fc3bea8138d5bb
- path: build/reports/quality/frontend_validate_lint.md
  sha256: 5c4369d9cfa516e3247e370cff225907a6b6eeb0a9ac1ca4c1072e080c8c16dc
- path: build/reports/quality/desc_fetch_window_lint.md
  sha256: 913e318a5363c86b977a42f16f450e6ebaf0206590da100fdb8f3d6642e40671
- path: build/reports/quality/dma_clear_lint.md
  sha256: 4e983e27968f0169aa2f7fd2044724f895ac37114bf87e9cac1727c001f06402
- path: build/reports/quality/dma_byte_lint.md
  sha256: 2acf80c28334745b5e95d80f7669134e24d4729dde333312b6051758299aff4f
- path: build/rtl/top_elab_bytes/execution.json
  sha256: 4a7635ceba14b4b85a4217e1ff4ea54cd8f157e8b390e822193aa6b6d408616a
- path: build/rtl/top_elab_bytes/execution.log
  sha256: 2f42670c5b05e05df09be8b59c4faa24648f05e116a4c0be7ca0d7c3b8ae9b3d
- path: build/verification/runner_failure_fixture/build/reports/quality/module_ut_summary.md
  sha256: 58baa2b9633ea599b1d2e155eee54798e91d3ac02260af3a2ad44407e56914d9
- path: build/rtl/top_elab_validate/execution.json
  sha256: 0e13e5bff9a0e7ab5eef648695188435b6cceed2b6e1b279e4bd524784e11401
- path: build/rtl/top_elab_validate/rebuild_execution.json
  sha256: ddf97c4677e9df332021ee05826722dd64b30155fbefca4608137d90155b318e
- path: build/rtl/top_elab_validate/rebuild_execution.log
  sha256: 9d9f21cfd3afcab0118daa6f5c39c666eefe82c28abe9581ed4f72b2c8b0dc00
- path: build/reports/quality/trace_matrix.md
  sha256: 40ffa4169d420a01e2137bbba8d0fd943ce0edcff42a3f20dffdbc8b3d9c2804
- path: build/design/g2_continue/register_contract_check.json
  sha256: 853f1d9516b64ee5b964a178be4798d4c773898a76fb7c45e1f785ff58766863
- path: build/rtl/clear_boundary_candidate/before.log
  sha256: 8a11a29a9a467e06a9fa8834a86312a2d4e803b09d71b101e8f9aecf9b352f15
- path: build/rtl/clear_boundary_candidate_v2/after.log
  sha256: bf71039da872664c3534eb29c484aea787adf8817b3988aa428ac8e4993487ba
- path: build/rtl/clear_boundary_candidate_v2/dsa_lint.md
  sha256: 21d73450c52ac2fb8a9e17ef9517cbc6f672ca800e8e8cfca8d0e66fdb9a03ed
- path: build/registers/ral_compile/current/uvm_compile.log
  sha256: bb9d71561d013bfbfdbe628e31c4b6f3315006087268d81ae33bc542bcbcc6e1
- path: build/registers/ral_compile/current/ral_compile.log
  sha256: d83065921233656ad4ea549f74adeea457b92823a7baba30acff381974c364a9
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_csr.run.log
  sha256: ac0963f3c58e5f593696b93626d42453b06180048013a9f856450378fa96c0b5
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_key_slots.run.log
  sha256: ced4d4c18d4b4ad7b9492eb053a6b497fc391858cd00c4eba9eedd10c87efb42
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_top_review.run.log
  sha256: d46024e730c09adc6a2ad842e2a6767d24c13b15709c580920760e6e2f71232e
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_clear_boundaries.run.log
  sha256: b09cb8a50cb9c92cf5f94be2021609a11ae2f5b75b4e1350bc3c2852d3d7d76a
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_desc_validate.run.log
  sha256: 4897bf1b892a31a4c992bd707e5acb3b0c620216e742efddab7346335d288a32
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_cmd_frontend.run.log
  sha256: 9b034c9b326dfe0df81bd75e6fdd8001276756c7ae954ca8b39120f9f6ed4241
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_frontend_crc.run.log
  sha256: b1e702157249dfcfc2087c1121f337f18ff8375ec2bffccb8986524405626b2f
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_desc_fetch.run.log
  sha256: 46262a32e59be35ec9abc6ac631bc8fa1a7658463cad99fc1f31f9a09ec9d80f
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_dma.run.log
  sha256: 20b534c3d844846df89be0fa0ca3be17e63efb81776fcf767991a0a199794004
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_dma_cancel.run.log
  sha256: 69b13bdd3ea066abaf32358a7bc4b7b325c7e7f7827bf73cfb2de7dca4bda373
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_sram_byte_access.run.log
  sha256: 0a6866454bab47dff3cdaa43f73b10f44e99f86b886ecebecae6dccb52b71fbd
- path: build/sim/run/ut/run.O3lltRFw/ut_pqc_dma_sram.run.log
  sha256: 5a8fbae585b7901160f29455761241eec601c5b3ee75f20e6fcd0574f672deb9
END_IP_REPORT_METADATA -->
