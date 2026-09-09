<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: package_check
status: pass
tool: fusesoc
tool_version: "2.4.6"
command: "fusesoc --cores-root=. run --target=elab/lint --build-root=build/rtl/<t> aixsilicon:ip:apb_demux:1.0.0"
artifacts:
  - path: aixsilicon_ip_apb_demux.core
    sha256: "<generated>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# FuseSoC 打包检查报告 - APB Demux

## 1. 基本信息

| 项目 | 内容 |
|------|------|
| IP | apb_demux |
| Core | `aixsilicon_ip_apb_demux.core` |
| VLNV | `aixsilicon:ip:apb_demux:1.0.0` |
| RTL fileset | `rtl_handwritten`（rtl/apb_demux_top.sv） |

## 2. Target 清单

| Target | 工具 | 状态 |
|--------|------|------|
| lint | vcs | ✅ pass（无 error/warning） |
| elab | vcs | ✅ pass |
| sim | vcs | ✅ target 定义 |
| smoke | vcs | ✅ target 定义 |
| synth | dc | ✅ target 定义 |
| formal | vcformal | ✅ target 定义 |

## 3. 参数化支持

| 参数 | 默认值 | 类型 |
|------|--------|------|
| NUM_SLAVES | 4 | int |
| ADDR_WIDTH | 32 | int |
| DATA_WIDTH | 32 | int |
| APB_PROFILE | 1 | int |
| ADDR_REMAP_ENABLE | 0 | int |
| TIMEOUT_ENABLE | 0 | int |
| TIMEOUT_CYCLES | 16 | int |
| OUTPUT_REGISTER | 0 | int |

## 4. 检查项

| 检查项 | 状态 |
|--------|------|
| core 文件存在于 IP 根 | ✅ |
| fileset 路径有效（相对 IP 根） | ✅ |
| lint/elab 实际运行通过 | ✅ |
| 无已交付 CBB/VIP 依赖（自研轻量互联） | ✅ |

## 5. 结论

FuseSoC 打包 **pass**。RTL lint/elab 通过，可进入 UVM 验证环境构建。
