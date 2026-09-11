`ifndef WATCHDOG_MODEL_CHANNEL__SV
`define WATCHDOG_MODEL_CHANNEL__SV
// Independent event-history oracle. Time is derived from epoch timestamps,
// not from DUT divider/counter state or DUT next-state functions.
class watchdog_model_channel extends uvm_object;
  `uvm_object_utils(watchdog_model_channel)
  watchdog_dut_cfg parameters;
  int channel,state,resume_state;
  config_t active,pending;
  bit pending_valid,fault,local_request,final_request,final_hold,prewarn;
  bit ack,recovery_armed,credit,unlock_pending,test_context;
  bit pause_sleep_active,pause_debug_active;
  bit[63:0] held_count,flow_elapsed[32],injected_age;
  bit injected_age_valid;
  bit [3:0] locks;
  bit [31:0] version,submitted,pending_version,raw,irq_enable,service_sequence,fault_count;
  int recoveries;
  longint unsigned epoch,paused_cycles,pause_begin,fault_epoch,unlock_epoch,credit_epoch;
  bit [15:0] unlock_source;
  bit client_seen[32],key_pending[32],flow_active[32];
  bit [15:0] key_source[32];
  int alive[32],next_checkpoint[32];
  bit [31:0] token[32];
  longint unsigned key_epoch[32],flow_epoch[32];
  bit first_valid,first_client_valid,first_source_valid,first_test;
  int first_state,first_client;
  bit [15:0] first_source;
  bit [31:0] first_causes,first_version,first_missing,first_service;
  bit [63:0] first_age;
  int injection_target=-1,injection_bit;
  bit delayed_service_fault;
  bit [31:0] persistent_integrity;
  bit [7:0] result;
  bit [31:0] last_events;
  longint unsigned now_cycle;
  extern function new(string name="watchdog_model_channel");
  extern function config_t standard_defaults();
  extern function void reset_model(int index,watchdog_dut_cfg cfg,longint unsigned cycle);
  extern function void clear_clients(bit restart);
  extern function bit[63:0] age_at(longint unsigned cycle);
  extern function bit[31:0] missing_clients();
  extern function bit[7:0] configuration_result(config_t c);
  extern function void step(longint unsigned cycle,watchdog_observation observation,bit execute,command_t command,config_t configuration);
  extern function snapshot_t image();
endclass
function watchdog_model_channel::new(string name="watchdog_model_channel");super.new(name);endfunction
function config_t watchdog_model_channel::standard_defaults();
  config_t c;c='0;c.word[0]=12;c.word[4]=65536;c.word[8]=65536;c.word[10]=256;
  c.word[11]=1;c.word[12]=32'h3de;return c;
endfunction
function void watchdog_model_channel::clear_clients(bit restart);
  for(int i=0;i<32;i++) begin
    client_seen[i]=0;key_pending[i]=0;flow_active[i]=0;alive[i]=0;next_checkpoint[i]=0;
    key_epoch[i]=0;flow_epoch[i]=0;key_source[i]=0;flow_elapsed[i]=0;
    if(restart) begin token[i]=32'h1d872b41 ^ (32'(channel)<<8) ^ 32'(i);if(token[i]==0) token[i]=1;end
  end
endfunction
function void watchdog_model_channel::reset_model(int index,watchdog_dut_cfg cfg,longint unsigned cycle);
  parameters=cfg;channel=index;active=standard_defaults();pending='0;
  state=parameters.autostart[index] ? 1 : 0;resume_state=0;
  pending_valid=0;fault=0;local_request=0;final_request=0;final_hold=0;prewarn=0;
  ack=0;recovery_armed=0;credit=0;unlock_pending=0;test_context=0;
  locks=4'(parameters.hard_lock[index]);version=0;submitted=0;pending_version=0;
  raw=0;irq_enable=0;service_sequence=0;fault_count=0;recoveries=0;persistent_integrity=0;
  epoch=cycle;paused_cycles=0;pause_begin=0;fault_epoch=0;unlock_epoch=0;credit_epoch=0;unlock_source=0;
  first_valid=0;first_client_valid=0;first_source_valid=0;first_test=0;first_state=0;first_client=0;
  first_source=0;first_causes=0;first_version=0;first_missing=0;first_service=0;first_age=0;
  injection_target=-1;delayed_service_fault=0;result=0;last_events=0;now_cycle=cycle;
  held_count=0;injected_age_valid=0;pause_sleep_active=0;pause_debug_active=0;
  clear_clients(1);
endfunction
function bit[63:0] watchdog_model_channel::age_at(longint unsigned cycle);
  bit[127:0] ticks,max_age;
  longint unsigned use_cycle;
  if(!(state inside {1,2,3})) return held_count;
  use_cycle=state==3 ? pause_begin : cycle;
  ticks=(128'(use_cycle-epoch-paused_cycles))/(128'(active.word[1])+1);
  max_age=(128'b1<<parameters.width)-1;
  return 64'(ticks>max_age ? max_age : ticks);
endfunction
function bit[31:0] watchdog_model_channel::missing_clients();
  bit[31:0] m;m=0;
  for(int i=0;i<parameters.clients;i++) if(active.word[11][i])
    m[i]=active.word[0][6:5]==2 ? alive[i]<active.client[i][1][15:0] : !client_seen[i];
  return m;
endfunction
function bit[7:0] watchdog_model_channel::configuration_result(config_t c);
  bit[63:0] lo,limit,pre,boot,dmin,dmax;
  bit[31:0] flags,required;
  bit invalid;
  flags=c.word[0];lo={c.word[3],c.word[2]};limit={c.word[5],c.word[4]};
  pre={c.word[7],c.word[6]};boot={c.word[9],c.word[8]};
  if((flags[4:3]>=2 && !parameters.token_support) ||
     (flags[6:5]!=0 && !parameters.supervision_support) || (flags[12] && !parameters.hw_support)) return 6;
  invalid=flags[31:13]!=0 || (c.word[1]>>parameters.prescale_width)!=0;
  if(parameters.width<64) invalid|=((lo|limit|pre|boot)>>parameters.width)!=0;
  invalid|=limit==0 || c.word[10]==0 || c.word[11]==0;
  if(parameters.clients<32) invalid|=(c.word[11]>>parameters.clients)!=0;
  invalid|=flags[0] ? lo>=limit : lo!=0;
  invalid|=flags[1] ? (pre<lo || pre>=limit) : pre!=0;
  invalid|=flags[2] ? boot==0 : boot!=0;
  invalid|=(flags[6:5]==0 && c.word[11]!=1) || (flags[6:5]==2 && flags[0]);
  invalid|=flags[6:5]==3 && flags[4:3]!=0;
  required=32'h3c2 | (parameters.safety ? 32'h1c : 0);
  invalid|=(c.word[12]&required)!=required || (c.word[12]&32'hfffff801)!=0 || c.word[15]>255;
  if(!flags[7]) invalid|=(c.word[13]|c.word[14]|c.word[15])!=0 || flags[8];
  else invalid|=c.word[14]<=c.word[13] || (flags[8] ? c.word[15]==0 : c.word[15]!=0);
  for(int i=0;i<parameters.clients;i++) if(c.word[11][i]) begin
    invalid|=(c.client[i][0]>>parameters.source_width)!=0 || c.client[i][2]>255;
    if(flags[6:5]==2) invalid|=c.client[i][1][15:0]==0 || c.client[i][1][15:0]>c.client[i][1][31:16];
    if(flags[6:5]==3) begin
      dmin={c.client[i][4],c.client[i][3]};dmax={c.client[i][6],c.client[i][5]};
      invalid|=c.client[i][2]==0 || dmax<=dmin;
      if(parameters.width<64) invalid|=((dmin|dmax)>>parameters.width)!=0;
    end
  end
  return invalid ? 4 : 0;
endfunction
function void watchdog_model_channel::step(longint unsigned cycle,watchdog_observation observation,
  bit execute,command_t command,config_t configuration);
  bit[63:0] age,limit,lower,deadline;
  bit[31:0] events,missing,old_service,old_version,expected_token;
  config_t old_config,compare_config;
  int old_state,client,supervision,algorithm,event_client;
  bit running,timeout_now,refresh,restart,complete,accepted,allowed,sensitive,credit_valid;
  bit new_fault,fatal,event_client_valid,event_source_valid,final_due,pause,second_consumed;
  bit old_key_pending[32],old_seen[32],old_flow[32];
  int old_alive[32],old_checkpoint[32];
  bit[31:0] old_token[32];
  bit[63:0] old_flow_elapsed[32];
  bit unlock_valid,old_test_context;
  longint unsigned phase_value;
  bit[15:0] event_source;
  now_cycle=cycle;old_state=state;old_config=active;old_service=service_sequence;old_version=version;
  age=injected_age_valid ? injected_age : age_at(cycle);injected_age_valid=0;
  old_test_context=test_context;supervision=active.word[0][6:5];algorithm=active.word[0][4:3];
  running=state==1 || state==2;limit=state==1 ? {active.word[9],active.word[8]} : {active.word[5],active.word[4]};
  lower=state!=1 && active.word[0][0] ? {active.word[3],active.word[2]} : 0;
  events=0;missing=missing_clients();result=0;refresh=0;restart=0;complete=0;accepted=0;
  event_client_valid=0;event_source_valid=0;event_client=int'(command.client);event_source=command.source;
  client=int'(command.client);second_consumed=0;
  for(int i=0;i<32;i++) begin
    old_key_pending[i]=key_pending[i];old_seen[i]=client_seen[i];old_flow[i]=flow_active[i];
    old_alive[i]=alive[i];old_checkpoint[i]=next_checkpoint[i];old_token[i]=token[i];old_flow_elapsed[i]=flow_elapsed[i];
  end
  events|=persistent_integrity;
  if(observation.access_error[channel]) events[10]=1;
  if(parameters.safety && observation.cdc_error[channel]) events[17]=1;
  if(delayed_service_fault) begin events[14]=1;delayed_service_fault=0;end
  if(injection_target>=0) begin
    case(injection_target)
      0,1: begin events[12]=1;persistent_integrity[12]=1;end
      4: events[12]=1;
      2: begin events[11]=1;persistent_integrity[11]=1;end
      3: events[13]=1;
      5: begin final_hold=1;delayed_service_fault=1;end
      default: `uvm_fatal("RM","unknown pending injected fault")
    endcase
    injection_target=-1;
  end
  timeout_now=running && age>=limit;
  if(running) begin
    for(int i=0;i<parameters.clients;i++) if(active.word[11][i] && supervision==3 && flow_active[i]) begin
      deadline=cycle-flow_epoch[i]-paused_cycles;flow_elapsed[i]=deadline;
      if(deadline>={active.client[i][6],active.client[i][5]}) begin events[9]=1;event_client=i;event_client_valid=1;end
    end
    if(timeout_now) begin
      if(supervision==2) begin if(missing==0) refresh=1;else events[6]=1;end
      else events[1]=1;
    end
  end
  final_due=fault && !final_request && cycle-fault_epoch>=active.word[14];
  credit_valid=credit && cycle-credit_epoch<64 && command.source==unlock_source;
  unlock_valid=unlock_pending && cycle-unlock_epoch<=32;
  if(unlock_pending && cycle-unlock_epoch>=32) unlock_pending=0;
  if(credit && cycle-credit_epoch>=64) credit=0;
  if(!observation.done[channel]) begin ack=0;recovery_armed=1;end
  allowed=execute && !observation.warm;
  if(execute && observation.warm) result=9;
  sensitive=command.opcode==1 || command.opcode==2 || command.opcode==3 || command.opcode==8'h48 || command.opcode==8'h60 || command.opcode==8'h64;
  if(allowed) begin
    bit authorized;
    authorized=command.opcode==8'h50 ? command.service_auth :
      (command.opcode inside {8'h58,8'h5c,8'h60,8'h64}) ? command.diag_auth : command.cfg_auth;
    if(command.opcode!=5 && !authorized) begin allowed=0;result=2;events[10]=1;end
    if(sensitive) begin credit=0;if(!credit_valid) begin allowed=0;result=14;end end
  end
  if(allowed) case(command.opcode)
    8'h40: begin
      if(command.data==32'hc0de1234) begin unlock_pending=1;unlock_epoch=cycle;unlock_source=command.source;credit=0;end
      else if(command.data==32'h3f21edcb && cycle-unlock_epoch<=32 &&
              command.source==unlock_source && unlock_valid) begin
        unlock_pending=0;credit=1;credit_epoch=cycle;
      end else begin unlock_pending=0;credit=0;result=2;end
    end
    1: begin
      result=configuration_result(configuration);
      if(locks[0]) result=5;
      else if(pending_valid) result=1;
      else if(state!=0 && !(state==2 && parameters.runtime_update)) result=3;
      else if(state==2 && result==0) begin
        compare_config=configuration;
        for(int i=1;i<8;i++) compare_config.word[i]=active.word[i];
        if(compare_config!=active) result=4;
      end
      if(result==0) begin
        submitted++;
        if(state==0) begin active=configuration;version=submitted;end
        else begin pending=configuration;pending_version=submitted;pending_valid=1;result=11;end
      end else if(result==4 || result==6) events[18]=1;
    end
    2: if(state!=0) result=3;else restart=1;
    3: begin
      if(parameters.no_stop[channel] || locks[1]) result=5;
      else if(!running) result=3;
      else begin state=0;held_count=age;for(int i=0;i<32;i++) begin key_pending[i]=0;flow_active[i]=0;end end
    end
    4: if(!pending_valid) result=15;else pending_valid=0;
    5: result=0;
    8'h48: locks|=command.data[3:0];
    8'h54: irq_enable=command.data & 32'h7ffff;
    8'h58: raw&=~command.data;
    8'h5c: if(command.data[0]) events[15]=1;
    8'h60: begin
      if(fault) result=3;
      else begin if(command.data[0]) first_valid=0;if(command.data[1]) fault_count=0;end
    end
    8'h64: begin
      if(!parameters.safety || !parameters.inject_enable) result=6;
      else if(locks[3]) result=5;
      else if(!command.cfg_auth || !observation.test_auth) result=2;
      else if(command.data[3:0]>5 ||
              (command.data[3:0] inside {0,2} && command.data[9:4]>=parameters.width) ||
              (command.data[3:0]==1 && command.data[9:4]>=parameters.prescale_width) ||
              (command.data[3:0]>=3 && command.data[9:4]!=0)) result=4;
      else begin
        injection_target=command.data[3:0];injection_bit=command.data[9:4];test_context=1;
        phase_value=(cycle-epoch-paused_cycles)%(64'(active.word[1])+1);
        if(injection_target==0) begin
          injected_age=age^(64'b1<<injection_bit);
          if(phase_value==active.word[1] && injected_age!=((128'b1<<parameters.width)-1)) injected_age++;
          injected_age_valid=1;
        end
        if(injection_target==1) begin
          injected_age=age+((phase_value^(64'b1<<injection_bit))==active.word[1] ? 1 : 0);
          injected_age_valid=1;
        end
        if(injection_target==3) begin state=7;held_count=age;end
      end
    end
    8'h50: begin
      if(state==3) result=8;
      else if(!running) result=3;
      else if(supervision==2 && timeout_now) result=13;
      else if(client>=parameters.clients || !active.word[11][client]) result=12;
      else if(command.hardware!=active.word[0][12] || command.source!=active.client[client][0]) begin result=2;events[10]=1;end
      else begin
        event_client_valid=1;event_source_valid=1;
        if(supervision==3) begin
          if(command.event_type==1 && command.data==0 && !flow_active[client] && !client_seen[client]) begin
            flow_active[client]=1;next_checkpoint[client]=1;flow_epoch[client]=cycle-paused_cycles;flow_elapsed[client]=0;accepted=1;
          end else if(command.event_type==2 && flow_active[client] && command.data==next_checkpoint[client] &&
                      command.data<active.client[client][2]) begin next_checkpoint[client]++;accepted=1;end
          else if(command.event_type==3 && flow_active[client] && command.data==next_checkpoint[client] &&
                  command.data==active.client[client][2]) begin
            deadline=cycle-flow_epoch[client]-paused_cycles;
            if(deadline<{active.client[client][4],active.client[client][3]} ||
               deadline>={active.client[client][6],active.client[client][5]}) events[9]=1;
            else complete=1;
          end else events[8]=1;
        end else if(command.event_type!=0) events[3]=1;
        else case(algorithm)
          0: if(command.data==32'ha5c35a3c) complete=1;else events[3]=1;
          1: begin
            if(!key_pending[client] && command.data==32'ha5c35a3c) begin
              key_pending[client]=1;key_epoch[client]=cycle-paused_cycles;key_source[client]=command.source;accepted=1;
            end else if(key_pending[client] && command.data==32'h5a3ca5c3 && command.source==key_source[client] &&
                        cycle-key_epoch[client]-paused_cycles<=active.word[10]) begin
              complete=1;key_pending[client]=0;second_consumed=1;
            end else begin events[3]=1;key_pending[client]=0;second_consumed=1;end
          end
          2,3: begin
            expected_token=algorithm==2 ? token[client] : ((token[client]<<7)|(token[client]>>25)) ^
              32'h6d2b79f5 ^ (32'(channel)<<8) ^ 32'(client);
            if(command.data==expected_token) complete=1;else events[3]=1;
          end
        endcase
        if(complete) begin
          if(age<lower) events[2]=1;
          else if((supervision==1 || supervision==3) && client_seen[client]) events[5]=1;
          else if(supervision==2 && alive[client]>=active.client[client][1][31:16]) events[7]=1;
          else if(!timeout_now && (events & 32'h37bfe)==0) begin
            accepted=1;service_sequence++;
            if(algorithm>=2) token[client]=(token[client]>>1) ^ (token[client][0] ? 32'h80200003 : 0);
            if(supervision==2) begin if(alive[client]<65535) alive[client]++;end
            else if(supervision==0) refresh=1;
            else begin client_seen[client]=1;flow_active[client]=0;if(missing_clients()==0) refresh=1;end
          end
        end
        if(!accepted) result=7;
      end
    end
    default: result=4;
  endcase
  for(int i=0;i<parameters.clients;i++)
    if(running && old_key_pending[i] && key_pending[i] && cycle-key_epoch[i]-paused_cycles>=active.word[10]) begin
      events[4]=1;key_pending[i]=0;event_client=i;event_client_valid=1;event_source_valid=0;
    end
  fatal=(events & 32'h37800)!=0;new_fault=fatal || (events & old_config.word[12])!=0;
  if(fault) begin
    if(cycle-fault_epoch>=active.word[13]) local_request=active.word[0][7];
    if(final_due) begin final_request=1;final_hold=1;state=5;end
  end
  if(new_fault || final_due) begin
    refresh=0;restart=0;
    if(execute && command.opcode inside {1,2,3,8'h50}) result=10;
    active=old_config;version=old_version;pending_valid=0;service_sequence=old_service;
    for(int i=0;i<32;i++) begin
      key_pending[i]=0;client_seen[i]=old_seen[i];flow_active[i]=old_flow[i];alive[i]=old_alive[i];
      next_checkpoint[i]=old_checkpoint[i];token[i]=old_token[i];flow_elapsed[i]=old_flow_elapsed[i];
    end
    held_count=age;
    if(!fault) begin
      fault=1;fault_epoch=cycle;if(fault_count!=32'hffffffff) fault_count++;
      state=4;local_request=old_config.word[0][7] && old_config.word[13]==0;
    end
    if(fatal || final_due || !old_config.word[0][7]) begin final_request=1;final_hold=1;state=5;end
    if(!first_valid && new_fault) begin
      first_valid=1;first_causes=events;first_age=age;first_state=old_state;
      first_version=old_version;first_missing=missing;first_service=old_service;
      first_client=event_client;first_source=event_source;
      first_client_valid=event_client_valid && !events[1] && !events[6];
      first_source_valid=event_source_valid && !events[1] && !events[6];first_test=old_test_context;
    end
  end else if(observation.warm) begin
    pending_valid=0;recoveries=0;fault=0;local_request=0;final_request=0;final_hold=0;
    fault_epoch=cycle;credit=0;unlock_pending=0;if(old_state!=0) restart=1;
  end else if(state==4 && local_request && active.word[0][7] && active.word[0][8] &&
              observation.done[channel] && recovery_armed && !ack) begin
    ack=1;recovery_armed=0;
    if(recoveries>=active.word[15]) begin events[16]=1;final_request=1;final_hold=1;state=5;end
    else begin recoveries++;fault=0;local_request=0;fault_epoch=cycle;pending_valid=0;restart=1;end
  end
  if(refresh || restart) begin
    epoch=cycle;paused_cycles=0;prewarn=0;state=restart && active.word[0][2] ? 1 : 2;
    if(refresh && pending_valid) begin active=pending;version=pending_version;pending_valid=0;end
    clear_clients(restart);
  end else if(!fault) begin
    pause=observation.sleep_req && active.word[0][9] ||
      observation.debug_req && observation.debug_auth && active.word[0][10] && !locks[2];
    if(running && state!=0 && pause) begin resume_state=old_state;state=3;pause_begin=cycle;end
    else if(old_state==3 && !pause) begin state=resume_state;paused_cycles+=cycle-pause_begin;end
    if(old_state==2 && active.word[0][1] && !prewarn && age>={active.word[7],active.word[6]} &&
       (supervision!=2 || missing!=0)) begin prewarn=1;events[0]=1;end
  end
  pause_sleep_active=state==3 && observation.sleep_req && active.word[0][9];
  pause_debug_active=state==3 && observation.debug_req && observation.debug_auth && active.word[0][10] && !locks[2];
  raw|=events;last_events=events;
endfunction
function snapshot_t watchdog_model_channel::image();
  snapshot_t s;bit[63:0] age,elapsed;int primary;
  s='0;age=age_at(now_cycle);
  s.word['h70/4]=32'(state)|(32'(fault)<<3)|(32'(prewarn)<<4)|(32'(pending_valid)<<5)|
    (32'(credit)<<6)|(32'(fault_count==32'hffffffff)<<7)|(32'(locks)<<8)|(32'(pause_sleep_active)<<12)|(32'(pause_debug_active)<<13);
  s.word['h74/4]=version;{s.word['h7c/4],s.word['h78/4]}=age;
  s.word['h80/4]=raw;s.word['h84/4]=irq_enable;
  for(int i=0;i<parameters.clients;i++) if(active.word[0][6:5] inside {1,3}) s.word['h88/4][i]=client_seen[i];
  s.word['h8c/4]=missing_clients();s.word['h90/4]=service_sequence;s.word['h94/4]=fault_count;
  s.word['h98/4]=32'(recoveries);s.word['h9c/4]=fault ? 32'((now_cycle-fault_epoch)>32'hffffffff ? 32'hffffffff : now_cycle-fault_epoch) : 0;
  if(first_valid) begin
    primary=0;
    begin int priority_bits[13]='{11,12,13,14,17,16,1,6,9,8,7,2,3};bit found=0;
      foreach(priority_bits[i]) if(first_causes[priority_bits[i]] && !found) begin primary=priority_bits[i];found=1;end
      if(!found) for(int i=0;i<19;i++) if(first_causes[i] && !found) begin primary=i;found=1;end
    end
    s.word['ha0/4]=1|(32'(first_client_valid)<<1)|(32'(first_source_valid)<<2)|(32'(first_test)<<3)|
      (32'(channel)<<8)|(32'(first_client)<<12)|(32'(primary)<<17);
    s.word['ha4/4]=first_causes;{s.word['hac/4],s.word['ha8/4]}=first_age;
    s.word['hb0/4]=32'(first_source);s.word['hb4/4]=first_version;s.word['hb8/4]=first_missing;
    s.word['hbc/4]=first_service;s.word['hc0/4]=32'(first_state);
  end
  for(int k=0;k<16;k++) s.word['h100/4+k]=active.word[k];
  for(int i=0;i<parameters.clients;i++) begin
    s.client[i][0]=32'(active.word[11][i])|(32'(client_seen[i])<<1)|(32'(key_pending[i])<<2)|
      (32'(flow_active[i])<<3)|(32'(next_checkpoint[i]>0 ? next_checkpoint[i]-1 : 0)<<8);
    s.client[i][1]=parameters.token_support && active.word[0][4:3]>=2 ? token[i] : 0;
    s.client[i][2]=32'(alive[i]);
    elapsed=flow_elapsed[i];
    if(active.word[0][6:5]==3) {s.client[i][4],s.client[i][3]}=elapsed;
    for(int k=0;k<7;k++) s.client[i][8+k]=active.client[i][k];
  end
  return s;
endfunction
`endif
