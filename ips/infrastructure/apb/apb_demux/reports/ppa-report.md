<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: ppa
status: pass
eda_profile: commercial-systemverilog
tool: dc_shell
tool_version: "V-2023.12-SP3"
command: "dc_shell -f build/rtl/synth/synth_28nm_logic.tcl"
artifacts:
  - path: reports/synth/area_28nm.rpt
    sha256: c7d40afc8940a4ee1f493b576fb9058e8fd792630acef3935bca13247f047f62
  - path: reports/synth/timing_28nm.rpt
    sha256: 1446df5d2d79acfc7d245b1ce5ebcaf2b8c5c8918b3bc5842379b3f46b8cdaf1
  - path: reports/synth/power_28nm.rpt
    sha256: 531d85dcab816f30a8d18ac8cd7bef676e28b376b04a5c821512cb680c0b8b46
  - path: reports/ppa/summary_CFG_BASE.yaml
    sha256: 946b2d9742c20687523a6f55bf4d9a46289739a6db36193455168853ff7c9cc8
  - path: reports/ppa/pareto_area_power.png
    sha256: 04e4aad1a2f79f450f8eb61676571426feb5b4f3f3ad54446f94310fc444b288
END_REPORT_META -->

# PPA 报告 - APB Demux

## 1. 工艺上下文

| 项 | 值 |
|----|-----|
| PDK | 28nm GF CMOS28LP + ARM SC9（`/home/eda/pdk/CMOS28NM`） |
| PDK status | `PDK_READY`（model/pdk.yaml） |
| target_library | `sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db` |
| operating_conditions | `tt_nominal_max_1p00v_25c` |
| 频率约束 | 400MHz（2.5ns） |
| 证据等级 | **E2**（功能完成后正式综合，PDK_READY 标准库 + DC） |

## 2. PPA 指标（CFG_BASE，默认配置）

| 指标 | 值 |
|------|-----|
| 面积 | **19.89 um²**（Total cell area，compile_ultra） |
| 最长组合路径 | 0.18ns（响应 mux 组合路径，report_timing 实测） |
| slack | 2.32ns（2.5ns 周期 − 0.18ns 组合到达） |
| 动态功耗 | **1.86 uW**（@400MHz，default activity） |
| 漏电功耗 | 2.67 nW |

> 注：默认配置（`TIMEOUT_ENABLE=0`/`OUTPUT_REGISTER=0`）无寄存器路径，关键路径为
> 组合响应 mux；因此时序 slack 由组合到达时间推导，非寄存器 STA 路径。

## 3. Pareto 图

见 `reports/ppa/pareto_area_power.png`（面积 vs 动态功耗）。

## 4. 结论

28nm 真实综合 **pass**（E2）。面积/功耗数据绑定 DC run 证据（reports/synth/*_28nm.rpt）。
PPA signoff policy = none（LRS 声明），本报告作为工艺上下文与综合证据留档。
