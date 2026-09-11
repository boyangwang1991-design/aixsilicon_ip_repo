// LLD.MOD.APB_SECURE_DEMUX.CSR: authorization and completion gating around native RDL.
module apb_secure_demux_csr (
    input logic pclk,preset_n,csr_setup_i,csr_access_i,
    input logic [31:0] offset_i,write_data_i,
    input logic write_i,
    input logic [3:0] strb_i,
    input logic [2:0] prot_i,
    input logic [apb_secure_demux_instance_pkg::C_MASTER_ID_WIDTH-1:0] master_i,
    input logic master_valid_i,dfx_authorized_i,
    input logic consume_i,synthetic_integrity_i,
    input logic [255:0] setup_record_i,transaction_record_i,
    input logic bus_failure_i,access_deny_i,cfg_deny_i,downstream_error_i,
    input logic deny_port_valid_i,
    input logic [4:0] deny_port_i,
    input logic new_transaction_i,activity_valid_i,
    input logic [4:0] activity_port_i,
    input logic downstream_wait_i,downstream_complete_i,
    output logic [31:0] read_data_o,
    output logic [7:0] reason_o,
    output logic [1:0] active_cfg_o [apb_secure_demux_instance_pkg::C_NUM_PORTS],
    output logic [7:0] active_perm_o [apb_secure_demux_instance_pkg::C_NUM_PORTS][apb_secure_demux_instance_pkg::C_NUM_MASTERS],
    output logic raw_bad_o,fatal_o,
    output logic [31:0] policy_version_o,
    output logic [1:0] armed_mode_o,
    output logic [4:0] armed_port_o,
    output logic [5:0] armed_master_o,
    output logic irq_o,security_alert_o,busy_o,active_port_valid_o,wait_threshold_o,
    output logic [4:0] active_port_o
);
    import apb_secure_demux_instance_pkg::*;
    localparam int unsigned NP=int'(C_NUM_PORTS),NM=int'(C_NUM_MASTERS),IW=int'(C_MASTER_ID_WIDTH);
    logic [REG_COUNT-1:0] rd_sel,wr_sel;
    logic [31:0] reg_read[REG_COUNT];
    logic native_ready,native_error,exists,type_ok,identity_ok,management_ok,precheck_ok,accept;
    logic [31:0] native_data,masked_write;
    integer reg_index;
    logic [7:0] precheck_reason;
    logic [1:0] shadow_cfg[NP];logic [7:0] shadow_perm[NP][NM];
    logic global_lock;logic [NP-1:0] port_lock;
    logic cfg_write,perm_write,global_write,port_write,commit_attempt,commit_accept,reload_accept;
    logic [4:0] command_port;logic [5:0] command_master;
    logic mask_valid,selected_locked;logic [4:0] first_locked;
    logic [31:0] commit_status,integrity_status;
    logic new_integrity,integrity_test;logic [13:0] integrity_location;
    logic [3:0] fault_clear,counter_clear;logic fifo_pop,read_first,read_last;
    logic first_valid,last_valid;logic [255:0] first_words,last_words,fifo_head;
    logic [31:0] fifo_status,deny_count,cfg_count,lost_count,downstream_count;
    logic [2:0] lost_increment;
    logic [3:0] event_valid;logic [255:0] event_data[4];
    logic [8:0] irq_events;logic irq_clear,irq_write,alert_write,intr_test;
    logic [31:0] intr_raw,intr_enable,alert_enable;
    logic threshold_write,target_write,inject_command,dfx_command_valid,dfx_target_valid;
    logic [1:0] dfx_clear;logic [4:0] dfx_counter_clear[NP];
    logic [31:0] threshold,target,dfx_status;
    logic synthetic_event,wait_event;
    logic [31:0] success[NP],port_deny[NP],port_error[NP],wait_total[NP],wait_max[NP];
    assign identity_ok=master_valid_i && ({1'b0,master_i}<(IW+1)'(NM));
    always_comb begin
        management_ok=1'b0;
        if(identity_ok) management_ok=C_MGMT_MASTER_MASK[master_i] && prot_i==3'b001;
        precheck_reason=8'b0;
        if(!(management_ok || (C_PUBLIC_ID_EN && identity_ok && !write_i && !prot_i[2] && public_address(offset_i))) ||
           (dfx_address(offset_i) && !dfx_authorized_i)) precheck_reason=8'h10;
        else if(offset_i[1:0]!=2'b00) precheck_reason=8'h11;
        else if(write_i && strb_i!=4'hf) precheck_reason=8'h12;
    end
    assign precheck_ok=(precheck_reason==0);
    apb_secure_demux_register_bridge u_bridge(.pclk,.preset_n,
        .psel((csr_setup_i || csr_access_i) && precheck_ok),.penable(csr_access_i),
        .pwrite(write_i),.address(offset_i),.write_data(write_data_i),.strb(strb_i),.prot(prot_i),
        .read_data_i(reg_read),.read_select_o(rd_sel),.write_select_o(wr_sel),
        .ready(native_ready),.error(native_error),.read_data(native_data));
    always_comb begin
        reg_index=0;exists=1'b0;type_ok=1'b0;
        for(int unsigned r=0;r<REG_COUNT;r++) if(offset_i==REG_ADDR[r]) begin
            reg_index=int'(r);exists=1'b1;type_ok=write_i ? REG_WRITABLE[r] : REG_READABLE[r];
        end
        masked_write=write_data_i & REG_MASK[reg_index];
        command_port=5'(REG_PORT[reg_index]);command_master=6'(REG_MASTER[reg_index]);
        reason_o=precheck_reason;
        if(precheck_ok) begin
            if(!exists) reason_o=8'h13;
            else if(!type_ok) reason_o=8'h14;
            else if(write_i) begin
                case(REG_KIND[reg_index])
                    K_CFG_SHADOW,K_PERM_SHADOW: begin
                        if(global_lock || port_lock[command_port]) reason_o=8'h15;
                        else if(fatal_o || raw_bad_o) reason_o=8'h17;
                    end
                    K_COMMIT_MASK,K_SHADOW_RELOAD: begin
                        if(global_lock || selected_locked) reason_o=8'h15;
                        else if(!mask_valid) reason_o=8'h16;
                        else if(fatal_o || raw_bad_o) reason_o=8'h17;
                    end
                    K_FIFO_POP: if(fifo_status[8]) reason_o=8'h16;
                    K_INJECT_TARGET: if(!dfx_target_valid) reason_o=8'h16;
                    K_INJECT_CMD: if(!dfx_command_valid) reason_o=8'h16;
                    default: begin end
                endcase
            end
        end
        if(csr_access_i && reason_o==0 && (native_error || !native_ready)) reason_o=8'h14;
    end
    assign accept=csr_access_i && reason_o==0 && native_ready && !native_error;
    assign read_data_o=accept && !write_i ? native_data : 32'b0;
    assign commit_attempt=csr_access_i && precheck_ok && exists && type_ok && write_i && REG_KIND[reg_index]==K_COMMIT_MASK;
    always_comb begin
        cfg_write=0;perm_write=0;global_write=0;port_write=0;commit_accept=0;reload_accept=0;
        fault_clear=0;counter_clear=0;fifo_pop=0;read_first=0;read_last=0;
        irq_clear=0;irq_write=0;alert_write=0;intr_test=0;
        threshold_write=0;target_write=0;inject_command=0;dfx_clear=0;
        for(int unsigned p=0;p<NP;p++) dfx_counter_clear[p]=0;
        if(accept) begin
            if(write_i && wr_sel[reg_index]) begin
                case(REG_KIND[reg_index])
                    K_CFG_SHADOW: cfg_write=1;
                    K_PERM_SHADOW: perm_write=1;
                    K_GLOBAL_LOCK: global_write=1;
                    K_PORT_LOCK: port_write=1;
                    K_COMMIT_MASK: commit_accept=1;
                    K_SHADOW_RELOAD: reload_accept=1;
                    K_FAULT_CLEAR: fault_clear=masked_write[3:0];
                    K_COUNTER_CLEAR: counter_clear=masked_write[3:0];
                    K_FIFO_POP: fifo_pop=masked_write[0];
                    K_INTR_RAW: irq_clear=1;
                    K_INTR_ENABLE: irq_write=1;
                    K_ALERT_ENABLE: alert_write=1;
                    K_INTR_TEST: intr_test=masked_write[8];
                    K_WAIT_THRESHOLD: threshold_write=1;
                    K_INJECT_TARGET: target_write=1;
                    K_INJECT_CMD: inject_command=1;
                    K_DFX_CLEAR: dfx_clear=masked_write[1:0];
                    K_DFX_COUNTER_CLEAR: dfx_counter_clear[command_port]=masked_write[4:0];
                    default: begin end
                endcase
            end else if(!write_i && rd_sel[reg_index]) begin
                read_first=(REG_KIND[reg_index]==K_FIRST_FAULT && REG_WORD[reg_index]==0);
                read_last=(REG_KIND[reg_index]==K_LAST_FAULT && REG_WORD[reg_index]==0);
            end
        end
    end
    always_comb begin
        for(int unsigned r=0;r<REG_COUNT;r++) begin
            reg_read[r]=REG_RESET[r];
            case(REG_KIND[r])
                K_STATUS:reg_read[r]={28'b0,last_valid,first_valid,global_lock,fatal_o};
                K_POLICY_VERSION:reg_read[r]=policy_version_o;
                K_GLOBAL_LOCK:reg_read[r]=32'(global_lock);
                K_COMMIT_STATUS:reg_read[r]=commit_status;
                K_INTR_RAW:reg_read[r]=intr_raw;
                K_INTR_ENABLE:reg_read[r]=intr_enable;
                K_INTR_MASKED:reg_read[r]=intr_raw & intr_enable;
                K_ALERT_ENABLE:reg_read[r]=alert_enable;
                K_FIFO_STATUS:reg_read[r]=fifo_status;
                K_ACCESS_DENY_COUNT:reg_read[r]=deny_count;
                K_CFG_DENY_COUNT:reg_read[r]=cfg_count;
                K_EVENT_LOST_COUNT:reg_read[r]=lost_count;
                K_DOWNSTREAM_ERR_COUNT:reg_read[r]=downstream_count;
                K_INTEGRITY_STATUS:reg_read[r]=integrity_status;
                K_FIRST_FAULT:reg_read[r]=first_words[REG_WORD[r]*32+:32];
                K_LAST_FAULT:reg_read[r]=last_words[REG_WORD[r]*32+:32];
                K_FIFO_HEAD:reg_read[r]=fifo_head[REG_WORD[r]*32+:32];
                K_DFX_STATUS:reg_read[r]=dfx_status;
                K_WAIT_THRESHOLD:reg_read[r]=threshold;
                K_INJECT_TARGET:reg_read[r]=target;
                K_PORT_LOCK:reg_read[r]=32'(port_lock[REG_PORT[r]]);
                K_CFG_SHADOW:reg_read[r]=32'(shadow_cfg[REG_PORT[r]]);
                K_CFG_ACTIVE:reg_read[r]=32'(active_cfg_o[REG_PORT[r]]);
                K_PERM_SHADOW:reg_read[r]=32'(shadow_perm[REG_PORT[r]][REG_MASTER[r]]);
                K_PERM_ACTIVE:reg_read[r]=32'(active_perm_o[REG_PORT[r]][REG_MASTER[r]]);
                K_SUCCESS_COUNT:reg_read[r]=success[REG_PORT[r]];
                K_DENY_COUNT:reg_read[r]=port_deny[REG_PORT[r]];
                K_SLVERR_COUNT:reg_read[r]=port_error[REG_PORT[r]];
                K_WAIT_TOTAL:reg_read[r]=wait_total[REG_PORT[r]];
                K_WAIT_MAX:reg_read[r]=wait_max[REG_PORT[r]];
                default: begin end
            endcase
        end
    end
    apb_secure_demux_policy #(.NUM_PORTS(NP),.NUM_MASTERS(NM),.POLICY_PARITY_EN(C_POLICY_PARITY_EN),
        .RESET_PORT_CFG(C_RESET_PORT_CFG),.RESET_PERM(C_RESET_PERM)) u_policy(
        .pclk,.preset_n,.cfg_write_i(cfg_write),.perm_write_i(perm_write),.global_lock_write_i(global_write),
        .port_lock_write_i(port_write),.commit_attempt_i(commit_attempt),.commit_accept_i(commit_accept),
        .reload_accept_i(reload_accept),.port_i(command_port),.master_i(command_master),.write_data_i(masked_write),
        .synthetic_integrity_i,.synthetic_port_i(setup_record_i[76:72]),.active_cfg_o,.shadow_cfg_o(shadow_cfg),
        .active_perm_o,.shadow_perm_o(shadow_perm),.global_lock_o(global_lock),.port_lock_o(port_lock),
        .raw_bad_o,.fatal_o,.new_integrity_o(new_integrity),.integrity_test_o(integrity_test),
        .policy_version_o,.commit_status_o(commit_status),.integrity_status_o(integrity_status),
        .mask_valid_o(mask_valid),.selected_locked_o(selected_locked),.first_locked_port_o(first_locked),
        .integrity_location_o(integrity_location));
    apb_secure_demux_dfx #(.NUM_PORTS(NP),.NUM_MASTERS(NM),.DFX_EN(C_DFX_EN),.POLICY_PARITY_EN(C_POLICY_PARITY_EN)) u_dfx(
        .pclk,.preset_n,.authorized_i(dfx_authorized_i),.threshold_write_i(threshold_write),.target_write_i(target_write),
        .inject_command_i(inject_command),.write_data_i(masked_write),.clear_i(dfx_clear),.counter_clear_i(dfx_counter_clear),
        .consume_i,.new_transaction_i,.activity_valid_i,.activity_port_i,.downstream_wait_i,.downstream_complete_i,
        .downstream_error_i,.deny_i(access_deny_i && deny_port_valid_i),.deny_port_i,
        .command_valid_o(dfx_command_valid),.target_valid_o(dfx_target_valid),.threshold_o(threshold),.target_o(target),
        .status_o(dfx_status),.armed_mode_o,.armed_port_o,.armed_master_o,.synthetic_event_o(synthetic_event),
        .wait_event_o(wait_event),.busy_o,.active_port_valid_o,.wait_threshold_o,.active_port_o,
        .success_count_o(success),.deny_count_o(port_deny),.slverr_count_o(port_error),.wait_total_o(wait_total),.wait_max_o(wait_max));
    always_comb begin
        event_valid={synthetic_event,wait_event,bus_failure_i,new_integrity};
        event_data[0]=integrity_test ? setup_record_i : 256'b0;
        event_data[0][71:64]=8'h30;event_data[0][87:80]=8'h08;
        event_data[0][76:72]=integrity_location[4:0];event_data[0][77]=(integrity_location[13:11]!=0);
        event_data[0][55]=integrity_test;
        if(!integrity_test) event_data[0][127:96]=policy_version_o;
        event_data[1]=transaction_record_i;
        event_data[2]=transaction_record_i;event_data[2][71:64]=8'h31;event_data[2][87:80]=8'h10;
        event_data[3]='0;event_data[3][55]=1;event_data[3][71:64]=8'h40;
        event_data[3][87:80]=8'h20;event_data[3][127:96]=policy_version_o;
        irq_events='0;
        irq_events[0]=access_deny_i;irq_events[1]=cfg_deny_i;
        irq_events[2]=access_deny_i && transaction_record_i[71:64]==8'h01;
        irq_events[3]=access_deny_i && transaction_record_i[71:64]==8'h02;
        irq_events[4]=new_integrity;irq_events[5]=(lost_increment!=0);
        irq_events[6]=downstream_error_i;irq_events[7]=wait_event;
        irq_events[8]=synthetic_event || integrity_test || (bus_failure_i && transaction_record_i[55]);
    end
    apb_secure_demux_events #(.EVENT_FIFO_DEPTH(C_EVENT_FIFO_DEPTH)) u_events(
        .pclk,.preset_n,.candidate_valid_i(event_valid),.candidate_data_i(event_data),.fault_clear_i(fault_clear),
        .counter_clear_i(counter_clear),.fifo_pop_i(fifo_pop),.first_word0_read_i(read_first),.last_word0_read_i(read_last),
        .access_deny_i,.cfg_deny_i,.downstream_error_i,.first_valid_o(first_valid),.last_valid_o(last_valid),
        .first_read_o(first_words),.last_read_o(last_words),.fifo_head_o(fifo_head),.fifo_status_o(fifo_status),
        .access_deny_count_o(deny_count),.cfg_deny_count_o(cfg_count),.event_lost_count_o(lost_count),
        .downstream_error_count_o(downstream_count),.lost_increment_o(lost_increment));
    apb_secure_demux_irq u_irq(.pclk,.preset_n,.event_bits_i(irq_events),.fatal_i(fatal_o),
        .raw_clear_i(irq_clear),.raw_clear_data_i(masked_write),.intr_enable_write_i(irq_write),
        .alert_enable_write_i(alert_write),.write_data_i(masked_write),.intr_test_i(intr_test),
        .intr_raw_o(intr_raw),.intr_enable_o(intr_enable),.alert_enable_o(alert_enable),.irq_o,.security_alert_o);
endmodule
