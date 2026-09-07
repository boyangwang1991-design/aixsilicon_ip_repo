# aixsilicon_ip_repo - IP Unified Repository

统一 IP 仓库（monorepo）。承载所有 IP 内容，按 `ips/<domain>/<subdomain>/<name>/`（规划）或
`ips/<vendor>/<ip>/<version>/`（已交付）组织，内嵌 `registry.yaml` 索引（唯一 SSOT）。
FuseSoC 只 add 这一个仓即可发现全部 IP。

本仓命名空间：`aixsilicon:ip:<ip>:<version>`（ADR-0003 统一 VLNV vendor；组织名 `boyangwang1991-design` 仅作为 remote URL 归属）

> 迁移注记：历史发布的 `boyangwang1991-design:ip:*` 核心进入 deprecated 别名窗口，
> 由 `ipkg` 下次发布时统一改写为 `aixsilicon:ip:*`；已锁定旧 VLNV 的 Lockfile 需同步更新。

## 目录结构

```text
aixsilicon_ip_repo/
├── README.md                     # 仓库说明 + IP 状态总览（脚本自动刷新）
├── ipkg.yaml                     # ipkg 配置（统一仓）
├── registry.yaml                 # IP 目录唯一 SSOT（由 scripts/build_ip_registry.py 生成/治理）
├── ips/
│   ├── <domain>/<subdomain>/<ip>/   # 规划条目（planned）与新建 IP 的工作目录
│   └── <vendor>/<ip>/<version>/     # 已交付/已纳管 IP 的版本目录（含 ip-package.yaml / metadata.yaml）
├── scripts/
│   ├── build_ip_registry.py      # registry.yaml 生成/校验/规范化（消费 scripts/data/*.py 清单）
│   ├── update_registry_readme.py # 将 registry.yaml 状态总览刷新到 README.md
│   ├── ip_status.py              # 按优先级/类型/领域/状态查询 IP
│   ├── ip_lib.py                 # 公共库（校验/表格）
│   └── data/                     # IP 清单数据（P0/P1/P2/P3）
└── .github/workflows/
    └── ci.yml                    # 统一仓 CI
```

## 用法

### 添加统一仓（消费者，一次性）

```bash
fusesoc library add aixsilicon_ip_repo https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git
```

### 搜索 IP

```bash
ipkg search gpio
ipkg list
ipkg info <ip> <version>
```

### IP 状态查询（registry.yaml SSOT）

```bash
python3 scripts/ip_status.py --priority P0            # P0 全部 IP
python3 scripts/ip_status.py --status released        # 已发布 IP
python3 scripts/ip_status.py --type generator         # Generator 类 IP
python3 scripts/ip_status.py --domain infrastructure  # 基础互联领域
python3 scripts/ip_status.py --name uart              # 按名称搜索
python3 scripts/ip_status.py --stats                  # 状态/优先级/类型统计
python3 scripts/ip_status.py --format csv             # CSV 输出
```

### 维护 registry.yaml（SSOT）

```bash
# 1. 修改 scripts/data/*.py 清单（新增/调整 IP）
python3 scripts/build_ip_registry.py --generate        # 重新生成 registry.yaml
python3 scripts/build_ip_registry.py --check           # 只读校验（implemented 目录实态）
python3 scripts/build_ip_registry.py --write           # 规范化重写（更新时间戳）

# 2. 刷新 README 状态总览（改 registry 后必须运行）
python3 scripts/update_registry_readme.py              # 就地刷新 README.md
python3 scripts/update_registry_readme.py --check      # 只读检查一致性
```

### 入库新 IP / 新版本（发布侧）

```bash
# 1. 从构建结果入库
ipkg stage <ip-workspace> --unified . --then-index

# 2. 提交推送（含 tag）
ipkg publish .
```

索引与内容在同一提交中更新，无需独立 PR。

## registry.yaml 条目格式

```yaml
schema_version: "2.0"
vendor: aixsilicon
library: ip

ips:
  - id: PER-008              # 自动分配（按领域前缀 + 序号）
    name: uart
    domain: peripheral
    subdomain: serial
    type: ip                 # ip | generator | wrapper | subsystem
    priority: P0             # P0~P3
    status: released         # planned | implemented | released | deprecated
    maturity: beta           # experimental | alpha | beta | production | legacy
    version: "0.1.0"
    interfaces: [apb4]
    description: "..."
    path: ips/boyangwang1991-design/uart/0.1.0
    vendor: boyangwang1991-design   # 非 aixsilicon 命名空间时出现
    core: boyangwang1991-design:ip:uart:0.1.0
```

**规则**：
- `registry.yaml` 是**唯一 SSOT**，由 `scripts/build_ip_registry.py` 生成；
- `status=implemented/released` 必须有对应物理目录（校验强制）；
- `planned` 条目为规划候选，无物理目录；
- 已交付 IP 使用 `ips/<vendor>/<ip>/<version>/` 布局，规划 IP 使用 `ips/<domain>/<subdomain>/<name>/` 布局。

## IP 状态总览

> 以下状态总览由 [`scripts/update_registry_readme.py`](scripts/update_registry_readme.py) 依据
> [`registry.yaml`](registry.yaml:1)（SSOT）自动生成；**修改 `registry.yaml` 后必须运行**
> `python3 scripts/update_registry_readme.py` 刷新本节，勿手工编辑。

<!-- IP-CATALOG-STATUS:BEGIN -->
> 本节由 `scripts/update_registry_readme.py` 依据 `registry.yaml`（SSOT）自动生成。
> 修改 `registry.yaml` 后必须运行 `python3 scripts/update_registry_readme.py` 刷新本节；勿手工编辑。
> 最后更新：`2026-09-07T02:41:36Z`

### 总览

| 指标                         | 数量 |
|------------------------------|------|
| 总条目（ips）                | 369  |
| released（已发布）           | 0    |
| implemented（已实现/已交付） | 1    |
| planned（规划候选）          | 368  |
| deprecated（已废弃）         | 0    |
| 实现率                       | 0.3% |

### 已发布 / 已实现 / 已纳管 IP（1）

| ID      | IP                                                                   | 类型 | 优先级 | 状态        | 版本  | 领域           |
|---------|----------------------------------------------------------------------|------|--------|-------------|-------|----------------|
| INF-011 | [axi2apb_bridge](ips/infrastructure/bridge/axi2apb_bridge/README.md) | ip   | P0     | implemented | 1.0.0 | infrastructure |

### 按优先级分布（released+implemented / planned）

| 优先级 | 已交付 | planned | 合计 |
|--------|--------|---------|------|
| P0     | 1      | 89      | 90   |
| P1     | 0      | 98      | 98   |
| P2     | 0      | 100     | 100  |
| P3     | 0      | 81      | 81   |

### 按类型分布

| 类型      | 数量 |
|-----------|------|
| generator | 18   |
| ip        | 325  |
| subsystem | 10   |
| wrapper   | 16   |

### 按领域分布（顶层 domain）

| 领域           | 数量 |
|----------------|------|
| accelerator    | 23   |
| analog         | 7    |
| automotive     | 7    |
| cache          | 7    |
| chip           | 8    |
| chiplet        | 10   |
| coherency      | 10   |
| compute        | 7    |
| crypto         | 3    |
| debug_trace    | 13   |
| dft            | 8    |
| high_speed_io  | 11   |
| infrastructure | 55   |
| memory         | 35   |
| mmu            | 4    |
| multimedia     | 14   |
| network        | 6    |
| peripheral     | 25   |
| phy            | 4    |
| reliability    | 5    |
| safety         | 24   |
| security       | 26   |
| subsystem      | 10   |
| system         | 41   |
| test           | 3    |
| virtualization | 3    |

### 全部 IP 明细（369，按领域分组）

#### accelerator（23，已交付=0）

| ID     | IP                                                                                                       | 类型 | 状态    | 优先级 | 版本  | 功能/描述            |
|--------|----------------------------------------------------------------------------------------------------------|------|---------|--------|-------|----------------------|
| AI-001 | [accelerator_descriptor_engine](ips/accelerator/scheduler/accelerator_descriptor_engine/README.md)       | ip   | planned | P3     | 0.1.0 | 加速器描述符引擎     |
| AI-002 | [accelerator_interrupt_aggregator](ips/accelerator/interrupt/accelerator_interrupt_aggregator/README.md) | ip   | planned | P3     | 0.1.0 | 加速器中断聚合器     |
| AI-003 | [accelerator_scheduler](ips/accelerator/scheduler/accelerator_scheduler/README.md)                       | ip   | planned | P3     | 0.1.0 | 加速器调度器         |
| AI-004 | [activation_engine](ips/accelerator/activation/activation_engine/README.md)                              | ip   | planned | P3     | 0.1.0 | 激活函数引擎         |
| AI-005 | [ai_scratchpad_controller](ips/accelerator/memory/ai_scratchpad_controller/README.md)                    | ip   | planned | P3     | 0.1.0 | AI Scratchpad 控制器 |
| AI-006 | [attention_accelerator](ips/accelerator/attention/attention_accelerator/README.md)                       | ip   | planned | P3     | 0.1.0 | 注意力加速器         |
| AI-007 | [convolution_accelerator](ips/accelerator/conv/convolution_accelerator/README.md)                        | ip   | planned | P3     | 0.1.0 | 卷积加速器           |
| AI-008 | [cordic](ips/accelerator/dsp/cordic/README.md)                                                           | ip   | planned | P3     | 0.1.0 | CORDIC 单元          |
| AI-009 | [crc_accelerator](ips/accelerator/dsp/crc_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | CRC 加速器           |
| AI-010 | [dct_accelerator](ips/accelerator/dsp/dct_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | DCT 加速器           |
| AI-011 | [dequantization_engine](ips/accelerator/quant/dequantization_engine/README.md)                           | ip   | planned | P3     | 0.1.0 | 反量化引擎           |
| AI-012 | [fft_accelerator](ips/accelerator/dsp/fft_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | FFT 加速器           |
| AI-013 | [fir_accelerator](ips/accelerator/dsp/fir_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | FIR 加速器           |
| AI-014 | [iir_accelerator](ips/accelerator/dsp/iir_accelerator/README.md)                                         | ip   | planned | P3     | 0.1.0 | IIR 加速器           |
| AI-015 | [matrix_multiply_accelerator](ips/accelerator/matmul/matrix_multiply_accelerator/README.md)              | ip   | planned | P3     | 0.1.0 | 矩阵乘加速器         |
| AI-016 | [quantization_engine](ips/accelerator/quant/quantization_engine/README.md)                               | ip   | planned | P3     | 0.1.0 | 量化引擎             |
| AI-017 | [sparse_accelerator](ips/accelerator/sparse/sparse_accelerator/README.md)                                | ip   | planned | P3     | 0.1.0 | 稀疏加速器           |
| AI-018 | [stream_fabric](ips/accelerator/fabric/stream_fabric/README.md)                                          | ip   | planned | P3     | 0.1.0 | 流式互联 Fabric      |
| AI-019 | [systolic_array](ips/accelerator/systolic/systolic_array/README.md)                                      | ip   | planned | P3     | 0.1.0 | 脉动阵列             |
| AI-020 | [tensor_core](ips/accelerator/matmul/tensor_core/README.md)                                              | ip   | planned | P3     | 0.1.0 | 张量核               |
| AI-021 | [tensor_dma](ips/accelerator/dma/tensor_dma/README.md)                                                   | ip   | planned | P3     | 0.1.0 | 张量 DMA             |
| AI-022 | [vector_accelerator](ips/accelerator/vector/vector_accelerator/README.md)                                | ip   | planned | P3     | 0.1.0 | 向量加速器           |
| AI-023 | [weight_dma](ips/accelerator/dma/weight_dma/README.md)                                                   | ip   | planned | P3     | 0.1.0 | 权重 DMA             |

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

#### automotive（7，已交付=0）

| ID      | IP                                                                                         | 类型 | 状态    | 优先级 | 版本  | 功能/描述              |
|---------|--------------------------------------------------------------------------------------------|------|---------|--------|-------|------------------------|
| AUT-001 | [automotive_ethernet](ips/automotive/ethernet/automotive_ethernet/README.md)               | ip   | planned | P2     | 0.1.0 | 车载以太网控制器       |
| AUT-002 | [e2e_protection_engine](ips/automotive/safety/e2e_protection_engine/README.md)             | ip   | planned | P2     | 0.1.0 | E2E 保护引擎（端到端） |
| AUT-003 | [flexray_controller](ips/automotive/flexray/flexray_controller/README.md)                  | ip   | planned | P2     | 0.1.0 | FlexRay 控制器         |
| AUT-004 | [psi5_controller](ips/automotive/sensor/psi5_controller/README.md)                         | ip   | planned | P2     | 0.1.0 | PSI5 控制器            |
| AUT-005 | [sensor_interface_controller](ips/automotive/sensor/sensor_interface_controller/README.md) | ip   | planned | P2     | 0.1.0 | 传感器接口控制器       |
| AUT-006 | [sent_controller](ips/automotive/sensor/sent_controller/README.md)                         | ip   | planned | P2     | 0.1.0 | SENT 控制器            |
| AUT-007 | [tsn_controller](ips/automotive/ethernet/tsn_controller/README.md)                         | ip   | planned | P2     | 0.1.0 | TSN 控制器             |

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

#### chiplet（10，已交付=0）

| ID      | IP                                                                                          | 类型 | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|---------------------------------------------------------------------------------------------|------|---------|--------|-------|--------------------|
| CHL-001 | [chiplet_discovery_controller](ips/chiplet/interdie/chiplet_discovery_controller/README.md) | ip   | planned | P3     | 0.1.0 | Chiplet 发现控制器 |
| CHL-002 | [chiplet_mailbox](ips/chiplet/interdie/chiplet_mailbox/README.md)                           | ip   | planned | P3     | 0.1.0 | Chiplet 邮箱       |
| CHL-003 | [die_id_controller](ips/chiplet/interdie/die_id_controller/README.md)                       | ip   | planned | P3     | 0.1.0 | Die ID 控制器      |
| CHL-004 | [die_to_die_adapter](ips/chiplet/die2die/die_to_die_adapter/README.md)                      | ip   | planned | P3     | 0.1.0 | Die-to-Die 适配器  |
| CHL-005 | [die_to_die_crc](ips/chiplet/die2die/die_to_die_crc/README.md)                              | ip   | planned | P3     | 0.1.0 | Die-to-Die CRC     |
| CHL-006 | [interdie_cdc_adapter](ips/chiplet/interdie/interdie_cdc_adapter/README.md)                 | ip   | planned | P3     | 0.1.0 | Die 间 CDC 适配器  |
| CHL-007 | [interdie_interrupt_bridge](ips/chiplet/interdie/interdie_interrupt_bridge/README.md)       | ip   | planned | P3     | 0.1.0 | Die 间中断桥       |
| CHL-008 | [link_training_controller](ips/chiplet/die2die/link_training_controller/README.md)          | ip   | planned | P3     | 0.1.0 | 链路训练控制器     |
| CHL-009 | [retry_controller](ips/chiplet/die2die/retry_controller/README.md)                          | ip   | planned | P3     | 0.1.0 | 重试控制器         |
| CHL-010 | [ucie_controller](ips/chiplet/ucie/ucie_controller/README.md)                               | ip   | planned | P3     | 0.1.0 | UCIe 控制器        |

#### coherency（10，已交付=0）

| ID      | IP                                                                               | 类型 | 状态    | 优先级 | 版本  | 功能/描述           |
|---------|----------------------------------------------------------------------------------|------|---------|--------|-------|---------------------|
| COH-001 | [ace_bridge](ips/coherency/ace/ace_bridge/README.md)                             | ip   | planned | P2     | 0.1.0 | ACE 桥              |
| COH-002 | [ace_lite_bridge](ips/coherency/ace/ace_lite_bridge/README.md)                   | ip   | planned | P2     | 0.1.0 | ACE-Lite 桥         |
| COH-003 | [coherency_manager](ips/coherency/ace/coherency_manager/README.md)               | ip   | planned | P2     | 0.1.0 | 一致性管理器        |
| COH-004 | [chi_home_node](ips/coherency/chi/chi_home_node/README.md)                       | ip   | planned | P3     | 0.1.0 | CHI Home Node       |
| COH-005 | [chi_interface](ips/coherency/chi/chi_interface/README.md)                       | ip   | planned | P3     | 0.1.0 | CHI 接口            |
| COH-006 | [chi_request_node](ips/coherency/chi/chi_request_node/README.md)                 | ip   | planned | P3     | 0.1.0 | CHI Request Node    |
| COH-007 | [chi_router](ips/coherency/chi/chi_router/README.md)                             | ip   | planned | P3     | 0.1.0 | CHI 路由器          |
| COH-008 | [chi_slave_node](ips/coherency/chi/chi_slave_node/README.md)                     | ip   | planned | P3     | 0.1.0 | CHI Slave Node      |
| COH-009 | [coherent_noc](ips/coherency/chi/coherent_noc/README.md)                         | ip   | planned | P3     | 0.1.0 | 一致性 NoC          |
| COH-010 | [distributed_snoop_filter](ips/coherency/chi/distributed_snoop_filter/README.md) | ip   | planned | P3     | 0.1.0 | 分布式 Snoop Filter |

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

| ID      | IP                                                                                   | 类型 | 状态    | 优先级 | 版本  | 功能/描述              |
|---------|--------------------------------------------------------------------------------------|------|---------|--------|-------|------------------------|
| DBG-001 | [debug_register_block](ips/debug_trace/debug/debug_register_block/README.md)         | ip   | planned | P0     | 0.1.0 | 调试寄存器块           |
| DBG-002 | [jtag_tap](ips/debug_trace/jtag/jtag_tap/README.md)                                  | ip   | planned | P0     | 0.1.0 | JTAG TAP 控制器        |
| DBG-003 | [performance_monitor](ips/debug_trace/monitor/performance_monitor/README.md)         | ip   | planned | P0     | 0.1.0 | 性能监控器             |
| DBG-004 | [riscv_debug_module](ips/debug_trace/debug/riscv_debug_module/README.md)             | ip   | planned | P0     | 0.1.0 | RISC-V Debug Module    |
| DBG-005 | [trace_buffer](ips/debug_trace/trace/trace_buffer/README.md)                         | ip   | planned | P0     | 0.1.0 | Trace 缓冲             |
| DBG-006 | [apb_transaction_monitor](ips/debug_trace/monitor/apb_transaction_monitor/README.md) | ip   | planned | P1     | 0.1.0 | APB 事务监控器         |
| DBG-007 | [axi_transaction_monitor](ips/debug_trace/monitor/axi_transaction_monitor/README.md) | ip   | planned | P1     | 0.1.0 | AXI 事务监控器         |
| DBG-008 | [bus_monitor](ips/debug_trace/monitor/bus_monitor/README.md)                         | ip   | planned | P1     | 0.1.0 | 总线监控器             |
| DBG-009 | [error_logger](ips/debug_trace/monitor/error_logger/README.md)                       | ip   | planned | P1     | 0.1.0 | 错误记录器             |
| DBG-010 | [event_counter](ips/debug_trace/monitor/event_counter/README.md)                     | ip   | planned | P1     | 0.1.0 | 事件计数器             |
| DBG-011 | [timestamp_unit](ips/debug_trace/trace/timestamp_unit/README.md)                     | ip   | planned | P1     | 0.1.0 | 时间戳单元             |
| DBG-012 | [trace_funnel](ips/debug_trace/trace/trace_funnel/README.md)                         | ip   | planned | P1     | 0.1.0 | Trace 漏斗（多路汇聚） |
| DBG-013 | [trace_replicator](ips/debug_trace/trace/trace_replicator/README.md)                 | ip   | planned | P1     | 0.1.0 | Trace 复制器           |

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

#### high_speed_io（11，已交付=0）

| ID      | IP                                                                          | 类型 | 状态    | 优先级 | 版本  | 功能/描述       |
|---------|-----------------------------------------------------------------------------|------|---------|--------|-------|-----------------|
| HSI-001 | [10g_mac](ips/high_speed_io/ethernet/10g_mac/README.md)                     | ip   | planned | P2     | 0.1.0 | 10G 以太网 MAC  |
| HSI-002 | [ethernet_mac](ips/high_speed_io/ethernet/ethernet_mac/README.md)           | ip   | planned | P2     | 0.1.0 | 以太网 MAC      |
| HSI-003 | [gbe_mac](ips/high_speed_io/ethernet/gbe_mac/README.md)                     | ip   | planned | P2     | 0.1.0 | 1G 以太网 MAC   |
| HSI-004 | [mipi_csi_controller](ips/high_speed_io/mipi/mipi_csi_controller/README.md) | ip   | planned | P2     | 0.1.0 | MIPI CSI 控制器 |
| HSI-005 | [mipi_dsi_controller](ips/high_speed_io/mipi/mipi_dsi_controller/README.md) | ip   | planned | P2     | 0.1.0 | MIPI DSI 控制器 |
| HSI-006 | [pcie_controller](ips/high_speed_io/pcie/pcie_controller/README.md)         | ip   | planned | P2     | 0.1.0 | PCIe 控制器     |
| HSI-007 | [sata_controller](ips/high_speed_io/storage/sata_controller/README.md)      | ip   | planned | P2     | 0.1.0 | SATA 控制器     |
| HSI-008 | [serdes_controller](ips/high_speed_io/serdes/serdes_controller/README.md)   | ip   | planned | P2     | 0.1.0 | SerDes 控制器   |
| HSI-009 | [ufs_controller](ips/high_speed_io/storage/ufs_controller/README.md)        | ip   | planned | P2     | 0.1.0 | UFS 控制器      |
| HSI-010 | [usb2_controller](ips/high_speed_io/usb/usb2_controller/README.md)          | ip   | planned | P2     | 0.1.0 | USB 2.0 控制器  |
| HSI-011 | [usb3_controller](ips/high_speed_io/usb/usb3_controller/README.md)          | ip   | planned | P2     | 0.1.0 | USB 3.x 控制器  |

#### infrastructure（55，已交付=1）

| ID      | IP                                                                                     | 类型      | 状态        | 优先级 | 版本  | 功能/描述                                                                      |
|---------|----------------------------------------------------------------------------------------|-----------|-------------|--------|-------|--------------------------------------------------------------------------------|
| INF-001 | [ahb2apb_bridge](ips/infrastructure/bridge/ahb2apb_bridge/README.md)                   | ip        | planned     | P0     | 0.1.0 | AHB→APB 桥（H2P）                                                              |
| INF-002 | [ahb2axi_bridge](ips/infrastructure/bridge/ahb2axi_bridge/README.md)                   | ip        | planned     | P0     | 0.1.0 | AHB→AXI 桥（H2X）                                                              |
| INF-003 | [ahb_cdc_bridge](ips/infrastructure/cdc/ahb_cdc_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | AHB CDC 桥                                                                     |
| INF-004 | [apb_cdc_bridge](ips/infrastructure/cdc/apb_cdc_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | APB CDC 桥                                                                     |
| INF-005 | [apb_demux](ips/infrastructure/apb/apb_demux/README.md)                                | ip        | planned     | P0     | 0.1.0 | APB Demux                                                                      |
| INF-006 | [apb_error_slave](ips/infrastructure/apb/apb_error_slave/README.md)                    | ip        | planned     | P0     | 0.1.0 | APB 错误默认 Slave                                                             |
| INF-007 | [apb_interconnect](ips/infrastructure/apb/apb_interconnect/README.md)                  | generator | planned     | P0     | 0.1.0 | APB 互联（P2P）                                                                |
| INF-008 | [apb_mux](ips/infrastructure/apb/apb_mux/README.md)                                    | ip        | planned     | P0     | 0.1.0 | APB Mux                                                                        |
| INF-009 | [apb_timeout](ips/infrastructure/apb/apb_timeout/README.md)                            | ip        | planned     | P0     | 0.1.0 | APB 超时监控                                                                   |
| INF-010 | [axi2ahb_bridge](ips/infrastructure/bridge/axi2ahb_bridge/README.md)                   | ip        | planned     | P0     | 0.1.0 | AXI→AHB 桥（X2H）                                                              |
| INF-011 | [axi2apb_bridge](ips/infrastructure/bridge/axi2apb_bridge/README.md)                   | ip        | implemented | P0     | 1.0.0 | AXI→APB 桥（X2P，AXI4/AXI4-Lite → APB3/APB4；G0-G3 通过，G4 BUG-001 blocking） |
| INF-012 | [axi4_axi4lite_converter](ips/infrastructure/bridge/axi4_axi4lite_converter/README.md) | ip        | planned     | P0     | 0.1.0 | AXI4→AXI4-Lite 协议转换                                                        |
| INF-013 | [axi_address_remapper](ips/infrastructure/axi/axi_address_remapper/README.md)          | ip        | planned     | P0     | 0.1.0 | AXI 地址重映射                                                                 |
| INF-014 | [axi_cdc_bridge](ips/infrastructure/cdc/axi_cdc_bridge/README.md)                      | ip        | planned     | P0     | 0.1.0 | AXI CDC 桥（异步时钟）                                                         |
| INF-015 | [axi_crossbar](ips/infrastructure/axi/axi_crossbar/README.md)                          | generator | planned     | P0     | 0.1.0 | 高并发 AXI Crossbar                                                            |
| INF-016 | [axi_demux](ips/infrastructure/axi/axi_demux/README.md)                                | ip        | planned     | P0     | 0.1.0 | 1→N AXI Demux                                                                  |
| INF-017 | [axi_error_slave](ips/infrastructure/axi/axi_error_slave/README.md)                    | ip        | planned     | P0     | 0.1.0 | AXI 默认错误响应 Slave                                                         |
| INF-018 | [axi_id_remapper](ips/infrastructure/axi/axi_id_remapper/README.md)                    | ip        | planned     | P0     | 0.1.0 | AXI ID 重映射                                                                  |
| INF-019 | [axi_interconnect](ips/infrastructure/axi/axi_interconnect/README.md)                  | generator | planned     | P0     | 0.1.0 | 多 Master/Slave AXI 互联（拓扑生成）                                           |
| INF-020 | [axi_mux](ips/infrastructure/axi/axi_mux/README.md)                                    | ip        | planned     | P0     | 0.1.0 | N→1 AXI Mux                                                                    |
| INF-021 | [axi_pipeline](ips/infrastructure/axi/axi_pipeline/README.md)                          | ip        | planned     | P0     | 0.1.0 | AXI 流水线（timing）                                                           |
| INF-022 | [axi_register_slice](ips/infrastructure/axi/axi_register_slice/README.md)              | ip        | planned     | P0     | 0.1.0 | AXI 寄存器切片（timing/PPA）                                                   |
| INF-023 | [axi_timeout_monitor](ips/infrastructure/axi/axi_timeout_monitor/README.md)            | ip        | planned     | P0     | 0.1.0 | AXI 总线超时监控                                                               |
| INF-024 | [axi_width_converter](ips/infrastructure/bridge/axi_width_converter/README.md)         | ip        | planned     | P0     | 0.1.0 | AXI 数据宽度转换                                                               |
| INF-025 | [interrupt_cdc_bridge](ips/infrastructure/cdc/interrupt_cdc_bridge/README.md)          | ip        | planned     | P0     | 0.1.0 | 中断 CDC 桥                                                                    |
| INF-026 | [register_cdc_bridge](ips/infrastructure/cdc/register_cdc_bridge/README.md)            | ip        | planned     | P0     | 0.1.0 | 寄存器 CDC 桥                                                                  |
| INF-027 | [ahb_interconnect](ips/infrastructure/ahb/ahb_interconnect/README.md)                  | generator | planned     | P1     | 0.1.0 | AHB 互联                                                                       |
| INF-028 | [ahb_mux_demux](ips/infrastructure/ahb/ahb_mux_demux/README.md)                        | ip        | planned     | P1     | 0.1.0 | AHB Mux/Demux                                                                  |
| INF-029 | [apb_firewall](ips/infrastructure/apb/apb_firewall/README.md)                          | ip        | planned     | P1     | 0.1.0 | APB 防火墙                                                                     |
| INF-030 | [apb_isolation_bridge](ips/infrastructure/apb/apb_isolation_bridge/README.md)          | ip        | planned     | P1     | 0.1.0 | APB 隔离桥                                                                     |
| INF-031 | [axi_arbiter](ips/infrastructure/axi/axi_arbiter/README.md)                            | ip        | planned     | P1     | 0.1.0 | AXI 仲裁器                                                                     |
| INF-032 | [axi_bandwidth_limiter](ips/infrastructure/axi/axi_bandwidth_limiter/README.md)        | ip        | planned     | P1     | 0.1.0 | AXI 带宽限制器                                                                 |
| INF-033 | [axi_exclusive_monitor](ips/infrastructure/axi/axi_exclusive_monitor/README.md)        | ip        | planned     | P1     | 0.1.0 | AXI 独占访问监控                                                               |
| INF-034 | [axi_isolation_bridge](ips/infrastructure/axi/axi_isolation_bridge/README.md)          | ip        | planned     | P1     | 0.1.0 | AXI 隔离桥                                                                     |
| INF-035 | [axi_ordering_controller](ips/infrastructure/axi/axi_ordering_controller/README.md)    | ip        | planned     | P1     | 0.1.0 | AXI 顺序控制器                                                                 |
| INF-036 | [axi_outstanding_limiter](ips/infrastructure/axi/axi_outstanding_limiter/README.md)    | ip        | planned     | P1     | 0.1.0 | AXI Outstanding 限制器                                                         |
| INF-037 | [axi_protocol_firewall](ips/infrastructure/axi/axi_protocol_firewall/README.md)        | ip        | planned     | P1     | 0.1.0 | AXI 协议防火墙                                                                 |
| INF-038 | [axi_qos_controller](ips/infrastructure/axi/axi_qos_controller/README.md)              | ip        | planned     | P1     | 0.1.0 | AXI QoS 控制器                                                                 |
| INF-039 | [axi_traffic_shaper](ips/infrastructure/axi/axi_traffic_shaper/README.md)              | ip        | planned     | P1     | 0.1.0 | AXI 流量整形器                                                                 |
| INF-040 | [axis_cdc](ips/infrastructure/cdc/axis_cdc/README.md)                                  | ip        | planned     | P1     | 0.1.0 | AXI-Stream CDC                                                                 |
| INF-041 | [axis_demux](ips/infrastructure/axi/axis_demux/README.md)                              | ip        | planned     | P1     | 0.1.0 | AXI-Stream Demux                                                               |
| INF-042 | [axis_mux](ips/infrastructure/axi/axis_mux/README.md)                                  | ip        | planned     | P1     | 0.1.0 | AXI-Stream Mux                                                                 |
| INF-043 | [event_cdc_bridge](ips/infrastructure/cdc/event_cdc_bridge/README.md)                  | ip        | planned     | P1     | 0.1.0 | 事件 CDC 桥                                                                    |
| INF-044 | [reset_domain_bridge](ips/infrastructure/cdc/reset_domain_bridge/README.md)            | ip        | planned     | P1     | 0.1.0 | 复位域桥（RDC）                                                                |
| INF-045 | [stream_cdc_bridge](ips/infrastructure/cdc/stream_cdc_bridge/README.md)                | ip        | planned     | P1     | 0.1.0 | 流 CDC 桥                                                                      |
| INF-046 | [stream_interconnect](ips/infrastructure/axi/stream_interconnect/README.md)            | generator | planned     | P1     | 0.1.0 | AXI-Stream 互联                                                                |
| INF-047 | [apb_noc_bridge](ips/infrastructure/noc/apb_noc_bridge/README.md)                      | ip        | planned     | P2     | 0.1.0 | APB↔NoC 桥                                                                     |
| INF-048 | [axi_noc_bridge](ips/infrastructure/noc/axi_noc_bridge/README.md)                      | ip        | planned     | P2     | 0.1.0 | AXI↔NoC 桥                                                                     |
| INF-049 | [noc_crossbar](ips/infrastructure/noc/noc_crossbar/README.md)                          | ip        | planned     | P2     | 0.1.0 | NoC Crossbar                                                                   |
| INF-050 | [noc_firewall](ips/infrastructure/noc/noc_firewall/README.md)                          | ip        | planned     | P2     | 0.1.0 | NoC 防火墙                                                                     |
| INF-051 | [noc_network_interface](ips/infrastructure/noc/noc_network_interface/README.md)        | ip        | planned     | P2     | 0.1.0 | NoC 网络接口（NI）                                                             |
| INF-052 | [noc_performance_monitor](ips/infrastructure/noc/noc_performance_monitor/README.md)    | ip        | planned     | P2     | 0.1.0 | NoC 性能监控器                                                                 |
| INF-053 | [noc_qos_manager](ips/infrastructure/noc/noc_qos_manager/README.md)                    | ip        | planned     | P2     | 0.1.0 | NoC QoS 管理器                                                                 |
| INF-054 | [noc_router](ips/infrastructure/noc/noc_router/README.md)                              | ip        | planned     | P2     | 0.1.0 | NoC 路由器（包交换）                                                           |
| INF-055 | [noc_traffic_shaper](ips/infrastructure/noc/noc_traffic_shaper/README.md)              | ip        | planned     | P2     | 0.1.0 | NoC 流量整形器                                                                 |

#### memory（35，已交付=0）

| ID      | IP                                                                                      | 类型      | 状态    | 优先级 | 版本  | 功能/描述                                                                |
|---------|-----------------------------------------------------------------------------------------|-----------|---------|--------|-------|--------------------------------------------------------------------------|
| MEM-001 | [lowrisc_prim](ips/lowrisc/prim/0.1.0/README.md)                                        | ip        | planned | P0     | 0.1.0 | OpenTitan primitives（secded ECC / ram / rom / cdc / sha2 / trivium 等） |
| MEM-002 | [lowrisc_testlib](ips/lowrisc/testlib/1.0.0/README.md)                                  | ip        | planned | P0     | 1.0.0 | OpenTitan 测试库（dummy 仿真单元）                                       |
| MEM-003 | [lowrisc_tlul](ips/lowrisc/tlul/0.1.0/README.md)                                        | ip        | planned | P0     | 0.1.0 | OpenTitan TileLink-UL 总线组件（socket / adapter / fifo / jtag_dtm 等）  |
| MEM-004 | [memory_interleaver](ips/memory/sram/memory_interleaver/README.md)                      | ip        | planned | P0     | 0.1.0 | 内存交织器                                                               |
| MEM-005 | [memory_scrubber](ips/memory/sram/memory_scrubber/README.md)                            | ip        | planned | P0     | 0.1.0 | 内存巡检（scrubber）                                                     |
| MEM-006 | [multiport_sram_controller](ips/memory/sram/multiport_sram_controller/README.md)        | generator | planned | P0     | 0.1.0 | 多端口 SRAM 控制器                                                       |
| MEM-007 | [register_file_wrapper](ips/memory/sram/register_file_wrapper/README.md)                | wrapper   | planned | P0     | 0.1.0 | 寄存器文件工艺抽象 Wrapper                                               |
| MEM-008 | [rom_controller](ips/memory/rom/rom_controller/README.md)                               | ip        | planned | P0     | 0.1.0 | ROM 控制器                                                               |
| MEM-009 | [rom_wrapper](ips/memory/rom/rom_wrapper/README.md)                                     | wrapper   | planned | P0     | 0.1.0 | ROM 工艺抽象 Wrapper                                                     |
| MEM-010 | [sram_controller](ips/memory/sram/sram_controller/README.md)                            | generator | planned | P0     | 0.1.0 | SRAM 控制器                                                              |
| MEM-011 | [sram_ecc_controller](ips/memory/sram/sram_ecc_controller/README.md)                    | ip        | planned | P0     | 0.1.0 | SRAM ECC 控制器                                                          |
| MEM-012 | [sram_wrapper](ips/memory/sram/sram_wrapper/README.md)                                  | wrapper   | planned | P0     | 0.1.0 | SRAM 工艺抽象 Wrapper                                                    |
| MEM-013 | [tcm_controller](ips/memory/tcm/tcm_controller/README.md)                               | ip        | planned | P0     | 0.1.0 | TCM 控制器                                                               |
| MEM-014 | [memory_bist_wrapper](ips/memory/bist/memory_bist_wrapper/README.md)                    | ip        | planned | P1     | 0.1.0 | 内存 BIST Wrapper                                                        |
| MEM-015 | [memory_firewall](ips/memory/security/memory_firewall/README.md)                        | ip        | planned | P1     | 0.1.0 | 内存防火墙                                                               |
| MEM-016 | [memory_qos_controller](ips/memory/qos/memory_qos_controller/README.md)                 | ip        | planned | P1     | 0.1.0 | 内存 QoS 控制器                                                          |
| MEM-017 | [memory_repair_controller](ips/memory/bist/memory_repair_controller/README.md)          | ip        | planned | P1     | 0.1.0 | 内存修复控制器                                                           |
| MEM-018 | [multi_bank_sram_controller](ips/memory/sram/multi_bank_sram_controller/README.md)      | generator | planned | P1     | 0.1.0 | 多 Bank SRAM 控制器                                                      |
| MEM-019 | [scratchpad_controller](ips/memory/sram/scratchpad_controller/README.md)                | ip        | planned | P1     | 0.1.0 | Scratchpad 控制器                                                        |
| MEM-020 | [address_hash_interleave](ips/memory/interleave/address_hash_interleave/README.md)      | ip        | planned | P2     | 0.1.0 | 地址哈希/交织单元                                                        |
| MEM-021 | [ddr4_controller](ips/memory/ddr/ddr4_controller/README.md)                             | ip        | planned | P2     | 0.1.0 | DDR4 控制器                                                              |
| MEM-022 | [ddr5_controller](ips/memory/ddr/ddr5_controller/README.md)                             | ip        | planned | P2     | 0.1.0 | DDR5 控制器                                                              |
| MEM-023 | [ddr_controller](ips/memory/ddr/ddr_controller/README.md)                               | ip        | planned | P2     | 0.1.0 | DDR 控制器                                                               |
| MEM-024 | [ddr_ecc_controller](ips/memory/ddr/ddr_ecc_controller/README.md)                       | ip        | planned | P2     | 0.1.0 | DDR ECC 控制器                                                           |
| MEM-025 | [ddr_phy_wrapper](ips/memory/ddr/ddr_phy_wrapper/README.md)                             | wrapper   | planned | P2     | 0.1.0 | DDR PHY Wrapper                                                          |
| MEM-026 | [ddr_scheduler](ips/memory/ddr/ddr_scheduler/README.md)                                 | ip        | planned | P2     | 0.1.0 | DDR 调度器                                                               |
| MEM-027 | [lpddr4_controller](ips/memory/ddr/lpddr4_controller/README.md)                         | ip        | planned | P2     | 0.1.0 | LPDDR4 控制器                                                            |
| MEM-028 | [lpddr5_controller](ips/memory/ddr/lpddr5_controller/README.md)                         | ip        | planned | P2     | 0.1.0 | LPDDR5 控制器                                                            |
| MEM-029 | [rowhammer_mitigation](ips/memory/ddr/rowhammer_mitigation/README.md)                   | ip        | planned | P2     | 0.1.0 | Rowhammer 缓解控制器                                                     |
| MEM-030 | [cxl_memory_controller](ips/memory/cxl/cxl_memory_controller/README.md)                 | ip        | planned | P3     | 0.1.0 | CXL 内存控制器                                                           |
| MEM-031 | [hbm_controller](ips/memory/hbm/hbm_controller/README.md)                               | ip        | planned | P3     | 0.1.0 | HBM 控制器                                                               |
| MEM-032 | [hbm_phy_wrapper](ips/memory/hbm/hbm_phy_wrapper/README.md)                             | wrapper   | planned | P3     | 0.1.0 | HBM PHY Wrapper                                                          |
| MEM-033 | [memory_compression_engine](ips/memory/compression/memory_compression_engine/README.md) | ip        | planned | P3     | 0.1.0 | 内存压缩引擎                                                             |
| MEM-034 | [memory_encryption_engine](ips/memory/security/memory_encryption_engine/README.md)      | ip        | planned | P3     | 0.1.0 | 内存加密引擎                                                             |
| MEM-035 | [persistent_memory_controller](ips/memory/cxl/persistent_memory_controller/README.md)   | ip        | planned | P3     | 0.1.0 | 持久内存控制器                                                           |

#### mmu（4，已交付=0）

| ID      | IP                                               | 类型 | 状态    | 优先级 | 版本  | 功能/描述           |
|---------|--------------------------------------------------|------|---------|--------|-------|---------------------|
| MMU-001 | [iommu](ips/mmu/iommu/iommu/README.md)           | ip   | planned | P2     | 0.1.0 | IOMMU               |
| MMU-002 | [mmu](ips/mmu/mmu/mmu/README.md)                 | ip   | planned | P2     | 0.1.0 | 内存管理单元（MMU） |
| MMU-003 | [mpu](ips/mmu/mpu/mpu/README.md)                 | ip   | planned | P2     | 0.1.0 | 内存保护单元（MPU） |
| MMU-004 | [pmp_manager](ips/mmu/pmp/pmp_manager/README.md) | ip   | planned | P2     | 0.1.0 | RISC-V PMP 管理器   |

#### multimedia（14，已交付=0）

| ID      | IP                                                                      | 类型 | 状态    | 优先级 | 版本  | 功能/描述             |
|---------|-------------------------------------------------------------------------|------|---------|--------|-------|-----------------------|
| MUL-001 | [audio_dma](ips/multimedia/audio/audio_dma/README.md)                   | ip   | planned | P2     | 0.1.0 | 音频 DMA              |
| MUL-002 | [camera_interface](ips/multimedia/video/camera_interface/README.md)     | ip   | planned | P2     | 0.1.0 | 相机接口              |
| MUL-003 | [display_controller](ips/multimedia/video/display_controller/README.md) | ip   | planned | P2     | 0.1.0 | 显示控制器            |
| MUL-004 | [i2s_controller](ips/multimedia/audio/i2s_controller/README.md)         | ip   | planned | P2     | 0.1.0 | I2S 控制器            |
| MUL-005 | [image_resizer](ips/multimedia/image/image_resizer/README.md)           | ip   | planned | P2     | 0.1.0 | 图像缩放器            |
| MUL-006 | [isp](ips/multimedia/image/isp/README.md)                               | ip   | planned | P2     | 0.1.0 | 图像信号处理器（ISP） |
| MUL-007 | [jpeg_codec](ips/multimedia/codec/jpeg_codec/README.md)                 | ip   | planned | P2     | 0.1.0 | JPEG 编解码器         |
| MUL-008 | [pdm_controller](ips/multimedia/audio/pdm_controller/README.md)         | ip   | planned | P2     | 0.1.0 | PDM 控制器            |
| MUL-009 | [tdm_controller](ips/multimedia/audio/tdm_controller/README.md)         | ip   | planned | P2     | 0.1.0 | TDM 控制器            |
| MUL-010 | [av1_codec](ips/multimedia/codec/av1_codec/README.md)                   | ip   | planned | P3     | 0.1.0 | AV1 编解码器          |
| MUL-011 | [gpu_interface](ips/multimedia/gpu/gpu_interface/README.md)             | ip   | planned | P3     | 0.1.0 | GPU 接口              |
| MUL-012 | [h264_codec](ips/multimedia/codec/h264_codec/README.md)                 | ip   | planned | P3     | 0.1.0 | H.264 编解码器        |
| MUL-013 | [h265_codec](ips/multimedia/codec/h265_codec/README.md)                 | ip   | planned | P3     | 0.1.0 | H.265 编解码器        |
| MUL-014 | [video_scaler](ips/multimedia/video/video_scaler/README.md)             | ip   | planned | P3     | 0.1.0 | 视频缩放器            |

#### network（6，已交付=0）

| ID      | IP                                                                  | 类型 | 状态    | 优先级 | 版本  | 功能/描述   |
|---------|---------------------------------------------------------------------|------|---------|--------|-------|-------------|
| NET-001 | [ipsec_engine](ips/network/security/ipsec_engine/README.md)         | ip   | planned | P3     | 0.1.0 | IPsec 引擎  |
| NET-002 | [macsec_engine](ips/network/security/macsec_engine/README.md)       | ip   | planned | P3     | 0.1.0 | MACsec 引擎 |
| NET-003 | [packet_classifier](ips/network/packet/packet_classifier/README.md) | ip   | planned | P3     | 0.1.0 | 报文分类器  |
| NET-004 | [packet_parser](ips/network/packet/packet_parser/README.md)         | ip   | planned | P3     | 0.1.0 | 报文解析器  |
| NET-005 | [qos_scheduler](ips/network/qos/qos_scheduler/README.md)            | ip   | planned | P3     | 0.1.0 | QoS 调度器  |
| NET-006 | [traffic_manager](ips/network/qos/traffic_manager/README.md)        | ip   | planned | P3     | 0.1.0 | 流量管理器  |

#### peripheral（25，已交付=0）

| ID      | IP                                                                            | 类型 | 状态    | 优先级 | 版本  | 功能/描述                                                                   |
|---------|-------------------------------------------------------------------------------|------|---------|--------|-------|-----------------------------------------------------------------------------|
| PER-001 | [gpio](ips/peripheral/io/gpio/README.md)                                      | ip   | planned | P0     | 0.1.0 | 通用 GPIO                                                                   |
| PER-002 | [i2c_master](ips/peripheral/serial/i2c_master/README.md)                      | ip   | planned | P0     | 0.1.0 | I2C 主机                                                                    |
| PER-003 | [i2c_slave](ips/peripheral/serial/i2c_slave/README.md)                        | ip   | planned | P0     | 0.1.0 | I2C 从机                                                                    |
| PER-004 | [pwm](ips/peripheral/timer/pwm/README.md)                                     | ip   | planned | P0     | 0.1.0 | PWM 控制器                                                                  |
| PER-005 | [spi_master](ips/peripheral/serial/spi_master/README.md)                      | ip   | planned | P0     | 0.1.0 | SPI 主机                                                                    |
| PER-006 | [spi_slave](ips/peripheral/serial/spi_slave/README.md)                        | ip   | planned | P0     | 0.1.0 | SPI 从机                                                                    |
| PER-007 | [timer](ips/peripheral/timer/timer/README.md)                                 | ip   | planned | P0     | 0.1.0 | 通用定时器                                                                  |
| PER-008 | [uart](ips/boyangwang1991-design/uart/0.1.0/README.md)                        | ip   | planned | P0     | 0.1.0 | 通用 UART（APB 接口，含 CSR/RX/TX，G0-G5 曾通过；工作区目录未落盘，待恢复） |
| PER-009 | [watchdog](ips/peripheral/timer/watchdog/README.md)                           | ip   | planned | P0     | 0.1.0 | 看门狗                                                                      |
| PER-010 | [can](ips/peripheral/automotive/can/README.md)                                | ip   | planned | P1     | 0.1.0 | CAN 控制器                                                                  |
| PER-011 | [can_fd](ips/peripheral/automotive/can_fd/README.md)                          | ip   | planned | P1     | 0.1.0 | CAN-FD 控制器                                                               |
| PER-012 | [doorbell_controller](ips/peripheral/intercore/doorbell_controller/README.md) | ip   | planned | P1     | 0.1.0 | 门铃（Doorbell）控制器                                                      |
| PER-013 | [emmc_controller](ips/peripheral/storage/emmc_controller/README.md)           | ip   | planned | P1     | 0.1.0 | eMMC 控制器                                                                 |
| PER-014 | [hardware_semaphore](ips/peripheral/intercore/hardware_semaphore/README.md)   | ip   | planned | P1     | 0.1.0 | 硬件信号量                                                                  |
| PER-015 | [i3c_controller](ips/peripheral/serial/i3c_controller/README.md)              | ip   | planned | P1     | 0.1.0 | I3C 控制器                                                                  |
| PER-016 | [input_capture](ips/peripheral/timer/input_capture/README.md)                 | ip   | planned | P1     | 0.1.0 | 输入捕获                                                                    |
| PER-017 | [lin](ips/peripheral/automotive/lin/README.md)                                | ip   | planned | P1     | 0.1.0 | LIN 控制器                                                                  |
| PER-018 | [mailbox](ips/peripheral/intercore/mailbox/README.md)                         | ip   | planned | P1     | 0.1.0 | 核间邮箱                                                                    |
| PER-019 | [ospi](ips/peripheral/serial/ospi/README.md)                                  | ip   | planned | P1     | 0.1.0 | OSPI 控制器                                                                 |
| PER-020 | [output_compare](ips/peripheral/timer/output_compare/README.md)               | ip   | planned | P1     | 0.1.0 | 输出比较                                                                    |
| PER-021 | [qspi](ips/peripheral/serial/qspi/README.md)                                  | ip   | planned | P1     | 0.1.0 | QSPI 控制器                                                                 |
| PER-022 | [quadrature_encoder](ips/peripheral/timer/quadrature_encoder/README.md)       | ip   | planned | P1     | 0.1.0 | 正交编码器接口                                                              |
| PER-023 | [rtc](ips/peripheral/timer/rtc/README.md)                                     | ip   | planned | P1     | 0.1.0 | 实时时钟（RTC）                                                             |
| PER-024 | [sd_host](ips/peripheral/storage/sd_host/README.md)                           | ip   | planned | P1     | 0.1.0 | SD Host 控制器                                                              |
| PER-025 | [sdio](ips/peripheral/storage/sdio/README.md)                                 | ip   | planned | P1     | 0.1.0 | SDIO 控制器                                                                 |

#### phy（4，已交付=0）

| ID      | IP                                                                      | 类型    | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|-------------------------------------------------------------------------|---------|---------|--------|-------|--------------------|
| PHY-001 | [ethernet_phy_wrapper](ips/phy/ethernet/ethernet_phy_wrapper/README.md) | wrapper | planned | P2     | 0.1.0 | 以太网 PHY Wrapper |
| PHY-002 | [mipi_phy_wrapper](ips/phy/mipi/mipi_phy_wrapper/README.md)             | wrapper | planned | P2     | 0.1.0 | MIPI PHY Wrapper   |
| PHY-003 | [pcie_phy_wrapper](ips/phy/pcie/pcie_phy_wrapper/README.md)             | wrapper | planned | P2     | 0.1.0 | PCIe PHY Wrapper   |
| PHY-004 | [usb_phy_wrapper](ips/phy/usb/usb_phy_wrapper/README.md)                | wrapper | planned | P2     | 0.1.0 | USB PHY Wrapper    |

#### reliability（5，已交付=0）

| ID      | IP                                                                                 | 类型 | 状态    | 优先级 | 版本  | 功能/描述          |
|---------|------------------------------------------------------------------------------------|------|---------|--------|-------|--------------------|
| REL-001 | [aging_monitor](ips/reliability/monitor/aging_monitor/README.md)                   | ip   | planned | P3     | 0.1.0 | 老化监控器         |
| REL-002 | [ecc_telemetry_controller](ips/reliability/ecc/ecc_telemetry_controller/README.md) | ip   | planned | P3     | 0.1.0 | ECC 遥测控制器     |
| REL-003 | [reliability_monitor](ips/reliability/monitor/reliability_monitor/README.md)       | ip   | planned | P3     | 0.1.0 | 可靠性监控器       |
| REL-004 | [soft_error_counter](ips/reliability/monitor/soft_error_counter/README.md)         | ip   | planned | P3     | 0.1.0 | 软错误计数器       |
| REL-005 | [sram_patrol_controller](ips/reliability/sram/sram_patrol_controller/README.md)    | ip   | planned | P3     | 0.1.0 | SRAM Patrol 控制器 |

#### safety（24，已交付=0）

| ID      | IP                                                                                       | 类型 | 状态    | 优先级 | 版本  | 功能/描述                               |
|---------|------------------------------------------------------------------------------------------|------|---------|--------|-------|-----------------------------------------|
| SAF-001 | [ecc_memory_controller](ips/safety/ecc/ecc_memory_controller/README.md)                  | ip   | planned | P0     | 0.1.0 | ECC 内存控制器                          |
| SAF-002 | [error_aggregator](ips/safety/fault/error_aggregator/README.md)                          | ip   | planned | P0     | 0.1.0 | 错误聚合器                              |
| SAF-003 | [error_injection_controller](ips/safety/fault/error_injection_controller/README.md)      | ip   | planned | P0     | 0.1.0 | 错误注入控制器                          |
| SAF-004 | [fault_manager](ips/safety/fault/fault_manager/README.md)                                | ip   | planned | P0     | 0.1.0 | 故障管理器                              |
| SAF-005 | [register_parity_controller](ips/safety/parity/register_parity_controller/README.md)     | ip   | planned | P0     | 0.1.0 | 寄存器奇偶校验控制器                    |
| SAF-006 | [safety_watchdog](ips/safety/watchdog/safety_watchdog/README.md)                         | ip   | planned | P0     | 0.1.0 | 安全看门狗                              |
| SAF-007 | [bus_crc_monitor](ips/safety/crc/bus_crc_monitor/README.md)                              | ip   | planned | P1     | 0.1.0 | 总线 CRC 监控                           |
| SAF-008 | [bus_parity_monitor](ips/safety/parity/bus_parity_monitor/README.md)                     | ip   | planned | P1     | 0.1.0 | 总线奇偶校验监控                        |
| SAF-009 | [clock_safety_monitor](ips/safety/monitor/clock_safety_monitor/README.md)                | ip   | planned | P1     | 0.1.0 | 时钟安全监控                            |
| SAF-010 | [diagnostic_controller](ips/safety/diagnostic/diagnostic_controller/README.md)           | ip   | planned | P1     | 0.1.0 | 诊断控制器                              |
| SAF-011 | [fault_response_controller](ips/safety/fault/fault_response_controller/README.md)        | ip   | planned | P1     | 0.1.0 | 故障响应控制器                          |
| SAF-012 | [lockstep_comparator](ips/safety/lockstep/lockstep_comparator/README.md)                 | ip   | planned | P1     | 0.1.0 | 锁步比较器                              |
| SAF-013 | [lockstep_controller](ips/safety/lockstep/lockstep_controller/README.md)                 | ip   | planned | P1     | 0.1.0 | 锁步控制器                              |
| SAF-014 | [reset_safety_monitor](ips/safety/monitor/reset_safety_monitor/README.md)                | ip   | planned | P1     | 0.1.0 | 复位安全监控                            |
| SAF-015 | [safe_state_controller](ips/safety/state/safe_state_controller/README.md)                | ip   | planned | P1     | 0.1.0 | 安全状态控制器                          |
| SAF-016 | [safety_manager](ips/safety/fault/safety_manager/README.md)                              | ip   | planned | P1     | 0.1.0 | 安全管理器                              |
| SAF-017 | [timeout_monitor](ips/safety/monitor/timeout_monitor/README.md)                          | ip   | planned | P1     | 0.1.0 | 超时监控器                              |
| SAF-018 | [diversity_comparator](ips/safety/lockstep/diversity_comparator/README.md)               | ip   | planned | P2     | 0.1.0 | 多样性比较器                            |
| SAF-019 | [e2e_crc_engine](ips/safety/crc/e2e_crc_engine/README.md)                                | ip   | planned | P2     | 0.1.0 | 端到端 CRC 引擎                         |
| SAF-020 | [fccu](ips/safety/fault/fccu/README.md)                                                  | ip   | planned | P2     | 0.1.0 | Fault Collection & Control Unit（FCCU） |
| SAF-021 | [lbist_safety_manager](ips/safety/lbist/lbist_safety_manager/README.md)                  | ip   | planned | P2     | 0.1.0 | LBIST 安全管理器                        |
| SAF-022 | [mbist_safety_manager](ips/safety/mbist/mbist_safety_manager/README.md)                  | ip   | planned | P2     | 0.1.0 | MBIST 安全管理器                        |
| SAF-023 | [ram_repair_safety_controller](ips/safety/repair/ram_repair_safety_controller/README.md) | ip   | planned | P2     | 0.1.0 | RAM 修复安全控制器                      |
| SAF-024 | [safety_event_router](ips/safety/fault/safety_event_router/README.md)                    | ip   | planned | P2     | 0.1.0 | 安全事件路由器                          |

#### security（26，已交付=0）

| ID      | IP                                                                                           | 类型      | 状态    | 优先级 | 版本  | 功能/描述               |
|---------|----------------------------------------------------------------------------------------------|-----------|---------|--------|-------|-------------------------|
| SEC-001 | [aes](ips/security/crypto/aes/README.md)                                                     | ip        | planned | P0     | 0.1.0 | AES 加解密引擎          |
| SEC-002 | [hmac](ips/security/crypto/hmac/README.md)                                                   | ip        | planned | P0     | 0.1.0 | HMAC 引擎               |
| SEC-003 | [key_manager](ips/security/key/key_manager/README.md)                                        | ip        | planned | P0     | 0.1.0 | 密钥管理器              |
| SEC-004 | [otp_efuse_controller](ips/security/efuse/otp_efuse_controller/README.md)                    | generator | planned | P0     | 0.1.0 | OTP/eFuse 控制器        |
| SEC-005 | [secure_boot_controller](ips/security/secure_boot/secure_boot_controller/README.md)          | ip        | planned | P0     | 0.1.0 | 安全启动控制器          |
| SEC-006 | [sha2](ips/security/crypto/sha2/README.md)                                                   | ip        | planned | P0     | 0.1.0 | SHA-2 哈希引擎          |
| SEC-007 | [trng](ips/security/crypto/trng/README.md)                                                   | ip        | planned | P0     | 0.1.0 | 真随机数发生器（TRNG）  |
| SEC-008 | [anti_rollback_controller](ips/security/secure_boot/anti_rollback_controller/README.md)      | ip        | planned | P1     | 0.1.0 | 防回滚控制器            |
| SEC-009 | [bus_firewall](ips/security/firewall/bus_firewall/README.md)                                 | ip        | planned | P1     | 0.1.0 | 总线防火墙              |
| SEC-010 | [crypto_dma](ips/security/crypto/crypto_dma/README.md)                                       | ip        | planned | P1     | 0.1.0 | 密码 DMA                |
| SEC-011 | [csrng_drbg](ips/security/crypto/csrng_drbg/README.md)                                       | ip        | planned | P1     | 0.1.0 | CSRNG/DRBG 确定性随机源 |
| SEC-012 | [dma_firewall](ips/security/firewall/dma_firewall/README.md)                                 | ip        | planned | P1     | 0.1.0 | DMA 防火墙              |
| SEC-013 | [ecc_crypto](ips/security/crypto/ecc_crypto/README.md)                                       | ip        | planned | P1     | 0.1.0 | 椭圆曲线密码（ECC）引擎 |
| SEC-014 | [key_vault](ips/security/key/key_vault/README.md)                                            | ip        | planned | P1     | 0.1.0 | 密钥保险库              |
| SEC-015 | [memory_protection_controller](ips/security/firewall/memory_protection_controller/README.md) | ip        | planned | P1     | 0.1.0 | 内存保护控制器          |
| SEC-016 | [register_firewall](ips/security/firewall/register_firewall/README.md)                       | ip        | planned | P1     | 0.1.0 | 寄存器防火墙            |
| SEC-017 | [rsa](ips/security/crypto/rsa/README.md)                                                     | ip        | planned | P1     | 0.1.0 | RSA 公钥引擎            |
| SEC-018 | [secure_debug_controller](ips/security/secure_debug/secure_debug_controller/README.md)       | ip        | planned | P1     | 0.1.0 | 安全调试控制器          |
| SEC-019 | [secure_mailbox](ips/security/secure_io/secure_mailbox/README.md)                            | ip        | planned | P1     | 0.1.0 | 安全邮箱                |
| SEC-020 | [sha3](ips/security/crypto/sha3/README.md)                                                   | ip        | planned | P1     | 0.1.0 | SHA-3 哈希引擎          |
| SEC-021 | [key_ladder](ips/security/key/key_ladder/README.md)                                          | ip        | planned | P2     | 0.1.0 | 密钥阶梯派生            |
| SEC-022 | [life_cycle_controller](ips/security/secure_boot/life_cycle_controller/README.md)            | ip        | planned | P2     | 0.1.0 | 生命周期控制器          |
| SEC-023 | [monotonic_counter](ips/security/counter/monotonic_counter/README.md)                        | ip        | planned | P2     | 0.1.0 | 单调计数器              |
| SEC-024 | [puf_controller](ips/security/puf/puf_controller/README.md)                                  | ip        | planned | P2     | 0.1.0 | PUF 控制器              |
| SEC-025 | [secure_counter](ips/security/counter/secure_counter/README.md)                              | ip        | planned | P2     | 0.1.0 | 安全计数器              |
| SEC-026 | [tamper_detector](ips/security/tamper/tamper_detector/README.md)                             | ip        | planned | P2     | 0.1.0 | 篡改检测器              |

#### subsystem（10，已交付=0）

| ID      | IP                                                                              | 类型      | 状态    | 优先级 | 版本  | 功能/描述                          |
|---------|---------------------------------------------------------------------------------|-----------|---------|--------|-------|------------------------------------|
| SUB-001 | [ai_accelerator_subsystem](ips/subsystem/ai/ai_accelerator_subsystem/README.md) | subsystem | planned | P3     | 0.1.0 | AI 加速器子系统                    |
| SUB-002 | [aon_subsystem](ips/subsystem/aon/aon_subsystem/README.md)                      | subsystem | planned | P3     | 0.1.0 | Always-On 子系统                   |
| SUB-003 | [cpu_subsystem](ips/subsystem/cpu/cpu_subsystem/README.md)                      | subsystem | planned | P3     | 0.1.0 | CPU 子系统（Core+Cache+CLIC 组合） |
| SUB-004 | [debug_subsystem](ips/subsystem/debug/debug_subsystem/README.md)                | subsystem | planned | P3     | 0.1.0 | 调试子系统                         |
| SUB-005 | [io_subsystem](ips/subsystem/io/io_subsystem/README.md)                         | subsystem | planned | P3     | 0.1.0 | IO 子系统                          |
| SUB-006 | [mcu_subsystem](ips/subsystem/mcu/mcu_subsystem/README.md)                      | subsystem | planned | P3     | 0.1.0 | MCU 子系统                         |
| SUB-007 | [memory_subsystem](ips/subsystem/memory/memory_subsystem/README.md)             | subsystem | planned | P3     | 0.1.0 | 内存子系统                         |
| SUB-008 | [safety_island](ips/subsystem/safety/safety_island/README.md)                   | subsystem | planned | P3     | 0.1.0 | 安全岛（Safety Island）            |
| SUB-009 | [security_subsystem](ips/subsystem/security/security_subsystem/README.md)       | subsystem | planned | P3     | 0.1.0 | 安全子系统                         |
| SUB-010 | [sensor_subsystem](ips/subsystem/sensor/sensor_subsystem/README.md)             | subsystem | planned | P3     | 0.1.0 | 传感器子系统                       |

#### system（41，已交付=0）

| ID      | IP                                                                                      | 类型      | 状态    | 优先级 | 版本  | 功能/描述                                                              |
|---------|-----------------------------------------------------------------------------------------|-----------|---------|--------|-------|------------------------------------------------------------------------|
| SYS-001 | [axi_dma](ips/system/dma/axi_dma/README.md)                                             | ip        | planned | P0     | 0.1.0 | AXI DMA                                                                |
| SYS-002 | [boot_controller](ips/system/boot/boot_controller/README.md)                            | ip        | planned | P0     | 0.1.0 | 启动控制器                                                             |
| SYS-003 | [chip_id_revision](ips/system/clock_reset/chip_id_revision/README.md)                   | ip        | planned | P0     | 0.1.0 | Chip ID / Revision ID                                                  |
| SYS-004 | [clint](ips/system/interrupt/clint/README.md)                                           | ip        | planned | P0     | 0.1.0 | RISC-V CLINT（核本地定时器中断）                                       |
| SYS-005 | [clock_controller](ips/system/clock_reset/clock_controller/README.md)                   | generator | planned | P0     | 0.1.0 | 时钟控制器                                                             |
| SYS-006 | [clock_monitor](ips/system/clock_reset/clock_monitor/README.md)                         | ip        | planned | P0     | 0.1.0 | 时钟监控器                                                             |
| SYS-007 | [crg](ips/system/clock_reset/crg/README.md)                                             | generator | planned | P0     | 0.1.0 | 时钟+复位生成器（CRG）                                                 |
| SYS-008 | [hac_aes](ips/aixsilicon/hac_aes/0.1.0/README.md)                                       | ip        | planned | P0     | 0.1.0 | HAC Golden Example A - 小型 AES/CRC 核（Profile HAC-P0, CTRL + EVENT） |
| SYS-009 | [interrupt_aggregator](ips/system/interrupt/interrupt_aggregator/README.md)             | ip        | planned | P0     | 0.1.0 | 中断聚合器                                                             |
| SYS-010 | [interrupt_gateway](ips/system/interrupt/interrupt_gateway/README.md)                   | ip        | planned | P0     | 0.1.0 | 中断网关                                                               |
| SYS-011 | [interrupt_router](ips/system/interrupt/interrupt_router/README.md)                     | generator | planned | P0     | 0.1.0 | 中断路由器                                                             |
| SYS-012 | [lowrisc_top](ips/lowrisc/top/0.1.0/README.md)                                          | ip        | planned | P0     | 0.1.0 | OpenTitan top 常量/包                                                  |
| SYS-013 | [mem2mem_dma](ips/system/dma/mem2mem_dma/README.md)                                     | ip        | planned | P0     | 0.1.0 | 内存到内存 DMA                                                         |
| SYS-014 | [multi_channel_dma](ips/system/dma/multi_channel_dma/README.md)                         | generator | planned | P0     | 0.1.0 | 多通道 DMA                                                             |
| SYS-015 | [plic](ips/system/interrupt/plic/README.md)                                             | ip        | planned | P0     | 0.1.0 | RISC-V PLIC（平台级中断控制器）                                        |
| SYS-016 | [reset_controller](ips/system/clock_reset/reset_controller/README.md)                   | generator | planned | P0     | 0.1.0 | 复位控制器                                                             |
| SYS-017 | [reset_monitor](ips/system/clock_reset/reset_monitor/README.md)                         | ip        | planned | P0     | 0.1.0 | 复位监控器                                                             |
| SYS-018 | [reset_reason_controller](ips/system/clock_reset/reset_reason_controller/README.md)     | ip        | planned | P0     | 0.1.0 | 复位原因控制器                                                         |
| SYS-019 | [simple_dma](ips/system/dma/simple_dma/README.md)                                       | ip        | planned | P0     | 0.1.0 | 简单 DMA                                                               |
| SYS-020 | [system_controller](ips/system/clock_reset/system_controller/README.md)                 | ip        | planned | P0     | 0.1.0 | 系统控制器                                                             |
| SYS-021 | [aia](ips/system/interrupt/aia/README.md)                                               | ip        | planned | P1     | 0.1.0 | RISC-V Advanced Interrupt Architecture（AIA）                          |
| SYS-022 | [data_mover](ips/system/dma/data_mover/README.md)                                       | ip        | planned | P1     | 0.1.0 | 数据搬运器                                                             |
| SYS-023 | [descriptor_engine](ips/system/dma/descriptor_engine/README.md)                         | ip        | planned | P1     | 0.1.0 | 描述符引擎                                                             |
| SYS-024 | [event_router](ips/system/interrupt/event_router/README.md)                             | generator | planned | P1     | 0.1.0 | 事件路由器                                                             |
| SYS-025 | [isolation_controller](ips/system/power/isolation_controller/README.md)                 | ip        | planned | P1     | 0.1.0 | 隔离控制器                                                             |
| SYS-026 | [peripheral_dma](ips/system/dma/peripheral_dma/README.md)                               | ip        | planned | P1     | 0.1.0 | 外设 DMA                                                               |
| SYS-027 | [power_domain_controller](ips/system/power/power_domain_controller/README.md)           | ip        | planned | P1     | 0.1.0 | 电源域控制器                                                           |
| SYS-028 | [power_manager](ips/system/power/power_manager/README.md)                               | ip        | planned | P1     | 0.1.0 | 电源管理器                                                             |
| SYS-029 | [power_sequencer](ips/system/power/power_sequencer/README.md)                           | ip        | planned | P1     | 0.1.0 | 电源时序控制器                                                         |
| SYS-030 | [retention_controller](ips/system/power/retention_controller/README.md)                 | ip        | planned | P1     | 0.1.0 | 保持控制器                                                             |
| SYS-031 | [scatter_gather_dma](ips/system/dma/scatter_gather_dma/README.md)                       | ip        | planned | P1     | 0.1.0 | Scatter-Gather DMA                                                     |
| SYS-032 | [sleep_controller](ips/system/power/sleep_controller/README.md)                         | ip        | planned | P1     | 0.1.0 | 睡眠控制器                                                             |
| SYS-033 | [stream_dma](ips/system/dma/stream_dma/README.md)                                       | ip        | planned | P1     | 0.1.0 | 流式 DMA                                                               |
| SYS-034 | [wakeup_controller](ips/system/power/wakeup_controller/README.md)                       | ip        | planned | P1     | 0.1.0 | 唤醒控制器                                                             |
| SYS-035 | [wakeup_event_controller](ips/system/interrupt/wakeup_event_controller/README.md)       | ip        | planned | P1     | 0.1.0 | 唤醒事件控制器                                                         |
| SYS-036 | [adaptive_clocking_controller](ips/system/power/adaptive_clocking_controller/README.md) | ip        | planned | P3     | 0.1.0 | 自适应时钟控制器                                                       |
| SYS-037 | [avs_controller](ips/system/power/avs_controller/README.md)                             | ip        | planned | P3     | 0.1.0 | AVS 控制器（自适应电压调节）                                           |
| SYS-038 | [droop_mitigation_controller](ips/system/power/droop_mitigation_controller/README.md)   | ip        | planned | P3     | 0.1.0 | 电压跌落缓解控制器                                                     |
| SYS-039 | [droop_monitor](ips/system/power/droop_monitor/README.md)                               | ip        | planned | P3     | 0.1.0 | 电压跌落监控器                                                         |
| SYS-040 | [dvfs_controller](ips/system/power/dvfs_controller/README.md)                           | ip        | planned | P3     | 0.1.0 | DVFS 控制器                                                            |
| SYS-041 | [thermal_manager](ips/system/power/thermal_manager/README.md)                           | ip        | planned | P3     | 0.1.0 | 热管理单元                                                             |

#### test（3，已交付=0）

| ID      | IP                                                                                     | 类型 | 状态    | 优先级 | 版本  | 功能/描述      |
|---------|----------------------------------------------------------------------------------------|------|---------|--------|-------|----------------|
| TST-001 | [infield_test_controller](ips/test/infield/infield_test_controller/README.md)          | ip   | planned | P3     | 0.1.0 | 在线测试控制器 |
| TST-002 | [production_test_controller](ips/test/production/production_test_controller/README.md) | ip   | planned | P3     | 0.1.0 | 量产测试控制器 |
| TST-003 | [silicon_health_monitor](ips/test/monitor/silicon_health_monitor/README.md)            | ip   | planned | P3     | 0.1.0 | 硅片健康监控器 |

#### virtualization（3，已交付=0）

| ID      | IP                                                                                   | 类型 | 状态    | 优先级 | 版本  | 功能/描述      |
|---------|--------------------------------------------------------------------------------------|------|---------|--------|-------|----------------|
| VIR-001 | [guest_timer](ips/virtualization/vm/guest_timer/README.md)                           | ip   | planned | P2     | 0.1.0 | Guest 定时器   |
| VIR-002 | [virtual_interrupt_router](ips/virtualization/vm/virtual_interrupt_router/README.md) | ip   | planned | P2     | 0.1.0 | 虚拟中断路由器 |
| VIR-003 | [vm_interrupt_controller](ips/virtualization/vm/vm_interrupt_controller/README.md)   | ip   | planned | P2     | 0.1.0 | VM 中断控制器  |


<!-- IP-CATALOG-STATUS:END -->

## 与 FuseSoC 集成

```bash
fusesoc library add aixsilicon_ip_repo https://github.com/boyangwang1991-design/aixsilicon_ip_repo.git
fusesoc run --target sim aixsilicon:ip:<ip>:<version>
```
