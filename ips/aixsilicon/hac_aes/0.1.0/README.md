# hac_aes — HAC Golden Example A（AES/CRC 核，HAC-P0）

> Profile：**HAC-P0 Control**（CTRL + EVENT）　系统侧推荐：AXI4-Lite + IRQ
> 状态：骨架（Golden Example，验证 HAC-IF 控制接口与轻量 Shell 面积）

## 范围（digest 21.4：IP 只放算法专用内容）

- 算法核心（AES/CRC 计算逻辑）；
- 算法专用 Wrapper（HAC-Core ↔ HAC-IF 语义映射）；
- 算法 Descriptor 定义；
- IP 专用寄存器；
- HAC-IF 配置 YAML（SSOT）。

## 资产

| 资产 | 路径 |
|---|---|
| IP Package | [`ip-package.yaml`](ip-package.yaml:1) |
| HAC-IF 配置 SSOT | [`model/hac_if.yaml`](model/hac_if.yaml:1) |
| 算法核心（骨架） | [`rtl/hac_aes_core.sv`](rtl/hac_aes_core.sv:1) |
| 算法专用 Wrapper（骨架） | [`rtl/hac_aes_wrapper.sv`](rtl/hac_aes_wrapper.sv:1) |
| FuseSoC Core | [`fusesoc/aixsilicon_ip_hac_aes.core`](fusesoc/aixsilicon_ip_hac_aes.core:1) |

## 说明

- 本 IP 依赖 HWIF `aix:interface:hac_ctrl` / `aix:interface:hac_event` 与 CBB `hac_ap_ctrl_adapter`；
- 系统侧 AXI4-Lite CSR 与中断由 HAC Shell（CBB `hac_shell` 模板）组合；
- 验证接入用 `aix:vip:hac_if` 与 AXI4-Lite VIP。

## 成熟度

- [ ] E0 Concept
- [ ] E1 Functional
- [ ] E2 Verified
- [ ] E3 Characterized
- [ ] E4 Released
