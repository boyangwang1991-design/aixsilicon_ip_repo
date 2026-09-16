# AIXSILICON IP 功能资产仓

面向 SoC / 子系统集成，承担独立功能、完整接口和异常恢复责任。

分类按责任与交付边界判定，详见 [IP/CBB 分类原则](docs/ip-cbb-classification.md) 和
[统一资产管理策略](docs/asset-management.md)。完整 AXI Register Slice、APB Register Bridge、
总线 CDC Bridge 属于 IP；FIFO、仲裁、同步和权限比较核心属于 CBB。
按本项目明确归属，单通道 axi_channel_register_slice 也由 IP 仓管理。
IP 不强制要求 CSR、中断或软件接口。

`registry.yaml` 是唯一规划与状态编辑入口；校验脚本不从历史清单恢复候选。
`planned` 允许有开发目录；`implemented` 不等于正式发布或所有配置已验证。
源码、规格、验证材料和证据随资产保存，通用研发方法由开发 Skill 管理。

## 目录与身份

- `ips/<domain>/<subdomain>/<name>/`：资产工程；已交付旧布局继续按 registry.path 定位。
- `registry.yaml`：正式主清单；`governance/`：稳定编号、迁移与退出记录。
- `docs/archive/`：历史清单与指导快照；保留的未入选工程不计入主清单。
- `scripts/`：仓内索引检查与 README 派生视图生成。

默认新资产 VLNV 为 `aixsilicon:ip:<name>:<version>`；兼容旧身份须显式登记。
APB 工程迁移及历史构建身份例外见 [清理报告](docs/archive/2026-09-ip-materials-review/cleanup-2026-09.md)。

## 使用与维护

```bash
fusesoc library add aixsilicon_ip_repo https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git
python3 scripts/build_ip_registry.py --check
python3 scripts/update_registry_readme.py
python3 scripts/update_registry_readme.py --check
```

本地在 workflow 根通过 `uv run --no-sync python repos/aixsilicon_ip_repo/scripts/<脚本>` 执行。
资产工程 scaffold、stage 与领域 Gate 使用对应开发套件；仓内校验不代替仿真、综合或发布资格。

## 资产状态总览

<!-- IP-CATALOG-STATUS:BEGIN -->
> 本节由 `scripts/update_registry_readme.py` 依据 `registry.yaml`（SSOT）自动生成。
> 修改 `registry.yaml` 后必须运行 `python3 scripts/update_registry_readme.py` 刷新本节；勿手工编辑。
> 最后更新：`2026-09-13T00:00:00Z`

### 总览

| 指标                         | 数量 |
|------------------------------|------|
| 总条目（ips）                | 286  |
| released（已发布）           | 0    |
| implemented（已实现/已交付） | 3    |
| planned（规划候选）          | 283  |
| deprecated（已废弃）         | 0    |
| 实现率                       | 1.0% |

### 已发布 / 已实现 / 已纳管 IP（3）

| ID             | IP                                                                             | 类型 | 优先级 | 状态        | 版本  | 领域           |
|----------------|--------------------------------------------------------------------------------|------|--------|-------------|-------|----------------|
| INF-004        | [apb_demux](ips/infrastructure/apb/apb_demux/README.md)                        | ip   | P0     | implemented | 1.0.0 | infrastructure |
| MIG-IP-BUS-003 | [apb_register_bridge](ips/infrastructure/bridge/apb_register_bridge/README.md) | ip   | P1     | implemented | 0.1.0 | infrastructure |
| PER-005        | [spi_master](ips/peripheral/serial/spi_master/README.md)                       | ip   | P0     | implemented | 1.0.0 | peripheral     |

### 按优先级分布（released+implemented / planned）

| 优先级 | 已交付 | planned | 合计 |
|--------|--------|---------|------|
| P0     | 2      | 73      | 75   |
| P1     | 1      | 109     | 110  |
| P2     | 0      | 62      | 62   |
| P3     | 0      | 39      | 39   |

### 按类型分布

| 类型      | 数量 |
|-----------|------|
| generator | 16   |
| ip        | 262  |
| wrapper   | 8    |

### 按领域分布（顶层 domain）

| 领域           | 数量 |
|----------------|------|
| accelerator    | 19   |
| analog         | 7    |
| automotive     | 1    |
| cache          | 7    |
| chip           | 8    |
| compute        | 7    |
| crypto         | 3    |
| debug_trace    | 13   |
| dft            | 8    |
| infrastructure | 65   |
| memory         | 17   |
| mmu            | 4    |
| multimedia     | 4    |
| network        | 6    |
| peripheral     | 25   |
| reliability    | 4    |
| safety         | 20   |
| security       | 27   |
| system         | 39   |
| test           | 2    |

### 全部 IP 明细（286，按领域分组）

#### accelerator（19，已交付=0）

| ID     | IP                                                                                                       | 类型 | 状态    | 优先级 | 版本  | 功能/描述            |
|--------|----------------------------------------------------------------------------------------------------------|------|---------|--------|-------|----------------------|
| AI-001 | [accelerator_descriptor_engine](ips/accelerator/scheduler/accelerator_descriptor_engine/README.md)       | ip   | planned | P3     | 0.1.0 | 加速器描述符引擎     |
| AI-002 | [accelerator_interrupt_aggregator](ips/accelerator/interrupt/accelerator_interrupt_aggregator/README.md) | ip   | planned | P3     | 0.1.0 | 加速器中断聚合器     |
| AI-003 | [accelerator_scheduler](ips/accelerator/scheduler/accelerator_scheduler/README.md)                       | ip   | planned | P3     | 0.1.0 | 加速器调度器         |
| AI-004 | [activation_engine](ips/accelerator/activation/activation_engine/README.md)                              | ip   | planned | P3     | 0.1.0 | 激活函数引擎         |
| AI-005 | [ai_scratchpad_controller](ips/accelerator/memory/ai_scratchpad_controller/README.md)                    | ip   | planned | P3     | 0.1.0 | AI Scratchpad 控制器 |
| AI-007 | [convolution_accelerator](ips/accelerator/conv/convolution_accelerator/README.md)                        | ip   | planned | P3     | 0.1.0 | 卷积加速器           |
| AI-008 | [crc_accelerator](ips/accelerator/dsp/crc_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | CRC 加速器           |
| AI-010 | [dequantization_engine](ips/accelerator/quant/dequantization_engine/README.md)                           | ip   | planned | P3     | 0.1.0 | 反量化引擎           |
| AI-011 | [fft_accelerator](ips/accelerator/dsp/fft_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | FFT 加速器           |
| AI-012 | [fir_accelerator](ips/accelerator/dsp/fir_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | FIR 加速器           |
| AI-013 | [iir_accelerator](ips/accelerator/dsp/iir_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | IIR 加速器           |
| AI-014 | [matrix_multiply_accelerator](ips/accelerator/matmul/matrix_multiply_accelerator/README.md)              | ip   | planned | P3     | 0.1.0 | 矩阵乘加速器         |
| AI-015 | [quantization_engine](ips/accelerator/quant/quantization_engine/README.md)                               | ip   | planned | P3     | 0.1.0 | 量化引擎             |
| AI-017 | [stream_fabric](ips/accelerator/fabric/stream_fabric/README.md)                                          | ip   | planned | P3     | 0.1.0 | 流式互联 Fabric      |
| AI-018 | [systolic_array](ips/accelerator/systolic/systolic_array/README.md)                                      | ip   | planned | P3     | 0.1.0 | 脉动阵列             |
| AI-019 | [tensor_core](ips/accelerator/matmul/tensor_core/README.md)                                              | ip   | planned | P3     | 0.1.0 | 张量核               |
| AI-020 | [tensor_dma](ips/accelerator/dma/tensor_dma/README.md)                                                   | ip   | planned | P3     | 0.1.0 | 张量 DMA             |
| AI-021 | [vector_accelerator](ips/accelerator/vector/vector_accelerator/README.md)                                | ip   | planned | P3     | 0.1.0 | 向量加速器           |
| AI-022 | [weight_dma](ips/accelerator/dma/weight_dma/README.md)                                                   | ip   | planned | P3     | 0.1.0 | 权重 DMA             |

#### analog（7，已交付=0）

| ID      | IP                                                                             | 类型    | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|--------------------------------------------------------------------------------|---------|---------|--------|-------|--------------------|
| ANA-001 | [adc_wrapper](ips/analog/adc/adc_wrapper/README.md)                            | wrapper | planned | P2     | 0.1.0 | ADC Wrapper        |
| ANA-002 | [dac_wrapper](ips/analog/dac/dac_wrapper/README.md)                            | wrapper | planned | P2     | 0.1.0 | DAC Wrapper        |
| ANA-003 | [dll_wrapper](ips/analog/dll/dll_wrapper/README.md)                            | wrapper | planned | P2     | 0.1.0 | DLL Wrapper        |
| ANA-004 | [oscillator_wrapper](ips/analog/osc/oscillator_wrapper/README.md)              | wrapper | planned | P2     | 0.1.0 | 振荡器 Wrapper     |
| ANA-005 | [pll_wrapper](ips/analog/pll/pll_wrapper/README.md)                            | wrapper | planned | P2     | 0.1.0 | PLL Wrapper        |
| ANA-006 | [temp_sensor_wrapper](ips/analog/sensor/temp_sensor_wrapper/README.md)         | wrapper | planned | P2     | 0.1.0 | 温度传感器 Wrapper |
| ANA-007 | [voltage_monitor_wrapper](ips/analog/sensor/voltage_monitor_wrapper/README.md) | wrapper | planned | P2     | 0.1.0 | 电压监控器 Wrapper |

#### automotive（1，已交付=0）

| ID      | IP                                                                             | 类型 | 状态    | 优先级 | 版本  | 功能/描述              |
|---------|--------------------------------------------------------------------------------|------|---------|--------|-------|------------------------|
| AUT-002 | [e2e_protection_engine](ips/automotive/safety/e2e_protection_engine/README.md) | ip   | planned | P2     | 0.1.0 | E2E 保护引擎（端到端） |

#### cache（7，已交付=0）

| ID      | IP                                                                                           | 类型 | 状态    | 优先级 | 版本  | 功能/描述        |
|---------|----------------------------------------------------------------------------------------------|------|---------|--------|-------|------------------|
| CAC-001 | [cache_maintenance_controller](ips/cache/maintenance/cache_maintenance_controller/README.md) | ip   | planned | P2     | 0.1.0 | Cache 维护控制器 |
| CAC-002 | [cache_prefetcher](ips/cache/prefetch/cache_prefetcher/README.md)                            | ip   | planned | P2     | 0.1.0 | Cache 预取器     |
| CAC-003 | [directory_controller](ips/cache/coherency/directory_controller/README.md)                   | ip   | planned | P2     | 0.1.0 | 目录控制器       |
| CAC-004 | [l1_cache_controller](ips/cache/l1/l1_cache_controller/README.md)                            | ip   | planned | P2     | 0.1.0 | L1 Cache 控制器  |
| CAC-005 | [l2_cache_controller](ips/cache/l2/l2_cache_controller/README.md)                            | ip   | planned | P2     | 0.1.0 | L2 Cache 控制器  |
| CAC-006 | [shared_llc_controller](ips/cache/llc/shared_llc_controller/README.md)                       | ip   | planned | P2     | 0.1.0 | 共享 LLC 控制器  |
| CAC-007 | [snoop_filter](ips/cache/coherency/snoop_filter/README.md)                                   | ip   | planned | P2     | 0.1.0 | Snoop Filter     |

#### chip（8，已交付=0）

| ID      | IP                                                                              | 类型      | 状态    | 优先级 | 版本  | 功能/描述       |
|---------|---------------------------------------------------------------------------------|-----------|---------|--------|-------|-----------------|
| CHP-001 | [pad_controller](ips/chip/pad/pad_controller/README.md)                         | ip        | planned | P0     | 0.1.0 | Pad 控制器      |
| CHP-002 | [pinmux](ips/chip/pinmux/pinmux/README.md)                                      | generator | planned | P0     | 0.1.0 | Pinmux 复用矩阵 |
| CHP-003 | [strap_controller](ips/chip/strap/strap_controller/README.md)                   | ip        | planned | P0     | 0.1.0 | Strap 控制器    |
| CHP-004 | [test_mode_controller](ips/chip/test/test_mode_controller/README.md)            | ip        | planned | P0     | 0.1.0 | 测试模式控制器  |
| CHP-005 | [device_info_controller](ips/chip/strap/device_info_controller/README.md)       | ip        | planned | P1     | 0.1.0 | 器件信息控制器  |
| CHP-006 | [gpio_matrix](ips/chip/pinmux/gpio_matrix/README.md)                            | generator | planned | P1     | 0.1.0 | GPIO 矩阵       |
| CHP-007 | [package_config_controller](ips/chip/strap/package_config_controller/README.md) | ip        | planned | P1     | 0.1.0 | 封装配置控制器  |
| CHP-008 | [pad_ring_adapter](ips/chip/pad/pad_ring_adapter/README.md)                     | generator | planned | P1     | 0.1.0 | Pad Ring 适配器 |

#### compute（7，已交付=0）

| ID      | IP                                                                         | 类型 | 状态    | 优先级 | 版本  | 功能/描述               |
|---------|----------------------------------------------------------------------------|------|---------|--------|-------|-------------------------|
| CPU-001 | [core_local_controller](ips/compute/riscv/core_local_controller/README.md) | ip   | planned | P2     | 0.1.0 | Core Local 控制器       |
| CPU-002 | [cpu_debug_transport](ips/compute/riscv/cpu_debug_transport/README.md)     | ip   | planned | P2     | 0.1.0 | CPU Debug Transport     |
| CPU-003 | [cpu_pmu](ips/compute/riscv/cpu_pmu/README.md)                             | ip   | planned | P2     | 0.1.0 | CPU PMU（性能监控单元） |
| CPU-004 | [cpu_trace](ips/compute/riscv/cpu_trace/README.md)                         | ip   | planned | P2     | 0.1.0 | CPU Trace               |
| CPU-005 | [hart_control_block](ips/compute/riscv/hart_control_block/README.md)       | ip   | planned | P2     | 0.1.0 | Hart 控制块             |
| CPU-006 | [riscv_cluster](ips/compute/riscv/riscv_cluster/README.md)                 | ip   | planned | P2     | 0.1.0 | RISC-V Cluster          |
| CPU-007 | [riscv_core](ips/compute/riscv/riscv_core/README.md)                       | ip   | planned | P2     | 0.1.0 | RISC-V Core             |

#### crypto（3，已交付=0）

| ID      | IP                                 | 类型 | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|------------------------------------|------|---------|--------|-------|--------------------|
| CRY-001 | [sm2](ips/crypto/sm/sm2/README.md) | ip   | planned | P2     | 0.1.0 | SM2 国密算法引擎   |
| CRY-002 | [sm3](ips/crypto/sm/sm3/README.md) | ip   | planned | P2     | 0.1.0 | SM3 国密哈希引擎   |
| CRY-003 | [sm4](ips/crypto/sm/sm4/README.md) | ip   | planned | P2     | 0.1.0 | SM4 国密加解密引擎 |

#### debug_trace（13，已交付=0）

| ID             | IP                                                                                       | 类型 | 状态    | 优先级 | 版本  | 功能/描述                                                                  |
|----------------|------------------------------------------------------------------------------------------|------|---------|--------|-------|----------------------------------------------------------------------------|
| DBG-001        | [debug_register_block](ips/debug_trace/debug/debug_register_block/README.md)             | ip   | planned | P0     | 0.1.0 | 调试寄存器块                                                               |
| DBG-002        | [jtag_tap](ips/debug_trace/jtag/jtag_tap/README.md)                                      | ip   | planned | P0     | 0.1.0 | JTAG TAP 控制器                                                            |
| DBG-003        | [performance_monitor](ips/debug_trace/monitor/performance_monitor/README.md)             | ip   | planned | P0     | 0.1.0 | 性能监控器                                                                 |
| DBG-004        | [riscv_debug_module](ips/debug_trace/debug/riscv_debug_module/README.md)                 | ip   | planned | P0     | 0.1.0 | RISC-V Debug Module                                                        |
| DBG-005        | [trace_buffer](ips/debug_trace/trace/trace_buffer/README.md)                             | ip   | planned | P0     | 0.1.0 | Trace 缓冲                                                                 |
| DBG-006        | [apb_transaction_monitor](ips/debug_trace/monitor/apb_transaction_monitor/README.md)     | ip   | planned | P1     | 0.1.0 | APB 事务监控器                                                             |
| DBG-007        | [axi_transaction_monitor](ips/debug_trace/monitor/axi_transaction_monitor/README.md)     | ip   | planned | P1     | 0.1.0 | AXI 事务监控器                                                             |
| DBG-008        | [bus_monitor](ips/debug_trace/monitor/bus_monitor/README.md)                             | ip   | planned | P1     | 0.1.0 | 总线监控器                                                                 |
| DBG-009        | [error_logger](ips/debug_trace/monitor/error_logger/README.md)                           | ip   | planned | P1     | 0.1.0 | 错误记录器                                                                 |
| DBG-010        | [timestamp_unit](ips/debug_trace/trace/timestamp_unit/README.md)                         | ip   | planned | P1     | 0.1.0 | 时间戳单元                                                                 |
| DBG-011        | [trace_funnel](ips/debug_trace/trace/trace_funnel/README.md)                             | ip   | planned | P1     | 0.1.0 | Trace 漏斗控制器（汇聚核 + 时间戳/过滤配置 + CSR）                         |
| DBG-012        | [trace_replicator](ips/debug_trace/trace/trace_replicator/README.md)                     | ip   | planned | P1     | 0.1.0 | Trace 复制器                                                               |
| MIG-IP-MON-016 | [lightweight_logic_analyzer](ips/debug_trace/debug/lightweight_logic_analyzer/README.md) | ip   | planned | P3     | 0.1.0 | Lightweight Logic Analyzer Shell；trigger+buffer+readout；调试配置按需裁剪 |

#### dft（8，已交付=0）

| ID      | IP                                                                               | 类型 | 状态    | 优先级 | 版本  | 功能/描述       |
|---------|----------------------------------------------------------------------------------|------|---------|--------|-------|-----------------|
| DFT-001 | [bist_clock_controller](ips/dft/mbist/bist_clock_controller/README.md)           | ip   | planned | P1     | 0.1.0 | BIST 时钟控制器 |
| DFT-002 | [boundary_scan_controller](ips/dft/scan/boundary_scan_controller/README.md)      | ip   | planned | P1     | 0.1.0 | 边界扫描控制器  |
| DFT-003 | [lbist_controller](ips/dft/lbist/lbist_controller/README.md)                     | ip   | planned | P1     | 0.1.0 | LBIST 控制器    |
| DFT-004 | [mbist_controller](ips/dft/mbist/mbist_controller/README.md)                     | ip   | planned | P1     | 0.1.0 | MBIST 控制器    |
| DFT-005 | [scan_controller](ips/dft/scan/scan_controller/README.md)                        | ip   | planned | P1     | 0.1.0 | 扫描链控制器    |
| DFT-006 | [analog_test_controller](ips/dft/analog/analog_test_controller/README.md)        | ip   | planned | P2     | 0.1.0 | 模拟测试控制器  |
| DFT-007 | [fuse_repair_controller](ips/dft/mbist/fuse_repair_controller/README.md)         | ip   | planned | P2     | 0.1.0 | Fuse 修复控制器 |
| DFT-008 | [memory_redundancy_analyzer](ips/dft/mbist/memory_redundancy_analyzer/README.md) | ip   | planned | P2     | 0.1.0 | 内存冗余分析器  |

#### infrastructure（65，已交付=2）

| ID              | IP                                                                                        | 类型      | 状态        | 优先级 | 版本  | 功能/描述                                                                                                                                                                                             |
|-----------------|-------------------------------------------------------------------------------------------|-----------|-------------|--------|-------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| INF-001         | [ahb2apb_bridge](ips/infrastructure/bridge/ahb2apb_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | AHB→APB 桥（H2P）                                                                                                                                                                                     |
| INF-002         | [ahb2axi_bridge](ips/infrastructure/bridge/ahb2axi_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | AHB→AXI 桥（H2X）                                                                                                                                                                                     |
| INF-003         | [ahb_cdc_bridge](ips/infrastructure/cdc/ahb_cdc_bridge/README.md)                         | ip        | planned     | P0     | 0.1.0 | AHB CDC 桥                                                                                                                                                                                            |
| INF-004         | [apb_demux](ips/infrastructure/apb/apb_demux/README.md)                                   | ip        | implemented | P0     | 1.0.0 | APB Demux（1→N APB Router）                                                                                                                                                                           |
| INF-005         | [apb_error_slave](ips/infrastructure/apb/apb_error_slave/README.md)                       | ip        | planned     | P0     | 0.1.0 | APB 错误默认 Slave                                                                                                                                                                                    |
| INF-006         | [apb_mux](ips/infrastructure/apb/apb_mux/README.md)                                       | ip        | planned     | P0     | 0.1.0 | APB Mux                                                                                                                                                                                               |
| INF-007         | [apb_timeout](ips/infrastructure/apb/apb_timeout/README.md)                               | ip        | planned     | P0     | 0.1.0 | APB 超时监控                                                                                                                                                                                          |
| INF-008         | [axi2ahb_bridge](ips/infrastructure/bridge/axi2ahb_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | AXI→AHB 桥（X2H）                                                                                                                                                                                     |
| INF-009         | [axi4_axi4lite_converter](ips/infrastructure/bridge/axi4_axi4lite_converter/README.md)    | ip        | planned     | P0     | 0.1.0 | AXI4→AXI4-Lite 协议转换                                                                                                                                                                               |
| INF-010         | [axi_address_remapper](ips/infrastructure/axi/axi_address_remapper/README.md)             | ip        | planned     | P0     | 0.1.0 | AXI 地址重映射                                                                                                                                                                                        |
| INF-011         | [axi_cdc_bridge](ips/infrastructure/cdc/axi_cdc_bridge/README.md)                         | ip        | planned     | P0     | 0.1.0 | AXI CDC 桥（异步时钟）                                                                                                                                                                                |
| INF-012         | [axi_error_slave](ips/infrastructure/axi/axi_error_slave/README.md)                       | ip        | planned     | P0     | 0.1.0 | AXI 默认错误响应 Slave                                                                                                                                                                                |
| INF-013         | [axi_interconnect](ips/infrastructure/axi/axi_interconnect/README.md)                     | generator | planned     | P0     | 0.1.0 | 多 Master/Slave AXI 互联（拓扑生成）                                                                                                                                                                  |
| INF-015         | [axi_register_slice](ips/infrastructure/axi/axi_register_slice/README.md)                 | ip        | planned     | P0     | 0.1.0 | 完整 AXI 接口 Register Slice/TPI；按通道配置缓冲与流水，承担完整接口契约；底层复用通道 CBB。                                                                                                          |
| INF-018         | [ahb_interconnect](ips/infrastructure/ahb/ahb_interconnect/README.md)                     | generator | planned     | P1     | 0.1.0 | AHB 互联                                                                                                                                                                                              |
| INF-019         | [ahb_mux_demux](ips/infrastructure/ahb/ahb_mux_demux/README.md)                           | ip        | planned     | P1     | 0.1.0 | AHB Mux/Demux                                                                                                                                                                                         |
| INF-020         | [apb_firewall](ips/infrastructure/apb/apb_firewall/README.md)                             | ip        | planned     | P1     | 0.1.0 | APB 防火墙                                                                                                                                                                                            |
| INF-021         | [apb_isolation_bridge](ips/infrastructure/apb/apb_isolation_bridge/README.md)             | ip        | planned     | P1     | 0.1.0 | APB 隔离桥                                                                                                                                                                                            |
| INF-022         | [axi_arbiter](ips/infrastructure/axi/axi_arbiter/README.md)                               | ip        | planned     | P1     | 0.1.0 | AXI 仲裁器                                                                                                                                                                                            |
| INF-023         | [axi_bandwidth_limiter](ips/infrastructure/axi/axi_bandwidth_limiter/README.md)           | ip        | planned     | P1     | 0.1.0 | AXI 带宽限制器                                                                                                                                                                                        |
| INF-024         | [axi_exclusive_monitor](ips/infrastructure/axi/axi_exclusive_monitor/README.md)           | ip        | planned     | P1     | 0.1.0 | AXI 独占访问监控                                                                                                                                                                                      |
| INF-025         | [axi_isolation_bridge](ips/infrastructure/axi/axi_isolation_bridge/README.md)             | ip        | planned     | P1     | 0.1.0 | AXI 隔离桥                                                                                                                                                                                            |
| INF-026         | [axi_ordering_controller](ips/infrastructure/axi/axi_ordering_controller/README.md)       | ip        | planned     | P1     | 0.1.0 | AXI 顺序控制器                                                                                                                                                                                        |
| INF-027         | [axi_protocol_firewall](ips/infrastructure/axi/axi_protocol_firewall/README.md)           | ip        | planned     | P1     | 0.1.0 | AXI 协议防火墙                                                                                                                                                                                        |
| INF-028         | [axi_qos_controller](ips/infrastructure/axi/axi_qos_controller/README.md)                 | ip        | planned     | P1     | 0.1.0 | AXI QoS 控制器                                                                                                                                                                                        |
| INF-029         | [axi_traffic_shaper](ips/infrastructure/axi/axi_traffic_shaper/README.md)                 | ip        | planned     | P1     | 0.1.0 | AXI 流量整形器                                                                                                                                                                                        |
| INF-030         | [axis_cdc](ips/infrastructure/cdc/axis_cdc/README.md)                                     | ip        | planned     | P1     | 0.1.0 | AXI-Stream CDC                                                                                                                                                                                        |
| INF-031         | [axis_demux](ips/infrastructure/axi/axis_demux/README.md)                                 | ip        | planned     | P1     | 0.1.0 | AXI-Stream Demux                                                                                                                                                                                      |
| INF-032         | [axis_mux](ips/infrastructure/axi/axis_mux/README.md)                                     | ip        | planned     | P1     | 0.1.0 | AXI-Stream Mux                                                                                                                                                                                        |
| INF-034         | [reset_domain_bridge](ips/infrastructure/cdc/reset_domain_bridge/README.md)               | ip        | planned     | P1     | 0.1.0 | 复位域桥（RDC）                                                                                                                                                                                       |
| INF-036         | [stream_interconnect](ips/infrastructure/axi/stream_interconnect/README.md)               | generator | planned     | P1     | 0.1.0 | AXI-Stream 互联                                                                                                                                                                                       |
| INF-046         | [apb_secure_demux](ips/infrastructure/apb/apb_secure_demux/README.md)                     | ip        | planned     | P0     | 1.0.0 | 安全 APB Demux；1→N 路由、可信主体权限、原子配置提交及审计                                                                                                                                            |
| MIG-IP-AXI-001  | [axi_channel_register_slice](ips/infrastructure/axi/axi_channel_register_slice/README.md) | ip        | planned     | P0     | 0.1.0 | AXI 单通道缓冲与时序切片；按用户 2026-09-13 仓库归属要求迁入 IP，区别于完整五通道 axi_register_slice。                                                                                                |
| MIG-IP-AXI-002  | [axi_lite_register_slice](ips/infrastructure/axi/axi_lite_register_slice/README.md)       | ip        | planned     | P0     | 0.1.0 | AXI-Lite Register Slice；combined/per-channel；小面积低延迟                                                                                                                                           |
| MIG-IP-AXI-003  | [axi_buffer](ips/infrastructure/axi/axi_buffer/README.md)                                 | ip        | planned     | P1     | 0.1.0 | AXI Buffer；channel depth/transaction buffer；Outstanding与背压                                                                                                                                       |
| MIG-IP-AXI-004  | [axi_width_converter](ips/infrastructure/axi/axi_width_converter/README.md)               | ip        | planned     | P1     | 0.1.0 | AXI Data Width Converter；upsize/downsize；Burst、strobe、unaligned                                                                                                                                   |
| MIG-IP-AXI-005  | [axi_addr_width_adapter](ips/infrastructure/axi/axi_addr_width_adapter/README.md)         | ip        | planned     | P1     | 0.1.0 | AXI Address Width Adapter；extend/truncate/window；地址合法性                                                                                                                                         |
| MIG-IP-AXI-006  | [axi_id_converter](ips/infrastructure/axi/axi_id_converter/README.md)                     | ip        | planned     | P1     | 0.1.0 | AXI ID Width Converter；remap/compress/expand；ID表面积和并发                                                                                                                                         |
| MIG-IP-AXI-007  | [axi_user_signal_adapter](ips/infrastructure/axi/axi_user_signal_adapter/README.md)       | ip        | planned     | P2     | 0.1.0 | AXI User Signal Adapter；map/tie/filter；固定字段裁剪                                                                                                                                                 |
| MIG-IP-AXI-008  | [axi_burst_splitter](ips/infrastructure/axi/axi_burst_splitter/README.md)                 | ip        | planned     | P1     | 0.1.0 | AXI Burst Splitter；boundary/max-length/4KB；状态与吞吐                                                                                                                                               |
| MIG-IP-AXI-010  | [axi_burst_length_adapter](ips/infrastructure/axi/axi_burst_length_adapter/README.md)     | ip        | planned     | P2     | 0.1.0 | AXI Burst Length Adapter；fixed/max programmable；地址推进                                                                                                                                            |
| MIG-IP-AXI-011  | [axi_outstanding_limiter](ips/infrastructure/axi/axi_outstanding_limiter/README.md)       | ip        | planned     | P1     | 0.1.0 | AXI Outstanding Limiter；global/per-ID/per-channel；计数器和阻塞                                                                                                                                      |
| MIG-IP-AXI-013  | [axi_transaction_serializer](ips/infrastructure/axi/axi_transaction_serializer/README.md) | ip        | planned     | P1     | 0.1.0 | AXI Transaction Serializer；full/per-ID；面积换并发                                                                                                                                                   |
| MIG-IP-AXI-016  | [axi_protocol_converter](ips/infrastructure/bridge/axi_protocol_converter/README.md)      | ip        | planned     | P1     | 0.1.0 | AXI Protocol Converter；AXI4↔AXI4-Lite subset；Burst拆分与错误                                                                                                                                        |
| MIG-IP-AXI-017  | [axi2apb_bridge](ips/infrastructure/bridge/axi2apb_bridge/README.md)                      | ip        | planned     | P1     | 0.1.0 | AXI-to-APB Bridge；single/multi port；队列、译码、时钟                                                                                                                                                |
| MIG-IP-AXI-020  | [axi_demux](ips/infrastructure/axi/axi_demux/README.md)                                   | ip        | planned     | P1     | 0.1.0 | AXI Demux；static/dynamic target；响应路由状态                                                                                                                                                        |
| MIG-IP-AXI-021  | [axi_mux](ips/infrastructure/axi/axi_mux/README.md)                                       | ip        | planned     | P1     | 0.1.0 | AXI Mux；fixed/RR/QoS arbitration；五通道仲裁与锁定                                                                                                                                                   |
| MIG-IP-AXI-024  | [axi_timeout_monitor](ips/infrastructure/axi/axi_timeout_monitor/README.md)               | ip        | planned     | P1     | 0.1.0 | AXI Timeout Monitor；per-channel/transaction；表项和恢复策略                                                                                                                                          |
| MIG-IP-AXI-028  | [axi_qos_mapper](ips/infrastructure/axi/axi_qos_mapper/README.md)                         | ip        | planned     | P2     | 0.1.0 | AXI QoS Mapper；static/table/traffic class；配置和仲裁衔接                                                                                                                                            |
| MIG-IP-AXI-030  | [axi_error_injector](ips/infrastructure/axi/axi_error_injector/README.md)                 | ip        | planned     | P2     | 0.1.0 | AXI Error Injector；channel/response/data；验证模式隔离                                                                                                                                               |
| MIG-IP-AXIS-001 | [axis_register_slice](ips/infrastructure/axis/axis_register_slice/README.md)              | ip        | planned     | P0     | 0.1.0 | AXI-Stream Register Slice；F/B/full/skid；Ready路径                                                                                                                                                   |
| MIG-IP-AXIS-002 | [axis_width_converter](ips/infrastructure/axis/axis_width_converter/README.md)            | ip        | planned     | P1     | 0.1.0 | AXI-Stream Width Converter；byte-aligned/general ratio；TKEEP/TLAST对齐                                                                                                                               |
| MIG-IP-AXIS-003 | [axis_switch](ips/infrastructure/axis/axis_switch/README.md)                              | ip        | planned     | P2     | 0.1.0 | AXI-Stream Switch；mux/demux/crossbar；包锁定与路由                                                                                                                                                   |
| MIG-IP-AXIS-004 | [axis_packet_fifo](ips/infrastructure/axis/axis_packet_fifo/README.md)                    | ip        | planned     | P1     | 0.1.0 | AXI-Stream Packet FIFO；store-forward/cut-through；包边界与容量                                                                                                                                       |
| MIG-IP-AXIS-005 | [axis_broadcaster](ips/infrastructure/axis/axis_broadcaster/README.md)                    | ip        | planned     | P2     | 0.1.0 | AXI-Stream Broadcaster；all/subset outputs；Ready汇聚                                                                                                                                                 |
| MIG-IP-AXIS-006 | [axis_combiner_subset](ips/infrastructure/axis/axis_combiner_subset/README.md)            | ip        | planned     | P2     | 0.1.0 | AXI-Stream Combiner/Subset；TDATA/TUSER composition；Lane映射                                                                                                                                         |
| MIG-IP-AXIS-007 | [axis_frame_length_monitor](ips/infrastructure/axis/axis_frame_length_monitor/README.md)  | ip        | planned     | P2     | 0.1.0 | AXI-Stream Frame Length Monitor；min/max/count；低开销检查                                                                                                                                            |
| MIG-IP-AXIS-008 | [axis_rate_limiter](ips/infrastructure/axis/axis_rate_limiter/README.md)                  | ip        | planned     | P2     | 0.1.0 | AXI-Stream Rate Limiter；token bucket/gap insert；吞吐整形                                                                                                                                            |
| MIG-IP-BUS-002  | [apb_slave_adapter](ips/infrastructure/bridge/apb_slave_adapter/README.md)                | ip        | planned     | P0     | 0.1.0 | APB Slave Adapter；APB3/APB4、wait/error；低面积与时序                                                                                                                                                |
| MIG-IP-BUS-003  | [apb_register_bridge](ips/infrastructure/bridge/apb_register_bridge/README.md)            | ip        | implemented | P1     | 0.1.0 | 同钟域 APB Slave→Master 寄存桥；协调 SETUP/ACCESS、等待与响应，避免重复下游访问；切断请求/响应时序路径，不是全部信号直接延迟一拍。 已迁入原 BUS-003 完整实现；保留旧构建标识，IP 发布资格待重新评估。 |
| MIG-IP-BUS-006  | [apb_cdc_bridge](ips/infrastructure/bridge/apb_cdc_bridge/README.md)                      | ip        | planned     | P1     | 0.1.0 | APB CDC Bridge；handshake/async queue；低吞吐CDC优化                                                                                                                                                  |
| MIG-IP-BUS-007  | [apb_width_adapter](ips/infrastructure/bridge/apb_width_adapter/README.md)                | ip        | planned     | P2     | 0.1.0 | APB Width Adapter；32/64/custom；Byte strobe与跨拍                                                                                                                                                    |
| MIG-IP-BUS-009  | [ahb_lite_slave_adapter](ips/infrastructure/bridge/ahb_lite_slave_adapter/README.md)      | ip        | planned     | P1     | 0.1.0 | AHB-Lite Slave Adapter；pipelined address/data；地址/数据相位                                                                                                                                         |
| MIG-IP-BUS-010  | [ahb_lite_register_slice](ips/infrastructure/bridge/ahb_lite_register_slice/README.md)    | ip        | planned     | P1     | 0.1.0 | AHB-Lite Register Slice；forward/full；HREADY路径                                                                                                                                                     |
| MIG-IP-BUS-013  | [ahb_apb_bridge](ips/infrastructure/bridge/ahb_apb_bridge/README.md)                      | ip        | planned     | P1     | 0.1.0 | AHB↔APB Bridge；single/multi APB port；Buffer与时钟比                                                                                                                                                 |

#### memory（17，已交付=0）

| ID      | IP                                                                                 | 类型      | 状态    | 优先级 | 版本  | 功能/描述                                    |
|---------|------------------------------------------------------------------------------------|-----------|---------|--------|-------|----------------------------------------------|
| MEM-004 | [memory_interleaver](ips/memory/sram/memory_interleaver/README.md)                 | ip        | planned | P0     | 0.1.0 | 内存交织器                                   |
| MEM-005 | [memory_scrubber](ips/memory/sram/memory_scrubber/README.md)                       | ip        | planned | P0     | 0.1.0 | 内存巡检控制器（集成 ECC、仲裁、告警与 CSR） |
| MEM-006 | [multiport_sram_controller](ips/memory/sram/multiport_sram_controller/README.md)   | generator | planned | P0     | 0.1.0 | 多端口 SRAM 控制器                           |
| MEM-008 | [rom_controller](ips/memory/rom/rom_controller/README.md)                          | ip        | planned | P0     | 0.1.0 | ROM 控制器                                   |
| MEM-010 | [sram_controller](ips/memory/sram/sram_controller/README.md)                       | generator | planned | P0     | 0.1.0 | SRAM 控制器                                  |
| MEM-011 | [sram_ecc_controller](ips/memory/sram/sram_ecc_controller/README.md)               | ip        | planned | P0     | 0.1.0 | SRAM ECC 控制器                              |
| MEM-013 | [tcm_controller](ips/memory/tcm/tcm_controller/README.md)                          | ip        | planned | P0     | 0.1.0 | TCM 控制器                                   |
| MEM-015 | [memory_firewall](ips/memory/security/memory_firewall/README.md)                   | ip        | planned | P1     | 0.1.0 | 内存防火墙                                   |
| MEM-016 | [memory_qos_controller](ips/memory/qos/memory_qos_controller/README.md)            | ip        | planned | P1     | 0.1.0 | 内存 QoS 控制器                              |
| MEM-017 | [memory_repair_controller](ips/memory/bist/memory_repair_controller/README.md)     | ip        | planned | P1     | 0.1.0 | 内存修复控制器                               |
| MEM-018 | [multi_bank_sram_controller](ips/memory/sram/multi_bank_sram_controller/README.md) | generator | planned | P1     | 0.1.0 | 多 Bank SRAM 控制器                          |
| MEM-019 | [scratchpad_controller](ips/memory/sram/scratchpad_controller/README.md)           | ip        | planned | P1     | 0.1.0 | Scratchpad 控制器                            |
| MEM-023 | [ddr_controller](ips/memory/ddr/ddr_controller/README.md)                          | ip        | planned | P2     | 0.1.0 | DDR 控制器                                   |
| MEM-024 | [ddr_ecc_controller](ips/memory/ddr/ddr_ecc_controller/README.md)                  | ip        | planned | P2     | 0.1.0 | DDR ECC 控制器                               |
| MEM-025 | [ddr_phy_wrapper](ips/memory/ddr/ddr_phy_wrapper/README.md)                        | wrapper   | planned | P2     | 0.1.0 | DDR PHY Wrapper                              |
| MEM-026 | [ddr_scheduler](ips/memory/ddr/ddr_scheduler/README.md)                            | ip        | planned | P2     | 0.1.0 | DDR 调度器                                   |
| MEM-034 | [memory_encryption_engine](ips/memory/security/memory_encryption_engine/README.md) | ip        | planned | P3     | 0.1.0 | 内存加密引擎                                 |

#### mmu（4，已交付=0）

| ID      | IP                                               | 类型 | 状态    | 优先级 | 版本  | 功能/描述                                                                                                                     |
|---------|--------------------------------------------------|------|---------|--------|-------|-------------------------------------------------------------------------------------------------------------------------------|
| MMU-001 | [iommu](ips/mmu/iommu/iommu/README.md)           | ip   | planned | P2     | 0.1.0 | IOMMU                                                                                                                         |
| MMU-002 | [mmu](ips/mmu/mmu/mmu/README.md)                 | ip   | planned | P2     | 0.1.0 | 内存管理单元（MMU）                                                                                                           |
| MMU-003 | [mpu](ips/mmu/mpu/mpu/README.md)                 | ip   | planned | P2     | 0.1.0 | 内存保护单元；规划 AXI 集成剖面，支持地址窗口、可信 MASTERID 与 AxPROT 权限判断、拒绝响应及异常管理；核心权限比较可复用 CBB。 |
| MMU-004 | [pmp_manager](ips/mmu/pmp/pmp_manager/README.md) | ip   | planned | P2     | 0.1.0 | RISC-V PMP 管理器                                                                                                             |

#### multimedia（4，已交付=0）

| ID      | IP                                                              | 类型 | 状态    | 优先级 | 版本  | 功能/描述  |
|---------|-----------------------------------------------------------------|------|---------|--------|-------|------------|
| MUL-001 | [audio_dma](ips/multimedia/audio/audio_dma/README.md)           | ip   | planned | P2     | 0.1.0 | 音频 DMA   |
| MUL-004 | [i2s_controller](ips/multimedia/audio/i2s_controller/README.md) | ip   | planned | P2     | 0.1.0 | I2S 控制器 |
| MUL-008 | [pdm_controller](ips/multimedia/audio/pdm_controller/README.md) | ip   | planned | P2     | 0.1.0 | PDM 控制器 |
| MUL-009 | [tdm_controller](ips/multimedia/audio/tdm_controller/README.md) | ip   | planned | P2     | 0.1.0 | TDM 控制器 |

#### network（6，已交付=0）

| ID      | IP                                                                  | 类型 | 状态    | 优先级 | 版本  | 功能/描述   |
|---------|---------------------------------------------------------------------|------|---------|--------|-------|-------------|
| NET-001 | [ipsec_engine](ips/network/security/ipsec_engine/README.md)         | ip   | planned | P3     | 0.1.0 | IPsec 引擎  |
| NET-002 | [macsec_engine](ips/network/security/macsec_engine/README.md)       | ip   | planned | P3     | 0.1.0 | MACsec 引擎 |
| NET-003 | [packet_classifier](ips/network/packet/packet_classifier/README.md) | ip   | planned | P3     | 0.1.0 | 报文分类器  |
| NET-004 | [packet_parser](ips/network/packet/packet_parser/README.md)         | ip   | planned | P3     | 0.1.0 | 报文解析器  |
| NET-005 | [qos_scheduler](ips/network/qos/qos_scheduler/README.md)            | ip   | planned | P3     | 0.1.0 | QoS 调度器  |
| NET-006 | [traffic_manager](ips/network/qos/traffic_manager/README.md)        | ip   | planned | P3     | 0.1.0 | 流量管理器  |

#### peripheral（25，已交付=1）

| ID      | IP                                                                            | 类型 | 状态        | 优先级 | 版本  | 功能/描述                                                                                 |
|---------|-------------------------------------------------------------------------------|------|-------------|--------|-------|-------------------------------------------------------------------------------------------|
| PER-001 | [gpio](ips/peripheral/io/gpio/README.md)                                      | ip   | planned     | P0     | 0.1.0 | 通用 GPIO                                                                                 |
| PER-002 | [i2c_master](ips/peripheral/serial/i2c_master/README.md)                      | ip   | planned     | P0     | 0.1.0 | I2C 主机                                                                                  |
| PER-003 | [i2c_slave](ips/peripheral/serial/i2c_slave/README.md)                        | ip   | planned     | P0     | 0.1.0 | I2C 从机                                                                                  |
| PER-004 | [pwm](ips/peripheral/timer/pwm/README.md)                                     | ip   | planned     | P0     | 0.1.0 | PWM 控制器                                                                                |
| PER-005 | [spi_master](ips/peripheral/serial/spi_master/README.md)                      | ip   | implemented | P0     | 1.0.0 | APB4 队列式 SPI master（四模式、暂停/中止，已完成仿真与 28nm 综合；候选实现，未量产冻结） |
| PER-006 | [spi_slave](ips/peripheral/serial/spi_slave/README.md)                        | ip   | planned     | P0     | 0.1.0 | SPI 从机                                                                                  |
| PER-007 | [timer](ips/peripheral/timer/timer/README.md)                                 | ip   | planned     | P0     | 0.1.0 | APB 定时器 IP（定时核 + CSR + 中断接口）                                                  |
| PER-008 | [uart](ips/boyangwang1991-design/uart/0.1.0/README.md)                        | ip   | planned     | P0     | 0.1.0 | 通用 UART（APB 接口，含 CSR/RX/TX，G0-G5 曾通过；工作区目录未落盘，待恢复）               |
| PER-009 | [watchdog](ips/peripheral/timer/watchdog/README.md)                           | ip   | planned     | P0     | 0.1.0 | APB 看门狗 IP（看门狗核 + CSR + 复位/中断策略）                                           |
| PER-010 | [can](ips/peripheral/automotive/can/README.md)                                | ip   | planned     | P1     | 0.1.0 | CAN 控制器                                                                                |
| PER-011 | [can_fd](ips/peripheral/automotive/can_fd/README.md)                          | ip   | planned     | P1     | 0.1.0 | CAN-FD 控制器                                                                             |
| PER-012 | [doorbell_controller](ips/peripheral/intercore/doorbell_controller/README.md) | ip   | planned     | P1     | 0.1.0 | 门铃（Doorbell）控制器                                                                    |
| PER-013 | [emmc_controller](ips/peripheral/storage/emmc_controller/README.md)           | ip   | planned     | P1     | 0.1.0 | eMMC 控制器                                                                               |
| PER-014 | [hardware_semaphore](ips/peripheral/intercore/hardware_semaphore/README.md)   | ip   | planned     | P1     | 0.1.0 | 硬件信号量                                                                                |
| PER-015 | [i3c_controller](ips/peripheral/serial/i3c_controller/README.md)              | ip   | planned     | P1     | 0.1.0 | I3C 控制器                                                                                |
| PER-016 | [input_capture](ips/peripheral/timer/input_capture/README.md)                 | ip   | planned     | P1     | 0.1.0 | 输入捕获                                                                                  |
| PER-017 | [lin](ips/peripheral/automotive/lin/README.md)                                | ip   | planned     | P1     | 0.1.0 | LIN 控制器                                                                                |
| PER-018 | [mailbox](ips/peripheral/intercore/mailbox/README.md)                         | ip   | planned     | P1     | 0.1.0 | 核间邮箱                                                                                  |
| PER-019 | [ospi](ips/peripheral/serial/ospi/README.md)                                  | ip   | planned     | P1     | 0.1.0 | OSPI 控制器                                                                               |
| PER-020 | [output_compare](ips/peripheral/timer/output_compare/README.md)               | ip   | planned     | P1     | 0.1.0 | 输出比较                                                                                  |
| PER-021 | [qspi](ips/peripheral/serial/qspi/README.md)                                  | ip   | planned     | P1     | 0.1.0 | QSPI 控制器                                                                               |
| PER-022 | [quadrature_encoder](ips/peripheral/timer/quadrature_encoder/README.md)       | ip   | planned     | P1     | 0.1.0 | 正交编码器接口                                                                            |
| PER-023 | [rtc](ips/peripheral/timer/rtc/README.md)                                     | ip   | planned     | P1     | 0.1.0 | 实时时钟（RTC）                                                                           |
| PER-024 | [sd_host](ips/peripheral/storage/sd_host/README.md)                           | ip   | planned     | P1     | 0.1.0 | SD Host 控制器                                                                            |
| PER-025 | [sdio](ips/peripheral/storage/sdio/README.md)                                 | ip   | planned     | P1     | 0.1.0 | SDIO 控制器                                                                               |

#### reliability（4，已交付=0）

| ID      | IP                                                                                 | 类型 | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|------------------------------------------------------------------------------------|------|---------|--------|-------|--------------------|
| REL-002 | [ecc_telemetry_controller](ips/reliability/ecc/ecc_telemetry_controller/README.md) | ip   | planned | P3     | 0.1.0 | ECC 遥测控制器     |
| REL-003 | [reliability_monitor](ips/reliability/monitor/reliability_monitor/README.md)       | ip   | planned | P3     | 0.1.0 | 可靠性监控器       |
| REL-004 | [soft_error_counter](ips/reliability/monitor/soft_error_counter/README.md)         | ip   | planned | P3     | 0.1.0 | 软错误计数器       |
| REL-005 | [sram_patrol_controller](ips/reliability/sram/sram_patrol_controller/README.md)    | ip   | planned | P3     | 0.1.0 | SRAM Patrol 控制器 |

#### safety（20，已交付=0）

| ID      | IP                                                                                       | 类型 | 状态    | 优先级 | 版本  | 功能/描述                               |
|---------|------------------------------------------------------------------------------------------|------|---------|--------|-------|-----------------------------------------|
| SAF-001 | [ecc_memory_controller](ips/safety/ecc/ecc_memory_controller/README.md)                  | ip   | planned | P0     | 0.1.0 | ECC 内存控制器                          |
| SAF-002 | [error_injection_controller](ips/safety/fault/error_injection_controller/README.md)      | ip   | planned | P0     | 0.1.0 | 错误注入控制器                          |
| SAF-003 | [fault_manager](ips/safety/fault/fault_manager/README.md)                                | ip   | planned | P0     | 0.1.0 | 故障管理器                              |
| SAF-004 | [register_parity_controller](ips/safety/parity/register_parity_controller/README.md)     | ip   | planned | P0     | 0.1.0 | 寄存器奇偶校验控制器                    |
| SAF-005 | [safety_watchdog](ips/safety/watchdog/safety_watchdog/README.md)                         | ip   | planned | P0     | 0.1.0 | 安全看门狗                              |
| SAF-006 | [bus_crc_monitor](ips/safety/crc/bus_crc_monitor/README.md)                              | ip   | planned | P1     | 0.1.0 | 总线 CRC 监控                           |
| SAF-007 | [bus_parity_monitor](ips/safety/parity/bus_parity_monitor/README.md)                     | ip   | planned | P1     | 0.1.0 | 总线奇偶校验监控                        |
| SAF-008 | [clock_safety_monitor](ips/safety/monitor/clock_safety_monitor/README.md)                | ip   | planned | P1     | 0.1.0 | 时钟安全监控                            |
| SAF-009 | [diagnostic_controller](ips/safety/diagnostic/diagnostic_controller/README.md)           | ip   | planned | P1     | 0.1.0 | 诊断控制器                              |
| SAF-010 | [fault_response_controller](ips/safety/fault/fault_response_controller/README.md)        | ip   | planned | P1     | 0.1.0 | 故障响应控制器                          |
| SAF-011 | [lockstep_controller](ips/safety/lockstep/lockstep_controller/README.md)                 | ip   | planned | P1     | 0.1.0 | 锁步控制器                              |
| SAF-012 | [reset_safety_monitor](ips/safety/monitor/reset_safety_monitor/README.md)                | ip   | planned | P1     | 0.1.0 | 复位安全监控                            |
| SAF-013 | [safe_state_controller](ips/safety/state/safe_state_controller/README.md)                | ip   | planned | P1     | 0.1.0 | 安全状态控制器                          |
| SAF-014 | [safety_manager](ips/safety/fault/safety_manager/README.md)                              | ip   | planned | P1     | 0.1.0 | 安全管理器                              |
| SAF-016 | [e2e_crc_engine](ips/safety/crc/e2e_crc_engine/README.md)                                | ip   | planned | P2     | 0.1.0 | 端到端 CRC 引擎                         |
| SAF-017 | [fccu](ips/safety/fault/fccu/README.md)                                                  | ip   | planned | P2     | 0.1.0 | Fault Collection & Control Unit（FCCU） |
| SAF-018 | [lbist_safety_manager](ips/safety/lbist/lbist_safety_manager/README.md)                  | ip   | planned | P2     | 0.1.0 | LBIST 安全管理器                        |
| SAF-019 | [mbist_safety_manager](ips/safety/mbist/mbist_safety_manager/README.md)                  | ip   | planned | P2     | 0.1.0 | MBIST 安全管理器                        |
| SAF-020 | [ram_repair_safety_controller](ips/safety/repair/ram_repair_safety_controller/README.md) | ip   | planned | P2     | 0.1.0 | RAM 修复安全控制器                      |
| SAF-021 | [safety_event_router](ips/safety/fault/safety_event_router/README.md)                    | ip   | planned | P2     | 0.1.0 | 安全事件路由器                          |

#### security（27，已交付=0）

| ID      | IP                                                                                           | 类型      | 状态    | 优先级 | 版本  | 功能/描述                               |
|---------|----------------------------------------------------------------------------------------------|-----------|---------|--------|-------|-----------------------------------------|
| SEC-001 | [aes](ips/security/crypto/aes/README.md)                                                     | ip        | planned | P0     | 0.1.0 | AES 加解密引擎                          |
| SEC-002 | [hmac](ips/security/crypto/hmac/README.md)                                                   | ip        | planned | P0     | 0.1.0 | HMAC 引擎                               |
| SEC-003 | [key_manager](ips/security/key/key_manager/README.md)                                        | ip        | planned | P0     | 0.1.0 | 密钥管理器                              |
| SEC-004 | [otp_efuse_controller](ips/security/efuse/otp_efuse_controller/README.md)                    | generator | planned | P0     | 0.1.0 | OTP/eFuse 控制器                        |
| SEC-005 | [secure_boot_controller](ips/security/secure_boot/secure_boot_controller/README.md)          | ip        | planned | P0     | 0.1.0 | 安全启动控制器                          |
| SEC-006 | [sha2](ips/security/crypto/sha2/README.md)                                                   | ip        | planned | P0     | 0.1.0 | SHA-2 哈希引擎                          |
| SEC-007 | [trng](ips/security/crypto/trng/README.md)                                                   | ip        | planned | P0     | 0.1.0 | 真随机数发生器（TRNG）                  |
| SEC-008 | [anti_rollback_controller](ips/security/secure_boot/anti_rollback_controller/README.md)      | ip        | planned | P1     | 0.1.0 | 防回滚控制器                            |
| SEC-009 | [bus_firewall](ips/security/firewall/bus_firewall/README.md)                                 | ip        | planned | P1     | 0.1.0 | 总线防火墙                              |
| SEC-010 | [crypto_dma](ips/security/crypto/crypto_dma/README.md)                                       | ip        | planned | P1     | 0.1.0 | 密码 DMA                                |
| SEC-011 | [csrng_drbg](ips/security/crypto/csrng_drbg/README.md)                                       | ip        | planned | P1     | 0.1.0 | CSRNG/DRBG 确定性随机源                 |
| SEC-012 | [dma_firewall](ips/security/firewall/dma_firewall/README.md)                                 | ip        | planned | P1     | 0.1.0 | DMA 防火墙                              |
| SEC-013 | [ecc_crypto](ips/security/crypto/ecc_crypto/README.md)                                       | ip        | planned | P1     | 0.1.0 | 椭圆曲线密码（ECC）引擎                 |
| SEC-014 | [key_vault](ips/security/key/key_vault/README.md)                                            | ip        | planned | P1     | 0.1.0 | 密钥保险库                              |
| SEC-015 | [memory_protection_controller](ips/security/firewall/memory_protection_controller/README.md) | ip        | planned | P1     | 0.1.0 | 内存保护控制器                          |
| SEC-016 | [register_firewall](ips/security/firewall/register_firewall/README.md)                       | ip        | planned | P1     | 0.1.0 | 寄存器防火墙                            |
| SEC-017 | [rsa](ips/security/crypto/rsa/README.md)                                                     | ip        | planned | P1     | 0.1.0 | RSA 公钥引擎                            |
| SEC-018 | [secure_debug_controller](ips/security/secure_debug/secure_debug_controller/README.md)       | ip        | planned | P1     | 0.1.0 | 安全调试控制器                          |
| SEC-019 | [secure_mailbox](ips/security/secure_io/secure_mailbox/README.md)                            | ip        | planned | P1     | 0.1.0 | 安全邮箱                                |
| SEC-020 | [sha3](ips/security/crypto/sha3/README.md)                                                   | ip        | planned | P1     | 0.1.0 | SHA-3 哈希引擎                          |
| SEC-021 | [key_ladder](ips/security/key/key_ladder/README.md)                                          | ip        | planned | P2     | 0.1.0 | 密钥阶梯派生                            |
| SEC-022 | [life_cycle_controller](ips/security/secure_boot/life_cycle_controller/README.md)            | ip        | planned | P2     | 0.1.0 | 生命周期控制器                          |
| SEC-023 | [monotonic_counter](ips/security/counter/monotonic_counter/README.md)                        | ip        | planned | P2     | 0.1.0 | 单调计数器                              |
| SEC-024 | [puf_controller](ips/security/puf/puf_controller/README.md)                                  | ip        | planned | P2     | 0.1.0 | PUF 控制器                              |
| SEC-025 | [secure_counter](ips/security/counter/secure_counter/README.md)                              | ip        | planned | P2     | 0.1.0 | 安全计数器                              |
| SEC-026 | [tamper_detector](ips/security/tamper/tamper_detector/README.md)                             | ip        | planned | P2     | 0.1.0 | 篡改检测器                              |
| SEC-027 | [pqc](ips/security/crypto/pqc/README.md)                                                     | ip        | planned | P0     | 0.1.0 | 可配置 ML-KEM + ML-DSA 后量子密码加速器 |

#### system（39，已交付=0）

| ID      | IP                                                                                      | 类型      | 状态    | 优先级 | 版本  | 功能/描述                                                  |
|---------|-----------------------------------------------------------------------------------------|-----------|---------|--------|-------|------------------------------------------------------------|
| SYS-001 | [axi_dma](ips/system/dma/axi_dma/README.md)                                             | ip        | planned | P0     | 0.1.0 | AXI DMA                                                    |
| SYS-002 | [boot_controller](ips/system/boot/boot_controller/README.md)                            | ip        | planned | P0     | 0.1.0 | 启动控制器                                                 |
| SYS-003 | [chip_id_revision](ips/system/clock_reset/chip_id_revision/README.md)                   | ip        | planned | P0     | 0.1.0 | Chip ID / Revision ID                                      |
| SYS-004 | [clint](ips/system/interrupt/clint/README.md)                                           | ip        | planned | P0     | 0.1.0 | RISC-V CLINT（核本地定时器中断）                           |
| SYS-005 | [clock_controller](ips/system/clock_reset/clock_controller/README.md)                   | generator | planned | P0     | 0.1.0 | 时钟控制器                                                 |
| SYS-006 | [clock_monitor](ips/system/clock_reset/clock_monitor/README.md)                         | ip        | planned | P0     | 0.1.0 | 时钟监控器                                                 |
| SYS-007 | [crg](ips/system/clock_reset/crg/README.md)                                             | generator | planned | P0     | 0.1.0 | 时钟+复位生成器（CRG）                                     |
| SYS-009 | [interrupt_aggregator](ips/system/interrupt/interrupt_aggregator/README.md)             | ip        | planned | P0     | 0.1.0 | 系统级中断聚合 IP（集成状态/屏蔽/告警与 CSR）              |
| SYS-010 | [interrupt_gateway](ips/system/interrupt/interrupt_gateway/README.md)                   | ip        | planned | P0     | 0.1.0 | 中断网关                                                   |
| SYS-011 | [interrupt_router](ips/system/interrupt/interrupt_router/README.md)                     | generator | planned | P0     | 0.1.0 | 系统级中断路由生成器（集成配置、目标接口与 CSR）           |
| SYS-013 | [mem2mem_dma](ips/system/dma/mem2mem_dma/README.md)                                     | ip        | planned | P0     | 0.1.0 | 内存到内存 DMA                                             |
| SYS-014 | [multi_channel_dma](ips/system/dma/multi_channel_dma/README.md)                         | generator | planned | P0     | 0.1.0 | 多通道 DMA                                                 |
| SYS-015 | [plic](ips/system/interrupt/plic/README.md)                                             | ip        | planned | P0     | 0.1.0 | RISC-V PLIC（平台级中断控制器）                            |
| SYS-016 | [reset_controller](ips/system/clock_reset/reset_controller/README.md)                   | generator | planned | P0     | 0.1.0 | 复位控制器                                                 |
| SYS-017 | [reset_monitor](ips/system/clock_reset/reset_monitor/README.md)                         | ip        | planned | P0     | 0.1.0 | 系统级复位监督器（集成原因/顺序/持续时间监控、告警与 CSR） |
| SYS-018 | [reset_reason_controller](ips/system/clock_reset/reset_reason_controller/README.md)     | ip        | planned | P0     | 0.1.0 | 复位原因控制器                                             |
| SYS-019 | [simple_dma](ips/system/dma/simple_dma/README.md)                                       | ip        | planned | P0     | 0.1.0 | 简单 DMA                                                   |
| SYS-020 | [system_controller](ips/system/clock_reset/system_controller/README.md)                 | ip        | planned | P0     | 0.1.0 | 系统控制器                                                 |
| SYS-021 | [aia](ips/system/interrupt/aia/README.md)                                               | ip        | planned | P1     | 0.1.0 | RISC-V Advanced Interrupt Architecture（AIA）              |
| SYS-022 | [data_mover](ips/system/dma/data_mover/README.md)                                       | ip        | planned | P1     | 0.1.0 | 数据搬运器                                                 |
| SYS-023 | [descriptor_engine](ips/system/dma/descriptor_engine/README.md)                         | ip        | planned | P1     | 0.1.0 | 描述符引擎                                                 |
| SYS-024 | [event_router](ips/system/interrupt/event_router/README.md)                             | generator | planned | P1     | 0.1.0 | 系统级事件路由生成器（集成映射配置、时钟域与 CSR）         |
| SYS-025 | [isolation_controller](ips/system/power/isolation_controller/README.md)                 | ip        | planned | P1     | 0.1.0 | 隔离控制器                                                 |
| SYS-026 | [peripheral_dma](ips/system/dma/peripheral_dma/README.md)                               | ip        | planned | P1     | 0.1.0 | 外设 DMA                                                   |
| SYS-027 | [power_domain_controller](ips/system/power/power_domain_controller/README.md)           | ip        | planned | P1     | 0.1.0 | 电源域控制器                                               |
| SYS-028 | [power_manager](ips/system/power/power_manager/README.md)                               | ip        | planned | P1     | 0.1.0 | 电源管理器                                                 |
| SYS-029 | [power_sequencer](ips/system/power/power_sequencer/README.md)                           | ip        | planned | P1     | 0.1.0 | 电源时序控制器                                             |
| SYS-030 | [retention_controller](ips/system/power/retention_controller/README.md)                 | ip        | planned | P1     | 0.1.0 | 保持控制器                                                 |
| SYS-031 | [scatter_gather_dma](ips/system/dma/scatter_gather_dma/README.md)                       | ip        | planned | P1     | 0.1.0 | Scatter-Gather DMA                                         |
| SYS-032 | [sleep_controller](ips/system/power/sleep_controller/README.md)                         | ip        | planned | P1     | 0.1.0 | 睡眠控制器                                                 |
| SYS-033 | [stream_dma](ips/system/dma/stream_dma/README.md)                                       | ip        | planned | P1     | 0.1.0 | 流式 DMA                                                   |
| SYS-034 | [wakeup_controller](ips/system/power/wakeup_controller/README.md)                       | ip        | planned | P1     | 0.1.0 | 唤醒控制器                                                 |
| SYS-035 | [wakeup_event_controller](ips/system/interrupt/wakeup_event_controller/README.md)       | ip        | planned | P1     | 0.1.0 | 唤醒事件控制器                                             |
| SYS-036 | [adaptive_clocking_controller](ips/system/power/adaptive_clocking_controller/README.md) | ip        | planned | P3     | 0.1.0 | 自适应时钟控制器                                           |
| SYS-037 | [avs_controller](ips/system/power/avs_controller/README.md)                             | ip        | planned | P3     | 0.1.0 | AVS 控制器（自适应电压调节）                               |
| SYS-038 | [droop_mitigation_controller](ips/system/power/droop_mitigation_controller/README.md)   | ip        | planned | P3     | 0.1.0 | 电压跌落缓解控制器                                         |
| SYS-039 | [droop_monitor](ips/system/power/droop_monitor/README.md)                               | ip        | planned | P3     | 0.1.0 | 电压跌落监控器                                             |
| SYS-040 | [dvfs_controller](ips/system/power/dvfs_controller/README.md)                           | ip        | planned | P3     | 0.1.0 | DVFS 控制器                                                |
| SYS-041 | [thermal_manager](ips/system/power/thermal_manager/README.md)                           | ip        | planned | P3     | 0.1.0 | 热管理单元                                                 |

#### test（2，已交付=0）

| ID      | IP                                                                                     | 类型 | 状态    | 优先级 | 版本  | 功能/描述      |
|---------|----------------------------------------------------------------------------------------|------|---------|--------|-------|----------------|
| TST-001 | [infield_test_controller](ips/test/infield/infield_test_controller/README.md)          | ip   | planned | P3     | 0.1.0 | 在线测试控制器 |
| TST-002 | [production_test_controller](ips/test/production/production_test_controller/README.md) | ip   | planned | P3     | 0.1.0 | 量产测试控制器 |


<!-- IP-CATALOG-STATUS:END -->
