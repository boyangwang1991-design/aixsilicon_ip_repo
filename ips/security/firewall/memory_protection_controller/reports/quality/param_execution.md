# AXI MPU - 参数配置执行汇总（Parameter Verification Execution）

> **IP**: `axi_mpu` · **Gate**: G4 (parameter_execution) · **Date**: 2026-09-10
> **数据来源**: evidence/ppa/<run_id>/（真实 dc_shell 运行，非计划推导）

## 1. 执行矩阵

| config_id | 参数组合 | Method | Exit Code | Tool Version | 原始日志 | 日志 SHA-256 | 结果 |
|---|---|---|---|---|---|---|---|
| CFG_R16_P0_200M | REGION_NUM=16, PIPELINE=0 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | 9c8f17c340fcf94fb293fafca966c39075a3b4f6cb9eaa3c158da6de62cf58e4 | pass |
| CFG_R16_P0_400M | REGION_NUM=16, PIPELINE=0 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | 5ca018c6ea2db6d476dc633f68fa1c98b50984ade1a2c108e1f55710b3b94277 | pass |
| CFG_R16_P0_500M | REGION_NUM=16, PIPELINE=0 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | cb82526889ba57636e67be447d108561ba04c9b9e0706fbbf915841214437229 | pass |
| CFG_R16_P1_200M | REGION_NUM=16, PIPELINE=1 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | 32a0ce125140c2e3fe7b1df456fd06d02f036d3484bb455a9a6bb96a71517362 | pass |
| CFG_R16_P1_400M | REGION_NUM=16, PIPELINE=1 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | 313962a35d1aabe54d7ef80908ba53873db8848f7d648d056bd37d24d6a57974 | pass |
| CFG_R16_P1_500M | REGION_NUM=16, PIPELINE=1 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | ba8b72819afe05493f61746cd6a2e51ad9a25d2640d93ed657b3ab4d73145de0 | pass |
| CFG_R4_P0_400M | REGION_NUM=4, PIPELINE=0 | elaborate+synth (dc_shell) | 0 | V-2023.12-SP3 | dc_shell.log | c4f2926d756252c62b8545ade643a11b0caed21c368ef0c2052e1a166f85d218 | pass |

## 2. 执行方式说明

- 每个 config_id 执行 `dc_shell -f <run>/synth.tcl`（内含 analyze/elaborate
  `axi_mpu -parameters "REGION_NUM=…,PIPELINE=…"` + compile + report_*）；
  elaborate 失败即整体失败（Negative 检查：无预期失败配置）。
- PASS 判定：exit_code=0 且 area/timing/power 三份原始报告存在；
  EDA 日志与 manifest 哈希逐点绑定（见 REPORT_META artifacts）。
- 功能回归（基线 RTL，14/14 PASS）见 reports/regression/junit.xml；
  参数点综合前后 RTL 未变，回归直接适用。

## 3. 结论

全部 7 个配置点 elab+synth PASS；无 waiver、无未执行项。

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: param_execution
status: pass
eda_profile: commercial-systemverilog
tool: dc_shell
tool_version: V-2023.12-SP3
command: uv run python scripts/ppa/run_sweep.py (per-point dc_shell -f synth.tcl)
config_count: 7
artifacts:
- path: evidence/ppa/CFG_R16_P0_200M_200MHz_f783dde9/dc_shell.log
  sha256: 9c8f17c340fcf94fb293fafca966c39075a3b4f6cb9eaa3c158da6de62cf58e4
- path: evidence/ppa/CFG_R16_P0_200M_200MHz_f783dde9/manifest.yaml
  sha256: 66be9c7e164102eb63dc42e24b5767b5d0a6e6b584b5401266ad372a418b91af
- path: evidence/ppa/CFG_R16_P0_400M_400MHz_f783dde9/dc_shell.log
  sha256: 5ca018c6ea2db6d476dc633f68fa1c98b50984ade1a2c108e1f55710b3b94277
- path: evidence/ppa/CFG_R16_P0_400M_400MHz_f783dde9/manifest.yaml
  sha256: e986d0028deae63cfa7a3530be49b1d275086d18ce5ea6252cc32689be6aa744
- path: evidence/ppa/CFG_R16_P0_500M_500MHz_f783dde9/dc_shell.log
  sha256: cb82526889ba57636e67be447d108561ba04c9b9e0706fbbf915841214437229
- path: evidence/ppa/CFG_R16_P0_500M_500MHz_f783dde9/manifest.yaml
  sha256: c3ebfab6d8c3557e29b8c4d99683792e50b9025299b1c70f6ade8e2b81568c03
- path: evidence/ppa/CFG_R16_P1_200M_200MHz_d916efef/dc_shell.log
  sha256: 32a0ce125140c2e3fe7b1df456fd06d02f036d3484bb455a9a6bb96a71517362
- path: evidence/ppa/CFG_R16_P1_200M_200MHz_d916efef/manifest.yaml
  sha256: 55af1deb969e15f8d167ca1ed82c3bfa8790b8f470e0b7c8c7a64ceb0e459511
- path: evidence/ppa/CFG_R16_P1_400M_400MHz_d916efef/dc_shell.log
  sha256: 313962a35d1aabe54d7ef80908ba53873db8848f7d648d056bd37d24d6a57974
- path: evidence/ppa/CFG_R16_P1_400M_400MHz_d916efef/manifest.yaml
  sha256: 5f9f66e7c4d098beea188c8342b183403ca7a8328c67ab7af68439a70427c434
- path: evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/dc_shell.log
  sha256: ba8b72819afe05493f61746cd6a2e51ad9a25d2640d93ed657b3ab4d73145de0
- path: evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/manifest.yaml
  sha256: e37a2ef0bebd9c5b820033720af106c5695332a91fc823f825d18cae30d17cb9
- path: evidence/ppa/CFG_R4_P0_400M_400MHz_8a79a8bd/dc_shell.log
  sha256: c4f2926d756252c62b8545ade643a11b0caed21c368ef0c2052e1a166f85d218
- path: evidence/ppa/CFG_R4_P0_400M_400MHz_8a79a8bd/manifest.yaml
  sha256: 2f872f8ddac7471047c0a11092c294c373d53c73346fd57ef9644e307154da6d
END_REPORT_META -->
