# PQC Hardware Model

ML-KEM/ML-DSA可执行硬件模型原型。工程将验证分成两条独立链：

1. 自研bit-accurate primitive模型：模算术、NTT调度、Keccak流、Codec、banked SRAM和描述符。
2. 完整算法交叉验证：纯Python FIPS实现与独立PQClean编译实现双向互操作。

## 运行

```bash
python -m pip install -e '.[test]'
pytest -q
python scripts/run_validation.py
```

离线环境可以把依赖预装到外部目录后设置`PYTHONPATH`。当前模型不是RTL，也不宣称完成侧信道、STA、CDC或FIPS 140-3认证；它是RTL实现和cocotb/Verilator差分验证的黄金模型起点。

## 模块边界

- `params.py`：六个标准参数集和输出长度。
- `modular.py`：定宽检查、Montgomery/Barrett、negacyclic schoolbook乘法。
- `ntt.py`：KEM/DSA双模、硬件蝶形调度、bank访问trace、精确逆变换。
- `codec.py`：LSB-first bit pack/unpack和规范性检查。
- `keccak.py`：增量SHA3/SHAKE硬件接口模型。
- `memory.py`：带page tag、权限和zeroize的banked SRAM。
- `descriptor.py`：128-byte命令描述符编解码与CRC。
- `accelerator.py`：完整算法API、key-slot和公开trace。
- `oracle.py`：独立标准库互操作检查。

## 重要边界

当前NTT模块实现了与计划硬件一致的蝶形stage/address调度和可逆性，未宣称其中间系数排列与任何特定C实现相同。RTL冻结时需要将FIPS常量生成器、Montgomery表示和ML-KEM base multiplication继续固化，并新增逐checkpoint比对。

