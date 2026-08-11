# MCDMA-style Run Log

> 增量运行日志：每个阶段结束时立即追加，不等全流程结束。
> 格式：`## <UTC时间戳> · <门禁> · <PHASE/action> · <STATUS>`

## 2026-08-11T07:46:31Z · workspace · PASS
- summary: 初始化 ip_uart 工作区 + uv 环境 + 脚本模板
- detail: 目录结构、pyproject/uv.lock/.venv、scripts/{init,setup,check_tools}.sh、env_check_report.md；EDA: vcs/verdi/spyglass PASS, dc_shell version cmd fail, vc_formal missing

## 2026-08-11T07:49:16Z · lrs · PASS
- summary: 编写 LRS 9 文档 + 抽取 42 条需求
- detail: docs/lrs: index/00/01/02/03/04/06/08/10；extract_requirements 校验通过；LP/SEC/DFX 声明 N/A；参考 OpenTitan uart.hjson/theory_of_operation；APB 接入新增 INTF.01.003

## 2026-08-11T07:51:36Z · reg_model · PASS
- summary: SystemRDL + PeakRDL 生成 CSR/C header/HTML/IP-XACT
- detail: regs/uart.rdl 14 regs 与 uart.hjson 一致；apb4-flat CSR vlogan PASS；register_check.md；核心 RTL 保持 OpenTitan 原版

## 2026-08-11T07:54:43Z · hld · PASS
- summary: 编写 HLD 9 文档 + 抽取 5 个 canonical 模型
- detail: 6 L1 模块、7 外部接口、3 域、0 CDC；42 条需求全覆盖校验通过；complexity=simple；APB 接入列为独立模块 apb2tlul

## 2026-08-11T07:55:33Z · lld · PASS
- summary: 编写 LLD 3 文档 + 抽取 micro_design.yaml
- detail: 6 模块、4 FSM（含 apb2tlul 五态桥 FSM）、10 中断、0 CDC；核心模块不改，apb2tlul 为新增；RTL TODO 列表已输出

## 2026-08-11T07:57:51Z · verification_plan · PASS
- summary: 验证方案 6 文档 + 抽取 verification.yaml
- detail: 6 features、7 testcase（≤简单上限 7）、6 coverage、6 assertion；must 需求全覆盖；vplan_check.md PASS

## 2026-08-11T08:26:31Z · rtl_gen · PASS
- summary: 纳入 OpenTitan 原版 UART RTL + 新增 apb2tlul/uart_apb_top
- detail: 核心 6 文件哈希一致未改动；公共库统一入 ips/lowrisc 并建 .core；VCS vlogan 通过；elab uart 与 uart_apb_top 通过；trace-seeds 生成

## 2026-08-11T08:27:59Z · fusesoc · PASS
- summary: 创建 FuseSoC core + 公共库统一入库
- detail: fusesoc/rtl-team_ip_uart.core 8 targets（default/apb/lint/elab/sim/smoke/synth/formal）；depend lowrisc:prim:all/tlul/top:constants；FuseSoC 2.4.6 解析通过；package_check.md

## 2026-08-11T08:55:00Z · G3 · rtl_check/lint · PASS
- summary: SpyGlass lint: 0 fatal 0 error 225 warnings(上游豁免)
- detail: 降级路径（FuseSoC 2.4.6 _solve bug）；spyglass.log sha3a4fbe2a

## 2026-08-11T08:55:10Z · G3 · rtl_check/elab · PASS
- summary: VCS elab: uart 与 uart_apb_top 通过
- detail: vlogan 全文件通过；elab log sha531b2cd3；rtl_check_summary.md REPORT_META 生成

## 2026-08-11T08:55:41Z · uvm_template · PASS
- summary: 实例化 UVM 模板（uart/tlul/apb 三 agent，flat 模式）
- detail: instantiate_template.py：88 修改/68 重命名/5 创建；无残留占位符；sim/Makefile 生成

## 2026-08-11T09:46:00Z · 11-protocol-agent · PASS
- summary: 重写 UART/TL-UL/APB 协议 agent + checker 多 analysis imp
- detail: tlul/apb/uart dec/interface/xaction/driver/monitor 重写；slave_driver 修复 slv_cb→mon_cb；sequence_library 适配 xaction 字段；monitor_cov 按 uart 字段实现；checker 扩展 _act/_exp/_tlul/_apb 四 analysis imp；env_package 包装 + env.list/verification.list 重构；VCS lint agent/env/tc 全部 PASS

## 2026-08-11T09:54:35Z · 12-env-rm-checker-cov · PASS
- summary: Env/RM/Checker/Coverage 完整实现 + harness 更新 + 完整 elaboration
- detail: uart_rm.sv WDATA→TX 行为建模（ctrl_shadow/tx_en/parity）；uart_fcov.sv 6 covergroup（baud/frame/fifo/error/mode/reg_access）；checker 三路径比对（act/exp/tlul/apb）；env 连接 RM↔checker；harness 双 DUT（uart TL-UL + uart_apb_top）+ 3 interface + config_db；check_uvm.f/verification.list 根相对路径 + RTL libs incdir；VCS 完整 elab 72 模块 PASS（simv 生成）

## 2026-08-11T09:59:00Z · 13-sequence-testcase · PASS
- summary: 7 个 testcase + vseq 开发完成，阶段二完整 elaboration PASS
- detail: test_matrix 7 用例映射：tc_uart_smoke/tx_rx/error/fifo/csr/perf/alert；uart_virtual_sequence.sv 7 个 vseq（含 tlul/apb/uart helper + wait_reset）；tc_base 配置 3 agent + uvm_root timeout；tc.list/check_uvm.f 更新；VCS lint tc PASS + 完整 elab simv 生成

## 2026-08-11T10:53:20Z · 14-build-run · PASS
- summary: 全 7 testcase 回归通过（0 ERROR / 0 FATAL）
- detail: 修复 TL-UL 握手（a_valid clocking 传播 + 双沿采样）；完整性 get_cmd_intg/data_intg 生成；CTRL SLPBK bit3 修正；RXLVL 轮询改有界；smoke/tx_rx/error/fifo/csr/perf/alert 全部 PASS；simv 已生成

## 2026-08-11T10:54:00Z · 16-trace · PASS
- summary: 四份追踪矩阵生成，0 gap
- detail: build_trace.py：req_to_hld=45, hld_to_lld=6, lld_to_rtl=7, req_to_test=120；gap_analysis 全部为空；reports/quality/trace_matrix.md 生成

## 2026-08-11T11:04:45Z · 15-quality-review · PASS
- summary: G0-G5 全 pass + 评审输出齐全
- detail: DC synthesis 补跑（check_design 0 error，dc_shell V-2023.12-SP3）→ G3 闭合；junit.xml/smoke_summary/testbench 创建 → G4 pass；review_findings/docs/integration/docs/user_manual → G5 pass；signoff_checklist/dashboard/uvm_review/coverage_review 生成

## 2026-08-11T11:06:05Z · 17-documentation · PASS
- summary: 集成指南 + 用户手册 + 寄存器编程指南 + 评审报告
- detail: docs/integration/uart_integration_guide.md + checklist；docs/user_manual/index + uart_register_programming_guide.md；reports/quality/integration_review.md + user_guide_review.md；G5 复算 pass

## 2026-08-11T11:08:35Z · 18-release · PASS (candidate)
- summary: 发布打包 candidate（266 文件，SHA-256 ee273811...）
- detail: build_release.py 生成 manifest + release_note + zip；因 ip_uart 未纳入父仓 git 跟踪（dirty）且缺 PDK 综合，按 candidate 发布并明确标注；排除浏览器 scratch（.launcher_data）后 0 scratch；archive 重开校验通过（无绝对路径/父穿越）

