# 寄存器结构与再生成

结构定义入口为templates/apb_secure_demux.rdl.j2中的SystemRDL；scripts/render_registers.py仅按合法实例展开端口/主体及复位值，不生成RTL行为。apb_secure_demux.rdl为典型夹具展开结果，供PeakRDL消费，禁止同时手改模板和派生RDL。所有RTL/RAL/Header/HTML/IP-XACT来自该RDL；特殊状态仍需LLD行为owner实现。

在IP目录使用workflow根uv环境，示例：

```bash
uv run python scripts/render_registers.py --model model/parameter_space.yaml --configuration CFG_TYPICAL_DIRECT --output regs/apb_secure_demux.rdl
uv run peakrdl regblock regs/apb_secure_demux.rdl -o rtl/generated --cpuif apb4-flat --module-name apb_secure_demux_csr --package-name apb_secure_demux_csr_pkg --default-reset arst_n --err-if-bad-addr --err-if-bad-rw
uv run peakrdl c-header regs/apb_secure_demux.rdl -o sw/include/apb_secure_demux_regs.h
uv run peakrdl uvm regs/apb_secure_demux.rdl -o verification/ral/apb_secure_demux_ral.sv
```

实际实例可用--config <instance.yaml>取代--model/--configuration；地址、管理掩码等必须显式提供。命名fixture不构成产品默认。配置manifest记录模板、配置、展开器及RDL哈希；改变实例必须重新生成全部视图，不允许仅覆盖顶层参数而复用旧CSR维度。

生成包的SIZE是最后实现寄存器末端，不是整个CSR窗口容量。外层译码必须继续使用合同CSR_SIZE=0x1000+NUM_PORTS*0x400，尾部保留空间仍属于本地CSR错误窗口。typical生成结构末端0x2e40，完整窗口0x3000；不能据sizeof(C结构)缩小窗口。

当前检查见reports/quality/register_check.md及registers证据。VCS探针只验证生成接口；external状态模型不是权限/锁/日志功能实现。RAL编译需先编译uvm_pkg，再编译生成package；仅加-ntb_opts不保证新工作库已包含uvm_pkg。

HTML 仅供本地查看：整个 PeakRDL 站点（含 JS/CSS/图片等资源）只生成到已忽略的 `build/registers/html/apb_secure_demux/`。禁止提交 GitHub、部署 GitHub Pages 或随 Release/发布包上传；证据索引不收录站点资源。旧 `docs/generated/*_regs.html/` 位置也已防御性忽略。

```bash
uv run peakrdl html regs/apb_secure_demux.rdl -o build/registers/html/apb_secure_demux
```
