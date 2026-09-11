// LLD FRONTEND + ROUTE. Generated instance package is an explicit build input.
module apb_secure_demux #(
    parameter int unsigned NUM_PORTS=int'(apb_secure_demux_instance_pkg::C_NUM_PORTS),
    parameter int unsigned NUM_MASTERS=int'(apb_secure_demux_instance_pkg::C_NUM_MASTERS),
    parameter int unsigned ADDR_WIDTH=int'(apb_secure_demux_instance_pkg::C_ADDR_WIDTH),
    parameter int unsigned DATA_WIDTH=32,
    parameter int unsigned MASTER_ID_WIDTH=int'(apb_secure_demux_instance_pkg::C_MASTER_ID_WIDTH),
    parameter logic [ADDR_WIDTH-1:0] PORT_BASE[NUM_PORTS]=apb_secure_demux_instance_pkg::C_PORT_BASE,
    parameter logic [ADDR_WIDTH:0] PORT_SIZE[NUM_PORTS]=apb_secure_demux_instance_pkg::C_PORT_SIZE,
    parameter logic [ADDR_WIDTH-1:0] CSR_BASE=ADDR_WIDTH'(apb_secure_demux_instance_pkg::C_CSR_BASE),
    parameter logic [NUM_MASTERS-1:0] MGMT_MASTER_MASK=NUM_MASTERS'(apb_secure_demux_instance_pkg::C_MGMT_MASTER_MASK),
    parameter logic [1:0] RESET_PORT_CFG[NUM_PORTS]=apb_secure_demux_instance_pkg::C_RESET_PORT_CFG,
    parameter logic [7:0] RESET_PERM[NUM_PORTS][NUM_MASTERS]=apb_secure_demux_instance_pkg::C_RESET_PERM,
    parameter bit REGISTER_MODE=1'(apb_secure_demux_instance_pkg::C_REGISTER_MODE),
    parameter bit OUTPUT_ISOLATION_EN=1'(apb_secure_demux_instance_pkg::C_OUTPUT_ISOLATION_EN),
    parameter int unsigned EVENT_FIFO_DEPTH=int'(apb_secure_demux_instance_pkg::C_EVENT_FIFO_DEPTH),
    parameter bit POLICY_PARITY_EN=1'(apb_secure_demux_instance_pkg::C_POLICY_PARITY_EN),
    parameter bit DFX_EN=1'(apb_secure_demux_instance_pkg::C_DFX_EN),
    parameter bit PUBLIC_ID_EN=1'(apb_secure_demux_instance_pkg::C_PUBLIC_ID_EN),
    localparam int unsigned PORT_W=(NUM_PORTS>1)?$clog2(NUM_PORTS):1
) (
    input logic pclk,preset_ni,
    input logic [ADDR_WIDTH-1:0] s_paddr,
    input logic s_psel,s_penable,s_pwrite,
    input logic [31:0] s_pwdata,
    input logic [3:0] s_pstrb,
    input logic [2:0] s_pprot,
    output logic [31:0] s_prdata,
    output logic s_pready,s_pslverr,
    input logic [MASTER_ID_WIDTH-1:0] master_id_i,
    input logic master_id_valid_i,
    output logic [ADDR_WIDTH-1:0] m_paddr[NUM_PORTS],
    output logic [NUM_PORTS-1:0] m_psel,m_penable,m_pwrite,
    output logic [31:0] m_pwdata[NUM_PORTS],
    output logic [3:0] m_pstrb[NUM_PORTS],
    output logic [2:0] m_pprot[NUM_PORTS],
    input logic [31:0] m_prdata[NUM_PORTS],
    input logic [NUM_PORTS-1:0] m_pready,m_pslverr,
    output logic [MASTER_ID_WIDTH-1:0] m_master_id_o[NUM_PORTS],
    output logic [NUM_PORTS-1:0] m_master_id_valid_o,
    output logic irq_o,security_alert_o,
    input logic dfx_authorized_i,
    output logic busy_o,active_port_valid_o,wait_threshold_o,
    output logic [4:0] active_port_o
);
    import apb_secure_demux_instance_pkg::*;
    // A parameter override may not silently reuse CSR structure from another instance.
    if(NUM_PORTS!=C_NUM_PORTS || NUM_MASTERS!=C_NUM_MASTERS || ADDR_WIDTH!=C_ADDR_WIDTH ||
       DATA_WIDTH!=32 || MASTER_ID_WIDTH!=C_MASTER_ID_WIDTH || CSR_BASE!=C_CSR_BASE ||
       MGMT_MASTER_MASK!=C_MGMT_MASTER_MASK || REGISTER_MODE!=C_REGISTER_MODE ||
       OUTPUT_ISOLATION_EN!=C_OUTPUT_ISOLATION_EN || EVENT_FIFO_DEPTH!=C_EVENT_FIFO_DEPTH ||
       POLICY_PARITY_EN!=C_POLICY_PARITY_EN || DFX_EN!=C_DFX_EN || PUBLIC_ID_EN!=C_PUBLIC_ID_EN) begin : g_bad_instance
        APB_SECURE_DEMUX_REGENERATE_FOR_CHANGED_CONFIGURATION invalid_configuration();
    end
    for(genvar p=0;p<NUM_PORTS;p++) begin : g_bind_port
        if(PORT_BASE[p]!=C_PORT_BASE[p] || PORT_SIZE[p]!=C_PORT_SIZE[p] || RESET_PORT_CFG[p]!=C_RESET_PORT_CFG[p]) begin : g_bad_port
            APB_SECURE_DEMUX_REGENERATE_FOR_CHANGED_CONFIGURATION invalid_configuration();
        end
        for(genvar m=0;m<NUM_MASTERS;m++) begin : g_bind_master
            if(RESET_PERM[p][m]!=C_RESET_PERM[p][m]) begin : g_bad_reset
                APB_SECURE_DEMUX_REGENERATE_FOR_CHANGED_CONFIGURATION invalid_configuration();
            end
        end
    end
    typedef enum logic [2:0] {IDLE=3'b000,LOCAL=3'b001,REG_SETUP=3'b010,ACCESS=3'b011} state_t;
    state_t state_q,state_d;
    logic setup_valid,upstream_access,local_complete,downstream_complete,downstream_wait,downstream_error;
    logic [NUM_PORTS-1:0] hits;
    logic csr_hit,port_valid;
    logic [PORT_W-1:0] port;
    logic [7:0] decode_reason,admission_reason,reason_q,csr_reason,completion_reason;
    logic natural_allow,allow_access,test_flag,consume,synthetic_integrity,dfx_match;
    logic [1:0] active_cfg[NUM_PORTS];logic [7:0] active_perm[NUM_PORTS][NUM_MASTERS];
    logic raw_bad,fatal;logic [31:0] version,version_q;
    logic [1:0] armed_mode;logic [4:0] armed_port;logic [5:0] armed_master;
    logic [ADDR_WIDTH-1:0] address_q,payload_address;
    logic [31:0] data_q,payload_data,csr_data,csr_offset;
    logic [3:0] strb_q,payload_strb;logic [2:0] prot_q,payload_prot;
    logic write_q,payload_write,master_valid_q,payload_master_valid;
    logic [MASTER_ID_WIDTH-1:0] master_q,payload_master;
    logic [PORT_W-1:0] port_q,route_port;
    logic port_valid_q,csr_q,test_q,route_valid,route_enable,activity_valid;
    logic [4:0] activity_port;
    logic access_deny,cfg_deny,bus_failure;
    logic [255:0] setup_record,transaction_record;
    assign setup_valid=preset_ni && state_q==IDLE && s_psel && !s_penable;
    assign upstream_access=s_psel && s_penable;
    assign local_complete=preset_ni && state_q==LOCAL && upstream_access;
    assign downstream_complete=preset_ni && state_q==ACCESS && port_valid_q && m_pready[port_q];
    assign downstream_wait=preset_ni && state_q==ACCESS && port_valid_q && !m_pready[port_q];
    assign downstream_error=downstream_complete && m_pslverr[port_q];
    apb_secure_demux_decode #(.NUM_PORTS(NUM_PORTS),.ADDR_WIDTH(ADDR_WIDTH),.PORT_BASE(PORT_BASE),
        .PORT_SIZE(PORT_SIZE),.CSR_BASE(CSR_BASE)) u_decode(.address_i(s_paddr),.port_hits_o(hits),
        .csr_hit_o(csr_hit),.port_o(port),.port_valid_o(port_valid),.reason_o(decode_reason));
    assign dfx_match=(5'(port)==armed_port) && (16'(master_id_i)==16'(armed_master));
    apb_secure_demux_access #(.NUM_PORTS(NUM_PORTS),.NUM_MASTERS(NUM_MASTERS),.MASTER_ID_WIDTH(MASTER_ID_WIDTH),.DFX_EN(DFX_EN)) u_access(
        .setup_valid_i(setup_valid),.decode_reason_i(decode_reason),.port_valid_i(port_valid),.port_i(port),
        .master_id_i,.master_valid_i(master_id_valid_i),.prot_i(s_pprot),.write_i(s_pwrite),
        .active_cfg_i(active_cfg),.active_perm_i(active_perm),.raw_bad_i(raw_bad),.fatal_i(fatal),
        .dfx_authorized_i,.dfx_match_i(dfx_match),.dfx_deny_armed_i(armed_mode==2'b01),
        .dfx_integrity_armed_i(armed_mode==2'b10),.natural_allow_o(natural_allow),.allow_o(allow_access),
        .reason_o(admission_reason),.test_o(test_flag),.consume_o(consume),.synthetic_integrity_o(synthetic_integrity));
    always_comb begin
        state_d=state_q;
        case(state_q)
            IDLE: if(setup_valid) begin
                if(allow_access) state_d=REGISTER_MODE ? REG_SETUP : ACCESS;
                else state_d=LOCAL;
            end
            LOCAL: if(local_complete) state_d=IDLE;
            REG_SETUP: state_d=ACCESS;
            ACCESS: if(downstream_complete) state_d=IDLE;
            default: begin end // Quarantine until trusted reset; no manufactured completion.
        endcase
    end
    always_ff @(posedge pclk or negedge preset_ni) begin
        if(!preset_ni) begin
            state_q<=IDLE;address_q<='0;data_q<=0;strb_q<=0;prot_q<=0;write_q<=0;
            master_q<='0;master_valid_q<=0;port_q<='0;port_valid_q<=0;csr_q<=0;test_q<=0;reason_q<=0;version_q<=0;
        end else begin
            state_q<=state_d;
            if(setup_valid) begin
                address_q<=s_paddr;data_q<=s_pwdata;strb_q<=s_pstrb;prot_q<=s_pprot;write_q<=s_pwrite;
                master_q<=master_id_i;master_valid_q<=master_id_valid_i;port_q<=port;port_valid_q<=port_valid;
                csr_q<=csr_hit && decode_reason==0;test_q<=test_flag;reason_q<=admission_reason;version_q<=version;
            end
        end
    end
    always_comb begin
        payload_address=address_q;payload_data=data_q;payload_strb=strb_q;payload_prot=prot_q;
        payload_write=write_q;payload_master=master_q;payload_master_valid=master_valid_q;
        if(state_q==IDLE) begin
            payload_address=s_paddr;payload_data=s_pwdata;payload_strb=s_pstrb;payload_prot=s_pprot;
            payload_write=s_pwrite;payload_master=master_id_i;payload_master_valid=master_id_valid_i;
        end
        route_valid=1'b0;route_enable=1'b0;route_port=port_q;
        if(preset_ni) begin
            if(setup_valid && allow_access && !REGISTER_MODE) begin route_valid=1;route_port=port;end
            else if((state_q==REG_SETUP || state_q==ACCESS) && port_valid_q) begin route_valid=1;route_enable=(state_q==ACCESS);end
        end
        m_psel='0;m_penable='0;m_pwrite='0;m_master_id_valid_o='0;
        for(int unsigned p=0;p<NUM_PORTS;p++) begin
            m_paddr[p]='0;m_pwdata[p]=0;m_pstrb[p]=0;m_pprot[p]=0;m_master_id_o[p]='0;
            if(preset_ni && (!OUTPUT_ISOLATION_EN || (route_valid && route_port==PORT_W'(p)))) begin
                m_paddr[p]=payload_address;m_pwdata[p]=payload_data;m_pstrb[p]=payload_strb;
                m_pprot[p]=payload_prot;m_pwrite[p]=payload_write;m_master_id_o[p]=payload_master;
            end
            if(route_valid && route_port==PORT_W'(p)) begin
                m_psel[p]=1;m_penable[p]=route_enable;m_master_id_valid_o[p]=payload_master_valid;
            end
        end
        s_pready=0;s_pslverr=0;s_prdata=0;
        if(preset_ni && upstream_access) begin
            if(state_q==LOCAL) begin
                s_pready=1;s_pslverr=(completion_reason!=0);s_prdata=csr_q ? csr_data : 32'b0;
            end else if(state_q==ACCESS && port_valid_q) begin
                s_pready=m_pready[port_q];
                if(m_pready[port_q]) begin s_prdata=m_prdata[port_q];s_pslverr=m_pslverr[port_q];end
            end
        end
    end
    assign completion_reason=csr_q ? csr_reason : reason_q;
    assign access_deny=local_complete && !csr_q && reason_q!=0;
    assign cfg_deny=local_complete && csr_q && csr_reason!=0;
    assign bus_failure=access_deny || cfg_deny || downstream_error;
    assign activity_valid=preset_ni && ((setup_valid && allow_access) || ((state_q==REG_SETUP || state_q==ACCESS) && port_valid_q));
    assign activity_port=setup_valid ? 5'(port) : 5'(port_q);
    assign csr_offset=32'(payload_address)-32'(CSR_BASE);
    always_comb begin
        setup_record='0;setup_record[31:0]=32'(s_paddr);setup_record[47:32]=16'(master_id_i);
        setup_record[48]=master_id_valid_i;setup_record[51:49]=s_pprot;setup_record[52]=s_pwrite;
        setup_record[53]=1;setup_record[55]=test_flag;setup_record[76:72]=5'(port);setup_record[77]=port_valid;
        setup_record[127:96]=version;setup_record[227:224]=s_pstrb;
        transaction_record='0;transaction_record[31:0]=32'(address_q);transaction_record[47:32]=16'(master_q);
        transaction_record[48]=master_valid_q;transaction_record[51:49]=prot_q;transaction_record[52]=write_q;
        transaction_record[53]=1;transaction_record[54]=csr_q;transaction_record[55]=test_q;
        transaction_record[71:64]=downstream_error ? 8'h20 : completion_reason;
        transaction_record[76:72]=5'(port_q);transaction_record[77]=port_valid_q;
        transaction_record[85:80]=downstream_error ? 6'h04 : (csr_q ? 6'h02 : 6'h01);
        transaction_record[127:96]=version_q;transaction_record[227:224]=strb_q;
    end
    apb_secure_demux_csr u_csr(.pclk,.preset_n(preset_ni),
        .csr_setup_i(setup_valid && csr_hit && decode_reason==0),.csr_access_i(local_complete && csr_q),
        .offset_i(csr_offset),.write_data_i(payload_data),.write_i(payload_write),.strb_i(payload_strb),
        .prot_i(payload_prot),.master_i(payload_master),.master_valid_i(payload_master_valid),.dfx_authorized_i,
        .consume_i(consume),.synthetic_integrity_i(synthetic_integrity),.setup_record_i(setup_record),
        .transaction_record_i(transaction_record),.bus_failure_i(bus_failure),.access_deny_i(access_deny),
        .cfg_deny_i(cfg_deny),.downstream_error_i(downstream_error),.deny_port_valid_i(port_valid_q),.deny_port_i(5'(port_q)),
        .new_transaction_i(setup_valid && allow_access),.activity_valid_i(activity_valid),.activity_port_i(activity_port),
        .downstream_wait_i(downstream_wait),.downstream_complete_i(downstream_complete),.read_data_o(csr_data),
        .reason_o(csr_reason),.active_cfg_o(active_cfg),.active_perm_o(active_perm),.raw_bad_o(raw_bad),.fatal_o(fatal),
        .policy_version_o(version),.armed_mode_o(armed_mode),.armed_port_o(armed_port),.armed_master_o(armed_master),
        .irq_o,.security_alert_o,.busy_o,.active_port_valid_o,.wait_threshold_o,.active_port_o);
endmodule
