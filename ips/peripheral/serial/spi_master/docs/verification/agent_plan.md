# Agent 复用

详见 ../reuse_plan.md。sync_fifo 是实际 CBB 依赖；APB VIP 尚未达到完整交付 gate，SPI VIP 未实现，当前采用本地 BFM。模块 UT 对罕见计数边界的 force 仅存在于验证源。
