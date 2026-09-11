# GPIO full process 执行状态

当前正在执行RTL检查和模块单元测试，完整流程尚未完成。

| 阶段 | 当前结果 | 证据或产物 |
|---|---|---|
| 00 环境 | 已检查，使用根uv环境及本机商业EDA | reports/preflight/ |
| LRS / G0 | 已批准，258项需求 | docs/lrs/、model/requirements.yaml |
| 参数合同 PC | 20参数、269配置静态检查通过；不是硬件PV | model/parameter_space.yaml |
| HLD / G1 | 用户已批准 | docs/hld/ |
| LLD / G2 | 委托批准；结构与CSR生成检查通过 | docs/lld/、reports/quality/register_check.md |
| 寄存器 | 753实例地址/名称一致，110字段行为引用齐全；CSR编译通过 | regs/gpio.rdl、reports/registers/contract_structure.json |
| VPLAN / VP0 | 委托批准，15用例、8类SVA，需求规划无gap | docs/verification/、model/verification.yaml |
| RTL | 包含顶层的12个设计模块已有candidate；FuseSoC/VCS默认配置elaboration通过 | rtl/、aixsilicon_ip_gpio.core |
| SpyGlass | 裁剪parity锁存推断已修复；重检0错误、4067告警，告警未闭环 | build/rtl/lint_fix1/ |
| Module UT | 顶层基础自检与event FIFO两项通过（errors=0）；没有全量通过证据 | verification/unit_test/、build/sim/ut/ |
| UVM/PV/coverage/G4 | 未完成 | 需继续实施全部计划 |
| PPA | 已扫描到本机28nm库；尚未综合签核 | model/pdk.yaml（本地工艺上下文） |
| 文档/发布/G5 | 未完成；没有提交、推送或上传发布物 | 后续按完整流程继续 |

用户先委托LRS自动审批，随后明确 `approve, complete the rest` 并要求 `continue`。
设计阶段记录为用户委托批准，不冒称独立人类评审；测试、覆盖率和物理门禁只接受真实证据。
当前quality模型需在RTL/验证证据齐备后重算，不可将上游通过解释为整个IP通过。

## GitHub上传边界

根据用户明确约束，PeakRDL HTML完整站点仅位于build/registers/html/gpio/，不提交或发布。
99个逐分册extract过程日志已迁入build/design/extraction_logs/，不进入GitHub或发布包。
正式canonical模型、最终审计报告与门禁所需证据按合同保留；原始gpio_contract.md未修改。

## 复用

parity CBB以FuseSoC depend引用，原core缺paramtype导致解析失败，采用build/cbb_adapter/
临时元数据适配器只读引用原RTL。此适配不宣称原CBB元数据已修复，也不进入发布物。
