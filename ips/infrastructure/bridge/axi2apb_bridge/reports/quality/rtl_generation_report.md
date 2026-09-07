# RTL 生成报告 - X2P

## 基本信息
- IP: x2p
- 生成日期: 2026-09-03
- RTL 状态: candidate（待 09-rtl-check 门禁确认）

## 生成文件

| 文件 | 模块 | 说明 |
|---|---|---|
| rtl/x2p_pkg.sv | x2p_pkg | 参数/常量包 |
| rtl/x2p_req_mgr.sv | x2p_req_mgr | 读写请求队列（FIFO） |
| rtl/x2p_scheduler.sv | x2p_scheduler | R/W 仲裁（RR/READ_PRI/WRITE_PRI × BEAT/TRANSACTION） |
| rtl/x2p_transfer_engine.sv | x2p_transfer_engine | Burst 跟踪、地址生成、宽度转换、subtransfer 生成 |
| rtl/x2p_cdc.sv | x2p_cdc | 双时钟异步 FIFO（Gray 指针） |
| rtl/x2p_apb_engine.sv | x2p_apb_engine | APB FSM（SETUP/ACCESS/WAIT/TIMEOUT） |
| rtl/x2p_rsp_mgr.sv | x2p_rsp_mgr | 读组装/错误聚合/R-B 输出 |
| rtl/x2p_axi_frontend.sv | x2p_axi_frontend | AXI 通道捕获 |
| rtl/x2p_top.sv | x2p_top | 顶层集成 |
| rtl/filelist.f | - | 编译 filelist |

## 语法验证

- VCS `-parse` 全部 9 文件解析成功，无语法/RTL 错误。
- 顶层识别：`x2p_top`。
- 链接阶段工具环境缺 32-bit `ctype-stubs_32.a`（VCS 安装问题，非 RTL），
  不影响解析；elaboration 门禁在 09-rtl-check 阶段以非 -m32 方式验证。

## trace seed

已输出 `reports/trace-seeds/lld_to_rtl.yaml`（LLD → RTL 链接全集）。