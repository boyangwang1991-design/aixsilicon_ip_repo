# ip-development-suite SKILL 优化点分析

> **来源**: APB CDC Bridge 完整开发流程实测 | **日期**: 2026-09-07
> **性质**: 供 skill 源仓（`aixsilicon_skill_repo`）改进的建议清单，非本 IP 交付物

---

## 1. SpyGlass 时机提前（最关键）

**实测问题**：流程为 `07 RTL → 09 FuseSoC lint/elab → Module UT`。VCS `-lint=all`
**未抓出** `s_req_ready` 输出未驱动（悬空 X），导致握手模块在所有 UT 中挂死、
耗费大量调试时间才定位。SpyGlass 的 undriven/STARC05 类规则可早期捕获此问题。

**优化建议**：
- `07-rtl-code-generator` SKILL 明确：**SpyGlass lint 在 Module UT 之前、RTL 生成后
  立即执行**，作为 G3 前置步骤（而非后续 RTL-check 才跑）。
- 在 SKILL 记录工具能力边界：VCS `-lint=all` 不覆盖"未驱动 output/inout 悬空"，
  需 SpyGlass `lint/lint_rtl` 捕获。

## 2. SpyGlass 运行脚本模板化

**实测问题**：`spyglass -shell` 手写 `read_file -type verilog`，从 build 目录算
相对路径（`../../..`）易错；`-type sverilog` 非法（合法值为 `verilog`），
SV 需 `set_option enableSV yes` 组合，文档未明确。

**优化建议**：固化 `scripts/spyglass_lint.sh` 模板：自动从 `rtl/filelist.f` 展开
文件、`set_option enableSV yes`、`current_goal lint/lint_rtl`、产物固定到
`build/rtl/lint_spyglass/`、生成 schema 2.0 兼容的 `spyglass_lint_report.md`。

## 3. VIP 无 RAL 场景的复用判据

**实测问题**：`apb_env` 无条件连接 `monitor → predictor`，无 RAL 时 predictor
`reg_map` 为 null 直接崩溃；`reuse-plan.md` 只讲"depend 引用 VIP"，未讲
**组件级复用**（agent/monitor 直接实例化）vs **env 级复用** 的判据。

**优化建议**：reuse-plan / 10-uvm-template-instantiation 增加判据：
- `register_model=none` 的 IP → 组件级复用（agent/monitor/scoreboard），
  绕过 apb_env 的 RAL 依赖；
- 有寄存器 IP → env 级 + RAL 四步接入（model/adapter/set_sequencer/front-door优先）；
- 强调"复用但不改"纪律：VIP 源码只读，集成差异在 IP 侧适配。

## 4. UT 骨架的驱动/等待纪律

**实测问题**（三类坑）：
1. task 用 `ref logic` 参数触发 ICPSD 编译错误；`input` 值传递导致 `wait` 挂死。
2. `@(posedge clk); sig=val;` 沿后赋值竞态，需 `#1` 后稳定采样。
3. 单周期脉冲用 `wait` 会漏检（wait 在信号短暂=1 时错过）。

**优化建议**：`ut_skeleton.sv` 增加"驱动/等待纪律"硬性章节：
- 输入一律 `@(posedge clk); #1; sig=val;`（沿后稳定，下一沿采样）；
- 等待一律内联 `wait(signal)` 或沿采样轮询，**禁止 task 传值等信号**；
- 挂死保护由 `run_ut.sh` 的 `timeout` 兜底（本次已采用）。

## 5. 编译期参数校验的标准做法

**实测问题**：顶层用 `initial $error` 校验非法参数，被 `audit_workspace.py`
标记 forbidden（procedural-initial）。

**优化建议**：07 SKILL 明确 RTL 内禁止 `initial`，并给出替代方案：
- `generate` 静态结构（非法位宽触发编译错误）；
- 参数契约表（FuseSoC `paramtype` 或 `model/parameter_space.yaml`）承接校验；
- 验证阶段 `TC.CONS.*.CFG` 补充运行时校验覆盖。

## 6. RTL-check 报告 / JUnit 生成模板

**实测问题**：`evaluate_quality.py` 要求：
- `rtl_check_summary.md` 的 REPORT_META 为 schema 2.0 且带 `checks` 映射
  （每项含 tool/tool_version/command/log/log_sha256，日志需真实存在且哈希匹配）；
- JUnit 的 testcase id/name 精确匹配 verification.yaml 的 smoke TC ID、
  且需覆盖全部 smoke 用例。

首版手写格式连环不达标（REPORT_META 缺 checks、JUnit 缺 CFG 用例、日志哈希不符）。
**优化建议**：固化 `gen_rtl_report.py` / JUnit 生成脚本，自动计算日志 SHA256、
列出全部 smoke ID，避免人工拼写不一致。

## 7. 环境脚本中间件落点

**实测问题**：`check_tools.sh` 检测 verdi 在工作区根生成 `verdiLog/`；VCS 编译在
源码目录留 `csrc/`（用户当场指出并清理）。

**优化建议**：00-ip-workspace 环境脚本统一 `cd build/` 后运行工具探测，或脚本内
自动清理；将"中间件只入 build/"提升为脚本退出级约束。

---

## 落地方式（遵循 AGENT.md）

以上改动须在 **skill 源仓 `repos/aixsilicon_skill_repo`** 修改对应
SKILL.md/模板/`eda_check_scripts.md`/`ut_skeleton.sv`，再
`uv run python bootstrap.py --ensure` 重新物化；**禁止直接编辑 `.roo/skills/` 物化副本**。