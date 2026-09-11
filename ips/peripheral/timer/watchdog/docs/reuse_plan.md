# Watchdog 复用评估与接入计划

基于当前工作区本地 registry、接口契约、core 和 VIP Gate 报告；未进行远程同步。
输入 SHA-256 见 `reports/full_flow/reuse_inputs.json`。当前为 HLD 候选决策。

| 资产 | 本地状态与匹配判断 | 接入和验收 |
|---|---|---|
| aixsilicon:cbb:round_robin_arbiter:0.1.0 | implemented；匹配邮箱/硬件两源公平仲裁 | NUM_REQ=2、PC_IMPL=0、组合 grant；core depend 引用 |
| incrementer_decrementer:0.1.0 | implemented；通道饱和/互补状态和故障优先级不同于独立模运算 | 不选用，通道状态更新由本 IP 负责 |
| lockstep_comparator:1.0.0 | implemented；按字段互补、原因分类与即时保持请求不同于普通向量比较 | 不选用；安全独立性及真实故障检测仍须验证 |
| APB VIP | developing / M1 / PARTIAL_DEVELOPING，G4/G5 PARTIAL、G6 NOT_RUN | 预备只读依赖；VPLAN 定义精确 APB4 范围 qualification，实测后才计入 G4 |
| HWIF IFC-APB-001 | APB4 基础契约 draft；允许原生 15 位地址/32 位数据 | LLD 明确 PPROT/PSTRB 及可信身份额外侧带绑定 |
| apb4_base / apb_csr_v1 profiles | draft；前者限定 32 位地址，后者限定 32/64 位并禁止 protection | 均不直接匹配；不宣称符合现成 CSR profile |

已有 CBB core 缺少已装 FuseSoC schema 所需 paramtype。历史 run_validation.py
在 build/dependency_adapter 中生成临时元数据并引用原 CBB SV；该历史结果不证明
当前全流程已解析成功。G3 重新记录解析/展开，优先 owner 修复；如使用适配，保存
原因和原始/适配元数据哈希。不复制或编辑 CBB 源码，build 编译导出不是交付件。

邮箱、复位/错误握手和通道监督在已检查 registry 中无实现且语义匹配的资产，保留
IP 专属实现。现有 APB UT 激励只属于模块测试，完整 UVM 接入仍是本次必需工作。
不能因 VIP 尚未发布而直接放弃复用；若 qualification 暴露缺陷，记录具体问题及
临时方案范围，不能将未闭合依赖标签转换为验证通过。

系统较宽 APB 地址必须先完整译码后缩窄到原生 15 位，禁止截断产生别名。可信身份、
诊断授权不能从非可信 PPROT 推导。该集成合同及 profile 差异须进入 LLD、VPLAN 和用户手册。
