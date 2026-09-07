# X2P 运行日志摘要（Full-Flow）

## 流程执行记录（对应 reports/quality/run_log.md 增量日志）

| 阶段 | 状态 | 证据 |
|---|---|---|
| 00 workspace | PASS | 布局 + uv(.venv/pyproject/uv.lock) + EDA commercial-systemverilog |
| 01 lrs | PASS (G0) | 42 需求抽取验证；`model/requirements.yaml` |
| 03 hld | PASS (G1) | 7 L1 模块/42 需求覆盖；extract_hld 校验通过 |
| 05 lld | PASS (G2) | 7 模块/3 FSM/2 CDC；extract_lld 校验通过 |
| 06 verification_plan | PASS | 15 features/16 tc/13 as/9 cov；must 全覆盖验证对象 |
| 07 rtl_gen | PASS (G3) | 9 文件；VCS parse + DC synth 通过；trace-seed 输出 |
| 08 fusesoc | PASS (G3) | `aixsilicon:ip:x2p:1.0.0`；6 targets |
| 09 rtl_check | PASS (G3) | lint/elab/synth 全通过；formal exploratory（无 VC Formal） |
| 10-13 uvm/seq | PASS | 模板实例化 + 定制 interface/driver/env/testcases；UVM 编译通过 |
| 14 build_run | FAIL (G4) | smoke 写通过/读 R timeout → BUG-001 |
| 16 trace | PASS | req_to_hld=43 / hld_to_lld=7 / lld_to_rtl=7 / req_to_test=91 |
| 15 quality_review | FAIL (G4) | 读路径 BUG-001 open |
| 17 documentation | PASS | integration_guide + user_guide |
| 18 release | FAIL (G5) | G5 未通过；`release/x2p_1.0.0_candidate.zip` 候选归档 |

## 门禁最终状态

| Gate | 状态 |
|---|---|
| G0 / G1 / G2 | PASS |
| G3 | PASS |
| G4 | FAIL：BUG-001（AXI 读路径 RVALID 永不建立） |
| G5 | NOT PASS（依赖 G4） |

## 已知缺陷（修复计划）

- **BUG-001**（High）：读请求 AR 入队后 scheduler 不授权读、无 APB 读访问、RVALID 10ms 超时。
  写路径（含 APB 传输 + timeout 恢复）验证通过。
  修复方向：核对 Scheduler → take_rd → TE 读事务链路中 AR 队列空/出队与该取数组合逻辑；
  RTL 侧叠加 `assert(ar_q_empty 在 push 后为 0)`、grant_rd 波形。修复后重跑 smoke 与全回归。

## 交付

- 交付物位于 `ip_x2p/`（RTL 9 文件、fusesoc/core、docs 全套、verification、trace、reports、release）。
- 状态: **candidate**（未发布；含 BUG-001）。