# 进阶专题检查记录

[教学目录](index.md)

日期：2026-09-18。范围：第 6～10 章、跨层示例与导航。关键阅读源码的 SHA-256 见 [supplement-snapshot.json](supplement-snapshot.json)，用于追溯本次讲解，不是 RTL 验证基线。

`bridge_demo.py` 在工作区 uv 环境运行，退出码 0。它使用标准库、仓内 codec 与独立代数 oracle，输出如下：

```text
12-bit pack [1, 2]: 012000
Compress/decompress d=4: max circular error=104
Compress/decompress d=10: max circular error=2
Stream handshake accepted: ['A', 'B']
Toy bank mapping: words 0/8 conflict; 0/1 do not
Ideal KEM forward NTT, 2 lanes: 448 cycles (not RTL latency)
Encaps-768: pk=1184 B, ct=1088 B, K=32 B; payload=2304 B
Frozen ML-KEM-768 case 2: manifest hashes, full ciphertext and K match
Oracle uses inverse Vandermonde and ring convolution; this is not an RTL test
```

冻结向量文件先校验 manifest 哈希，再比较完整 c 和 K；没有覆盖原向量。压缩误差遍历全部 3329 个 canonical 系数。握手与 bank 实验是简化示例，不是周期精确模型。

新增脚本 Ruff 检查通过。工作区 `make check`（Ruff、6 项 schema、125 项 pytest）和 `pre-commit run --all-files` 均退出 0。考虑此前沙箱内 Python 退出挂起，本次这些检查在经工具批准的沙箱外运行。

这些工作区门禁不自动覆盖被父仓忽略的子仓教材，因此另外检查了教学 Markdown 相对链接、代码块闭合、尾空白、PNG 文件头/尺寸、提示词 JSON 和示例 AST。最终检查退出码 0：27 份 Markdown、365 个本地链接、8 张 PNG。新封装流程图经过原生生图重试后成功，已目视核对并落到项目目录。

未执行 RTL 仿真、综合或完整第三方算法 pytest；没有把教程实验记作 RTL 回归通过。
