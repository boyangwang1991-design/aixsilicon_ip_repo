# UART Simulation Directory

本目录用于运行 uart IP 模块的 UVM 仿真。

## 目录结构

```
sim/
├── Makefile           # 仿真 Makefile
├── README.md          # 本文件
└── run/               # 运行时生成的测试目录
    ├── tc_sanity_12345/
    │   ├── compile.log
    │   ├── run.log
    │   └── ...
    └── ...
```

## 快速开始

### 编译并运行

```bash
# 运行默认测试 (tc_sanity)
make run

# 运行指定测试
make run TEST=tc_basic_reset

# 指定随机种子
make run TEST=tc_sanity SEED=12345
```

### 回归测试

```bash
# 运行所有测试
make regress
```

### Verdi 调试

```bash
# 启动 Verdi 查看波形
make verdi
```

### 覆盖率

```bash
# 启用覆盖率编译和运行
make run COV=1

# 生成覆盖率报告
make coverage
```

### 清理

```bash
# 清理所有运行文件
make clean
```

## Makefile 变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `SIMULATOR` | 仿真器 (vcs/xcelium/questa) | vcs |
| `TEST` | 测试名称 | tc_sanity |
| `SEED` | 随机种子 | random |
| `GUI` | 是否启动 GUI (0/1) | 0 |
| `COV` | 是否收集覆盖率 (0/1) | 0 |

## 注意事项

- 所有运行结果都保存在 `run/` 目录下
- 每个测试运行会创建独立的子目录 `run/<TEST>_<SEED>/`
- 编译和运行日志分别保存为 `compile.log` 和 `run.log`
