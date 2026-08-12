//==============================================================================
// 文件名: tc_sanity.sv
// 描述:   健康检查测试用例
//         启动 sanity sequence，完成最小可运行测试
//==============================================================================

`ifndef TC_SANITY__SV
`define TC_SANITY__SV

class tc_sanity extends tc_base;

    //==========================================================================
    // UVM 组件注册
    //==========================================================================
    
    `uvm_component_utils_begin(tc_sanity)
    `uvm_component_utils_end
    
    //==========================================================================
    // 构造函数
    //==========================================================================
    
    extern function new(string name = "tc_sanity", uvm_component parent = null);
    
    //==========================================================================
    // 运行阶段
    //==========================================================================
    
    extern virtual task run_phase(uvm_phase phase);

endclass

//==========================================================================
// Extern 函数定义
//==========================================================================

/// @brief 构造函数定义
/// @param name   测试名称字符串
/// @param parent 父组件句柄
function tc_sanity::new(string name = "tc_sanity", uvm_component parent = null);
    super.new(name, parent);
endfunction

/// @brief 运行阶段定义
/// @param phase 当前阶段句柄
task tc_sanity::run_phase(uvm_phase phase);
    apb_sanity_seq seq;
    
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), "健康检查测试开始", UVM_LOW)
    
    // 创建并启动序列
    seq = apb_sanity_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);
    
    // 等待一段时间确保所有事务完成
    #1000;
    
    `uvm_info(get_type_name(), "健康检查测试完成", UVM_LOW)
    
    phase.drop_objection(this);
endtask

`endif // TC_SANITY_SV
