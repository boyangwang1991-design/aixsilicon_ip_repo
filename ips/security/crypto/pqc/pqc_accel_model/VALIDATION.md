# 验证报告

## 验证对象

- 六个参数集：ML-KEM-512/768/1024、ML-DSA-44/65/87。
- 完整操作：KEM KeyGen/Encaps/Decaps，DSA KeyGen/Sign/Verify。
- 硬件primitive：双模NTT调度、Montgomery算术、LSB Codec、Keccak流、banked secure SRAM、128-byte descriptor。

## 独立性

- 完整算法模型：`kyber-py 1.2.0`与`dilithium-py 1.4.0`。
- 编译oracle：`pqcrypto 1.0.0`，其底层来自独立C实现。
- 自研模块：`pqc_hw_model`中的primitive、存储、描述符和trace代码未调用oracle内部函数。

## 已执行检查

1. ML-KEM三参数集自身KeyGen→Encaps→Decaps闭环。
2. ML-KEM模型生成key、oracle encaps、模型decaps。
3. ML-KEM oracle生成key、模型encaps、oracle decaps。
4. ML-KEM密文翻转后产生32-byte rejection secret，且公开trace shape一致。
5. ML-DSA三参数集自身Sign→Verify及消息篡改检查。
6. ML-DSA模型生成签名、oracle验签。
7. ML-DSA oracle生成签名、模型验签。
8. KEM/DSA双模NTT forward/inverse round-trip。
9. Montgomery表示和乘法边界值检查。
10. Codec property test、Keccak与Python标准库逐字节比较。
11. descriptor round-trip/CRC破坏、SRAM owner/debug/zeroize负向检查。

机器生成结果见`validation_report.json`。

本次交付环境实测结果：

- `compileall`：PASS；
- 单轮pytest：26/26 PASS；
- 20轮随机化重复回归：20/20 PASS；
- 累计pytest case执行：520，失败0。

## 验证结论边界

PASS表示当前Python模型、两套算法实现和编译oracle在上述接口与测试上相容。它不等价于：

- NIST ACVP或FIPS 140-3认证；
- 与未来RTL逐周期等价；
- 标准NTT中间排列/Montgomery常量已经冻结；
- 侧信道、故障注入、CDC、STA或门级验证已经完成。

进入RTL前必须继续完成：导入NIST ACVP/KAT文件；冻结FIPS errata版本；实现ML-KEM base multiplication的标准中间checkpoint；将算法内部primitive调用替换为当前硬件模块接口；增加cocotb/Verilator同向量差分。
