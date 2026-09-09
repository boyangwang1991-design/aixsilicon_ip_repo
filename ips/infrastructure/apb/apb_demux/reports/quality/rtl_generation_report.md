<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: rtl_generation
status: pass
tool: vcs
tool_version: "W-2024.09-SP1"
command: "vcs -sverilog -ntb_opts uvm-1.2 -full64 -quiet -o build/rtl/elab/simv rtl/apb_demux_top.sv -top apb_demux_top"
artifacts:
  - path: rtl/apb_demux_top.sv
    sha256: "<generated>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# RTL 生成报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| RTL 文件 | `rtl/apb_demux_top.sv` |
| 语言 | SystemVerilog（可综合） |
| 模块 | `apb_demux_top` |

## 2. 功能实现清单

| 功能 | 实现 | 需求引用 |
|------|------|----------|
| 地址译码 | 组合 `hit[i]` 计算 | LRS.FUNC.01.002 |
| PSEL one-hot | `sel[i] = psel & hit[i]` | LRS.FUNC.02.002 |
| 请求 fanout | 广播 + remap | LRS.FUNC.02.001, 06.002 |
| 响应 mux | one-hot mux | LRS.FUNC.04.001 |
| PSLVERR 透传 | mux 直通 | LRS.FUNC.04.002 |
| Decode Miss | `PREADY=1,PSLVERR=1,PRDATA=0` | LRS.FUNC.05.002 |
| Timeout | 可选 counter | LRS.FUNC.07.001 |
| Response Register | 可选寄存器 | LRS.FUNC.08.002 |
| APB3/APB4 | `APB_PROFILE` 裁剪 | LRS.CFG.04.001 |
| 复位 | PRESETn，`M_PSEL` 全 0 | LRS.RESET.02.002 |

## 3. Elaboration 检查

| 检查 | 状态 |
|------|------|
| VCS elaboration | ✅ pass（无语法/链接错误） |
| 可综合性 | ✅（无仿真构造） |
| 单时钟域 | ✅ |

## 4. 结论

RTL 实现 **pass**，可进入 FuseSoC 打包与 lint/synth 检查。
