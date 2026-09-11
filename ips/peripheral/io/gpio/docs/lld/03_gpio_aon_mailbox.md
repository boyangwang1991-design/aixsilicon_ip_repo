# GPIO 微设计：gpio_aon_mailbox

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.MAILBOX
name: gpio_aon_mailbox
hld_ref:
- HLD.MOD.GPIO.MAILBOX
req_ref:
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: AON_WAKE_EN == 1
rtl_intent:
  separate_module: true
  suggested_name: gpio_aon_mailbox
clock_domains:
- CLK_MAIN
- CLK_AON
reset_domains:
- RST_MAIN
- RST_POR_MAIN
- RST_AON
END_LLD_MODULE_META -->

## 周期行为与状态

源端req_toggle、冻结payload和inflight使用主POR复位；目的端ack_toggle、响应payload和已处理身份使用AON冷复位。主staging/cache/软件状态main复位。源端只有READY且!BUSY接受命令，接受沿复制整组staging到payload、翻转req_toggle并置inflight。
req_toggle两级同步到AON，稳定新token与已处理不同才执行一次。目标执行/拒绝后原子更新ack_toggle和完整响应，保持至下一请求。ack_toggle两级同步回主；匹配当前req_toggle且inflight时释放槽并复制响应。
主暖复位不修改req_toggle/payload/inflight。主恢复计数至少覆盖返回同步级填充，inflight为1则等旧应答并丢弃旧软件完成；当同步ack与req一致且槽空后置READY。旧token永不翻转重发。
接受命令计时从0开始，每运行pclk加1；达到AON_TIMEOUT置TIMEOUT与sticky诊断，BUSY不释放。ACK迟到仍完成原操作；无cancel。新合法命令才清DONE/ERROR/TIMEOUT。BUSY时所有Bank staging/命令写都错。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.MAILBOX
module_ref: LLD.MOD.GPIO.MAILBOX
hld_ref:
- HLD.MOD.GPIO.MAILBOX
req_ref:
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.MAILBOX
module_ref: LLD.MOD.GPIO.MAILBOX
reset_domain: RST_MAIN/RST_POR_MAIN/RST_AON
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.MAILBOX
req_ref:
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。

## Mailbox载荷连接定义

request为224位保持总线：[3:0]命令one-hot，[5:4]Bank，[37:6]ENABLE，
[69:38]/[101:70]/[133:102]为MODE0/1/2，[149:134]DIV，[157:150]COUNT，
[189:158]CLEAR/LOCK_MASK，高位保留0。response为352位，低位起11个32位字：
PENDING、VALID、LOCK、ENABLE、MODE0、MODE1、MODE2、DIV、COUNT、保留0、保留0。
返回ERROR为与response同时保持的单独位。寄存器结构仍以RDL为准，此处仅为内部连接。
目的端见到新token产生一拍command；业务模块下一沿提供registered response_valid/data，
桥接器随后锁存response并更新ACK。同步器两级给保持数据足够传播时间，约束应覆盖该多周期路径。
