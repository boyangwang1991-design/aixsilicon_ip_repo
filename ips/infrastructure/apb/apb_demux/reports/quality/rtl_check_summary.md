<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_demux
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: vcs lint/elab + dc_shell 28nm synth
artifacts:
- path: build/rtl/lint/aixsilicon_ip_apb_demux_1.0.0/lint-vcs/vcs.log
  sha256: b43df100035694179e54d2c85dce54221c954029be0207ecdd7ed5161652e9fe
- path: build/rtl/elab/aixsilicon_ip_apb_demux_1.0.0/elab-vcs/vcs.log
  sha256: 950120cf6e2d9a51decdfc5a601febce15dd2854962426033b71d491779fd55f
- path: reports/synth/dc_synth_28nm.log
  sha256: c811f63d7297aa1ac374f252023c23dd0ebe76c839e477407ee8a40fa9697326
checks:
  lint:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: W-2024.09-SP1
    command: vcs -sverilog -ntb_opts uvm-1.2 -full64 -lint=all rtl/apb_demux_top.sv
    log: build/rtl/lint/aixsilicon_ip_apb_demux_1.0.0/lint-vcs/vcs.log
    log_sha256: b43df100035694179e54d2c85dce54221c954029be0207ecdd7ed5161652e9fe
  elab:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: W-2024.09-SP1
    command: vcs -sverilog -ntb_opts uvm-1.2 -full64 -o build/rtl/elab/simv rtl/apb_demux_top.sv -top apb_demux_top
    log: build/rtl/elab/aixsilicon_ip_apb_demux_1.0.0/elab-vcs/vcs.log
    log_sha256: 950120cf6e2d9a51decdfc5a601febce15dd2854962426033b71d491779fd55f
  synth:
    status: pass
    exit_code: 0
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command: dc_shell -f build/rtl/synth/synth_28nm_logic.tcl
    log: reports/synth/dc_synth_28nm.log
    log_sha256: c811f63d7297aa1ac374f252023c23dd0ebe76c839e477407ee8a40fa9697326
END_REPORT_META -->

# RTL 检查摘要 - APB Demux

## 1. Lint / Elaboration / Synthesis（28nm）

| 检查 | 工具 | 结果 |
|------|------|------|
| lint | vcs | ✅ pass（-lint=all 无 error） |
| elab | vcs | ✅ pass |
| synth | dc_shell | ✅ pass（**28nm 真实综合**，GF CMOS28LP + ARM SC9，area=19.89um²） |

## 2. 工艺上下文

- PDK: `model/pdk.yaml`（status=PDK_READY，28nm GF CMOS28LP + ARM SC9）
- target_library: `sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db`
- operating_conditions: `tt_nominal_max_1p00v_25c`
- 频率: 400MHz

## 3. 结论

RTL 检查 **pass**。
