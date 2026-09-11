# GPIO 微设计：gpio_capture

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.CAPTURE
name: gpio_capture
hld_ref:
- HLD.MOD.GPIO.CAPTURE
req_ref:
- LRS.FUNC.GPIO.CAP001.001
- LRS.FUNC.GPIO.CAP001.002
- LRS.FUNC.GPIO.CAP002.001
- LRS.FUNC.GPIO.CAP002.002
- LRS.FUNC.GPIO.CAP003.001
- LRS.FUNC.GPIO.CAP003.002
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: SNAPSHOT_EN == 1 or STRAP_EN == 1
rtl_intent:
  separate_module: true
  suggested_name: gpio_capture
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
END_LLD_MODULE_META -->

## 周期行为与状态

snapshot_req或软件trigger在同一主沿合并，捕获全部Bank沿前IN_DATA/VALID并将32-bit SNAP_SEQ加1回绕。后续任意沿可覆盖，读取方以SEQ检测更新。
Strap仅首次有效请求采样物理同步视图；所有INPUT_CAP_MASK指定脚必须available且同步填充完毕。不可用请求不占用一次捕获机会，置STRAP_EARLY供软件重试；STRAP_VALID置1后直到主复位均忽略新请求。
SNAPSHOT_EN/STRAP_EN独立裁剪；软件与硬件触发在对应关闭时无副作用，读回0。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.CAPTURE
module_ref: LLD.MOD.GPIO.CAPTURE
hld_ref:
- HLD.MOD.GPIO.CAPTURE
req_ref:
- LRS.FUNC.GPIO.CAP001.001
- LRS.FUNC.GPIO.CAP001.002
- LRS.FUNC.GPIO.CAP002.001
- LRS.FUNC.GPIO.CAP002.002
- LRS.FUNC.GPIO.CAP003.001
- LRS.FUNC.GPIO.CAP003.002
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: SNAPSHOT_EN == 1 or STRAP_EN == 1
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.CAPTURE
module_ref: LLD.MOD.GPIO.CAPTURE
reset_domain: RST_MAIN
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.CAPTURE
req_ref:
- LRS.FUNC.GPIO.CAP001.001
- LRS.FUNC.GPIO.CAP001.002
- LRS.FUNC.GPIO.CAP002.001
- LRS.FUNC.GPIO.CAP002.002
- LRS.FUNC.GPIO.CAP003.001
- LRS.FUNC.GPIO.CAP003.002
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
