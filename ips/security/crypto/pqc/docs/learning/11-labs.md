# 11 · 动手实验、预期现象与排错

[上一章](10-security.md) · [学习首页](../index.md) · [下一章](12-status-and-references.md)

配套 [learning_demo.py](../examples/learning_demo.py) 直接导入你指定目录中的模型，没有重新实现另一套算法。它只打印学习用数据、长度和状态，不输出私钥、共享秘密或签名随机种子。

## 运行位置与环境

以下命令从工作区根执行，复用根 `.venv`，不在子仓创建虚拟环境：

```bash
cd /home/eda/workspace/aixsilicon_workflow
PQC_ROOT="$PWD/repos/aixsilicon_ip_repo/ips/security/crypto/pqc"
PQC_MODEL="$PQC_ROOT/pqc_accel_model"
uv run --no-sync python "$PQC_ROOT/docs/examples/learning_demo.py" primitives
```

脚本按自身位置定位模型，因此普通运行不需额外 PYTHONPATH。primitives 模式仅需要标准库；`PqcAccelerator` 的第三方依赖在实例化时才导入。

算法模型锁定 `kyber-py==1.2.0`、`dilithium-py==1.4.0`、`pqcrypto==1.0.0`；测试还需要 pytest 和 hypothesis，详见 [requirements.txt](../../pqc_accel_model/requirements.txt)。在本多仓工作区，应通过根项目的 uv 依赖管理安装与记录缺失依赖，不要在子仓另建 `.venv`，也不要把依赖缺失误诊成算法失败。

## 实验一：手算与运行对应

primitives 模式顺序演示：

| 步骤 | 预期 | 为什么有意义 |
|---|---|---|
| n=4 的负循环乘法 | `[1,6,0,1]` | 验证折回是减号 |
| 123×456 mod 3329 | 通过 Montgomery 得到与 `%q` 相同结果 | 检查域转换闭环 |
| KEM-768 NTT 往返 | 恢复全部 256 系数；正变换理想周期 448 | 观察 7 层调度 |
| DSA-65 NTT 往返 | 恢复全部 256 系数；正变换理想周期 512 | 观察 8 层调度 |
| 3-bit packing | `d100` | 观察跨字节和零 padding |
| 非规范系数 | 3329 被 12-bit 解码，但 canonical 为 False | 分清位宽合法与模数合法 |
| SHAKE 分段输入 | 与一次性 hashlib 相同 | 理解 absorb 分段等价性 |
| 描述符破坏 | CRC 异常 | 检查字节布局和错误路径 |
| SRAM 权限与清零 | 错 owner/debug 拒绝，秘密页清为零 | 理解最小安全语义 |

最后应打印 `Primitive learning checks: PASS`。这验证教材例子与当前模型的对应关系，没有验证硬件电路。

进一步练习：把 NTT lanes 改为 1、4，记录理想周期，解释为什么系数输出不应改变。再看 trace 的 bank_conflicts，思考为什么增加 lane 并未自动解决存储端口冲突。

## 实验二：完整算法 API

依赖满足后运行：

```bash
uv run --no-sync python "$PQC_ROOT/docs/examples/learning_demo.py" algorithms
```

预期 KEM-768 的 pk/ct/ss 长度为 1184/1088/32；合法密文得到相同秘密，翻转一个密文字节后得到 32 B 的拒绝秘密，人工 public trace 的形状相同。DSA-65 的公钥/签名长度为 1952/3309；原消息验证成功，消息或 context 改变后验证失败。

本实验默认用 deterministic 签名便于学习，不改变库的生产使用策略。不要把算法模式的成功解释成自研 Poly/Sampler/Codec 已经组成完整算法。

## 实验三：运行既有测试

```bash
PYTHONPATH="$PQC_MODEL/src${PYTHONPATH:+:$PYTHONPATH}" \
  uv run --no-sync python -m pytest "$PQC_MODEL/tests" -q \
  -o cache_dir=/tmp/pqc-learning-pytest
```

模型历史报告记录 26 个测试通过及重复回归；你的环境必须独立记录自己的退出码、依赖版本与日志。不要直接调用会覆盖历史 JSON 的 `scripts/run_validation.py` 来“试试看”。

阅读测试时，把覆盖范围拆开：`test_ntt_roundtrip` 只检查可逆；算法互操作测试比较两套实现的完整结果；descriptor 测试检查 CRC；没有一个测试单独代表整个 IP 完成。

## 实验四：从一个字节错误追到模块

假设公钥输入长度正确，但某系数编码为 4000：位解包能读出 4000，canonical 检查应失败，不能先 `%3329` 再允许进入算法。排错顺序是 descriptor 长度 → DMA 字节顺序 → Codec 位拼接 → canonical 状态 → 序列器错误归属。

假设 Decaps 结果只在背压时错误：先检查握手接受条件、游标是否提前递增、原始密文页是否被覆盖，再检查数学公式。固定随机种子下无背压正确，并不能排除时序缺陷。

## 从学习实验走到 RTL 验证

建议按“模运算 → NTT 每 stage → 多项式乘法 → 编码和采样 → 整条算法 → 顶层总线”逐层比对。每个 checkpoint 要同时记录值、表示、参数集、地址单位与身份。

| 层次 | 有效的检查 | 常见误判 |
|---|---|---|
| 数学模型 | 与独立慢速/标准实现相符 | 自己的 forward/inverse 抵消同一个错误 |
| 原语 RTL | 相同向量及背压下数据/顺序相符 | 只有 done 出现就算通过 |
| 算法 RTL | 完整公钥/密文/签名/秘密逐字节相符 | 只比较长度或摘要一部分 |
| 系统 RTL | 输出、completion、IRQ、撤销均符合合同 | 算法完成后忽略总线响应 |
| 安全验证 | 明确威胁模型下检查访问、随机量、故障与泄漏 | 相同 Python trace 就声称恒时 |

现有入口见 [verification/README.md](../../verification/README.md)、[模块 UT runner](../../verification/unit_test/run_ut.sh) 和[验证计划](../verification/index.md)。RTL 仿真依赖 EDA 工具与工程配置，本教材不将运行 Python demo 描述成运行 RTL。

## 常见问题

| 现象 | 首先检查 |
|---|---|
| `No module named pqc_hw_model` | 运行教材脚本，或为 pytest 设置模型 src 的 PYTHONPATH |
| 缺 kyber_py/dilithium_py/pqcrypto | 根环境依赖和锁定版本；primitives 模式仍可独立学习 |
| 缺 hypothesis | pytest 的属性测试依赖尚未安装 |
| SHAKE 第二次输出重复 | 当前 `digest` 是前缀接口，没有流式游标 |
| 算法 trace.cycles=0 | API 只发摘要事件，未提供周期模型 |
| NTT 值与 C 实现不同 | 先核对排列、Montgomery 因子、根表和规范化 |
| 子进程打印 PASS 却不退出 | 单独记录进程退出状态；不能仅凭 PASS 文本认定回归完成 |

本次编写时的实际运行结果另见[本次检查记录](validation.md)，与模型历史报告分开保存。
