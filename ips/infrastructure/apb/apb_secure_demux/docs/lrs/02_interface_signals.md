# Interface Requirements：外部信号

| 信号 | 方向 | 位宽 | 定义 |
|---|---|---:|---|
| pclk | 输入 | 1 | 功能时钟 |
| preset_ni | 输入 | 1 | 低有效可信模块复位，异步置位复位、同步释放 |
| s_paddr | 输入 | ADDR_WIDTH | 上游字节地址 |
| s_psel / s_penable / s_pwrite | 输入 | 各 1 | APB 控制 |
| s_pwdata / s_pstrb / s_pprot | 输入 | 32/4/3 | APB 写数据、字节选通与保护属性 |
| s_prdata / s_pready / s_pslverr | 输出 | 32/1/1 | 上游响应 |
| master_id_i / master_id_valid_i | 输入 | MASTER_ID_WIDTH/1 | 可信主体身份 |
| m_paddr[i] | 输出 | ADDR_WIDTH | 各输出原始地址 |
| m_psel[i] / m_penable[i] / m_pwrite[i] | 输出 | 各 1 | 各输出控制 |
| m_pwdata[i] / m_pstrb[i] / m_pprot[i] | 输出 | 32/4/3 | 各输出请求 |
| m_prdata[i] / m_pready[i] / m_pslverr[i] | 输入 | 32/1/1 | 各下游响应 |
| m_master_id_o[i] / m_master_id_valid_o[i] | 输出 | MASTER_ID_WIDTH/1 | 随选中事务透传身份，支持级联保护 |
| irq_o | 输出 | 1 | 普通中断，电平保持 |
| security_alert_o | 输出 | 1 | 安全事件告警，电平保持 |
| dfx_authorized_i | 输入 | 1 | 可信 DFX 授权，高有效 |
| busy_o / active_port_valid_o | 输出 | 各 1 | 受控 DFX 观测 |
| active_port_o | 输出 | 5 | 当前外设目标编号 |
| wait_threshold_o | 输出 | 1 | 等待超阈值粘滞观测 |


所有功能信号属 pclk 域。集成层负责异步授权同步和跨域告警同步。
PPROT[0] 表示特权，PPROT[1] 表示 Non-secure，PPROT[2] 表示指令；
可信管理请求要求身份有效且范围合法、固定管理掩码命中，并为 Secure 特权数据访问。
