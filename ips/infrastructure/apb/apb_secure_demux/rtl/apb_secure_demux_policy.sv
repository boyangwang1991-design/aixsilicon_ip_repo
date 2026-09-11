// Implements LLD.MOD.APB_SECURE_DEMUX.POLICY. Single state owner, atomic bank updates.
module apb_secure_demux_policy #(
    parameter int unsigned NUM_PORTS=8,
    parameter int unsigned NUM_MASTERS=16,
    parameter bit POLICY_PARITY_EN=1'b1,
    parameter logic [1:0] RESET_PORT_CFG [NUM_PORTS]='{default:'0},
    parameter logic [7:0] RESET_PERM [NUM_PORTS][NUM_MASTERS]='{default:'0}
) (
    input logic pclk,preset_n,
    input logic cfg_write_i,perm_write_i,global_lock_write_i,port_lock_write_i,
    input logic commit_attempt_i,commit_accept_i,reload_accept_i,
    input logic [4:0] port_i,
    input logic [5:0] master_i,
    input logic [31:0] write_data_i,
    input logic synthetic_integrity_i,
    input logic [4:0] synthetic_port_i,
    output logic [1:0] active_cfg_o [NUM_PORTS],shadow_cfg_o [NUM_PORTS],
    output logic [7:0] active_perm_o [NUM_PORTS][NUM_MASTERS],shadow_perm_o [NUM_PORTS][NUM_MASTERS],
    output logic global_lock_o,
    output logic [NUM_PORTS-1:0] port_lock_o,
    output logic raw_bad_o,fatal_o,new_integrity_o,integrity_test_o,
    output logic [31:0] policy_version_o,commit_status_o,integrity_status_o,
    output logic mask_valid_o,selected_locked_o,
    output logic [13:0] integrity_location_o,
    output logic [4:0] first_locked_port_o
);
    logic port_ok,master_ok,configuration_ok;
    logic [31:0] commit_result;
    logic [13:0] raw_location;
    logic lock_global_bad;
    logic [NUM_PORTS-1:0] lock_port_bad,cfg_active_bad,cfg_shadow_bad;
    logic [NUM_MASTERS-1:0] perm_active_bad [NUM_PORTS],perm_shadow_bad [NUM_PORTS];
    assign port_ok=({1'b0,port_i}<6'(NUM_PORTS));
    assign master_ok=({1'b0,master_i}<7'(NUM_MASTERS));
    assign mask_valid_o=(write_data_i!=32'b0) && ((write_data_i >> NUM_PORTS)==32'b0);
    always_comb begin
        selected_locked_o=1'b0;first_locked_port_o=5'b0;
        for(int unsigned p=0;p<NUM_PORTS;p++) begin
            if(write_data_i[p] && port_lock_o[p] && !selected_locked_o) begin
                selected_locked_o=1'b1;first_locked_port_o=5'(p);
            end
        end
        commit_result=32'h00000001;
        if(!mask_valid_o) commit_result=32'h00000012;
        else if(global_lock_o) commit_result=32'h00000022;
        else if(selected_locked_o) commit_result=32'h00002032 | (32'(first_locked_port_o)<<8);
        else if(fatal_o || raw_bad_o) commit_result=32'h00000042;
    end
    assign configuration_ok=mask_valid_o && !global_lock_o && !selected_locked_o && !fatal_o && !raw_bad_o;
    always_ff @(posedge pclk or negedge preset_n) begin
        if(!preset_n) begin
            policy_version_o<=32'b0;commit_status_o<=32'b0;
            for(int unsigned p=0;p<NUM_PORTS;p++) begin
                active_cfg_o[p]<=RESET_PORT_CFG[p];shadow_cfg_o[p]<=RESET_PORT_CFG[p];
                for(int unsigned m=0;m<NUM_MASTERS;m++) begin
                    active_perm_o[p][m]<=RESET_PERM[p][m];shadow_perm_o[p][m]<=RESET_PERM[p][m];
                end
            end
        end else begin
            if(commit_attempt_i) commit_status_o<=commit_result;
            if(commit_accept_i && configuration_ok) begin
                policy_version_o<=policy_version_o+32'd1;
                for(int unsigned p=0;p<NUM_PORTS;p++) if(write_data_i[p]) begin
                    active_cfg_o[p]<=shadow_cfg_o[p];
                    for(int unsigned m=0;m<NUM_MASTERS;m++) active_perm_o[p][m]<=shadow_perm_o[p][m];
                end
            end
            if(reload_accept_i && configuration_ok) begin
                for(int unsigned p=0;p<NUM_PORTS;p++) if(write_data_i[p]) begin
                    shadow_cfg_o[p]<=active_cfg_o[p];
                    for(int unsigned m=0;m<NUM_MASTERS;m++) shadow_perm_o[p][m]<=active_perm_o[p][m];
                end
            end
            if(port_ok && !global_lock_o && !port_lock_o[port_i] && !fatal_o && !raw_bad_o) begin
                if(cfg_write_i) shadow_cfg_o[port_i]<=write_data_i[1:0];
                if(perm_write_i && master_ok) shadow_perm_o[port_i][master_i]<=write_data_i[7:0];
            end
        end
    end
    if(POLICY_PARITY_EN) begin : g_protected
        logic [1:0] global_lock_q,port_lock_q [NUM_PORTS];
        logic cfg_active_parity_q [NUM_PORTS],cfg_shadow_parity_q [NUM_PORTS];
        logic perm_active_parity_q [NUM_PORTS][NUM_MASTERS],perm_shadow_parity_q [NUM_PORTS][NUM_MASTERS];
        wire cfg_write_parity,perm_write_parity;
        parity_gen_check #(.DATA_WIDTH(4),.PARITY_TYPE(0),.PC_IMPL(0)) u_write_cfg(.data_i({2'b0,write_data_i[1:0]}),.parity_o(cfg_write_parity));
        parity_gen_check #(.DATA_WIDTH(8),.PARITY_TYPE(0),.PC_IMPL(0)) u_write_perm(.data_i(write_data_i[7:0]),.parity_o(perm_write_parity));
        assign global_lock_o=(global_lock_q!=2'b01);
        assign lock_global_bad=(global_lock_q!=2'b01 && global_lock_q!=2'b10);
        always_ff @(posedge pclk or negedge preset_n) begin
            if(!preset_n) global_lock_q<=2'b01;
            else if(global_lock_write_i && write_data_i[0]) global_lock_q<=2'b10;
        end
        for(genvar p=0;p<NUM_PORTS;p++) begin : g_port
            wire cfg_active_parity,cfg_shadow_parity;
            parity_gen_check #(.DATA_WIDTH(4),.PARITY_TYPE(0),.PC_IMPL(0)) u_active_cfg(.data_i({2'b0,active_cfg_o[p]}),.parity_o(cfg_active_parity));
            parity_gen_check #(.DATA_WIDTH(4),.PARITY_TYPE(0),.PC_IMPL(0)) u_shadow_cfg(.data_i({2'b0,shadow_cfg_o[p]}),.parity_o(cfg_shadow_parity));
            assign port_lock_o[p]=(port_lock_q[p]!=2'b01);
            assign lock_port_bad[p]=(port_lock_q[p]!=2'b01 && port_lock_q[p]!=2'b10);
            assign cfg_active_bad[p]=(cfg_active_parity!=cfg_active_parity_q[p]);
            assign cfg_shadow_bad[p]=(cfg_shadow_parity!=cfg_shadow_parity_q[p]);
            always_ff @(posedge pclk or negedge preset_n) begin
                if(!preset_n) begin
                    port_lock_q[p]<=2'b01;
                    cfg_active_parity_q[p]<=^RESET_PORT_CFG[p];cfg_shadow_parity_q[p]<=^RESET_PORT_CFG[p];
                end else begin
                    if(port_lock_write_i && port_i==5'(p) && write_data_i[0]) port_lock_q[p]<=2'b10;
                    if(commit_accept_i && configuration_ok && write_data_i[p]) cfg_active_parity_q[p]<=cfg_shadow_parity_q[p];
                    if(reload_accept_i && configuration_ok && write_data_i[p]) cfg_shadow_parity_q[p]<=cfg_active_parity_q[p];
                    if(cfg_write_i && port_i==5'(p) && !global_lock_o && !port_lock_o[p] && !fatal_o && !raw_bad_o) cfg_shadow_parity_q[p]<=cfg_write_parity;
                end
            end
            for(genvar m=0;m<NUM_MASTERS;m++) begin : g_master
                wire active_parity,shadow_parity;
                parity_gen_check #(.DATA_WIDTH(8),.PARITY_TYPE(0),.PC_IMPL(0)) u_active_perm(.data_i(active_perm_o[p][m]),.parity_o(active_parity));
                parity_gen_check #(.DATA_WIDTH(8),.PARITY_TYPE(0),.PC_IMPL(0)) u_shadow_perm(.data_i(shadow_perm_o[p][m]),.parity_o(shadow_parity));
                assign perm_active_bad[p][m]=(active_parity!=perm_active_parity_q[p][m]);
                assign perm_shadow_bad[p][m]=(shadow_parity!=perm_shadow_parity_q[p][m]);
                always_ff @(posedge pclk or negedge preset_n) begin
                    if(!preset_n) begin perm_active_parity_q[p][m]<=^RESET_PERM[p][m];perm_shadow_parity_q[p][m]<=^RESET_PERM[p][m];end
                    else begin
                        if(commit_accept_i && configuration_ok && write_data_i[p]) perm_active_parity_q[p][m]<=perm_shadow_parity_q[p][m];
                        if(reload_accept_i && configuration_ok && write_data_i[p]) perm_shadow_parity_q[p][m]<=perm_active_parity_q[p][m];
                        if(perm_write_i && port_i==5'(p) && master_i==6'(m) && !global_lock_o && !port_lock_o[p] && !fatal_o && !raw_bad_o) perm_shadow_parity_q[p][m]<=perm_write_parity;
                    end
                end
            end
        end
    end else begin : g_unprotected
        assign lock_global_bad=1'b0;assign lock_port_bad='0;assign cfg_active_bad='0;assign cfg_shadow_bad='0;
        for(genvar p=0;p<NUM_PORTS;p++) begin : g_zero
            assign perm_active_bad[p]='0;assign perm_shadow_bad[p]='0;
        end
        always_ff @(posedge pclk or negedge preset_n) begin
            if(!preset_n) begin global_lock_o<=1'b0;port_lock_o<='0;end
            else begin
                if(global_lock_write_i && write_data_i[0]) global_lock_o<=1'b1;
                if(port_lock_write_i && port_ok && write_data_i[0]) port_lock_o[port_i]<=1'b1;
            end
        end
    end
    always_comb begin
        raw_bad_o=lock_global_bad;raw_location=14'b0;
        for(int unsigned p=0;p<NUM_PORTS;p++) begin
            if(!raw_bad_o && lock_port_bad[p]) begin raw_bad_o=1'b1;raw_location={3'd1,6'b0,5'(p)};end
            if(!raw_bad_o && cfg_active_bad[p]) begin raw_bad_o=1'b1;raw_location={3'd2,6'b0,5'(p)};end
            if(!raw_bad_o && cfg_shadow_bad[p]) begin raw_bad_o=1'b1;raw_location={3'd3,6'b0,5'(p)};end
            for(int unsigned m=0;m<NUM_MASTERS;m++)
                if(!raw_bad_o && perm_active_bad[p][m]) begin raw_bad_o=1'b1;raw_location={3'd4,6'(m),5'(p)};end
            for(int unsigned m=0;m<NUM_MASTERS;m++)
                if(!raw_bad_o && perm_shadow_bad[p][m]) begin raw_bad_o=1'b1;raw_location={3'd5,6'(m),5'(p)};end
        end
    end
    assign integrity_location_o=raw_bad_o ? raw_location : {3'd6,6'b0,synthetic_port_i};
    assign new_integrity_o=POLICY_PARITY_EN && !fatal_o && (raw_bad_o || synthetic_integrity_i);
    assign integrity_test_o=new_integrity_o && !raw_bad_o && synthetic_integrity_i;
    always_ff @(posedge pclk or negedge preset_n) begin
        if(!preset_n) begin fatal_o<=1'b0;integrity_status_o<=32'b0;end
        else if(new_integrity_o) begin
            fatal_o<=1'b1;
            integrity_status_o<=raw_bad_o ? {16'b0,raw_location,2'b11} : {16'b0,3'd6,6'b0,synthetic_port_i,2'b11};
        end
    end
endmodule
