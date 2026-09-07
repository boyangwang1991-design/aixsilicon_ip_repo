# MCDMA-style Run Log

> 增量运行日志：每个阶段结束时立即追加，不等全流程结束。
> 格式：`## <UTC时间戳> · <门禁> · <PHASE/action> · <STATUS>`

## 2026-09-03T13:14:19Z · workspace · PASS
- summary: ip_x2p 工作区初始化：标准布局 + uv(.venv/pyproject/uv.lock) + EDA profile commercial-systemverilog(VCS/DC/SpyGlass 就绪)
- detail: 环境报告 reports/quality/env_check_report.md；复用规划 docs/reuse_plan.md（CBB round_robin_arbiter 语义不匹配自研；VIP axi4/apb developing 不支撑 G4，self-contained）

## 2026-09-03T13:17:28Z · G0 · lrs · PASS
- summary: LRS 完成: 42 需求(INTF6/FUNC29/PERF4/CONS3) 抽取至 model/requirements.yaml, G0 PASS
- detail: extract_requirements.py validation PASSED; reports/quality/lrs_check.md; N/A 类别在 index.md 声明

## 2026-09-03T13:21:32Z · G1 · hld · PASS
- summary: HLD 完成: 7 L1 模块/6 外部接口/4 域/2 CDC 路径, 42 需求全覆盖, extract_hld 校验 PASS, G1 PASS
- detail: reports/quality/hld_check.md; 关键决策: Width Conversion 在 CDC 前; R/W 仲裁 Beat 粒度且 sub-transfer 原子

## 2026-09-03T13:23:07Z · G2 · lld · PASS
- summary: LLD 完成: 7 模块/3 FSM(SCH/TE/APB)/2 CDC/8 reset, extract_lld 校验 PASS, G2 PASS
- detail: reports/quality/lld_check.md; RTL TODO 列表在 docs/lld/02_verification_delivery.md §6; 内部事务接口 x2p_req/x2p_apb_req/x2p_rsp

## 2026-09-03T13:26:53Z · verification_plan · PASS
- summary: 验证方案 6 文档完成: 15 features/16 tc/13 as/9 cov, extract_verification 校验 PASS(所有 must 有验证对象)
- detail: reports/quality/vplan_check.md; RM=UVM x2p_scoreboard 唯一参考; VIP axi4/apb developing 不支撑 G4, self-contained

## 2026-09-03T13:46:24Z · G3 · rtl_gen · PASS
- summary: RTL 生成完成: 9 个 .sv 文件(顶层 x2p_top + 8 子模块), VCS -parse 解析成功
- detail: reports/quality/rtl_generation_report.md; filelist.f; trace-seeds/lld_to_rtl.yaml; 注意 VCS 链接缺 32bit lib(环境问题, 解析通过)

## 2026-09-03T13:48:34Z · G3 · fusesoc · PASS
- summary: FuseSoC core 创建: aixsilicon:ip:x2p:1.0.0, 6 targets(lint/elab/sim/smoke/synth/formal), core show 通过
- detail: reports/quality/package_check.md; colors: rtl_handwritten 9sv + rtl_includes; sim harness 后补

## 2026-09-03T13:50:43Z · G3 · rtl_check/elab · PASS
- summary: FuseSoC elab 通过: x2p_top elaboration 成功(Time 0, 无 error)
- detail: build/aixsilicon_ip_x2p_1.0.0/elab-vcs/vcs.log; Full64 无 32bit lib 问题

## 2026-09-03T13:50:43Z · G3 · rtl_check/lint · PASS
- summary: FuseSoC lint 通过: VCS lint 模式编译无 error
- detail: build/aixsilicon_ip_x2p_1.0.0/lint-vcs/vcs.log

## 2026-09-03T13:51:41Z · G3 · rtl_check/synth · PASS
- summary: DC 综合通过: Elaborated 1 design, SYNTH_OK, 生成 x2p_top_synth.v
- detail: reports/synth/{qor,area,hierarchy}.rpt; warnings: ELAB-311 default 不可达(合法), LINT-52 apb_error 裁剪(APB4 下预期)

## 2026-09-03T13:51:41Z · G3 · rtl_check/formal · SKIP
- summary: formal 降级: VC Formal 未安装, lint+elab+synth 为 G3 证据, formal 标记 exploratory
- detail: reports/quality/rtl_check_summary.md

## 2026-09-03T14:04:15Z · G4 · uvm_template · PASS
- summary: UVM 环境实例化+定制: 模板 109 文件 flat 实例化, 定制 axi interface/driver/env/testcases, VCS 编译成功(simv)
- detail: check_uvm.f/verification.list/sim Makefile; 3 测试 tc_sanity/tc_burst/tc_timeout

## 2026-09-03T14:28:06Z · G4 · sequence · PASS
- summary: UVM 环境编译成功, smoke tc_sanity 运行: 写路径通过(B 响应/APB 访问), 读路径 R timeout(BUG-001)
- detail: 写路径验证 APB SETUP/ACCESS 时序正确; 读路径待修(调度/读组装), 列为 BUG-001 记录于 run_log

## 2026-09-03T14:32:18Z · G4 · build_run · FAIL
- summary: smoke 运行: 编译 PASS, 写路径 PASS, 读路径 R timeout(BUG-001), smoke 标记 partial_fail
- detail: reports/smoke/smoke_summary.md; BUG-001: AXI 读 RVALID 永不拉高, 读请求未产生 APB 访问

## 2026-09-03T14:37:44Z · trace · PASS
- summary: trace 生成: req_to_hld=43 hld_to_lld=7 lld_to_rtl=7 req_to_test=91

## 2026-09-03T14:37:44Z · G4 · quality_review · FAIL
- summary: G4 评审: 读路径 BUG-001 open, G4 FAIL, G5 未通过
- detail: reports/quality/gate_report.md + model/quality.yaml

## 2026-09-03T14:37:44Z · G5 · release · FAIL
- summary: release: G5 未通过, 生成 1.0.0-candidate 归档(非发布), manifest+release_note
- detail: release/x2p_1.0.0_candidate/; BUG-001 修复后重跑 G4/G5

## 2026-09-03T14:42:58Z · G4 · build_run · FAIL
- summary: 读路径调试收口: BUG-001(AR 入队后 scheduler 不 grant 读/无 APB 读/R 超时)确认 open, 回退未验证 pulse 改动保持 RTL 基线
- detail: 写路径复现通过; 多轮探针确认读未被调度; BUG-001 修复方向记录于 run_log_summary.md

## 2026-09-04T01:18:53Z · G4 · debug · SKIP
- summary: BUG-001 深入调试(14 轮): module 直驱确认 AR 握手成功但 R 永不建立; 探针/shebang/config_db 干扰排除; 根因为 RTL 读路径设计缺陷(调度读授权/TE 读 APB/rsp_mgr 组装链)
- detail: RTL: x2p_top/x2p_transfer_engine/x2p_rsp_mgr; 修复方向: scheduler grant_rd 后 TE 读事务应推进 APB 读, 需波形级逐级核验; 交付保持 candidate

## 2026-09-04T01:27:38Z · G4 · build_run · FAIL
- summary: final: BUG-001 scheduler grant 恒 0(读/写均未授权), module直驱确认 AR/AW 握手上达队列但调度不触发; 已回退所有未验证 RTL 改动, 基线编译通过
- detail: 需 VCS/Verdi 波形级定位 scheduler_switch_ok/sel 链; 交付保持 x2p_1.0.0_candidate

## 2026-09-04T01:28:32Z · G4 · sequence · SKIP
- summary: 读路径最终结论: TE state/req_valid 链路静态正确, 但实测调度 grant 恒 0/描述符丢失, 需 VCS-Verdi 波形级逐级定位(switch_ok/sel_rd/desc 时序); BUG-001 保持 open, 交付 candidate
- detail: 已完成 module直驱/探针/RTL静态审查; 剩余为波形级调试范畴; run_log_summary.md 记录根因链与修复方向

## 2026-09-04T03:07:00Z · G4 · debug · FAIL→(修复)
- summary: BUG-001 波形级定位(FSDB+单时钟顶层 UT): 之前"调度 grant 恒0/无事务上总线"的根因是 harness 刺激 BUG——axi_write_word/axi_read_word 用 `while(!ready)@(posedge)` 在 ready 已为1时同拍拉高又拉低 valid(0 脉宽), awvalid/arvalid 从未真正拉高; 修正为 `do @(posedge); while(!ready)` 后事务正常上总线
- detail: FSDB run/fsdb/x2p_read_write.fsdb 确认 awvalid/arvalid 恒 0; 单时钟 ut_read_path 复现写 B 完成但读 R 数据错/超时; 打开 4 个 RTL 缺陷并修复

## 2026-09-04T03:08:00Z · G4 · rtl_gen · PASS(修复4缺陷)
- summary: 读路径 RTL 修复:
  BUG-001(响应方向错): x2p_top 用当前 APB 请求方向 apb_write_x 作响应方向 → 每事务最后 sub 响应被误路由(读的最后 sub→误发 B / 写的最后 sub→R 永不完成)。x2p_apb_engine 新增 rsp_write=write_q 输出, x2p_top 方向位改用它;
  BUG-002(多拍写 W 数据): w_q_pop 仅出队首拍, te_wdata_valid 依赖 te_take_wr_d1 单拍 → TE 卡 ST_WAITDATA; 改为 w_q_pop=te_take_wr||w_q_pop_next 且 te_wdata_valid=!w_q_empty;
  BUG-003(rsp_mgr 写侧缺复位): bresp_out_q/bid_out_q/b_pending_q/b_error_q 未复位 → B 通道 x;
  BUG-004(读累加器未清): beat 输出后 rdata_accum_q 未清 → 窄读高 lane 带上一 beat 陈旧数据
- detail: rtl/x2p_top.sv, rtl/x2p_apb_engine.sv, rtl/x2p_rsp_mgr.sv; 均经单时钟顶层 UT 与回归验证

## 2026-09-04T03:09:00Z · G4 · env · PASS
- summary: harness 修复: SYNC 模式 pclk 与 aclk 同源(原 pclk 恒 125MHz 独立 → CDC bypass 下跨域采样错误); harness 模块级激励限定 tc_sanity, tc_burst/timeout 由 UVM VIP(axi_driver)驱动避免双驱动竞争
- detail: verification/th/harness.sv; 新增 FSDB dump(+FSDB_FILE 可配)

## 2026-09-04T03:10:00Z · G4 · sequence · PASS
- summary: 单元测试 6 个全 PASS: ut_req_mgr/ut_scheduler/ut_transfer_engine/ut_apb_engine/ut_rsp_mgr/ut_read_path(顶层读路径: 单拍8B/4-beat burst/窄读4B)
- detail: verification/unit_test/ + run_ut.sh; ut_rsp_mgr 覆盖 BUG-004 回归(窄读高 lane=0); ut_transfer_engine 覆盖 2-beat 写 wdata 交接(BUG-002 回归)

## 2026-09-04T03:11:00Z · G4 · build_run · PASS
- summary: UVM 回归全绿: tc_sanity PASS(R 返回正确 rdata, B bid/bresp 正确), tc_burst PASS, tc_timeout PASS; UVM_ERROR=0 UVM_FATAL=0; BUG-001 closed
- detail: reports/smoke/smoke_summary.md(status=pass); 读路径从 AR→调度→TE→APB 读→rsp_mgr 组装→R 闭环

## 2026-09-07T01:34:11Z · G4 · build_run · PASS
- summary: 使用修改后的 apb/axi VIP(a10f794, 修复 P1-P5) 回归全绿: tc_sanity/tc_burst/tc_timeout 均 PASS, UVM_ERROR=0 UVM_FATAL=0
- detail: VIP_REPO HEAD=a10f794 (fix P1-P5: disable fork B backfill, default ready, apb_if init, ZERO_WAIT read, config_db doc)。x2p env/harness 已适配新 VIP API(axi4_master_agent/apb_slave_agent/suppress_pready)。编译产物 build/sim/simv; 运行日志 build/sim/run/*.log

## 2026-09-07T01:34:11Z · G4 · env · PASS
- summary: 修复 tc_timeout 适配修改后 VIP: APB_DISABLED→APB_ACTIVE_SLAVE+suppress_pready, 关闭超时场景 SVA
- detail: 根因: P3 修复后 apb_if 必选信号纯声明无初值, APB_DISABLED 下 pready 悬空 X→DUT if(!pready) 判定假→timeout 计数永不递增→永不超时(旧 X1 诊断为 DECODE_ERROR 实为 guard 超时返回初值)。修复: env 保持 APB_ACTIVE_SLAVE, harness 在 +X2P_APB_TIMEOUT 时置 u_apb.suppress_pready=1 且 u_apb.sva_enable=0(超时恢复为 DUT 主动放弃事务的协议异常路径, RUL-003 wait 稳定断言不适用)。改动: verification/env/x2p_env.sv, verification/th/harness.sv

## 2026-09-07T01:40:41Z · env · PASS
- summary: 清理仓库卫生: 删除 archived(52文件旧自研验证环境), 迁移 verdiLog→build/verdiLog, unit_test csrc 重定向到 build/sim/run/ut
- detail: 1) ip_x2p/archived 删除: 旧 verification_env + verification_env_utils(apb_utils/axi_utils 自研组件), 全项目零引用, 当前已用 VIP 仓库 axi4/apb。2) 根级 verdiLog/ 整体迁移到 ip_x2p/build/verdiLog/ (含 novas_autosave.ses.config/verdi.cmd/fsdb 日志等 Verdi 中间产物)。3) verification/unit_test/csrc + ucli.key 删除; run_ut.sh 改为 cd (build/sim/run/ut) 再 vcs, csrc 落 build/sim/run/ut/csrc 不再污染源码目录。已验证 ut_req_mgr PASS 且源码目录无 csrc。

