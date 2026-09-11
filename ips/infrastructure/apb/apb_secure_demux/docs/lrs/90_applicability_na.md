# 不适用项与保护边界

## Low Power（LP）

N/A - 不提供本地低功耗协议或独立 retention 电源域。外部功能门控须遵守 RST-005，等待期间不得停响应时钟。

## Generator（GEN）

N/A - 本次交付类型为 parameterized SystemVerilog IP，无改变模块结构的 Python Hardware IR 生成器需求。
参数合法性和配置检查仍是 required，不因本项 N/A 省略。

## Functional Safety（SAFE）

适用配置存储完整性故障检测与阻断；相关条目位于 08_safety_integrity 分册。
N/A - 不承诺特定 ASIL、FMEDA 诊断覆盖率或认证等级；不覆盖任意多 bit、组合逻辑、日志存储和总线传输故障。
