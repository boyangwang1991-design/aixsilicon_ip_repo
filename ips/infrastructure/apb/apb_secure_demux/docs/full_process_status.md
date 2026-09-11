# 安全 APB Demux full-flow 状态

G0/G1/G2已通过，最新用户批准“approve and proceed all process”作用于已核对40个输入的LLD/寄存器行为评审包。VP0已由后续用户“continue”批准并绑定53个输入哈希；功能RTL和十个模块UT已完成，G3检查进行中，full-flow尚未完成。执行授权持续有效。

| 交付项 | owner | 路径 | 当前证据或缺口 |
|---|---|---|---|
| 工作区与资产登记 | 00 | ip-package.yaml、IP registry | planned，未宣称implemented或released |
| LRS/G0 | 01 | docs/lrs | 169需求；CR-001～003已批准 |
| 参数合同 | 19-PC | model/parameter_space.yaml | 17参数、8命名夹具、75检查点含11负例；此前17个边界测试通过 |
| HLD/G1 | 03 | docs/hld | 九模块承接全部需求；用户批准 |
| LLD/字段行为 | 05 | docs/lld；docs/reviews/g2_behavior_approval.md | 9模块、19接口、122字段行为已批准 |
| 寄存器/G2 | 02 | regs；rtl/generated；sw/include；verification/ral；build/registers/html（仅本地） | 典型399/最大4503寄存器；历史8配置RDL/结构/regblock/vlogan通过（授权域元数据更新前）；当前典型多视图已刷新；非零reset夹具通过；VCS接口探针9笔通过；Header C11编译、RAL显式uvm_pkg编译通过 |
| VPLAN/VP0 | 06 | docs/verification | 16 feature、20 testcase、12性质、16覆盖义务；结构审计通过，VP0 approved；批准记录见docs/reviews/vp0_approval.md |
| 静态trace | 16 | trace；reports/quality/trace_matrix.md | REQ→HLD169、HLD→LLD9、REQ→Test411，无需求缺口；LLD→RTL九个链接已生成，尚非执行闭环 |
| 功能RTL/UT/封装/静态检查 | 07–09/ut/G3 | rtl、verification、core、reports | 九逻辑模块功能RTL已实现；十个FuseSoC/VCS模块UT全部通过。SpyGlass已有0 Fatal/0 Error，当前输入重绑及告警评审待完成；28nm DC修正后重跑中；G3未关闭 |
| UVM/回归/参数执行/覆盖/RTM | 10–16/19-PV/G4 | verification、reports、trace | 尚未实施；CSR探针不是IP级UVM或形式证明 |
| 软件示例/集成与用户文档 | 17 | sw、docs/integration、user_manual | 最终交付待实现/验证闭环 |
| PPA/发布 | 20/18/G5 | constraints、reports、release | 本地28nm PDK_READY；10ns表征约束下DC重跑中。四点PPA及产品约束/系统证据未闭环；未发布 |
| SKILL改进 | 私有skill仓 | docs/apb-secure-demux-full-process-improvements.md | 持续记录实际缺陷、环境差异与验收建议 |

## 本轮环境与检查

原沙箱VCS无法连接许可证，获准沙箱外执行后elaboration及仿真通过。uv离线探针在沙箱外正常退出，随后pre-commit全部通过；历史超时日志保留，不改写为过去已成功。生成CSR语法pass不等于功能owner或综合pass。RAL首次仅传-ntb_opts缺uvm_pkg，显式先编译UVM1.2 package后通过。

十个模块UT已通过，完整报告见reports/quality/module_ut_summary.md；工艺映射重跑、STA、形式及UVM回归仍待后续真实检查。CR-004受控APB核验、CR-005系统/工艺输入与VIP G4/G5 PARTIAL资格缺口未关闭。没有提交、推送或发布。

## 下一步

沿用已批准VP0与全流程授权，完成当前输入的G3证据、八个命名配置顶层UT预检，然后推进UVM、回归、19-PV和PPA。当前参数预检不会冒充回归后的19-PV。所有门禁按实际日志、输入哈希和未关闭依赖判定。

## HTML 仓库卫生

按用户明确要求，PeakRDL HTML 整站已移入被忽略的 build/registers/html/apb_secure_demux；旧导出路径额外加入忽略规则。已核查原站点没有被 Git 跟踪或暂存，当前本地站点被忽略；发布证据索引排除所有站点资源。禁止上传 GitHub、Pages 或 Release。诊断与迁移记录见 reports/quality/registers/html_local_only.json。
