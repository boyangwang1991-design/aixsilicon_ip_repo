class tc_dsa_verify_main extends tc_base;
  `uvm_component_utils(tc_dsa_verify_main)
  virtual pqc_main_if bus;
  byte unsigned pk[0:2591],sig[0:4626],msg[0:65536],ctx[0:254],desc[0:127];
  int pklen,siglen,mlen,clen,pset,wa,wb,writes,acks,count;
  int seen[0:31];bit observing;string vectors;
  function new(string name="tc_dsa_verify_main",uvm_component parent=null);super.new(name,parent);endfunction
  virtual function void configure_env();super.configure_env();env_cfg.enable_rm=0;env_cfg.enable_checker=0;endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus)) `uvm_fatal("DSA_VERIFY","missing bus")
    if(!$value$plusargs("DSA_VECTORS=%s",vectors)) `uvm_fatal("DSA_VERIFY","missing vectors")
  endfunction
  function logic[31:0] word_at(int a);return {bus.mem[a+3],bus.mem[a+2],bus.mem[a+1],bus.mem[a]};endfunction
  function bit in_region(int a,int n,int base,int size);return size>0 && a>=base && a+n<=base+((size+15)/16)*16;endfunction
  task monitor();
    forever begin
      @(posedge bus.clk);
      if(observing) begin
        if(bus.arvalid && bus.arready) begin
          int a,n;a=int'(bus.araddr);n=16*(int'(bus.arlen)+1);
          if(!in_region(a,n,'h1000,128) && !in_region(a,n,'h4000,pklen+siglen) &&
             !in_region(a,n,'ha000,clen) && !in_region(a,n,'h10000,mlen))
            `uvm_fatal("READ_RANGE",$sformatf("unexpected read %h bytes %0d",a,n))
        end
        if(bus.awvalid && bus.awready) begin
          if(wb!=0) `uvm_fatal("AXI","overlapping writes")
          wa=int'(bus.awaddr);wb=int'(bus.awlen)+1;writes++;
        end
        if(bus.wvalid && bus.wready) begin
          if(wb==0 || bus.wlast!==(wb==1)) `uvm_fatal("AXI","bad write boundary")
          for(int b=0;b<16;b++) if(bus.wstrb[b]) begin
            int a;a=wa+b;
            if(a<'h8000 || a>='h8020) `uvm_fatal("WRITE_RANGE","Verify may write only completion")
            if(seen[a-'h8000]++) `uvm_fatal("DUP","duplicate completion byte")
            count++;
          end
          wb--;wa+=16;
        end
        if(bus.bvalid && bus.bready) acks++;
        if(bus.irq && (count!=32 || writes==0 || acks!=writes)) `uvm_fatal("EARLY_IRQ","IRQ before completion B")
      end
    end
  endtask
  task run_case(int n,int variant);
    logic[31:0] rd,intr,raw;bit err;int polls,cbytes,zbits;string descname;
    pset=n/3+4;pklen=pset==4?1312:pset==5?1952:2592;siglen=pset==4?2420:pset==5?3309:4627;
    mlen=n%3==0?0:n%3==1?137:65537;clen=n%3==0?0:n%3==1?1:255;
    cbytes=pset==4?32:pset==5?48:64;zbits=pset==4?18:20;
    $readmemh($sformatf("%s/%0d_pk.hex",vectors,n),pk,0,pklen-1);
    $readmemh($sformatf("%s/%0d_sig.hex",vectors,n),sig,0,siglen-1);
    $readmemh($sformatf("%s/%0d_message.hex",vectors,n),msg,0,mlen==0?0:mlen-1);
    $readmemh($sformatf("%s/%0d_context.hex",vectors,n),ctx,0,clen==0?0:clen-1);
    descname=variant==5?"badmsg_desc":variant==6?"badctx_desc":"desc";
    $readmemh($sformatf("%s/%0d_%s.hex",vectors,n,descname),desc);
    case(variant)
      1:sig[0]^=1;
      2:begin raw={8'b0,sig[cbytes+2],sig[cbytes+1],sig[cbytes]} & ~((32'd1<<zbits)-1);
        sig[cbytes]=raw[7:0];sig[cbytes+1]=raw[15:8];sig[cbytes+2]=raw[23:16];end
      3:sig[siglen-1]=255;
      4:pk[0]^=1;
      5:begin if(mlen==0) begin mlen=1;msg[0]='h5a;end else msg[0]^=1;end
      6:begin if(clen==0) begin clen=1;ctx[0]='h5a;end else ctx[0]^=1;end
    endcase
    @(negedge bus.clk);
    foreach(bus.mem[i]) bus.mem[i]=8'ha5;
    foreach(desc[i]) bus.mem['h1000+i]=desc[i];
    for(int i=0;i<pklen;i++) bus.mem['h4000+i]=pk[i];
    for(int i=0;i<siglen;i++) bus.mem['h4000+pklen+i]=sig[i];
    for(int i=0;i<mlen;i++) bus.mem['h10000+i]=msg[i];
    for(int i=0;i<clen;i++) bus.mem['ha000+i]=ctx[i];
    foreach(seen[i]) seen[i]=0;
    wa=0;wb=0;writes=0;acks=0;count=0;bus.response_delay=17+n;
    apb_write(PQC_REG_INTR_STATE,32'h1f);apb_write(PQC_REG_INTR_ENABLE,1);observing=1;
    apb_write(PQC_REG_COMMAND,32'h10000012+(32'(pset)<<8));
    apb_write(PQC_REG_DESC_ADDR_LO,'h1000);apb_write(PQC_REG_DESC_ADDR_HI,0);apb_write(PQC_REG_DOORBELL,1);
    polls=0;
    do begin
      repeat(500) @(negedge bus.clk);apb_read(PQC_REG_STATUS,rd,err);polls++;
      if(err || rd[3]) `uvm_fatal("DSA_VERIFY_STATUS",$sformatf("case=%0d variant=%0d status=%h",n,variant,rd))
      apb_read(PQC_REG_INTR_STATE,intr,err);
      if(err || polls>20000) `uvm_fatal("DSA_VERIFY_TIMEOUT","command failed to retire")
    end while(!intr[0]);
    @(negedge bus.clk);observing=0;
    if(count!=32 || wb!=0 || acks!=writes) `uvm_fatal("COUNTS","incomplete completion")
    if(word_at('h8000)!==32'h44560000+n || word_at('h8004)!==32'(variant!=0) ||
       word_at('h8008)!==0 || word_at('h800c)!==0 || word_at('h8010)!==32'(variant==0) ||
       word_at('h8014)!==0 || word_at('h8018)===0 || word_at('h801c)!==0)
      `uvm_fatal("VERIFY_RESULT",$sformatf("case=%0d variant=%0d status=%h result=%h",n,variant,word_at('h8004),word_at('h8010)))
    apb_read(PQC_REG_RESULT,rd,err);
    if(err || rd[1:0]!=={1'b1,(variant==0)}) `uvm_fatal("RESULT_CSR","wrong persistent verification result")
    for(int i=0;i<16;i++) if(bus.mem['h8020+i]!==8'ha5) `uvm_fatal("GUARD","completion overflow")
    `uvm_info("DSA_VERIFY_CASE_PASS",$sformatf("case=%0d variant=%0d pset=%0d message=%0d context=%0d",n*7+variant,variant,pset,mlen,clen),UVM_NONE)
  endtask
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    env.apb_vip.monitor.set_report_verbosity_level(UVM_NONE);fork monitor();join_none
    repeat(20) @(negedge bus.clk);bringup();
    for(int n=0;n<9;n++) for(int v=0;v<7;v++) run_case(n,v);
    `uvm_info("DSA_VERIFY_MAIN_PASS","63 independent normal and rejection vectors",UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass
