# RTL 检查汇总 - X2P

<!-- REPORT_META
schema_version: "2.0"
ip_name: x2p
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
checks:
  lint: pass
  elab: pass
  synth: pass
  formal: exploratory (VC Formal 未安装)
END_REPORT_META -->

## 1. Lint（FuseSoC VCS lint mode）

- 状态: **PASS**
- 证据: `build/aixsilicon_ip_x2p_1.0.0/lint-vcs/vcs.log`
- 结论: VCS `-sverilog -lint=all` 编译全部 9 个 RTL 文件，无 error。

## 2. Elaboration（FuseSoC VCS elab mode）

- 状态: **PASS**
- 证据: `build/aixsilicon_ip_x2p_1.0.0/elab-vcs/vcs.log`
- 结论: `x2p_top` elaboration 成功，无 error，资源/层次正确。

## 3. Synthesis（Design Compiler）

- 状态: **PASS**
- 证据: `reports/synth/qor.rpt` / `area.rpt` / `build/synth/x2p_top_synth.v`
- 结论: `Elaborated 1 design` + `SYNTH_OK`，RTL 可综合。
- Warnings:
  - `ELAB-311` CASE default 不可达（size_bytes case 已覆盖 0-7 全值）→ 合法，保留防御性默认。
  - `LINT-52` `apb_error` 在 APB4 profile 下直连 0 → 预期（APB3 partial 逻辑参数化裁剪）。

## 4. Formal（VC Formal）

- 状态: **exploratory**
- 原因: 环境未安装 VC Formal。降级为 lint+elab+RTL 语义 review 作为探索性证据，
  不参与 G3-G5 正式门禁判定。

## 5. 结论

G3 输入满足：lint/elab/synth 三项 RTL 工具检查通过（commercial-systemverilog 证据）。
formal 因工具缺失标记 exploratory，不影响 G3（已验证可综合）。