# FuseSoC 打包质量检查 - X2P

## 基本信息
- IP: x2p
- Core: `fusesoc/aixsilicon_ip_x2p.core`
- VLNV: `aixsilicon:ip:x2p:1.0.0`
- 校验日期: 2026-09-03

## Core 解析验证

`fusesoc core show aixsilicon:ip:x2p:1.0.0` 通过，识别出 6 个 target：
`lint / elab / sim / smoke / synth / formal`。

## Filesets

| Fileset | 文件 | 说明 |
|---|---|---|
| rtl_handwritten | 9 个 .sv | 手写 RTL |
| rtl_includes | x2p_defs.svh | 包含头文件 |

> X2P 无 generated RTL（register_model=none），故无 rtl_generated。
> sim/smoke 的 verification harness 文件由 10-13 阶段创建后补充到 core。

## 质量规则

| 检查项 | 结果 |
|---|---|
| 6 个 target 齐全 | ✅ |
| 引用的 RTL 文件存在 | ✅ |
| VLNV 统一 aixsilicon:ip:x2p | ✅ |

## 说明

- synth target 的 DC script 为空占位（09-rtl-check 直接以 DC 执行综合）。
- formal target 因无 VC Formal 标记 exploratory。