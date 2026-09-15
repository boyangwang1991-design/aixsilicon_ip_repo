`ifndef APB_SECURE_DEMUX_RM__SV
`define APB_SECURE_DEMUX_RM__SV
// Independent contract model. Structure constants are RDL-derived; behavior is
// implemented from contract sections 6–12, never from DUT state or readback.
class apb_secure_demux_rm extends uvm_component;
  `uvm_component_utils(apb_secure_demux_rm)
  bit [1:0] active_cfg[ASD_NP],shadow_cfg[ASD_NP];
  byte unsigned active_perm[ASD_NP][ASD_NM],shadow_perm[ASD_NP][ASD_NM];
  bit global_lock,port_lock[ASD_NP],fatal,first_valid,last_valid,overflow,wait_hit;
  int unsigned policy_version,commit_status,integrity_status;
  bit [8:0] raw,intr_enable,alert_enable,cycle_irq;
  int unsigned access_denies,cfg_denies,lost,downstream_errors;
  int unsigned success[ASD_NP],denies[ASD_NP],slverrs[ASD_NP];
  int unsigned wait_total[ASD_NP],wait_max[ASD_NP],threshold,target;
  bit [1:0] armed;
  int unsigned armed_port,armed_master;
  bit [63:0] timestamp;
  int unsigned event_sequence;
  bit [255:0] first_record,last_record,first_snapshot,last_snapshot,fifo[$];
  bit [255:0] candidates[4];
  bit [3:0] candidate_valid;
  bit raw_fault,fault_observed;
  int unsigned new_integrity_status;
  extern function new(string name,uvm_component parent);
  extern function void reset();
  extern function int reg_index(int unsigned offset);
  extern function int index_of(register_kind_t kind,int port=0,int master=0,int word_index=0);
  extern function bit mgmt(asd_request_t r);
  extern function bit sensitive(int unsigned offset);
  extern function byte csr_reason(asd_request_t r,bit authorized);
  extern function asd_prediction_t admission(asd_request_t r,bit authorized);
  extern function int unsigned read_csr(asd_request_t r,bit authorized);
  extern function void complete_csr(asd_request_t r,bit authorized);
  extern function void start_cycle();
  extern function void observe_fault(bit active,bit data_fault,int kind,int port,int master,int bit_index);
  extern function void end_cycle();
  extern function void record_event(int priority_index,byte reason,asd_request_t r,
      bit associated,bit csr,int port,bit is_test,int unsigned version,bit [5:0] source);
  extern function void bus_failure(asd_request_t r,byte reason,bit csr,int port,
      bit is_test,int unsigned version);
  extern function void wait_cycle(asd_request_t r,int port,int unsigned waits,
      bit first_threshold,int unsigned version);
  extern function void target_complete(int port,bit error,int unsigned waits);
  extern function void consume_injection(asd_request_t r,int port,byte reason);
  extern function int unsigned sat(int unsigned value,int unsigned increment=1);
endclass
function apb_secure_demux_rm::new(string name,uvm_component parent);
  super.new(name,parent); reset();
endfunction
function int unsigned apb_secure_demux_rm::sat(int unsigned value,int unsigned increment=1);
  bit [32:0] sum;
  sum={1'b0,value}+{1'b0,increment};
  return sum[32]?'1:sum[31:0];
endfunction
function void apb_secure_demux_rm::reset();
  foreach(active_cfg[p]) begin
    active_cfg[p]=C_RESET_PORT_CFG[p];shadow_cfg[p]=C_RESET_PORT_CFG[p];
    port_lock[p]=0;success[p]=0;denies[p]=0;slverrs[p]=0;wait_total[p]=0;wait_max[p]=0;
    for(int m=0;m<ASD_NM;m++) begin
      active_perm[p][m]=C_RESET_PERM[p][m];shadow_perm[p][m]=C_RESET_PERM[p][m];
    end
  end
  global_lock=0;fatal=0;policy_version=0;commit_status=0;integrity_status=0;
  raw=0;intr_enable=0;alert_enable='h9b;cycle_irq=0;
  access_denies=0;cfg_denies=0;lost=0;downstream_errors=0;
  threshold=0;target=0;armed=0;armed_port=0;armed_master=0;wait_hit=0;
  first_valid=0;last_valid=0;overflow=0;first_record=0;last_record=0;
  first_snapshot=0;last_snapshot=0;fifo.delete();timestamp=0;event_sequence=0;
  candidate_valid=0;foreach(candidates[c]) candidates[c]=0;
  raw_fault=0;fault_observed=0;new_integrity_status=0;
endfunction
function int apb_secure_demux_rm::reg_index(int unsigned offset);
  foreach(REG_ADDR[i]) if(REG_ADDR[i]==offset) return i;
  return -1;
endfunction
function int apb_secure_demux_rm::index_of(register_kind_t kind,int port=0,int master=0,int word_index=0);
  foreach(REG_KIND[i])
    if(REG_KIND[i]==kind && REG_PORT[i]==port && REG_MASTER[i]==master && REG_WORD[i]==word_index)
      return i;
  `uvm_fatal("RM_STRUCTURE",$sformatf("No register kind=%s port=%0d master=%0d word=%0d",
                                    kind.name(),port,master,word_index))
  return -1;
endfunction
function bit apb_secure_demux_rm::mgmt(asd_request_t r);
  return r.valid && r.master<ASD_NM && C_MGMT_MASTER_MASK[r.master] && r.prot==3'b001;
endfunction
function bit apb_secure_demux_rm::sensitive(int unsigned offset);
  int port_offset;
  if(offset=='h40 || (offset>='h100 && offset<'h1000)) return 1;
  if(offset>='h1000) begin
    port_offset=(offset-'h1000)%'h400;
    return (offset-'h1000)/'h400<ASD_NP && port_offset>='h14 && port_offset<'h2c;
  end
  return 0;
endfunction
function byte apb_secure_demux_rm::csr_reason(asd_request_t r,bit authorized);
  int unsigned offset,value,mask;
  int i,p,m;
  bit locked,changed,invalid;
  register_kind_t k;
  offset=r.addr-32'(C_CSR_BASE);i=reg_index(offset);
  if(!(mgmt(r) || (C_PUBLIC_ID_EN && !r.write && !r.prot[2] && offset<'h10 &&
       r.valid && r.master<ASD_NM))) return 'h10;
  if(sensitive(offset) && !authorized) return 'h10;
  if(offset%4) return 'h11;
  if(r.write && r.strb!='hf) return 'h12;
  if(i<0) return 'h13;
  if((r.write && !REG_WRITABLE[i]) || (!r.write && !REG_READABLE[i])) return 'h14;
  if(!r.write) return 0;
  k=REG_KIND[i];p=REG_PORT[i];m=REG_MASTER[i];value=r.data&REG_MASK[i];
  mask=(ASD_NP==32)?'1:((32'b1<<ASD_NP)-1);
  locked=0;changed=0;invalid=0;
  case(k)
    K_CFG_SHADOW,K_PERM_SHADOW: begin changed=1;locked=global_lock||port_lock[p];end
    K_COMMIT_MASK,K_SHADOW_RELOAD: begin
      changed=1;locked=global_lock;
      foreach(port_lock[q]) if(value[q] && port_lock[q]) locked=1;
      invalid=(value==0 || (value&~mask)!=0);
    end
    K_FIFO_POP: invalid=(fifo.size()==0);
    K_INJECT_TARGET: invalid=(armed!=0 || value[4:0]>=ASD_NP || value[13:8]>=ASD_NM);
    K_INJECT_CMD: invalid=(!$onehot(value[2:0]) || (value[2:1]!=0 && armed!=0) ||
                           (value[2] && !C_POLICY_PARITY_EN));
    default: begin end
  endcase
  if(locked) return 'h15;
  if(invalid) return 'h16;
  if(changed && (fatal || raw_fault)) return 'h17;
  return 0;
endfunction
function asd_prediction_t apb_secure_demux_rm::admission(asd_request_t r,bit authorized);
  asd_prediction_t v;
  int hits,p,category;
  bit csr;
  v='0;v.port=-1;hits=0;p=-1;
  csr=({1'b0,r.addr}>={1'b0,32'(C_CSR_BASE)} &&
       {1'b0,r.addr}<{1'b0,32'(C_CSR_BASE)}+33'('h1000+ASD_NP*'h400));
  if(csr) hits++;
  foreach(C_PORT_BASE[q]) if({1'b0,r.addr}>={1'b0,C_PORT_BASE[q]} &&
      {1'b0,r.addr}<{1'b0,C_PORT_BASE[q]}+C_PORT_SIZE[q]) begin hits++;p=q;end
  if(hits>1) v.reason='h02;
  else if(hits==0) v.reason='h01;
  else if(csr) begin v.reason=csr_reason(r,authorized);v.port=-2;end
  else begin
    v.port=p;category=int'(r.prot[1:0])+(r.write?4:0);
    if(!r.valid || r.master>=ASD_NM) v.reason='h03;
    else if(fatal || raw_fault) v.reason='h04;
    else if(!active_cfg[p][0]) v.reason='h05;
    else if(r.prot[2] && (r.write || !active_cfg[p][1])) v.reason='h06;
    else if(!active_perm[p][r.master][category]) v.reason=r.write?'h08:'h07;
    else if(C_DFX_EN && authorized && armed!=0 && p==armed_port && r.master==armed_master)
      v.reason=armed[1]?'h04:'h41;
  end
  v.error=(v.reason!=0);v.ready=1;
  return v;
endfunction
function int unsigned apb_secure_demux_rm::read_csr(asd_request_t r,bit authorized);
  int i,p,m,w;
  register_kind_t k;
  i=reg_index(r.addr-32'(C_CSR_BASE));
  if(i<0) `uvm_fatal("RM_DECODE","read_csr called for unmapped register")
  k=REG_KIND[i];p=REG_PORT[i];m=REG_MASTER[i];w=REG_WORD[i];
  case(k)
    K_IP_ID,K_VERSION,K_CAP0,K_CAP1,K_MGMT_MASK_LO,K_MGMT_MASK_HI,K_MAP_BASE,K_MAP_LIMIT:
      return REG_RESET[i];
    K_STATUS: return {28'b0,last_valid,first_valid,global_lock,fatal};
    K_POLICY_VERSION:return policy_version;
    K_GLOBAL_LOCK:return 32'(global_lock);
    K_PORT_LOCK:return 32'(port_lock[p]);
    K_COMMIT_STATUS:return commit_status;
    K_CFG_SHADOW:return 32'(shadow_cfg[p]);
    K_CFG_ACTIVE:return 32'(active_cfg[p]);
    K_PERM_SHADOW:return 32'(shadow_perm[p][m]);
    K_PERM_ACTIVE:return 32'(active_perm[p][m]);
    K_INTR_RAW:return 32'(raw);
    K_INTR_ENABLE:return 32'(intr_enable);
    K_INTR_MASKED:return 32'(raw&intr_enable);
    K_ALERT_ENABLE:return 32'(alert_enable);
    K_FIFO_STATUS:return 32'(fifo.size())|(fifo.size()==0?'h100:0)|
        ((C_EVENT_FIFO_DEPTH!=0 && fifo.size()==C_EVENT_FIFO_DEPTH)?'h200:0)|(overflow?'h400:0);
    K_ACCESS_DENY_COUNT:return access_denies;
    K_CFG_DENY_COUNT:return cfg_denies;
    K_EVENT_LOST_COUNT:return lost;
    K_DOWNSTREAM_ERR_COUNT:return downstream_errors;
    K_INTEGRITY_STATUS:return integrity_status;
    K_FIRST_FAULT:return !first_valid?0:(w==0?first_record[31:0]:first_snapshot[w*32+:32]);
    K_LAST_FAULT:return !last_valid?0:(w==0?last_record[31:0]:last_snapshot[w*32+:32]);
    K_FIFO_HEAD:return fifo.size()==0?0:fifo[0][w*32+:32];
    K_DFX_STATUS:return {28'b0,wait_hit,armed,authorized};
    K_WAIT_THRESHOLD:return threshold;
    K_INJECT_TARGET:return target;
    K_SUCCESS_COUNT:return success[p];
    K_DENY_COUNT:return denies[p];
    K_SLVERR_COUNT:return slverrs[p];
    K_WAIT_TOTAL:return wait_total[p];
    K_WAIT_MAX:return wait_max[p];
    default: `uvm_fatal("RM_READ",$sformatf("Unmodeled readable kind %s",k.name()))
  endcase
  return 0;
endfunction
function void apb_secure_demux_rm::complete_csr(asd_request_t r,bit authorized);
  int i,p,m,fail_port,fail_reason;
  int unsigned value,mask;
  byte reason;
  bit [255:0] removed;
  register_kind_t k;
  i=reg_index(r.addr-32'(C_CSR_BASE));reason=csr_reason(r,authorized);
  if(i<0) return;
  k=REG_KIND[i];p=REG_PORT[i];m=REG_MASTER[i];value=r.data&REG_MASK[i];
  mask=(ASD_NP==32)?'1:((32'b1<<ASD_NP)-1);
  // Commit diagnostics apply after base checks even if dynamic acceptance fails.
  if(r.write && k==K_COMMIT_MASK && reason inside {0,'h15,'h16,'h17}) begin
    fail_reason=0;fail_port=-1;
    if(value==0 || (value&~mask)!=0) fail_reason=1;
    else if(global_lock) fail_reason=2;
    else begin
      foreach(port_lock[q]) if(value[q] && port_lock[q] && fail_port<0) fail_port=q;
      if(fail_port>=0) fail_reason=3;
      else if(fatal || raw_fault) fail_reason=4;
    end
    commit_status=(fail_reason==0)?1:2|(fail_reason<<4)|
                  ((fail_port<0)?0:('h2000|(fail_port<<8)));
  end
  if(reason) return;
  if(!r.write) begin
    if(k==K_FIRST_FAULT && REG_WORD[i]==0) first_snapshot=first_valid?first_record:0;
    if(k==K_LAST_FAULT && REG_WORD[i]==0) last_snapshot=last_valid?last_record:0;
    return;
  end
  case(k)
    K_GLOBAL_LOCK:global_lock|=value[0];
    K_PORT_LOCK:port_lock[p]|=value[0];
    K_CFG_SHADOW:shadow_cfg[p]=value[1:0];
    K_PERM_SHADOW:shadow_perm[p][m]=value[7:0];
    K_COMMIT_MASK,K_SHADOW_RELOAD:begin
      foreach(active_cfg[q]) if(value[q]) begin
        if(k==K_COMMIT_MASK) begin
          active_cfg[q]=shadow_cfg[q];
          for(int z=0;z<ASD_NM;z++) active_perm[q][z]=shadow_perm[q][z];
        end else begin
          shadow_cfg[q]=active_cfg[q];
          for(int z=0;z<ASD_NM;z++) shadow_perm[q][z]=active_perm[q][z];
        end
      end
      if(k==K_COMMIT_MASK) policy_version++;
    end
    K_INTR_RAW:raw&=~value[8:0];
    K_INTR_ENABLE:intr_enable=value[8:0];
    K_ALERT_ENABLE:alert_enable=value[8:0];
    K_INTR_TEST:cycle_irq[8]|=value[8];
    K_FAULT_CLEAR:begin
      if(value[0]) begin first_valid=0;first_snapshot=0;end
      if(value[1]) begin last_valid=0;last_snapshot=0;end
      if(value[2]) fifo.delete();
      if(value[3]) overflow=0;
    end
    K_FIFO_POP:if(value[0]) removed=fifo.pop_front();
    K_COUNTER_CLEAR:begin
      if(value[0]) access_denies=0;if(value[1]) cfg_denies=0;
      if(value[2]) lost=0;if(value[3]) downstream_errors=0;
    end
    K_WAIT_THRESHOLD:threshold=value;
    K_DFX_CLEAR:begin if(value[0]) wait_hit=0;if(value[1]) armed=0;end
    K_INJECT_TARGET:target=value;
    K_INJECT_CMD:begin
      if(value[0]) begin
        record_event(3,'h40,'0,0,0,-1,1,policy_version,6'b100000);
        cycle_irq[8]=1;
      end else begin armed=value[2:1];armed_port=target[4:0];armed_master=target[13:8];end
    end
    K_DFX_COUNTER_CLEAR:begin
      if(value[0]) success[p]=0;if(value[1]) denies[p]=0;if(value[2]) slverrs[p]=0;
      if(value[3]) wait_total[p]=0;if(value[4]) wait_max[p]=0;
    end
    default:`uvm_fatal("RM_WRITE",$sformatf("Unmodeled writable kind %s",k.name()))
  endcase
endfunction
function void apb_secure_demux_rm::start_cycle();
  cycle_irq=0;candidate_valid=0;foreach(candidates[c]) candidates[c]=0;
endfunction
function void apb_secure_demux_rm::observe_fault(bit active,bit data_fault,int kind,
                                               int port,int master,int bit_index);
  raw_fault=active && C_POLICY_PARITY_EN;
  if(raw_fault && !fault_observed) begin
    fault_observed=1;
    if(kind==0) global_lock=1;
    if(kind==1) port_lock[port]=1;
    if(data_fault) case(kind)
      2:active_cfg[port]^=2'(1<<bit_index);
      3:shadow_cfg[port]^=2'(1<<bit_index);
      4:active_perm[port][master]^=8'(1<<bit_index);
      5:shadow_perm[port][master]^=8'(1<<bit_index);
    endcase
  end
  if(raw_fault && !fatal) begin
    new_integrity_status=(kind<<13)|((kind>=4?master:0)<<7)|((kind==0?0:port)<<2)|3;
    record_event(0,'h30,'0,0,0,kind==0?-1:port,0,policy_version,6'b001000);
  end
endfunction
function void apb_secure_demux_rm::record_event(int priority_index,byte reason,asd_request_t r,
    bit associated,bit csr,int port,bit is_test,int unsigned version,bit [5:0] source);
  bit [255:0] rec;
  rec=0;
  if(associated) begin
    rec[31:0]=r.addr;rec[47:32]=r.master[15:0];rec[48]=r.valid;
    rec[51:49]=r.prot;rec[52]=r.write;rec[53]=1;rec[54]=csr;rec[227:224]=r.strb;
  end
  rec[55]=is_test;rec[71:64]=reason;
  if(port>=0) begin rec[76:72]=5'(port);rec[77]=1;end
  rec[85:80]=source;rec[127:96]=version;
  rec[191:128]=timestamp;rec[223:192]=event_sequence;
  if(candidate_valid[priority_index]) `uvm_fatal("RM_EVENT","Duplicate candidate in a single source")
  candidates[priority_index]=rec;candidate_valid[priority_index]=1;
endfunction
function void apb_secure_demux_rm::bus_failure(asd_request_t r,byte reason,bit csr,int port,
    bit is_test,int unsigned version);
  bit [5:0] source;
  if(reason=='h20) begin source=4;downstream_errors=sat(downstream_errors);cycle_irq[6]=1;end
  else if(csr) begin source=2;cfg_denies=sat(cfg_denies);cycle_irq[1]=1;end
  else begin
    source=1;access_denies=sat(access_denies);cycle_irq[0]=1;
    if(C_DFX_EN && port>=0) denies[port]=sat(denies[port]);
  end
  if(reason=='h01) cycle_irq[2]=1;
  if(reason=='h02) cycle_irq[3]=1;
  if(is_test) cycle_irq[8]=1;
  record_event(1,reason,r,1,csr,port,is_test,version,source);
endfunction
function void apb_secure_demux_rm::wait_cycle(asd_request_t r,int port,int unsigned waits,
    bit first_threshold,int unsigned version);
  if(!C_DFX_EN) return;
  wait_total[port]=sat(wait_total[port]);
  if(first_threshold) begin
    wait_hit=1;cycle_irq[7]=1;
    record_event(2,'h31,r,1,0,port,0,version,6'b010000);
  end
endfunction
function void apb_secure_demux_rm::target_complete(int port,bit error,int unsigned waits);
  if(!C_DFX_EN) return;
  if(error) slverrs[port]=sat(slverrs[port]);else success[port]=sat(success[port]);
  if(waits>wait_max[port]) wait_max[port]=waits;
endfunction
function void apb_secure_demux_rm::consume_injection(asd_request_t r,int port,byte reason);
  if(reason=='h41 || (reason=='h04 && !fatal && !raw_fault && armed[1])) begin
    if(armed[1]) begin
      fatal=1;integrity_status='hc003;
      record_event(0,'h30,r,1,0,port,1,policy_version,6'b001000);
      cycle_irq[4]=1;cycle_irq[8]=1;
    end
    armed=0;
  end
endfunction
function void apb_secure_demux_rm::end_cycle();
  int count,selected,losses;
  count=$countones(candidate_valid);selected=-1;losses=0;
  if(raw_fault && !fatal) begin fatal=1;integrity_status=new_integrity_status;end
  for(int c=0;c<4;c++) if(candidate_valid[c] && selected<0) selected=c;
  if(selected>=0) begin
    losses=count-1;
    if(!first_valid) begin first_valid=1;first_record=candidates[selected];end
    last_valid=1;last_record=candidates[selected];
    if(C_EVENT_FIFO_DEPTH!=0) begin
      if(fifo.size()<C_EVENT_FIFO_DEPTH) fifo.push_back(candidates[selected]);
      else begin overflow=1;losses++;end
    end
    event_sequence++;
  end
  if(losses) begin lost=sat(lost,losses);cycle_irq[5]=1;end
  if(fatal) cycle_irq[4]=1;
  raw|=cycle_irq;timestamp++;
endfunction

`endif // APB_SECURE_DEMUX_RM__SV
