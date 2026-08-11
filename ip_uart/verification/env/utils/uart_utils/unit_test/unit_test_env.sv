//==============================================================================
// 文件名: unit_test_env.sv
// 描述:   单元测试环境类
//         例化 agent、配置模式、连接 checker
//==============================================================================

`ifndef UNIT_TEST_ENV__SV
`define UNIT_TEST_ENV__SV

class unit_test_env extends uvm_env;

    //==========================================================================
    // UVM 组件注册
    //==========================================================================
    
    `uvm_component_utils_begin(unit_test_env)
    `uvm_component_utils_end
    
    //==========================================================================
    // 子组件句柄
    //==========================================================================
    
    uart_interface_agent     agent;       // Agent 实例
    uart_interface_agent_cfg agent_cfg;   // Agent 配置
    unit_test_checker      checker;     // 检查器
    
    //==========================================================================
    // 构造函数
    //==========================================================================
    
    extern function new(string name = "unit_test_env", uvm_component parent = null);
    
    //==========================================================================
    // 构建阶段
    //==========================================================================
    
    extern virtual function void build_phase(uvm_phase phase);
    
    //==========================================================================
    // 连接阶段
    //==========================================================================
    
    extern virtual function void connect_phase(uvm_phase phase);
    
    //==========================================================================
    // 报告阶段
    //==========================================================================
    
    extern virtual function void report_phase(uvm_phase phase);

endclass

//==========================================================================
// Extern 函数定义
//==========================================================================

/// @brief 构造函数定义
/// @param name   环境名称字符串
/// @param parent 父组件句柄
function unit_test_env::new(string name = "unit_test_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

/// @brief 构建阶段定义
/// @param phase 当前阶段句柄
function void unit_test_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 创建 Agent 配置
    agent_cfg = uart_interface_agent_cfg::type_id::create("agent_cfg");
    
    // 从 config_db 获取虚拟接口
    if (!uvm_config_db#(virtual uart_interface)::get(this, "", "vif", agent_cfg.vif)) begin
        `uvm_fatal(get_type_name(), "无法获取虚拟接口 vif")
    end
    
    // 配置为 Full BFM 模式 (用于单元测试)
    agent_cfg.config_as_full_bfm();
    
    // 传递配置给 agent
    uvm_config_db#(uart_interface_agent_cfg)::set(this, "agent", "cfg", agent_cfg);
    
    // 创建 Agent
    agent = uart_interface_agent::type_id::create("agent", this);
    
    // 创建 Checker
    checker = unit_test_checker::type_id::create("checker", this);
endfunction

/// @brief 连接阶段定义
/// @param phase 当前阶段句柄
function void unit_test_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // 连接 monitor 到 checker
    if (agent_cfg.enable.monitor) begin
        agent.monitor.item_port.connect(checker.item_export);
    end
endfunction

/// @brief 报告阶段定义
/// @param phase 当前阶段句柄
function void unit_test_env::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "单元测试环境报告阶段", UVM_LOW)
endfunction

`endif // UNIT_TEST_ENV_SV
