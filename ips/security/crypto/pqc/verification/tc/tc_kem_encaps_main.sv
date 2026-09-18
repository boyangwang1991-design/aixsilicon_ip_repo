// Actual RTL Encaps KAT. Expected data is frozen; no DPI/software algorithm.
class tc_kem_encaps_main extends tc_base;
  `uvm_component_utils(tc_kem_encaps_main)
  virtual pqc_main_if bus;
  byte unsigned pk[0:1567],ct[0:1567],ss[0:31],msg[0:31],desc[0:127];
  int seen_ct[0:1567],seen_ss[0:31],seen_comp[0:31];
  int pk_len,ct_len,case_id,write_addr,write_beats,writes,acks,ct_count,ss_count,comp_count;
  int entropy_count,read_count;
  bit observing;
  string vectors;
  function new(string name="tc_kem_encaps_main",uvm_component parent=null);super.new(name,parent);endfunction
  virtual function void configure_env();
    super.configure_env();env_cfg.enable_rm=0;env_cfg.enable_checker=0;
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus)) `uvm_fatal("MAIN","missing interface")
    if(!$value$plusargs("ENCAPS_VECTORS=%s",vectors)) `uvm_fatal("MAIN","missing frozen vector path")
  endfunction
  task observe();
    forever begin
      @(posedge bus.clk);
      if(observing) begin
        if(bus.entropy_enable && bus.entropy_ready) entropy_count++;
        if(bus.arvalid && bus.arready) begin
          if(!((bus.araddr>= 'h1000 && bus.araddr+16*(int'(bus.arlen)+1)<='h1080) ||
               (bus.araddr>= 'h2000 && bus.araddr+16*(int'(bus.arlen)+1)<='h2000+pk_len)))
            `uvm_fatal("READ_RANGE","unexpected external read")
          read_count+=16*(int'(bus.arlen)+1);
        end
        if(bus.awvalid && bus.awready) begin
          if(write_beats!=0) `uvm_fatal("AXI","overlapping writes")
          write_addr=int'(bus.awaddr);write_beats=int'(bus.awlen)+1;writes++;
          if(write_addr=='h6000 && (ct_count!=ct_len || ss_count!=32 || acks!=writes-1))
            `uvm_fatal("COMMIT_ORDER","completion precedes all output responses")
        end
        if(bus.wvalid && bus.wready) begin
          if(write_beats==0) `uvm_fatal("AXI","write without address")
          if(bus.wlast !== (write_beats==1)) `uvm_fatal("AXI","invalid WLAST")
          for(int i=0;i<16;i++) if(bus.wstrb[i]) begin
            int a;a=write_addr+i;
            if(a>='h4000 && a<'h4000+ct_len) begin
              if(bus.wdata[8*i+:8] !== ct[a-'h4000])
                `uvm_fatal("KAT_CT",$sformatf("case=%0d byte=%0d got=%02x expected=%02x",case_id,a-'h4000,bus.wdata[8*i+:8],ct[a-'h4000]))
              if(seen_ct[a-'h4000]++) `uvm_fatal("DUP","ciphertext byte written twice")
              ct_count++;
            end else if(a>='h5000 && a<'h5020) begin
              if(bus.wdata[8*i+:8] !== ss[a-'h5000]) `uvm_fatal("KAT_SS","shared secret mismatch")
              if(seen_ss[a-'h5000]++) `uvm_fatal("DUP","secret byte written twice")
              ss_count++;
            end else if(a>='h6000 && a<'h6020) begin
              if(seen_comp[a-'h6000]++) `uvm_fatal("DUP","completion byte written twice")
              comp_count++;
            end else `uvm_fatal("WRITE_RANGE",$sformatf("unauthorized write %h",a))
          end
          write_beats--;write_addr+=16;
        end
        if(bus.bvalid && bus.bready) acks++;
        if(bus.irq && (comp_count!=32 || acks!=writes || writes==0))
          `uvm_fatal("EARLY_IRQ","IRQ before completion B response")
      end
    end
  endtask
  function logic[31:0] memory_word(int a);
    return {bus.mem[a+3],bus.mem[a+2],bus.mem[a+1],bus.mem[a]};
  endfunction
  task run_case(int n);
    logic[31:0] rd;bit err;int pset,polls;
    case_id=n;pset=n/2+1;pk_len=384*(pset+1)+32;ct_len=pset==1?768:pset==2?1088:1568;
    $readmemh($sformatf("%s/%0d_pk.hex",vectors,n),pk,0,pk_len-1);
    $readmemh($sformatf("%s/%0d_ct.hex",vectors,n),ct,0,ct_len-1);
    $readmemh($sformatf("%s/%0d_ss.hex",vectors,n),ss);
    $readmemh($sformatf("%s/%0d_m.hex",vectors,n),msg);
    $readmemh($sformatf("%s/%0d_desc.hex",vectors,n),desc);
    @(negedge bus.clk);
    foreach(bus.mem[i]) bus.mem[i]=8'ha5;
    foreach(desc[i]) bus.mem['h1000+i]=desc[i];
    for(int i=0;i<pk_len;i++) bus.mem['h2000+i]=pk[i];
    foreach(msg[i]) bus.entropy_bytes[i]=msg[i];
    foreach(seen_ct[i]) seen_ct[i]=0;
    foreach(seen_ss[i]) seen_ss[i]=0;
    foreach(seen_comp[i]) seen_comp[i]=0;
    write_beats=0;writes=0;acks=0;ct_count=0;ss_count=0;comp_count=0;entropy_count=0;read_count=0;
    bus.entropy_tag=8'h10+8'(pset);bus.entropy_enable=1;bus.response_delay=17+n*3;
    apb_write(PQC_REG_INTR_STATE,32'h1f);
    apb_write(PQC_REG_INTR_ENABLE,1);
    observing=1;
    apb_write(PQC_REG_COMMAND,32'h10000001+(32'(pset)<<8));
    apb_write(PQC_REG_DESC_ADDR_LO,'h1000);apb_write(PQC_REG_DESC_ADDR_HI,0);
    apb_write(PQC_REG_DOORBELL,1);
    polls=0;
    do begin
      repeat(500) @(negedge bus.clk);
      apb_read(PQC_REG_STATUS,rd,err);polls++;
      if(err || rd[3]) `uvm_fatal("STATUS",$sformatf("case %0d failed STATUS=%h",n,rd))
    end while(!bus.irq && polls<4000);
    if(!bus.irq) `uvm_fatal("TIMEOUT","command did not retire")
    if(ct_count!=ct_len || ss_count!=32 || comp_count!=32 || entropy_count!=4 || read_count!=128+pk_len)
      `uvm_fatal("COUNTS",$sformatf("ct=%0d ss=%0d comp=%0d entropy=%0d read=%0d",ct_count,ss_count,comp_count,entropy_count,read_count))
    if(memory_word('h6000)!==32'h12340000+n || memory_word('h6004)!==0 || memory_word('h6008)!==ct_len ||
       memory_word('h600c)!==32 || memory_word('h6010)!==0 || memory_word('h6014)!==0 || memory_word('h6018)==0 || memory_word('h601c)!==0)
      `uvm_fatal("COMPLETION","bad completion record")
    for(int i=0;i<ct_len;i++) if(bus.mem['h4000+i]!==ct[i]) `uvm_fatal("MEM","ciphertext memory mismatch")
    foreach(ss[i]) if(bus.mem['h5000+i]!==ss[i]) `uvm_fatal("MEM","shared secret memory mismatch")
    if(bus.mem['h4000+ct_len]!==8'ha5 || bus.mem['h5020]!==8'ha5 || bus.mem['h6020]!==8'ha5)
      `uvm_fatal("GUARD","output overrun")
    observing=0;bus.entropy_enable=0;
    apb_write(PQC_REG_INTR_STATE,32'h1f);
    `uvm_info("ENCAPS_CASE_PASS",$sformatf("case=%0d pset=%0d checked ciphertext=%0d secret=32 completion=32 delayed_B=%0d",n,pset,ct_len,bus.response_delay),UVM_LOW)
  endtask
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fork observe(); join_none
    repeat(20) @(negedge bus.clk);
    bringup();repeat(100) @(negedge bus.clk);
    for(int n=0;n<6;n++) run_case(n);
    `uvm_info("ENCAPS_MAIN_PASS","6 frozen KATs, real RTL, all bytes checked",UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass
