`ifndef WATCHDOG_REFERENCE_MODEL__SV
`define WATCHDOG_REFERENCE_MODEL__SV
class watchdog_reference_model extends uvm_component;
  `uvm_component_utils(watchdog_reference_model)
  uvm_analysis_imp_apb #(apb_item,watchdog_reference_model) apb_in;
  uvm_analysis_imp_wdt #(watchdog_observation,watchdog_reference_model) wdt_in;
  uvm_analysis_port #(watchdog_prediction) expected_ap;
  watchdog_dut_cfg parameters;
  virtual watchdog_control_if vif;
  watchdog_model_channel channels[16];
  config_t staging[16];
  snapshot_t snapshots[16],reply_snapshot;
  bit[4:0] client_select[16];bit[10:0] service_select[16];
  bit[15:0] snapshot_valid;
  bit[31:0] snapshot_sequence[16];
  command_t mailbox;
  config_t mailbox_config;
  bit busy,done,reply_pending;
  bit[31:0] issued_sequence,done_sequence,done_info;
  bit[7:0] done_result,reply_result;
  time reply_time,last_wdt_time;
  int reply_age,wdt_release,pclk_release,apb_release;
  longint unsigned apb_count;
  bit[15:0] irq_pipe[4],fault_pipe[4],local_pipe[4];
  bit final_pipe[4],safe_pipe[4];
  bit[15:0] prior_irq,prior_fault,prior_local;
  bit prior_final,prior_safe;
  int scenario,feature;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void emit(string label,bit[63:0] value,bit[63:0] mask='1);
  extern function bit[31:0] read_value(bit[31:0] address);
  extern function void write_apb(apb_item item);
  extern function void write_wdt(watchdog_observation observation);
  extern function void reset_bus(bit cold);
  extern function void check_phase(uvm_phase phase);
  extern function void oracle_self_test();
endclass
function watchdog_reference_model::new(string name,uvm_component parent);
  super.new(name,parent);apb_in=new("apb_in",this);wdt_in=new("wdt_in",this);expected_ap=new("expected_ap",this);
endfunction
function void watchdog_reference_model::build_phase(uvm_phase phase);
  if(!uvm_config_db#(watchdog_dut_cfg)::get(this,"","dut",parameters)) `uvm_fatal("RM","missing DUT configuration")
  if(!uvm_config_db#(virtual watchdog_control_if)::get(this,"","vif",vif)) `uvm_fatal("RM","missing control interface")
  for(int i=0;i<parameters.channels;i++) begin
    channels[i]=watchdog_model_channel::type_id::create($sformatf("channel_%0d",i));
    channels[i].reset_model(i,parameters,0);
  end
  reset_bus(1);oracle_self_test();
endfunction
function void watchdog_reference_model::emit(string label,bit[63:0] value,bit[63:0] mask='1);
  watchdog_prediction p;p=watchdog_prediction::type_id::create("prediction");
  p.label=label;p.expected_value=value;p.mask=mask;p.feature=feature;p.scenario=scenario;
  expected_ap.write(p);
endfunction
function void watchdog_reference_model::reset_bus(bit cold);
  for(int i=0;i<parameters.channels;i++) begin
    staging[i]=channels[i].standard_defaults();client_select[i]=0;service_select[i]=0;
    if(cold) begin snapshots[i]='0;snapshot_sequence[i]=0;end
  end
  for(int i=0;i<4;i++) begin irq_pipe[i]=0;fault_pipe[i]=0;local_pipe[i]=0;final_pipe[i]=0;safe_pipe[i]=0;end
  if(cold) begin
    snapshot_valid=0;busy=0;done=0;reply_pending=0;issued_sequence=0;done_sequence=0;done_info=0;done_result=0;
    mailbox='0;mailbox_config='0;reply_snapshot='0;reply_age=0;
  end
endfunction
function bit[31:0] watchdog_reference_model::read_value(bit[31:0] address);
  int ch,offset,cl;bit[31:0] value;
  value=0;ch=int'((address-32'h1000)>>10);offset=int'(address&32'h3ff);
  if(address<32'h1000) begin
    case(address)
      0: value=32'h57445431;
      4: value=32'h10000;
      8: value=32'(parameters.channels-1)|(32'(parameters.clients-1)<<5)|
         (32'(parameters.width)<<11)|(32'(parameters.prescale_width)<<18);
      12: value=32'(parameters.token_support)|(32'(parameters.supervision_support)<<1)|
          (32'(parameters.hw_support)<<2)|(32'(parameters.safety)<<3)|(32'(parameters.runtime_update)<<4)|
          (32'(parameters.inject_enable)<<5)|(32'(parameters.sync_stages-2)<<8);
      16: value=32'(busy)|(32'(done)<<1)|(32'(done_result)<<8);
      20: value=issued_sequence;
      24: value=done_sequence;
      28: value=done_info;
      32: value=32'(irq_pipe[parameters.sync_stages-1]);
      36: value=32'(fault_pipe[parameters.sync_stages-1]);
      40: value=32'(local_pipe[parameters.sync_stages-1])|
          (32'(final_pipe[parameters.sync_stages-1])<<16)|(32'(safe_pipe[parameters.sync_stages-1])<<17);
      default: value=0;
    endcase
  end else if(ch<parameters.channels) begin
    cl=int'(client_select[ch]);
    if(offset<64) value=staging[ch].word[offset/4];
    else if(offset=='h4c) value=32'(service_select[ch]);
    else if(offset=='h140) value=32'(client_select[ch]);
    else if(offset>='h144 && offset<='h15c && cl<parameters.clients) value=staging[ch].client[cl][(offset-'h144)/4];
    else if(offset=='h68) value=32'(snapshot_valid[ch]);
    else if(offset=='h6c) value=snapshot_sequence[ch];
    else if(snapshot_valid[ch]) begin
      if(offset>='h180 && offset<='h1b8 && cl<parameters.clients) value=snapshots[ch].client[cl][(offset-'h180)/4];
      else if(offset>='h70 && offset<'h140) value=snapshots[ch].word[offset/4];
    end
  end
  return value;
endfunction
function void watchdog_reference_model::write_apb(apb_item item);
  watchdog_reg_views_pkg::register_access_t access_info;
  bit wr,error,channel_valid,is_staging,is_command,authorization;
  int ch,offset,cl;bit[7:0] operation;bit[31:0] value;
  if(item.status==APB_ABORTED) return;
  access_info=watchdog_reg_views_pkg::access_at(32'(item.addr));
  wr=item.direction==APB_WRITE;ch=int'((item.addr-32'h1000)>>10);offset=int'(item.addr&32'h3ff);
  channel_valid=item.addr>=32'h1000 && ch<parameters.channels;
  cl=channel_valid ? int'(client_select[ch]) : 0;
  is_staging=channel_valid && (offset<64 || offset=='h4c || offset=='h140 || (offset>='h144 && offset<='h15c));
  is_command=channel_valid && offset>='h40 && offset<='h64 && offset!='h4c;
  operation=offset=='h44 ? item.wdata[7:0] : 8'(offset);
  error=!access_info.valid || item.addr[1:0]!=0 || (item.addr>=32'h1000 && !channel_valid);
  authorization=1;
  if(wr) begin
    error|=item.strb!=4'hf || !access_info.writable || (item.wdata & ~access_info.write_mask)!=0;
    if(channel_valid && offset>='h144 && offset<='h15c && cl>=parameters.clients) error=1;
    if(is_staging) authorization=vif.cfg_auth;
    else if(is_command) begin
      if(offset=='h50) authorization=vif.service_auth;
      else if(offset inside {'h58,'h5c,'h60}) authorization=vif.diag_auth;
      else if(offset=='h64) authorization=vif.diag_auth && vif.cfg_auth;
      else if(!(offset=='h44 && item.wdata==5)) authorization=vif.cfg_auth;
      error|=busy;
    end
    error|=!authorization;
  end
  value=error ? 0 : (read_value(32'(item.addr)) & access_info.read_mask);
  emit($sformatf("APB:%0d",apb_count),{31'b0,error,wr ? 32'b0 : value},33'h1ffffffff);
  apb_count++;
  if(item.observed_wait_cycles>1) `uvm_error("APB_LATENCY","ACCESS exceeded two pclk edges")
  if(!error && wr && is_staging) begin
    if(offset<64) staging[ch].word[offset/4]=32'(item.wdata);
    else if(offset=='h4c) service_select[ch]=11'(item.wdata);
    else if(offset=='h140) client_select[ch]=5'(item.wdata);
    else staging[ch].client[cl][(offset-'h144)/4]=32'(item.wdata);
  end
  if(!error && wr && is_command) begin
    if(busy) `uvm_error("MAILBOX","oracle accepted a second outstanding command")
    issued_sequence++;busy=1;done=0;mailbox='0;
    mailbox.channel=4'(ch);mailbox.client=service_select[ch][4:0];mailbox.event_type=service_select[ch][10:8];
    mailbox.opcode=operation;mailbox.data=32'(item.wdata);mailbox.seq=issued_sequence;
    mailbox.source=vif.source_id;mailbox.cfg_auth=vif.cfg_auth;mailbox.service_auth=vif.service_auth;
    mailbox.diag_auth=vif.diag_auth;mailbox.hardware=0;mailbox_config=staging[ch];
  end
endfunction
function void watchdog_reference_model::write_wdt(watchdog_observation observation);
  bit[15:0] irq_now,fault_now,local_now,pause_now,recovery_now;
  bit final_now,safe_now,alert_now,wake_now;
  bit execute;
  command_t selected;
  config_t selected_config;
  bit[7:0] result;
  irq_now=0;fault_now=0;local_now=0;pause_now=0;recovery_now=0;
  final_now=0;safe_now=0;alert_now=0;wake_now=0;
  for(int i=0;i<parameters.channels;i++) begin
    irq_now[i]=|(channels[i].raw & channels[i].irq_enable);
    fault_now[i]=channels[i].fault;local_now[i]=channels[i].local_request;
    final_now|=channels[i].final_request || channels[i].final_hold;
  end
  safe_now=final_now;
  if(observation.kind==PCLK_EDGE) begin
    if(!observation.por_n) begin pclk_release=0;apb_release=0;reset_bus(1);end
    else begin
      pclk_release++;
      if(!observation.preset_n) apb_release=0;else apb_release++;
      if(apb_release<=parameters.sync_stages || pclk_release<=parameters.sync_stages) reset_bus(0);
      else begin
        if(observation.stamp==last_wdt_time) begin
          irq_now=prior_irq;fault_now=prior_fault;local_now=prior_local;final_now=prior_final;safe_now=prior_safe;
        end
        for(int k=parameters.sync_stages-1;k>0;k--) begin
          irq_pipe[k]=irq_pipe[k-1];fault_pipe[k]=fault_pipe[k-1];local_pipe[k]=local_pipe[k-1];
          final_pipe[k]=final_pipe[k-1];safe_pipe[k]=safe_pipe[k-1];
        end
        irq_pipe[0]=irq_now;fault_pipe[0]=fault_now;local_pipe[0]=local_now;final_pipe[0]=final_now;safe_pipe[0]=safe_now;
      end
      if(reply_pending && observation.stamp>reply_time && pclk_release>parameters.sync_stages) begin
        reply_age++;
        if(reply_age>parameters.sync_stages) begin
          busy=0;done=1;done_sequence=mailbox.seq;done_result=reply_result;
          done_info=32'(mailbox.channel)|(32'(mailbox.client)<<4)|(32'(mailbox.opcode)<<9);
          if(mailbox.opcode==5 && reply_result==0) begin
            snapshots[mailbox.channel]=reply_snapshot;snapshot_valid[mailbox.channel]=1;snapshot_sequence[mailbox.channel]=mailbox.seq;
          end
          reply_pending=0;
        end
      end
    end
    emit($sformatf("PCLK:%0d:irq",observation.cycle),64'(irq_pipe[parameters.sync_stages-1]),64'hffff);
    return;
  end
  prior_irq=irq_now;prior_fault=fault_now;prior_local=local_now;prior_final=final_now;prior_safe=safe_now;last_wdt_time=observation.stamp;
  if(!observation.por_n) wdt_release=0;else wdt_release++;
  if(wdt_release<=parameters.sync_stages+1) begin
    for(int i=0;i<parameters.channels;i++) channels[i].reset_model(i,parameters,observation.cycle);
  end else begin
    selected=observation.command;selected_config=observation.command_config;
    if(observation.command_valid && !observation.command.hardware) begin
      if(!busy || reply_pending) `uvm_error("MAILBOX","execution without one outstanding accepted command")
      if(observation.command!==mailbox) `uvm_error("MAILBOX","executed command differs from the APB-captured transaction")
      if(observation.command_config!==mailbox_config) `uvm_error("MAILBOX","cross-domain configuration payload torn or replaced")
      selected=mailbox;selected_config=mailbox_config;
    end
    result=0;
    for(int i=0;i<parameters.channels;i++) begin
      execute=observation.command_valid && !observation.command_canceled && !observation.command_integrity && selected.channel==i;
      channels[i].step(observation.cycle,observation,execute,selected,selected_config);
      if(execute) result=channels[i].result;
    end
    if(observation.command_valid) begin
      if(observation.command_canceled) result=9;
      else if(observation.command_integrity) result=10;
      emit($sformatf("WDT:%0d:result",observation.cycle),64'(result),64'hff);
      if(!observation.command.hardware) begin
        reply_pending=1;reply_time=observation.stamp;reply_age=0;reply_result=result;
        reply_snapshot=channels[selected.channel].image();
      end
    end
  end
  fault_now=0;local_now=0;pause_now=0;recovery_now=0;final_now=0;alert_now=0;wake_now=0;
  for(int i=0;i<parameters.channels;i++) begin
    fault_now[i]=channels[i].fault;local_now[i]=channels[i].local_request;
    pause_now[i]=channels[i].state==3;recovery_now[i]=channels[i].ack;
    final_now|=channels[i].final_request || channels[i].final_hold;
    alert_now|=channels[i].fault || channels[i].final_hold;
    wake_now|=channels[i].fault || (channels[i].raw[0] && channels[i].active.word[0][11]);
  end
  emit($sformatf("WDT:%0d:nmi",observation.cycle),64'(fault_now),64'hffff);
  emit($sformatf("WDT:%0d:local",observation.cycle),64'(local_now),64'hffff);
  emit($sformatf("WDT:%0d:pause",observation.cycle),64'(pause_now),64'hffff);
  emit($sformatf("WDT:%0d:recovery",observation.cycle),64'(recovery_now),64'hffff);
  emit($sformatf("WDT:%0d:final",observation.cycle),64'(final_now),1);
  emit($sformatf("WDT:%0d:safe",observation.cycle),64'(final_now),1);
  emit($sformatf("WDT:%0d:alert",observation.cycle),64'(alert_now),1);
  emit($sformatf("WDT:%0d:wake",observation.cycle),64'(wake_now),1);
endfunction
function void watchdog_reference_model::check_phase(uvm_phase phase);
  if(busy || reply_pending) `uvm_error("RM_DRAIN","test ended with an unresolved accepted mailbox command")
endfunction
function void watchdog_reference_model::oracle_self_test();
  watchdog_model_channel c;watchdog_observation o;command_t cmd;config_t conf;snapshot_t sampled;
  c=watchdog_model_channel::type_id::create("oracle_self_test");o=watchdog_observation::type_id::create("event");
  c.reset_model(0,parameters,0);conf=c.standard_defaults();conf.word[0]=0;conf.word[8]=0;conf.word[4]=5;conf.word[1]=1;
  c.active=conf;c.state=2;c.epoch=0;
  if(c.age_at(9)!=4 || c.age_at(10)!=5) `uvm_fatal("RM_SELF","independent divider formula failed")
  cmd='0;c.step(9,o,0,cmd,conf);if(c.fault) `uvm_fatal("RM_SELF","premature timeout")
  c.step(10,o,0,cmd,conf);if(!c.fault || !c.final_request || c.first_age!=5) `uvm_fatal("RM_SELF","exact timeout failed")
  c.step(20,o,0,cmd,conf);sampled=c.image();if(sampled.word['h78/4]!=5) `uvm_fatal("RM_SELF","fault count hold failed")
  c.reset_model(0,parameters,0);conf=c.standard_defaults();conf.word[0]=1;conf.word[8]=0;conf.word[4]=5;conf.word[2]=2;
  c.active=conf;c.state=2;cmd.opcode=8'h50;cmd.data=32'ha5c35a3c;cmd.service_auth=1;
  c.step(2,o,1,cmd,conf);if(c.fault || c.age_at(2)!=0) `uvm_fatal("RM_SELF","inclusive lower window failed")
  c.reset_model(0,parameters,0);c.active=conf;c.state=2;
  c.step(5,o,1,cmd,conf);if(!c.fault || c.result!=10) `uvm_fatal("RM_SELF","timeout must beat boundary service")
endfunction
`endif
