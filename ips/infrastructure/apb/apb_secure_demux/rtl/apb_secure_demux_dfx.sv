// Implements LLD.MOD.APB_SECURE_DEMUX.DFX. No permission bypass.
module apb_secure_demux_dfx #(
    parameter int unsigned NUM_PORTS=8,
    parameter int unsigned NUM_MASTERS=16,
    parameter bit DFX_EN=1'b1,
    parameter bit POLICY_PARITY_EN=1'b1
) (
    input logic pclk,preset_n,authorized_i,
    // Command valid inputs are accepted management CSR completions.
    input logic threshold_write_i,target_write_i,inject_command_i,
    input logic [31:0] write_data_i,
    input logic [1:0] clear_i,
    input logic [4:0] counter_clear_i [NUM_PORTS],
    input logic consume_i,new_transaction_i,
    input logic activity_valid_i,
    input logic [4:0] activity_port_i,
    input logic downstream_wait_i,downstream_complete_i,downstream_error_i,
    input logic deny_i,
    input logic [4:0] deny_port_i,
    output logic command_valid_o,target_valid_o,
    output logic [31:0] threshold_o,target_o,status_o,
    output logic [1:0] armed_mode_o,
    output logic [4:0] armed_port_o,
    output logic [5:0] armed_master_o,
    output logic synthetic_event_o,wait_event_o,
    output logic busy_o,active_port_valid_o,wait_threshold_o,
    output logic [4:0] active_port_o,
    output logic [31:0] success_count_o [NUM_PORTS],
    output logic [31:0] deny_count_o [NUM_PORTS],
    output logic [31:0] slverr_count_o [NUM_PORTS],
    output logic [31:0] wait_total_o [NUM_PORTS],
    output logic [31:0] wait_max_o [NUM_PORTS]
);
    if(!DFX_EN) begin : g_disabled
        assign command_valid_o=1'b0;assign target_valid_o=1'b0;
        assign threshold_o=32'b0;assign target_o=32'b0;assign status_o=32'b0;
        assign armed_mode_o=2'b00;assign armed_port_o=5'b0;assign armed_master_o=6'b0;
        assign synthetic_event_o=1'b0;assign wait_event_o=1'b0;
        assign busy_o=1'b0;assign active_port_valid_o=1'b0;assign wait_threshold_o=1'b0;assign active_port_o=5'b0;
        for(genvar p=0;p<NUM_PORTS;p++) begin : g_zero
            assign success_count_o[p]=32'b0;assign deny_count_o[p]=32'b0;
            assign slverr_count_o[p]=32'b0;assign wait_total_o[p]=32'b0;assign wait_max_o[p]=32'b0;
        end
    end else begin : g_enabled
        logic wait_hit_q,wait_reported_q;
        logic [31:0] wait_count_q,wait_next;
        logic [1:0] mode_q;
        logic [4:0] target_port_q,armed_port_q;
        logic [5:0] target_master_q,armed_master_q;
        logic active;
        function automatic logic [31:0] increment(input logic [31:0] value);
            return (&value) ? value : value+32'd1;
        endfunction
        assign target_valid_o=(mode_q==2'b00) && ({1'b0,write_data_i[4:0]} < 6'(NUM_PORTS)) &&
            ({1'b0,write_data_i[13:8]} < 7'(NUM_MASTERS));
        assign command_valid_o=(write_data_i[2:0]==3'b001) ||
            ((mode_q==2'b00) && ((write_data_i[2:0]==3'b010) ||
            (POLICY_PARITY_EN && write_data_i[2:0]==3'b100)));
        assign synthetic_event_o=authorized_i && inject_command_i && command_valid_o && write_data_i[0];
        assign armed_mode_o=mode_q;
        assign armed_port_o=armed_port_q;
        assign armed_master_o=armed_master_q;
        assign target_o={18'b0,target_master_q,3'b0,target_port_q};
        assign status_o={28'b0,wait_hit_q,(mode_q==2'b10),(mode_q==2'b01),authorized_i};
        assign active=activity_valid_i && ({1'b0,activity_port_i}<6'(NUM_PORTS));
        assign busy_o=authorized_i && active;
        assign active_port_valid_o=authorized_i && active;
        assign active_port_o=active_port_valid_o ? activity_port_i : 5'b0;
        assign wait_threshold_o=authorized_i && wait_hit_q;
        assign wait_next=increment(wait_count_q);
        assign wait_event_o=active && downstream_wait_i && !wait_reported_q &&
            (threshold_o!=32'b0) && (wait_next>=threshold_o);
        always_ff @(posedge pclk or negedge preset_n) begin
            if(!preset_n) begin
                threshold_o<=32'b0;target_port_q<=5'b0;target_master_q<=6'b0;
                armed_port_q<=5'b0;armed_master_q<=6'b0;mode_q<=2'b00;
                wait_hit_q<=1'b0;wait_reported_q<=1'b0;wait_count_q<=32'b0;
            end else begin
                if(!authorized_i) mode_q<=2'b00;
                else begin
                    if(clear_i[1] || consume_i) mode_q<=2'b00;
                    else if(inject_command_i && command_valid_o && !write_data_i[0]) begin
                        mode_q<=write_data_i[2] ? 2'b10 : 2'b01;
                        armed_port_q<=target_port_q;armed_master_q<=target_master_q;
                    end
                    if(target_write_i && target_valid_o) begin target_port_q<=write_data_i[4:0];target_master_q<=write_data_i[13:8];end
                    if(threshold_write_i) threshold_o<=write_data_i;
                end
                if(authorized_i && clear_i[0]) wait_hit_q<=1'b0;
                if(new_transaction_i) begin wait_count_q<=32'b0;wait_reported_q<=1'b0;end
                else if(active && downstream_wait_i) wait_count_q<=wait_next;
                if(wait_event_o) begin wait_hit_q<=1'b1;wait_reported_q<=1'b1;end
            end
        end
        for(genvar p=0;p<NUM_PORTS;p++) begin : g_counters
            logic [31:0] success_base,deny_base,error_base,total_base,max_base;
            assign success_base=(authorized_i && counter_clear_i[p][0]) ? 32'b0 : success_count_o[p];
            assign deny_base=(authorized_i && counter_clear_i[p][1]) ? 32'b0 : deny_count_o[p];
            assign error_base=(authorized_i && counter_clear_i[p][2]) ? 32'b0 : slverr_count_o[p];
            assign total_base=(authorized_i && counter_clear_i[p][3]) ? 32'b0 : wait_total_o[p];
            assign max_base=(authorized_i && counter_clear_i[p][4]) ? 32'b0 : wait_max_o[p];
            always_ff @(posedge pclk or negedge preset_n) begin
                if(!preset_n) begin
                    success_count_o[p]<=32'b0;deny_count_o[p]<=32'b0;slverr_count_o[p]<=32'b0;
                    wait_total_o[p]<=32'b0;wait_max_o[p]<=32'b0;
                end else begin
                    success_count_o[p]<=(active && activity_port_i==5'(p) && downstream_complete_i && !downstream_error_i) ? increment(success_base) : success_base;
                    slverr_count_o[p]<=(active && activity_port_i==5'(p) && downstream_complete_i && downstream_error_i) ? increment(error_base) : error_base;
                    deny_count_o[p]<=(deny_i && deny_port_i==5'(p)) ? increment(deny_base) : deny_base;
                    wait_total_o[p]<=(active && activity_port_i==5'(p) && downstream_wait_i) ? increment(total_base) : total_base;
                    wait_max_o[p]<=(active && activity_port_i==5'(p) && downstream_complete_i && wait_count_q>max_base) ? wait_count_q : max_base;
                end
            end
        end
    end
endmodule
