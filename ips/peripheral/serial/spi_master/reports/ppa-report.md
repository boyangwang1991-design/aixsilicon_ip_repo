# 28nm PPA 表征

GF CMOS28LP sc9 base HVT，TT 1.00 V / 25°C，DC V-2023.12-SP3。目标库和 operating condition 由 model/pdk.yaml 与 build/rtl/pdk_setup.tcl 绑定。100 MHz PCLK、IO/负载假设见 constraints/characterization.sdc。

| 配置 | CS/TX/RX/CMD | cell area (µm²) | 最差 slack (ns) | dynamic power |
|---|---|---:|---:|---:|
| small | 1/4/4/2 | 9295.533 | 2.36 | 770.7318 uW |
| default | 4/32/32/4 | 16622.307 | 2.64 | 1.5612 mW |
| max | 8/256/256/16 | 72418.553 | 2.85 | 7.6922 mW |

三种配置均生成真实门级网表，零 violated constraints。功耗为默认概率传播的 vectorless 估计，未经工作负载 VCD/SAIF 标定；不等于实测功耗。无布局布线、Pad、PCB 或功耗门控签核。源/导出副本/网表哈希见各配置 source-binding.json。
