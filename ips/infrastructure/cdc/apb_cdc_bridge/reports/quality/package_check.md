# FuseSoC 打包检查报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G3 输入

## 1. Core 文件

- 路径：`apb_cdc_bridge.core`（IP 工作区根）
- VLNV：`aixsilicon:ip:apb_cdc_bridge:1.0.0`
- generation_profile：`sv`

## 2. Filesets

| fileset | 内容 |
|---------|------|
| rtl_handwritten | 7 个 RTL 模块 |
| rtl_includes | 定义头 |

## 3. Targets

| target | tool | 状态 |
|--------|------|------|
| lint | vcs | ✔ |
| elab | vcs | ✔ |
| sim | vcs | ✔ |
| smoke | vcs | ✔ |
| synth | dc | ✔ |
| formal | vc_formal | ✔（工具缺失记录 finding） |

## 4. 验证

```text
fusesoc --cores-root=. core show aixsilicon:ip:apb_cdc_bridge
✓ Core 解析成功，6 target 可见
```

## 5. 结论

**Package Check: PASS** — FuseSoC core 可解析，target 完整。
