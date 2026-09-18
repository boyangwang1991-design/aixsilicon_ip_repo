// Actual RTL Decaps KAT. Expected data is frozen; no DPI/software algorithm.
// The private key dk is imported through the dedicated KM sideload, the
// ciphertext is staged in AXI memory, the RTL recomputes and selects the
// shared secret, and the testbench compares the DMA output byte-by-byte.
class tc_kem_decaps_main extends tc_base;
  `uvm_component_utils(tc_kem_decaps_main)
  virtual pqc_main_if bus;
  byte unsigned dk[0:4095],ct[0:2047],ss[0:31],desc[0:127];
  int dk_len,ct_len,case_id,write_addr,write_beats,writes,acks,ss_count,comp_count;
  int read_count;
  int seen_ss[0:31],seen_comp[0:31];
  logic [31:0] baseline_cycles[0:8];
  bit observing;
  string vectors;
  function new(string name="tc_kem_decaps_main",uvm_component parent=null);super.new(name,parent);endfunction
  virtual function void configure_env();
    super.configure_env();env_cfg.enable_rm=0;env_cfg.enable_checker=0;
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus)) `uvm_fatal("MAIN","missing interface")
    if(!$value$plusargs("DECAPS_VECTORS=%s",vectors)) `uvm_fatal("MAIN","missing frozen vector path")
  endfunction

  task observe();
    forever begin
      @(posedge bus.clk);
      if(observing) begin
        if(bus.arvalid && bus.arready) begin
          if(!((bus.araddr>= 'h1000 && bus.araddr+16*(int'(bus.arlen)+1)<='h1080) ||
               (bus.araddr>= 'h2000 && bus.araddr+16*(int'(bus.arlen)+1)<='h2000+ct_len)))
            `uvm_fatal("READ_RANGE","unexpected external read")
          read_count+=16*(int'(bus.arlen)+1);
        end
        if(bus.awvalid && bus.awready) begin
          if(write_beats!=0) `uvm_fatal("AXI","overlapping writes")
          write_addr=int'(bus.awaddr);write_beats=int'(bus.awlen)+1;writes++;
          if(write_addr=='h6000 && (ss_count!=32 || acks!=writes-1))
            `uvm_fatal("COMMIT_ORDER","completion precedes output B response")
        end
        if(bus.wvalid && bus.wready) begin
          if(write_beats==0) `uvm_fatal("AXI","write without address")
          if(bus.wlast !== (write_beats==1)) `uvm_fatal("AXI","invalid WLAST")
          for(int i=0;i<16;i++) if(bus.wstrb[i]) begin
            int a;a=write_addr+i;
            if(a>='h4000 && a<'h4020) begin
              if(seen_ss[a-'h4000]++) `uvm_fatal("DUP","secret byte written twice")
              if(bus.wdata[8*i+:8] !== ss[a-'h4000])
                `uvm_fatal("KAT_SS",$sformatf("case=%0d byte=%0d got=%02x expected=%02x",case_id,a-'h4000,bus.wdata[8*i+:8],ss[a-'h4000]))
              ss_count++;
            end else if(a>='h6000 && a<'h6020) begin
              if(seen_comp[a-'h6000]++) `uvm_fatal("DUP","completion byte written twice")
              comp_count++;
            end else `uvm_fatal("WRITE_RANGE",$sformatf("unauthorized write %h",a))
          end
          write_beats--;write_addr+=16;
        end
        if(bus.bvalid && bus.bready) acks++;
        if(bus.irq && (comp_count!=32 || acks!=writes || writes==0)) begin
          `uvm_info("EARLY_IRQ",$sformatf("irq@writes=%0d acks=%0d ss=%0d comp=%0d",writes,acks,ss_count,comp_count),UVM_NONE)
          `uvm_fatal("EARLY_IRQ","IRQ before completion B response")
        end
      end
    end
  endtask

  function logic[31:0] memory_word(int a);
    return {bus.mem[a+3],bus.mem[a+2],bus.mem[a+1],bus.mem[a]};
  endfunction

  // Import the private key through the KM sideload and wait for km_done.
  task import_key(logic[31:0] handle, logic[3:0] pset);
    int i;
    @(negedge bus.clk);
    bus.km_handle=handle;bus.km_algo=1;bus.km_pset=pset;
    bus.km_usage=8'h04;   // usage bit 2 = Decaps
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

  task run_case(int n);
    logic[31:0] rd,intr;bit err;int pset,polls,vector_id,variant;
    vector_id=n<36 ? n/4 : n-36;variant=n<36 ? n%4 : 0;
    case_id=n;pset=vector_id<6 ? vector_id/2+1 : vector_id-5;
    dk_len=(pset==1?1632:pset==2?2400:3168);ct_len=pset==1?768:pset==2?1088:1568;
    $readmemh($sformatf("%s/%0d_dk.hex",vectors,vector_id),dk,0,dk_len-1);
    $readmemh($sformatf("%s/%0d_ct.hex",vectors,vector_id),ct,0,ct_len-1);
    $readmemh($sformatf("%s/%0d_ss.hex",vectors,vector_id),ss);
    $readmemh($sformatf("%s/%0d_desc.hex",vectors,vector_id),desc);
    if(variant!=0) begin
      ct[variant==1 ? 0 : variant==2 ? ct_len/2 : ct_len-1]^=8'h01;
      $readmemh($sformatf("%s/%0d_reject_%0d_ss.hex",vectors,vector_id,variant),ss);
    end
    @(negedge bus.clk);
    foreach(bus.mem[i]) bus.mem[i]=8'ha5;
    foreach(desc[i]) bus.mem['h1000+i]=desc[i];
    for(int i=0;i<ct_len;i++) bus.mem['h2000+i]=ct[i];
    write_beats=0;writes=0;acks=0;ss_count=0;comp_count=0;read_count=0;
    foreach(seen_ss[i]) begin seen_ss[i]=0;seen_comp[i]=0;end
    // Identical public bus timing for the matched/mismatched cycle comparison;
    // an additional nine commands separately exercise periodic backpressure.
    bus.stalls_enabled=(n>=36);
    bus.response_delay=19+vector_id*3;
    import_key(32'hDECA0000+vector_id, 4'(pset));
    apb_write(PQC_REG_INTR_STATE,32'h1f);
    apb_write(PQC_REG_INTR_ENABLE,1);
    observing=1;
    apb_write(PQC_REG_COMMAND,32'h10000002+(32'(pset)<<8));
    apb_write(PQC_REG_DESC_ADDR_LO,'h1000);apb_write(PQC_REG_DESC_ADDR_HI,0);
    apb_write(PQC_REG_DOORBELL,1);
    polls=0;
    do begin
      repeat(500) @(negedge bus.clk);
      apb_read(PQC_REG_STATUS,rd,err);polls++;
      if(err || rd[3]) `uvm_fatal("STATUS",$sformatf("case %0d failed STATUS=%h",n,rd))
      // INTR_STATE.done is sticky (W1C): a reliable completion indicator even
      // when the single-cycle irq pulse is missed between polls.
      apb_read(PQC_REG_INTR_STATE,intr,err);
    end while(((intr[0]==0) && !bus.irq) && polls<4000);
    if(intr[0]==0 && !bus.irq) begin
      logic[31:0] ec; bit e2;
      apb_read(PQC_REG_ERROR_CODE,ec,e2);
      `uvm_fatal("TIMEOUT",$sformatf("command did not retire: STATUS=%h INTR=%h ERR=%h polls=%0d",rd,intr,ec,polls))
    end
    if(ss_count!=32 || comp_count!=32 || read_count!=128+ct_len)
      `uvm_fatal("COUNTS",$sformatf("ss=%0d comp=%0d read=%0d",ss_count,comp_count,read_count))
    if(memory_word('h6000)!==32'h12340000+vector_id || memory_word('h6008)!==32 || memory_word('h6018)==0 ||
       memory_word('h6004)!==0 || memory_word('h600c)!==0 || memory_word('h6010)!==0 ||
       memory_word('h6014)!==0 || memory_word('h601c)!==0)
      `uvm_fatal("COMPLETION","bad completion record")
    if(n<36) begin
      if(variant==0) baseline_cycles[vector_id]=memory_word('h6018);
      else if(memory_word('h6018)!==baseline_cycles[vector_id])
        `uvm_fatal("CONSTANT_TIME",$sformatf("vector=%0d variant=%0d cycles=%0d baseline=%0d",vector_id,variant,memory_word('h6018),baseline_cycles[vector_id]))
    end
    foreach(ss[i]) if(bus.mem['h4000+i]!==ss[i]) `uvm_fatal("MEM","shared secret memory mismatch")
    if(bus.mem['h4020]!==8'ha5 || bus.mem['h6020]!==8'ha5)
      `uvm_fatal("GUARD","output overrun")
    observing=0;
    apb_write(PQC_REG_INTR_STATE,32'h1f);
    `uvm_info("DECAPS_CASE_PASS",$sformatf("case=%0d pset=%0d variant=%0d stalls=%0d cycles=%0d checked secret=32 completion=32",n,pset,variant,bus.stalls_enabled,memory_word('h6018)),UVM_LOW)
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    env.apb_vip.monitor.set_report_verbosity_level(UVM_NONE);
    fork observe(); join_none
    repeat(20) @(negedge bus.clk);
    bringup();repeat(100) @(negedge bus.clk);
    for(int n=0;n<45;n++) run_case(n);
    `uvm_info("DECAPS_MAIN_PASS","45 cases: nine normal vectors, 27 rejection/constant-time cases, nine backpressure repeats",UVM_NONE)
    phase.drop_objection(this);
  endtask
endclass
