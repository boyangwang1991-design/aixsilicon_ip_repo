# 安全 APB Demux 验证方案

<!-- VPLAN_META
schema_version: '2.0'
ip_name: apb_secure_demux
ip_display_name: 安全APB分发器
delivery_model: parameterized
lrs_baseline: ASD-LRS-1.0.0-USER-APPROVED
hld_baseline: ASD-HLD-1.0.0-USER-APPROVED
lld_baseline: docs/reviews/g2_behavior_approval.md
verification_level: full
document_version: 1.0.0
status: draft
verification_baseline: ASD-VPLAN-1.0.0-DRAFT
END_VPLAN_META -->

## 范围与准入

G0/G1有用户批准，LLD/字段行为有本轮明确批准，G2已具备原生寄存器及接口探针证据。此前CSR探针仅是生成器接口检查，不能充当以下IP用例已通过的证据。当前VPLAN为待评审计划，没有为新增验证方法/覆盖义务代填批准。

全流程覆盖全部169条需求，包含安全功能、两时序模式、全部参数开关、非二幂及边界、软件可见寄存器行为、系统信任假设、形式性质与四个PPA点。系统与工艺证据缺失仍是阻断项，不把它们合并为一个RTL仿真PASS。

## 验证顺序与回归

先执行每个独立RTL模块的Module UT、FuseSoC lint/elaboration/综合/形式检查并完成G3，再实例化UVM1.2环境。UVM smoke先验证reset、最小允许/拒绝、管理CSR和direct/register路径，失败立即停止。全量回归执行所有可达smoke/regression/extended用例，然后运行19-PV参数矩阵、覆盖分析、最终RTM和G4。

每个UVM用例全量运行时采用种子1、17、101；smoke先种子1，随机/竞争压力另用1001..1010。同一编译配置内可复用二进制，但须核对完整输入清单、参数/宏、工具版本和二进制哈希；不同配置独立构建与覆盖库。运行后核对RNTST为指定class，恰好一个UVM_TESTNAME；不把selector冲突当成功。

默认用例超时200000功能周期，长等待测试由sequence显式配置更小的可预期界限；形式/工具任务由runner设墙钟上限并保存timeout，不记为PASS。普通DUT没有等待超时取消，testbench不能期望DUT强制结束故意卡死的目标；此场景由测试控制目标恢复或可信复位，并分别验证恢复与复位行为。

## 验收

全部必需用例通过，无未解释scoreboard、协议断言或UVM_ERROR/FATAL。功能覆盖强制bins须100%命中或逐项获评审豁免；断言必须既无失败又有非空激活/完成覆盖。line、branch、condition、toggle、FSM状态/转移分别报告并分析所有未覆盖项，不以单一百分比替代安全性质。不存在预批准的覆盖排除。

拒绝无副作用、锁不可绕过、原子提交、onehot0必须有形式验证或可审计穷尽检查。随机仿真不能替代此证明。形式假设只约束可信输入协议与静态合法参数，不得假设DUT输出安全、锁永远不置位或软件永远授权。

受控IHI0024核验、X2P身份/属性绑定与无旁路证明、可信reset/DFX来源、实际PDK/SDC/corner和两模式典型/最大综合证据独立验收。正式签核需这些owner证据齐全，不能依赖fixture默认值。
