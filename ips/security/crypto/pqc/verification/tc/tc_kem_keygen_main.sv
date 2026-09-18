// VPLAN KeyGen bring-up: frozen independent KAT, dedicated custody, real DMA.
class tc_kem_keygen_main extends tc_base;
  `uvm_component_utils(tc_kem_keygen_main)
  virtual pqc_main_if bus;
  byte unsigned ek[0:1567],dk[0:3167],desc[0:127];
  int pk_len,dk_len,case_id,pset,write_addr,write_beats,writes,acks;
  int pk_count,handle_count,comp_count,custody_count,headers,read_count;
  int seen_pk[0:1567],seen_handle[0:3],seen_comp[0:31];
  bit observing,ack_sent,ack_seen,was_stalled;
  logic [32:0] stalled_word;
  string vectors;
  function new(string name="tc_kem_keygen_main",uvm_component parent=null);super.new(name,parent);endfunction
  virtual function void configure_env();super.configure_env();env_cfg.enable_rm=0;env_cfg.enable_checker=0;endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus)) `uvm_fatal("KEYGEN","missing bus")
    if(!$value$plusargs("KEYGEN_VECTORS=%s",vectors)) `uvm_fatal("KEYGEN","missing frozen vectors")
  endfunction
  function logic[31:0] word_at(int a);
    return {bus.mem[a+3],bus.mem[a+2],bus.mem[a+1],bus.mem[a]};
  endfunction
  task monitor();
    forever begin
      @(posedge bus.clk);
      if(observing) begin
        if(bus.km_custody_header_valid && bus.km_custody_header_ready) begin
          headers++;
          if(headers!=1 || bus.km_custody_handle!==bus.km_generated_handle ||
             bus.km_custody_epoch!==bus.km_generated_epoch || bus.km_custody_owner!==8'h5a ||
             bus.km_custody_domain!==8'ha3 || bus.km_custody_algo!==4'd1 ||
             bus.km_custody_pset!==4'(pset) || bus.km_custody_bytes!==16'(dk_len) ||
             bus.km_custody_transaction!==32'(case_id+1))
            `uvm_fatal("CUSTODY_HEADER","incorrect generated identity or duplicate header")
        end
        if(was_stalled && (!bus.km_custody_valid || {bus.km_custody_last,bus.km_custody_data}!==stalled_word))
          `uvm_fatal("CUSTODY_STALL","private word changed under backpressure")
        was_stalled=bus.km_custody_valid && !bus.km_custody_ready;
        stalled_word={bus.km_custody_last,bus.km_custody_data};
        if(bus.km_custody_valid && bus.km_custody_ready) begin
          if(headers!=1 || custody_count>=dk_len || bus.km_custody_last!==(custody_count+4==dk_len))
            `uvm_fatal("CUSTODY_LENGTH","invalid private stream boundary")
          for(int b=0;b<4;b++)
            if(bus.km_custody_data[8*b+:8]!==dk[custody_count+b])
              `uvm_fatal("KAT_DK",$sformatf("case=%0d byte=%0d got=%02x expected=%02x",case_id,custody_count+b,bus.km_custody_data[8*b+:8],dk[custody_count+b]))
          custody_count+=4;
        end
        if(bus.arvalid && bus.arready) begin
          if(bus.araddr<'h1000 || bus.araddr+16*(int'(bus.arlen)+1)>'h1080)
            `uvm_fatal("READ_RANGE","KeyGen must read only its public descriptor")
          read_count+=16*(int'(bus.arlen)+1);
        end
        if(bus.awvalid && bus.awready) begin
          if(!ack_seen || custody_count!=dk_len) `uvm_fatal("CUSTODY_ORDER","DMA before matching custody ACK")
          if(write_beats!=0) `uvm_fatal("AXI","overlapping write addresses")
          write_addr=int'(bus.awaddr);write_beats=int'(bus.awlen)+1;writes++;
          if(write_addr=='h4000 && (pk_count!=pk_len || acks!=writes-1)) `uvm_fatal("ORDER","handle before public key response")
          if(write_addr=='h6000 && (pk_count!=pk_len || handle_count!=4 || acks!=writes-1)) `uvm_fatal("ORDER","completion before output responses")
        end
        if(bus.wvalid && bus.wready) begin
          if(write_beats==0 || bus.wlast!==(write_beats==1)) `uvm_fatal("AXI","bad W boundary")
          for(int b=0;b<16;b++) if(bus.wstrb[b]) begin
            int a;a=write_addr+b;
            if(a>='h2000 && a<'h2000+pk_len) begin
              if(seen_pk[a-'h2000]++) `uvm_fatal("DUP","duplicate public key byte")
              if(bus.wdata[8*b+:8]!==ek[a-'h2000]) `uvm_fatal("KAT_EK",$sformatf("case=%0d byte=%0d got=%02x expected=%02x",case_id,a-'h2000,bus.wdata[8*b+:8],ek[a-'h2000]))
              pk_count++;
            end else if(a>='h4000 && a<'h4004) begin
              if(seen_handle[a-'h4000]++) `uvm_fatal("DUP","duplicate handle byte")
              if(bus.wdata[8*b+:8]!==bus.km_generated_handle[8*(a-'h4000)+:8]) `uvm_fatal("HANDLE","wrong custody handle")
              handle_count++;
            end else if(a>='h6000 && a<'h6020) begin
              if(seen_comp[a-'h6000]++) `uvm_fatal("DUP","duplicate completion byte")
              comp_count++;
            end else `uvm_fatal("WRITE_RANGE","unauthorized write or private material on DMA")
          end
          write_beats--;write_addr+=16;
        end
        if(bus.bvalid && bus.bready) acks++;
        if(bus.irq && (comp_count!=32 || acks!=writes || writes==0)) `uvm_fatal("EARLY_IRQ","IRQ before completion response")
      end
    end
  endtask
  task serve_custody();
    forever begin
      @(negedge bus.clk);
      bus.km_custody_header_ready=observing && bus.cycles%7!=0;
      bus.km_custody_ready=observing && bus.cycles%5!=0 && bus.cycles%5!=1;
      if(observing && bus.km_custody_ack_ready && !ack_sent) begin
        if(custody_count!=dk_len) `uvm_fatal("ACK_ORDER","ACK requested before complete private stream")
        bus.km_custody_ack_transaction=bus.km_custody_transaction^32'h1;
        bus.km_custody_ack_epoch=bus.km_custody_epoch;
        bus.km_custody_ack_handle=bus.km_custody_handle;
        bus.km_custody_ack_owner=bus.km_custody_owner;
        bus.km_custody_ack_domain=bus.km_custody_domain;
        bus.km_custody_ack_bytes=bus.km_custody_bytes;
        bus.km_custody_ack_success=1;
        bus.km_custody_ack_valid=1;
        @(negedge bus.clk);bus.km_custody_ack_valid=0;
        repeat(17+case_id) @(negedge bus.clk);
        if(!bus.km_custody_ack_ready || writes!=0) `uvm_fatal("ACK_IDENTITY","wrong transaction ACK retired command")
        bus.km_custody_ack_transaction=bus.km_custody_transaction;
        bus.km_custody_ack_valid=1;
        @(negedge bus.clk);bus.km_custody_ack_valid=0;ack_sent=1;ack_seen=1;
      end
    end
  endtask
  task run_case(int n);
    logic[31:0] rd,intr;bit err;int polls;
    case_id=n;pset=n/3+1;pk_len=pset==1?800:pset==2?1184:1568;dk_len=pset==1?1632:pset==2?2400:3168;
    $readmemh($sformatf("%s/%0d_ek.hex",vectors,n),ek,0,pk_len-1);
    $readmemh($sformatf("%s/%0d_dk.hex",vectors,n),dk,0,dk_len-1);
    $readmemh($sformatf("%s/%0d_desc.hex",vectors,n),desc);
    @(negedge bus.clk);
    $readmemh($sformatf("%s/%0d_entropy.hex",vectors,n),bus.entropy_bytes,0,63);
    foreach(bus.mem[i]) bus.mem[i]=8'ha5;
    foreach(desc[i]) bus.mem['h1000+i]=desc[i];
    foreach(seen_pk[i]) seen_pk[i]=0;
    foreach(seen_handle[i]) seen_handle[i]=0;
    foreach(seen_comp[i]) seen_comp[i]=0;
    pk_count=0;handle_count=0;comp_count=0;custody_count=0;headers=0;read_count=0;
    write_beats=0;writes=0;acks=0;ack_sent=0;ack_seen=0;was_stalled=0;
    bus.km_generated_handle=32'h4B470100+n;bus.km_generated_epoch=32'h12340000+n;
    bus.km_generated_owner=8'h5a;bus.km_generated_domain=8'ha3;
    bus.entropy_tag={4'd1,4'(pset)};bus.entropy_words=8;bus.entropy_enable=1;bus.response_delay=19+n*3;
    apb_write(PQC_REG_INTR_STATE,32'h1f);apb_write(PQC_REG_INTR_ENABLE,1);
    observing=1;
    apb_write(PQC_REG_COMMAND,32'h10000000+(32'(pset)<<8));
    apb_write(PQC_REG_DESC_ADDR_LO,'h1000);apb_write(PQC_REG_DESC_ADDR_HI,0);apb_write(PQC_REG_DOORBELL,1);
    polls=0;
    do begin
      repeat(500) @(negedge bus.clk);
      apb_read(PQC_REG_STATUS,rd,err);polls++;
      if(err || rd[3]) `uvm_fatal("KEYGEN_STATUS",$sformatf("case=%0d status=%h",n,rd))
      apb_read(PQC_REG_INTR_STATE,intr,err);
      if(err) `uvm_fatal("KEYGEN_STATUS","interrupt read failed")
      if(polls>4000) `uvm_fatal("KEYGEN_TIMEOUT","command did not retire")
    end while(!intr[0]);
    @(negedge bus.clk);observing=0;bus.entropy_enable=0;
    if(pk_count!=pk_len || handle_count!=4 || comp_count!=32 || custody_count!=dk_len || headers!=1 || !ack_seen || read_count!=128)
      `uvm_fatal("KEYGEN_COUNTS","missing or duplicate output/confirmation")
    if(word_at('h6000)!==32'h4B470000+n || word_at('h6004)!==0 || word_at('h6008)!==32'(pk_len) ||
       word_at('h600c)!==4 || word_at('h6010)!==0 || word_at('h6014)!==0 || word_at('h6018)===0 || word_at('h601c)!==0)
      `uvm_fatal("COMPLETION","invalid completion fields")
    for(int i=0;i<16;i++)
      if(bus.mem['h2000+pk_len+i]!==8'ha5 || bus.mem['h4004+i]!==8'ha5 || bus.mem['h6020+i]!==8'ha5)
        `uvm_fatal("GUARD","write beyond logical output")
    `uvm_info("KEYGEN_CASE_PASS",$sformatf("case=%0d pset=%0d checked pk=%0d private=%0d handle=4 completion=32",n,pset,pk_count,custody_count),UVM_NONE)
  endtask
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    env.apb_vip.monitor.set_report_verbosity_level(UVM_NONE);
    fork monitor();serve_custody();join_none
    repeat(20) @(negedge bus.clk);bringup();
    for(int n=0;n<9;n++) run_case(n);
    `uvm_info("KEYGEN_MAIN_PASS","nine KATs with custody stalls and wrong-transaction ACK rejection",UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass
