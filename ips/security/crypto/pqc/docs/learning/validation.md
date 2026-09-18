# 教材编写与检查记录

[学习首页](../index.md) · [实验说明](11-labs.md)

日期：2026-09-18。本页记录本次文档工作的检查，区别于模型历史报告及现有 EDA 回归。改动范围为新建学习材料、示例和配图，未修改算法模型或 RTL。

## 已执行的内容检查

- 对照 `pqc_accel_model/src/pqc_hw_model` 全部模块及现有测试，整理真实调用关系与局限。
- 对照 HLD、LLD、RTL 包与顶层检查模块名称、参数、描述符偏移、opcode 和数据尺寸。
- 阅读最新统一报告，更新 Decaps 已修复的状态；没有将现有 UVM/UT 数字当成本次运行结果。
- 使用 ChatGPT 原生生图生成及校正 7 张最终 PNG，目视核对后插入 Markdown；错误蝶形草图与未修正的签名草图未交付。
- 保存最终[基础图提示词](../assets/learning/prompts.json)与[复杂图及修正提示词](../assets/learning/complex-prompts.json)；源码读取快照见 [source-snapshot.json](source-snapshot.json)，其哈希只用于追溯本次阅读内容，不是验证签名。

## 本次实验

`learning_demo.py primitives` 的全部断言执行通过，包含负循环乘法、Montgomery、KEM/DSA NTT 往返、packing、SHAKE、描述符 CRC、SRAM 权限和清零。

关键输出：

```text
negacyclic: [1, 6, 0, 1]
Montgomery product: 2824
ML-KEM-768 NTT roundtrip: OK; ideal forward cycles: 448
ML-DSA-65 NTT roundtrip: OK; ideal forward cycles: 512
LSB packing: d100 ; noncanonical coefficient rejected
SHAKE chunking and repeated-prefix semantics: OK
descriptor: 128 B; header: 01020010 ; CRC corruption caught
SRAM owner/debug denial and secret-page zeroize: OK
```

初次沙箱内运行打印 PASS 后未退出，20 秒超时后被终止，退出码 137。随后在沙箱外按教材的正常命令重新运行，全部断言通过且进程正常退出，**退出码 0**，未对交付示例加入强制退出代码。文档检查器还检查相对链接、代码块闭合、尾空白、PNG 文件头/尺寸、提示词 JSON 和示例 Python 语法。

当前根环境检测到 pytest、kyber_py，但缺少 hypothesis、dilithium_py、pqcrypto；本次未改变根依赖环境，未重跑完整算法/互操作 pytest。历史 `26/26` 与 `520` 次执行仍仅属于原模型报告。

最终文档专属检查退出码 0：21 份 Markdown、290 个本地相对链接全部有效；7 张 PNG 文件头与尺寸合法；两份提示词 JSON 可解析；当前 RTL 顶层目录的模块文件均有教学地图入口；示例 Python 语法和 Ruff 检查通过。交付包括 12 章主教材、5 章硬件教学内容及各自导航/记录，标准 `docs/user_manual/` 未放入本次教学材料。

## 通用工作区检查的限制

初次在沙箱内尝试 `make check` 与 `pre-commit run --all-files`，各设 45 秒上限，以防环境退出挂起无限阻塞。`make check` 停在 bootstrap 已输出 materialize SKIP 后；pre-commit 的前七项基础检查通过，但停在本地 `aix-guard-runtime-paths`。这两次沙箱运行超时终止，退出码 137，本身不算通过。

随后在沙箱外重跑：`make check` 的 Ruff、6 项 schema 同步检查和 125 个工作区 pytest 用例通过，退出码 0；`pre-commit run --all-files` 全部通过，退出码 0。

这两项检查覆盖工作区既有文件，不是新增子仓教材的专属验证。教材的链接、插图引用、示例与基础格式单独检查；本次没有执行综合、RTL 仿真、CDC、STA、ACVP 或侧信道测量。
