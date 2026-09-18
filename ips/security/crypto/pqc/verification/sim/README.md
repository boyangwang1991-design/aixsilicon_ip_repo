# PQC 仿真入口

从本目录运行 `make run TEST=tc_kem_decaps_main SEED=1`，或从工作区根运行
`make -C repos/aixsilicon_ip_repo/ips/security/crypto/pqc/verification/sim regress`。
Makefile 使用工作区唯一 uv 环境及 `run_uvm.py`，默认 seed 为 1。
`make compile` 只编译，不能作为测试通过；`make ut` 使用模块 UT 的 FuseSoC 入口。

`make regress` 执行 Makefile 中列出的自检查用例，默认 seeds 为 `1 17`，
不是完整 G4 测试计划。可用 `TESTS` 和 `SEEDS` 显式选择子集。
当前仅支持 VCS/UVM 1.2；FuseSoC UVM 依赖接入、真实 coverage 和参数空间仍未闭环。
没有可用的 coverage 入口，不沿用模板的伪目标。

每次在 `<ip>/build/sim/uvm/run-*/` 独立编译，保存输入文件集合和哈希、
工具版本、编译命令与日志、二进制哈希、逐测试日志、`summary.json` 和 `junit.xml`。
退出码、实际测试名、UVM 摘要及算法完成标记都必须满足检查。
输入或二进制在运行期间变化使整批证据失效。详情见 [验证说明](../README.md)。

Decaps 每次运行 45 个命令：9 组正常向量、27 组密文首/中/末字节篡改、
9 组总线背压重复。数据由离线 oracle 冻结，仿真不调用软件密码算法。
局部固定周期检查不代替完整安全与掩码验证。

KeyGen 增量用 `TEST=tc_kem_keygen_main` 运行：三参数集各三组d/z，专用托管私钥、
公钥/句柄DMA及completion均做逐字节检查。托管错误transaction ACK不能提前退休。
`docs/learning/*.md` 是辅助教学文档，其前后哈希单独记录在summary，允许并发编辑；
其余设计/验证文档、源码、向量、Core及VIP仍参与严格构建身份检查。
