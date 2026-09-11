# WATCHDOG Simulation Directory

本目录用于运行 watchdog IP 模块的 UVM 仿真。

## 目录结构

```
verification/sim/          # 入口（源码，可提交）
├── Makefile               # 仿真 Makefile
└── README.md              # 本文件

<ip>/build/sim/            # 运行产物（git 忽略，不提交）
├── simv / csrc/ / simv.daidir/
├── run/
│   ├── tc_sanity_12345/
│   │   └── run.log
│   └── ...
└── *.fsdb / *.log        # 波形与日志
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

- 所有运行产物都写入 `<ip>/build/sim/`（`simv`、`csrc/`、`run/`、`*.fsdb`），
  本目录只保留 Makefile/README 入口；`build/` 已被工作区 `.gitignore` 忽略。
- 每个测试运行会创建独立的子目录 `<ip>/build/sim/run/<TEST>_<SEED>/`
- 编译和运行日志分别保存为 `<ip>/build/sim/compile.log` 和
  `<ip>/build/sim/run/<TEST>_<SEED>/run.log`
