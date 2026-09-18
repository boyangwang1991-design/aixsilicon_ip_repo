class tc_dsa_sign_main extends tc_base;
  `uvm_component_utils(tc_dsa_sign_main)
  virtual pqc_main_if bus;
  byte unsigned dk[0:4895],sig[0:4626],msg[0:65536],ctx[0:254],desc[0:127];
  int dk_len,pklen,siglen,mlen,clen,pset,wa,wb,writes,acks,count;
  int seen_sig[0:4626],sig_count,entropy_count;int seen[0:31];bit observing;string vectors;
  function new(string name="tc_dsa_sign_main",uvm_component parent=null);super.new(name,parent);endfunction
  virtual function void configure_env();super.configure_env();env_cfg.enable_rm=0;env_cfg.enable_checker=0;endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus)) `uvm_fatal("DSA_SIGN","missing bus")
    if(!$value$plusargs("DSA_VECTORS=%s",vectors)) `uvm_fatal("DSA_SIGN","missing vectors")
  endfunction
  function logic[31:0] word_at(int a);return {bus.mem[a+3],bus.mem[a+2],bus.mem[a+1],bus.mem[a]};endfunction
  function bit in_region(int a,int n,int base,int size);return size>0 && a>=base && a+n<=base+((size+15)/16)*16;endfunction
  task monitor();
    forever begin
      @(posedge bus.clk);
      if(observing) begin
        if(bus.entropy_enable && bus.entropy_ready) entropy_count++;
        if(bus.arvalid && bus.arready) begin
          int a,n;a=int'(bus.araddr);n=16*(int'(bus.arlen)+1);
          if(!in_region(a,n,'h1000,128) &&
             !in_region(a,n,'ha000,clen) && !in_region(a,n,'h10000,mlen))
            `uvm_fatal("READ_RANGE",$sformatf("unexpected read %h bytes %0d",a,n))
        end
        if(bus.awvalid && bus.awready) begin
          if(wb!=0) `uvm_fatal("AXI","overlapping writes")
          wa=int'(bus.awaddr);wb=int'(bus.awlen)+1;writes++;
          if(wa=='h8000 && (sig_count!=siglen || acks!=writes-1)) `uvm_fatal("ORDER","completion before signature B")
        end
        if(bus.wvalid && bus.wready) begin
          if(wb==0 || bus.wlast!==(wb==1)) `uvm_fatal("AXI","bad write boundary")
          for(int b=0;b<16;b++) if(bus.wstrb[b]) begin
            int a;a=wa+b;
            if(a>='h4000 && a<'h4000+siglen) begin
              if(seen_sig[a-'h4000]++) `uvm_fatal("DUP","duplicate signature byte")
              if(bus.wdata[8*b+:8]!==sig[a-'h4000]) `uvm_fatal("KAT_SIG",$sformatf("byte=%0d got=%02x expected=%02x",a-'h4000,bus.wdata[8*b+:8],sig[a-'h4000]))
              sig_count++;
            end else if(a>='h8000 && a<'h8020) begin
              if(seen[a-'h8000]++) `uvm_fatal("DUP","duplicate completion byte")
              count++;
            end else `uvm_fatal("WRITE_RANGE","Sign output outside signature/completion")
          end
          wb--;wa+=16;
        end
        if(bus.bvalid && bus.bready) acks++;
        if(bus.irq && (count!=32 || writes==0 || acks!=writes)) `uvm_fatal("EARLY_IRQ","IRQ before completion B")
      end
    end
  endtask
  task import_key(logic[31:0] handle, logic[3:0] pset);
    int i;
    @(negedge bus.clk);
    bus.km_handle=handle;bus.km_algo=2;bus.km_pset=pset;
    bus.km_usage=8'h02;   // usage bit 1 = Sign
    bus.km_bytes=16'(dk_len);
    foreach(dk[i]) bus.km_payload[i]=dk[i];
    // Wait for the work-key RAM to finish its reset sweep (K_WIPE -> K_EMPTY)
    // before offering the import header; otherwise load_begin_ready stays low.
    `uvm_info("KM","waiting for work-key RAM ready",UVM_LOW)
    for(i=0;i<20000;i++) begin
      @(negedge bus.clk);
      if(bus.km_begin_ready) break;
    end
    if(i>=20000) begin
      `uvm_info("KM",$sformatf("not ready after %0d; begin_ready=%b",i,bus.km_begin_ready),UVM_LOW)
      `uvm_fatal("KM","work-key RAM not ready")
    end
    `uvm_info("KM",$sformatf("ready after %0d; begin_ready=%b",i,bus.km_begin_ready),UVM_LOW)
    bus.km_begin=1;
    // One handshake is enough: the DUT accepts the header on km_begin_ready and
    // moves out of K_EMPTY, so km_begin_ready drops immediately. Deassert km_begin
    // after a couple of cycles; the data stream then runs on km_ready.
    repeat(2) @(negedge bus.clk);
    bus.km_begin=0;
    `uvm_info("KM","import header accepted",UVM_LOW)
    for(i=0;i<200000;i++) begin
      @(negedge bus.clk);
      if(bus.km_done) begin `uvm_info("KM",$sformatf("import done after %0d",i),UVM_LOW); break; end
      if(bus.km_error) `uvm_fatal("KM","private key import rejected")
    end
    if(i>=200000) `uvm_fatal("KM","private key import timeout")
  endtask

  task run_case(int n,int variant);
    logic[31:0] rd,intr,raw;bit err;int polls,cbytes,zbits;string descname,sig_name;
    pset=n/3+4;pklen=pset==4?1312:pset==5?1952:2592;siglen=pset==4?2420:pset==5?3309:4627;
    mlen=n%3==0?0:n%3==1?137:65537;clen=n%3==0?0:n%3==1?1:255;
    cbytes=pset==4?32:pset==5?48:64;zbits=pset==4?18:20;
    dk_len=pset==4?2560:pset==5?4032:4896;
    if(variant==1) begin sig_name="hedged_sig";descname="hedged_desc";end else begin sig_name="sig";descname="sign_desc";end
    $readmemh($sformatf("%s/%0d_sk.hex",vectors,n),dk,0,dk_len-1);
    $readmemh($sformatf("%s/%0d_%s.hex",vectors,n,sig_name),sig,0,siglen-1);
    $readmemh($sformatf("%s/%0d_message.hex",vectors,n),msg,0,mlen==0?0:mlen-1);
    $readmemh($sformatf("%s/%0d_context.hex",vectors,n),ctx,0,clen==0?0:clen-1);
    $readmemh($sformatf("%s/%0d_%s.hex",vectors,n,descname),desc);
    $readmemh($sformatf("%s/%0d_rnd.hex",vectors,n),bus.entropy_bytes,0,31);
    @(negedge bus.clk);
    foreach(bus.mem[i]) bus.mem[i]=8'ha5;
    foreach(desc[i]) bus.mem['h1000+i]=desc[i];
    for(int i=0;i<mlen;i++) bus.mem['h10000+i]=msg[i];
    for(int i=0;i<clen;i++) bus.mem['ha000+i]=ctx[i];
    foreach(seen[i]) seen[i]=0;
    foreach(seen_sig[i]) seen_sig[i]=0;
    sig_count=0;entropy_count=0;
    bus.entropy_tag={4'd2,4'(pset)};bus.entropy_words=4;bus.entropy_enable=1;
    import_key(32'hD5A00000+n,4'(pset));
    wa=0;wb=0;writes=0;acks=0;count=0;bus.response_delay=17+n;
    apb_write(PQC_REG_INTR_STATE,32'h1f);apb_write(PQC_REG_INTR_ENABLE,1);observing=1;
    apb_write(PQC_REG_COMMAND,32'h10000011+(32'(pset)<<8));
    apb_write(PQC_REG_DESC_ADDR_LO,'h1000);apb_write(PQC_REG_DESC_ADDR_HI,0);apb_write(PQC_REG_DOORBELL,1);
    polls=0;
    do begin
      repeat(500) @(negedge bus.clk);apb_read(PQC_REG_STATUS,rd,err);polls++;
      if(err || rd[3]) `uvm_fatal("DSA_SIGN_STATUS",$sformatf("case=%0d variant=%0d status=%h",n,variant,rd))
      apb_read(PQC_REG_INTR_STATE,intr,err);
      if(err || polls>400000) `uvm_fatal("DSA_SIGN_TIMEOUT","command failed to retire")
    end while(!intr[0]);
    @(negedge bus.clk);observing=0;bus.entropy_enable=0;
    if(count!=32 || wb!=0 || acks!=writes) `uvm_fatal("COUNTS","incomplete completion")
    if(sig_count!=siglen || entropy_count!=(variant==1?4:0)) `uvm_fatal("COUNTS","signature or entropy length mismatch")
    if(word_at('h8000)!==32'h44530000+n || word_at('h8004)!==0 ||
       word_at('h8008)!==32'(siglen) || word_at('h800c)!==0 || word_at('h8010)!==0 ||
       word_at('h8014)!==0 || word_at('h8018)===0 || word_at('h801c)!==0)
      `uvm_fatal("COMPLETION","invalid signature completion")
    for(int i=0;i<16;i++) if(bus.mem['h8020+i]!==8'ha5 || bus.mem['h4000+siglen+i]!==8'ha5) `uvm_fatal("GUARD","output overflow")
    `uvm_info("DSA_SIGN_CASE_PASS",$sformatf("case=%0d variant=%0d pset=%0d message=%0d context=%0d",n*3+variant,variant,pset,mlen,clen),UVM_NONE)
  endtask
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);fork monitor();join_none
    repeat(20) @(negedge bus.clk);bringup();
    for(int n=0;n<9;n++) for(int v=0;v<3;v++) run_case(n,v);
    `uvm_info("DSA_SIGN_MAIN_PASS","27 independent deterministic/repeated/hedged signatures",UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass
