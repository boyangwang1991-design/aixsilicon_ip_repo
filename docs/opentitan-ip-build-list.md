# OpenTitan IP Repo 构建清单（第一批：可直接构建）

> 来源：`/home/eda/workspace/opentitan`（OpenTitan 源码副本）
> 许可证：全部为 **Apache-2.0**（沿用仓库根 [`LICENSE`](/home/eda/workspace/opentitan/LICENSE)）
> 命名规范：FuseSoC VLNV `lowrisc:ip:<name>:<version>`（沿用 OpenTitan 上游命名）
> 版本规范：SemVer（见 [`references/vlnv-semver.md`](../.roo/skills/iprepo-management-suite/references/vlnv-semver.md)）

## 判定标准（可直接构建）

满足以下全部条件即可直接构建为独立 IP repo：

- [x] 有 FuseSoC `.core` 文件（`hw/ip/<ip>/*.core`）
- [x] 有完整 RTL 源码（`rtl/`）
- [x] 有寄存器定义（`data/*.hjson`，可经 reggen 生成寄存器）
- [x] 有文档（`doc/` 或 `README.md`）
- [x] 有验证环境（`dv/`，仅做参考标记，非硬性阻塞）
- [x] 不依赖 Top 级 ipgen 生成（非 `top_earlgrey/ip_autogen` 专属）

---

## 批次 0：公共地基库（必须先构建）

所有下游 IP 均依赖以下两个基础库，**应先发布并打 tag**，供后续 IP 通过 FuseSoC `depend` 引用。

| 仓库 | VLNV | 源路径 | RTL | DV | Doc | 说明 |
|---|---|---|---|---|---|---|
| ip-prim | `lowrisc:prim:all`（约 60 个 prim_* 子 core） | [`hw/ip/prim`](/home/eda/workspace/opentitan/hw/ip/prim) | ✅ | ✅ | ✅ | 全 IP 公共原语库（含各工艺变体 prim_generic / prim_xilinx / prim_xilinx_ultrascale / prim_asap7，可一并纳入或单独工艺 repo） |
| ip-tlul | `lowrisc:ip:tlul`（含 adapter/socket/headers/trans_intg 等子 core） | [`hw/ip/tlul`](/home/eda/workspace/opentitan/hw/ip/tlul) | ✅ | ⚠️ | ✅ | TileLink-UL 总线基础设施，几乎所有 IP 依赖 |

---

## 批次 1：可直接构建的完整 IP（共 28 个）

按功能分类，全部满足判定标准。`DV` 列 ✅ 表示有 `dv/` 环境，⚠️ 表示缺失（不影响 RTL 构建，发布时建议补做）。

### 1.1 加解密 / 哈希

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| AES | `lowrisc:ip:aes:1.0.0` | [`hw/ip/aes`](/home/eda/workspace/opentitan/hw/ip/aes) | ✅ | ✅ | ✅ | prim, tlul, lc_ctrl_pkg, edn_pkg, keymgr_pkg |
| HMAC | `lowrisc:ip:hmac:0.1.0` | [`hw/ip/hmac`](/home/eda/workspace/opentitan/hw/ip/hmac) | ✅ | ✅ | ✅ | prim, tlul |
| KMAC | `lowrisc:ip:kmac:0.1.0` | [`hw/ip/kmac`](/home/eda/workspace/opentitan/hw/ip/kmac) | ✅ | ✅ | ✅ | prim, tlul, keymgr_pkg, sha3, edn_pkg, kmac_pkg, lc_ctrl_pkg |
| ASCON | `lowrisc:ip:ascon:0.1.0` | [`hw/ip/ascon`](/home/eda/workspace/opentitan/hw/ip/ascon) | ✅ | ✅ | ✅ | prim, tlul, lc_ctrl_pkg, edn_pkg, keymgr_pkg |
| OTBN | `lowrisc:ip:otbn:0.1.0` | [`hw/ip/otbn`](/home/eda/workspace/opentitan/hw/ip/otbn) | ✅ | ✅ | ✅ | prim, tlul, keymgr_pkg, edn_pkg, otbn_pkg, kmac_pkg, sha3, otp_ctrl_pkg |

### 1.2 随机数 / 熵源

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| Entropy Src | `lowrisc:ip:entropy_src:0.1.0` | [`hw/ip/entropy_src`](/home/eda/workspace/opentitan/hw/ip/entropy_src) | ✅ | ✅ | ✅ | prim, tlul, sha3, otp_ctrl_pkg, entropy_src_*_sm_pkg |
| CSRNG | `lowrisc:ip:csrng:0.1.0` | [`hw/ip/csrng`](/home/eda/workspace/opentitan/hw/ip/csrng) | ✅ | ✅ | ✅ | prim, tlul, aes, otp_ctrl_pkg, csrng_pkg |
| EDN | `lowrisc:ip:edn:0.1.0` | [`hw/ip/edn`](/home/eda/workspace/opentitan/hw/ip/edn) | ✅ | ✅ | ✅ | prim, tlul, edn_pkg |

### 1.3 密钥 / 生命周期安全

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| Key Manager | `lowrisc:ip:keymgr:0.1.0` | [`hw/ip/keymgr`](/home/eda/workspace/opentitan/hw/ip/keymgr) | ✅ | ✅ | ✅ | prim, tlul, flash_ctrl_pkg, keymgr_pkg, kmac_pkg, otp_ctrl_pkg, rom_ctrl_pkg |
| Key Manager DPE | `lowrisc:ip:keymgr_dpe:0.1.0` | [`hw/ip/keymgr_dpe`](/home/eda/workspace/opentitan/hw/ip/keymgr_dpe) | ✅ | ✅ | ✅ | prim, tlul, keymgr_dpe_pkg, kmac_pkg, rom_ctrl_pkg, keymgr_common |
| Life Cycle Ctrl | `lowrisc:ip:lc_ctrl:0.1.0` | [`hw/ip/lc_ctrl`](/home/eda/workspace/opentitan/hw/ip/lc_ctrl) | ✅ | ✅ | ✅ | prim, tlul, lc_ctrl_pkg, otp_ctrl_pkg, otp_macro_pkg, kmac_pkg, rv_dm |
| RRAM Ctrl | `lowrisc:ip:rram_ctrl:0.1.0` | [`hw/ip/rram_ctrl`](/home/eda/workspace/opentitan/hw/ip/rram_ctrl) | ✅ | ✅ | ✅ | prim, tlul, otp_ctrl_pkg, otp_ctrl_macro_pkg, rram_ctrl_pkg, rram_ctrl_reg |
| ROM Ctrl | `lowrisc:ip:rom_ctrl:0.1.0` | [`hw/ip/rom_ctrl`](/home/eda/workspace/opentitan/hw/ip/rom_ctrl) | ✅ | ✅ | ✅ | prim, tlul, kmac_pkg, rom_ctrl_pkg |

### 1.4 通信接口

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| UART | `lowrisc:ip:uart:0.1.0` | [`hw/ip/uart`](/home/eda/workspace/opentitan/hw/ip/uart) | ✅ | ✅ | ✅ | prim, tlul |
| I2C | `lowrisc:ip:i2c:0.1.0` | [`hw/ip/i2c`](/home/eda/workspace/opentitan/hw/ip/i2c) | ✅ | ✅ | ✅ | prim, tlul, i2c_pkg |
| SPI Host | `lowrisc:ip:spi_host:1.0.0` | [`hw/ip/spi_host`](/home/eda/workspace/opentitan/hw/ip/spi_host) | ✅ | ✅ | ✅ | prim, tlul, spi_device_pkg |
| SPI Device | `lowrisc:ip:spi_device:0.1.0` | [`hw/ip/spi_device`](/home/eda/workspace/opentitan/hw/ip/spi_device) | ✅ | ✅ | ✅ | prim, tlul, lc_ctrl_pkg, spi_device_pkg |
| USB Device | `lowrisc:ip:usbdev:0.1.0` | [`hw/ip/usbdev`](/home/eda/workspace/opentitan/hw/ip/usbdev) | ✅ | ✅ | ✅ | prim, tlul(socket_1n), usb_fs_nb_pe, usbdev_pkg |
| Mailbox (MBX) | `lowrisc:ip:mbx:0.1.0` | [`hw/ip/mbx`](/home/eda/workspace/opentitan/hw/ip/mbx) | ✅ | ✅ | ✅ | prim, tlul(headers) |
| Pattern Gen | `lowrisc:ip:pattgen:0.1.0` | [`hw/ip/pattgen`](/home/eda/workspace/opentitan/hw/ip/pattgen) | ✅ | ✅ | ✅ | prim, tlul |

### 1.5 定时 / 模拟 / 系统控制

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| AON Timer | `lowrisc:ip:aon_timer:0.1.0` | [`hw/ip/aon_timer`](/home/eda/workspace/opentitan/hw/ip/aon_timer) | ✅ | ✅ | ✅ | prim, tlul |
| RV Timer | `lowrisc:ip:rv_timer:0.1.0` | [`hw/ip/rv_timer`](/home/eda/workspace/opentitan/hw/ip/rv_timer) | ✅ | ✅ | ✅ | prim, tlul, rv_timer_reg_pkg |
| ADC Ctrl | `lowrisc:ip:adc_ctrl:1.0.0` | [`hw/ip/adc_ctrl`](/home/eda/workspace/opentitan/hw/ip/adc_ctrl) | ✅ | ✅ | ✅ | prim, tlul, ast_pkg |
| SysRst Ctrl | `lowrisc:ip:sysrst_ctrl:1.0.0` | [`hw/ip/sysrst_ctrl`](/home/eda/workspace/opentitan/hw/ip/sysrst_ctrl) | ✅ | ✅ | ✅ | prim, tlul |

### 1.6 存储 / 调试 / 其他

| IP | VLNV（建议初始版本） | 源路径 | RTL | DV | Doc | 关键依赖 |
|---|---|---|---|---|---|---|
| SRAM Ctrl | `lowrisc:ip:sram_ctrl:0.1.0` | [`hw/ip/sram_ctrl`](/home/eda/workspace/opentitan/hw/ip/sram_ctrl) | ✅ | ✅ | ✅ | prim, tlul(adapter_sram), sram_ctrl_pkg, lc_ctrl_pkg, otp_ctrl_pkg |
| DMA | `lowrisc:ip:dma:0.1.0` | [`hw/ip/dma`](/home/eda/workspace/opentitan/hw/ip/dma) | ✅ | ✅ | ✅ | prim, tlul(headers, adapter_host), dma_pkg |
| RV Debug Module | `lowrisc:ip:rv_dm:0.1.0` | [`hw/ip/rv_dm`](/home/eda/workspace/opentitan/hw/ip/rv_dm) | ✅ | ✅ | ✅ | prim, tlul(adapter_host), jtag_pkg, vendored pulp_riscv_dbg |
| SoC Debug Ctrl | `lowrisc:ip:soc_dbg_ctrl:0.1.0` | [`hw/ip/soc_dbg_ctrl`](/home/eda/workspace/opentitan/hw/ip/soc_dbg_ctrl) | ✅ | ✅ | ✅ | prim, tlul, rom_ctrl_pkg, soc_dbg_ctrl_pkg, lc_ctrl_pkg |

> 说明：`RV Timer` 未列入 BLOCKFILE 受保护列表，但结构完整；`RRAM Ctrl` 依赖 `lowrisc:earlgrey_ip:otp_ctrl_macro_pkg`（Top 级 pkg，需同步打包或抽为公共 pkg）。

---

## 构建顺序（拓扑排序）

1. **批次 0**：`ip-prim` → `ip-tlul`（所有 IP 的公共依赖，先打 tag）
2. **批次 1 - 无外部 pkg 依赖的简单 IP**（先构建，作为依赖验证）：
   `uart`、`aon_timer`、`sysrst_ctrl`、`hmac`、`pattgen`、`mbx`
3. **批次 1 - 有 pkg 级依赖的 IP**（依赖上一步产物）：
   `i2c`、`spi_host`、`spi_device`、`usbdev`、`rv_timer`、`adc_ctrl`、`edn`、`sram_ctrl`、`dma`
4. **批次 1 - 密码学 / 安全 IP**（依赖 prim + 多个 pkg）：
   `aes`、`ascon`、`entropy_src`、`csrng`、`hmac`、`kmac`、`otbn`、`keymgr`、`keymgr_dpe`、`lc_ctrl`、`rom_ctrl`、`rram_ctrl`、`rv_dm`、`soc_dbg_ctrl`

---

## 依赖打包注意事项

- **prim**：单个 `.core`（`lowrisc:prim:all`）聚合约 60 个 `prim_*.core` 子模块，构建 `ip-prim` 时需全量收录 `rtl/` 与所有子 `.core`。
- **tlul**：包含 `adapter_*`、`socket_*`、`headers`、`trans_intg`、`jtag_dtm` 等子 core，需全量收录。
- **pkg 依赖**：如 `lc_ctrl_pkg`、`edn_pkg`、`keymgr_pkg` 等随宿主 IP 一起打包，下游通过 FuseSoC `depend: lowrisc:ip:<x>_pkg` 引用；发布时在 `ip-package.yaml` 中声明对应版本约束（建议 `^0.1.0`）。
- **Top 级 pkg**：`ast_pkg`（adc_ctrl 依赖）、`otp_ctrl_macro_pkg`（rram_ctrl 依赖）、`pwrmgr_pkg`（soc_dbg_ctrl 依赖）位于 Top 层，需抽为公共 pkg repo 或随宿主 IP 附带。
- **vendored IP**：`rv_dm` 依赖 [`hw/vendor/pulp_riscv_dbg`](/home/eda/workspace/opentitan/hw/vendor/pulp_riscv_dbg)，建议作为外部依赖引用，不重复 vendored。

---

## 批次 2（需补件后可构建，本清单暂不展开）

| IP | 缺失项 | 处理建议 |
|---|---|---|
| `i3c` | 无 `.core` | 补齐 FuseSoC core + DV |
| `bkdr_loader` | 无 `dv/` | FPGA 专用，可延后 |
| `otp_macro` / `rram_macro` | 无 `doc/` | 补齐 README 后构建 |
| `flash_ctrl` / `otp_ctrl` | 依赖 Top ipgen 生成 | 随 Top 仓库发布，不单独构建 |
| `rv_core_ibex` / `racl_ctrl` / `soc_dbg_ctrl` 相关 | 依赖 vendored ibex / Top | 归入处理器 / Top 仓库 |
