module watchdog_channel #(
  parameter int CHANNEL_ID=0, COUNTER_WIDTH=32, PRESCALE_WIDTH=16,
    NUM_CLIENTS=1, SOURCE_WIDTH=4,
  parameter bit SUPPORT_TOKEN_QA=0, SUPPORT_SUPERVISION=0, SUPPORT_HW_EVENT=0,
    SAFETY_EN=0, ALLOW_RUNTIME_UPDATE=0, AUTO_START=0, NO_STOP=1,
    HARD_CFG_LOCK=0, DIAG_INJECT_EN=0,
  parameter watchdog_pkg::config_t DEFAULT_CFG=watchdog_pkg::default_config()
)(
  input logic clk, rst_n,
  input logic cmd_valid,
  input watchdog_pkg::command_t cmd,
  input watchdog_pkg::config_t cmd_config,
  input logic access_error, cdc_error,
  input logic sleep_req, debug_req, debug_auth, warm_reset_evt, recovery_done, test_auth,
  output logic [7:0] result,
  output watchdog_pkg::snapshot_t snapshot_next,
  output logic irq, active_fault, pause_ack, recovery_ack, nmi_req,
  output logic local_reset_req, system_reset_req, safe_state_req, safety_alert, wake_req
);
  import watchdog_pkg::*;
  localparam int W=COUNTER_WIDTH, P=PRESCALE_WIDTH;
  typedef struct packed {
    logic pending, flow_active, seen;
    logic [7:0] last_step;
    logic [15:0] source, alive;
    logic [31:0] seq_age, token;
    logic [W-1:0] elapsed;
  } client_t;
  typedef struct packed {
    config_t cfg, pending_cfg;
    logic cfg_pending;
    logic [31:0] version, submitted_version, pending_version;
    logic [2:0] state, resume_state;
    logic [3:0] locks;
    logic [W-1:0] count;
    logic [P-1:0] divider;
    logic prewarn, fault, local_req, final_req, ack, recovery_armed;
    logic [7:0] recoveries;
    logic [31:0] esc_age, raw, irq_mask, service_seq, fault_count;
    logic unlock_pending, credit;
    logic [15:0] unlock_source;
    logic [6:0] unlock_age, credit_age;
    logic first_valid, first_client_valid, first_source_valid, first_test;
    logic [4:0] first_client;
    logic [15:0] first_source;
    logic [31:0] first_cause, first_version, first_missing, first_service_seq;
    logic [W-1:0] first_count;
    logic [2:0] first_state;
    logic test_context;
    logic [NUM_CLIENTS-1:0][$bits(client_t)-1:0] clients;
  } state_t;
  state_t q,n;
  logic initialized;
  function automatic state_t reset_state();
    state_t r;
    r='0; r.cfg=DEFAULT_CFG;
    r.state=3'(AUTO_START ? (DEFAULT_CFG.word[0][2] ? BOOT : RUN) : DISABLED);
    r.locks={3'b0,HARD_CFG_LOCK};
    return r;
  endfunction
  client_t cq[NUM_CLIENTS],cn[NUM_CLIENTS];
  (* keep = "true", dont_touch = "true" *) logic [W-1:0] count_bar, count_bar_n;
  (* keep = "true", dont_touch = "true" *) logic [P-1:0] divider_bar, divider_bar_n;
  (* keep = "true", dont_touch = "true" *) config_t cfg_bar;
  (* keep="true", dont_touch="true" *) config_t pending_cfg_bar;
  logic control_parity;
  (* keep = "true", dont_touch = "true" *) logic [3:0] locks_bar;
  (* keep = "true", dont_touch = "true" *) logic [2:0] state_bar;
  (* keep="true", dont_touch="true" *) logic [31:0] esc_bar,esc_bar_n;
  (* keep="true", dont_touch="true" *) logic fault_bar,final_bar,clients_parity;
  (* keep="true", dont_touch="true" *) logic final_hold,final_hold_bar;
  logic final_set,shadow_final_due;
  logic inject_compare, inject_service;
  logic inject_compare_n, inject_service_n;
  config_t cfg_bar_n;
  logic [W-1:0] age, shadow_age;
  logic [31:0] events, missing, seen, ctrl;
  logic tick, shadow_tick, running, pause_sleep, pause_debug, do_refresh, do_restart;
  logic completed, accepted, timed_out, fatal, new_fault, sensitive, cmd_allowed;
  logic event_client_valid, event_source_valid, final_due;
  logic [4:0] event_client;
  logic [15:0] event_source;
  logic [W-1:0] deadline_age[NUM_CLIENTS];
  logic [63:0] threshold, window_min, pretime;
  logic [31:0] expected;
  config_t cmp_cfg;
  integer cl;
  logic [1:0] sup,mode;

  typedef struct packed {
    logic accepted, completed, refresh, restart;
  } qualification_t;
  (* keep="true", dont_touch="true" *) qualification_t protected_qualification;
  logic qualification_mismatch, qualification_error;

  // Reconstruct eligibility from protected OLD state and raw transaction inputs.
  // This path never consumes accepted/do_refresh/do_restart or next client state.
  function automatic qualification_t qualify_protected(
    input state_t old, input config_t protected_cfg, input logic [2:0] protected_state,
    input logic [W-1:0] candidate, input logic hard_fault,
    input command_t transaction, input logic valid, warm, access_bad,
    input logic recovery, ready_initialized, protected_fault, protected_final,
    input logic [31:0] protected_escalation
  );
    qualification_t v;
    client_t client_state;
    logic [31:0] causes, missing_set, limit_mask, token_expected;
    logic [63:0] limit, lower, elapsed;
    logic active, end_of_epoch, eligible, clear_sequence, partial, all_seen;
    logic deny, policy_fault, ending, sensitive_op;
    logic [1:0] supervision, algorithm;
    logic [31:0] control;
    integer selected;
    v='0; causes='0; missing_set='0;
    control=protected_cfg.word[0]; supervision=control[6:5]; algorithm=control[4:3];
    limit_mask=protected_cfg.word[11]; selected=int'(transaction.client);
    active=ready_initialized && (protected_state==3'(RUN) || protected_state==3'(BOOT));
    limit=protected_state==3'(BOOT) ? {protected_cfg.word[9],protected_cfg.word[8]} :
      {protected_cfg.word[5],protected_cfg.word[4]};
    lower=protected_state!=3'(BOOT) && control[0] ?
      {protected_cfg.word[3],protected_cfg.word[2]} : 64'b0;
    end_of_epoch=active && !(64'(candidate)<limit);
    eligible=valid && !warm && transaction.opcode==SERVICE && transaction.service_auth && active &&
      !(supervision==2 && end_of_epoch) && selected<NUM_CLIENTS;
    if(selected<NUM_CLIENTS) eligible=eligible && limit_mask[selected] &&
      !(transaction.hardware^control[12]) &&
      !(|(32'(transaction.source)^protected_cfg.client[selected][0]));
    clear_sequence=0; partial=0; all_seen=1;
    for(int i=0;i<NUM_CLIENTS;i++) begin
      client_state=client_t'(old.clients[i]);
      if(limit_mask[i]) begin
        missing_set[i]=supervision==2 ?
          client_state.alive<protected_cfg.client[i][1][15:0] : !client_state.seen;
        if(!client_state.seen && selected!=i) all_seen=0;
        if(active && supervision==3 && client_state.flow_active) begin
          elapsed=64'((&client_state.elapsed) ? client_state.elapsed : client_state.elapsed+1'b1);
          if(!(elapsed<{protected_cfg.client[i][6],protected_cfg.client[i][5]})) causes[9]=1;
        end
      end
    end
    if(end_of_epoch) begin
      if(supervision==2) begin
        if(missing_set=='0) v.refresh=1;
        else causes[6]=1;
      end else causes[1]=1;
    end
    if(access_bad) causes[10]=1;
    if(valid && !warm && transaction.opcode==SERVICE && !transaction.service_auth) causes[10]=1;
    if(valid && !warm && transaction.opcode==SERVICE && transaction.service_auth && active &&
       !(supervision==2 && end_of_epoch) && selected<NUM_CLIENTS && limit_mask[selected] &&
       ((transaction.hardware^control[12]) ||
        (|(32'(transaction.source)^protected_cfg.client[selected][0])))) causes[10]=1;
    if(eligible) begin
      client_state=client_t'(old.clients[selected]);
      elapsed=64'((&client_state.elapsed) ? client_state.elapsed : client_state.elapsed+1'b1);
      if(supervision==3) begin
        partial=(transaction.event_type==1 && transaction.data==0 &&
                 !client_state.flow_active && !client_state.seen) ||
                (transaction.event_type==2 && client_state.flow_active &&
                 transaction.data==32'(client_state.last_step)+32'd1 &&
                 transaction.data<protected_cfg.client[selected][2]);
        ending=transaction.event_type==3 && client_state.flow_active &&
          transaction.data==protected_cfg.client[selected][2] &&
          transaction.data==32'(client_state.last_step)+32'd1;
        if(ending) begin
          if(elapsed<{protected_cfg.client[selected][4],protected_cfg.client[selected][3]} ||
             !(elapsed<{protected_cfg.client[selected][6],protected_cfg.client[selected][5]})) causes[9]=1;
          else v.completed=1;
        end else if(!partial) causes[8]=1;
      end else if(transaction.event_type!=0) causes[3]=1;
      else begin
        case(algorithm)
          0: begin v.completed=!(|(transaction.data^32'ha5c35a3c)); causes[3]=!v.completed; end
          1: begin
            partial=!client_state.pending && !(|(transaction.data^32'ha5c35a3c));
            v.completed=client_state.pending && !(|(transaction.data^32'h5a3ca5c3)) &&
              !(|(client_state.source^transaction.source)) &&
              ((&client_state.seq_age) ? client_state.seq_age : client_state.seq_age+32'd1)<=protected_cfg.word[10];
            clear_sequence=client_state.pending;
            if(!partial && !v.completed) causes[3]=1;
          end
          2,3: begin
            token_expected=algorithm==2 ? client_state.token :
              ((client_state.token<<7)|(client_state.token>>25)) ^ 32'h6d2b79f5 ^
              (32'(CHANNEL_ID)<<8) ^ 32'(selected);
            v.completed=!(|(transaction.data^token_expected)); causes[3]=!v.completed;
          end
          default: causes[3]=1;
        endcase
      end
      v.accepted=partial;
      if(v.completed) begin
        if(64'(candidate)<lower) causes[2]=1;
        else if((supervision==1 || supervision==3) && client_state.seen) causes[5]=1;
        else if(supervision==2 && client_state.alive>=protected_cfg.client[selected][1][31:16]) causes[7]=1;
        else if(!end_of_epoch && !(|(causes & 32'h3fe)) && !hard_fault) begin
          v.accepted=1;
          if(supervision==0 || ((supervision==1 || supervision==3) && all_seen)) v.refresh=1;
        end
      end
    end
    // Inclusive sequence deadline; a consumed or rejected second word clears it.
    for(int i=0;i<NUM_CLIENTS;i++) begin
      client_state=client_t'(old.clients[i]);
      if(active && client_state.pending && !(eligible && selected==i && clear_sequence) &&
         ((&client_state.seq_age) ? client_state.seq_age : client_state.seq_age+32'd1)>=protected_cfg.word[10])
        causes[4]=1;
    end
    sensitive_op=transaction.opcode==COMMIT || transaction.opcode==START ||
      transaction.opcode==STOP || transaction.opcode==LOCK_SET ||
      transaction.opcode==DIAG_CLEAR || transaction.opcode==INJECT;
    deny=!transaction.cfg_auth;
    if(transaction.opcode==IRQ_CLEAR || transaction.opcode==IRQ_TEST ||
       transaction.opcode==DIAG_CLEAR || transaction.opcode==INJECT) deny=!transaction.diag_auth;
    if(valid && !warm && transaction.opcode!=SERVICE && transaction.opcode!=SNAPSHOT && deny) causes[10]=1;
    policy_fault=|(causes & protected_cfg.word[12]);
    ending=protected_fault && !protected_final &&
      ((&protected_escalation) || protected_escalation+32'd1>=protected_cfg.word[14]);
    if(!hard_fault && !policy_fault && !ending) begin
      v.restart=(warm && protected_state!=3'(DISABLED)) ||
        (valid && !warm && transaction.opcode==START && !deny && sensitive_op &&
         old.credit && old.credit_age<63 && transaction.source==old.unlock_source &&
         protected_state==3'(DISABLED)) ||
        (!warm && protected_state==3'(FAULT) && old.local_req && control[7] && control[8] &&
         recovery && old.recovery_armed && !old.ack && old.recoveries<protected_cfg.word[15][7:0]);
    end else begin v.refresh=0; v.restart=0; end
    return v;
  endfunction

  if(W!=32 && W!=48 && W!=64) begin : g_bad_w
    $error("COUNTER_WIDTH must be 32, 48 or 64");
  end
  if(P<1 || P>16 || NUM_CLIENTS<1 || NUM_CLIENTS>32 || SOURCE_WIDTH<1 || SOURCE_WIDTH>16) begin : g_bad_p
    $error("Invalid watchdog channel parameters");
  end
  if(validate_config(DEFAULT_CFG,W,P,NUM_CLIENTS,SOURCE_WIDTH,SUPPORT_TOKEN_QA,
     SUPPORT_SUPERVISION,SUPPORT_HW_EVENT,SAFETY_EN)!=OK) begin : g_bad_default
    $error("DEFAULT_CFG is invalid");
  end

  always_comb begin
    n=q;
    count_bar_n=count_bar; divider_bar_n=divider_bar; cfg_bar_n=cfg_bar;
    inject_compare_n=0; inject_service_n=0; esc_bar_n=esc_bar;
    for(int i=0;i<NUM_CLIENTS;i++) begin
      cq[i]=client_t'(q.clients[i]); cn[i]=cq[i];
      deadline_age[i]=(&cq[i].elapsed) ? cq[i].elapsed : cq[i].elapsed+1'b1;
    end
    ctrl=q.cfg.word[0]; sup=ctrl[6:5]; mode=ctrl[4:3];
    running=initialized && (q.state==RUN || q.state==BOOT);
    pause_sleep=sleep_req && ctrl[9];
    pause_debug=debug_req && debug_auth && ctrl[10] && !q.locks[2];
    tick=(q.divider==P'(q.cfg.word[1]));
    shadow_tick=((~divider_bar)==P'(~cfg_bar.word[1]));
    age=q.count; shadow_age=~count_bar;
    if(running) begin
      if(tick && !(&q.count)) age=q.count+1'b1;
      if(shadow_tick && !(&shadow_age)) shadow_age=shadow_age+1'b1;
      n.count=age; n.divider=tick ? '0 : q.divider+1'b1;
      count_bar_n=~shadow_age;
      divider_bar_n=shadow_tick ? '1 : divider_bar-1'b1;
    end
    threshold=(q.state==BOOT) ? {q.cfg.word[9],q.cfg.word[8]} : {q.cfg.word[5],q.cfg.word[4]};
    window_min=(q.state==BOOT || !ctrl[0]) ? 0 : {q.cfg.word[3],q.cfg.word[2]};
    pretime={q.cfg.word[7],q.cfg.word[6]};
    events=0; missing=0; seen=0; result=OK;
    do_refresh=0; do_restart=0; completed=0; accepted=0;
    fatal=0; new_fault=0; timed_out=0; cmd_allowed=cmd_valid && !warm_reset_evt;
    sensitive=cmd.opcode==COMMIT || cmd.opcode==START || cmd.opcode==STOP ||
      cmd.opcode==LOCK_SET || cmd.opcode==DIAG_CLEAR || cmd.opcode==INJECT;
    event_client_valid=0; event_source_valid=0; event_client=cmd.client; event_source=cmd.source;
    final_due=q.fault && !q.final_req && sat32(q.esc_age)>=q.cfg.word[14];
    cl=int'(cmd.client); expected=0; cmp_cfg=cmd_config;
    for(int i=0;i<NUM_CLIENTS;i++) begin
      if(cq[i].seen) seen[i]=1;
      if(q.cfg.word[11][i]) begin
        missing[i]=(sup==2) ? (cq[i].alive<q.cfg.client[i][1][15:0]) : !cq[i].seen;
        if(running) begin
          if(cq[i].pending) cn[i].seq_age=sat32(cq[i].seq_age);
          if(sup==3 && cq[i].flow_active) begin
            cn[i].elapsed=deadline_age[i];
            if(64'(deadline_age[i])>={q.cfg.client[i][6],q.cfg.client[i][5]}) begin
              events[9]=1; event_client_valid=1; event_client=5'(i);
            end
          end
        end
      end
    end
    if(sup==0) missing=1;
    if(access_error) events[10]=1;
    if(q.unlock_pending) begin
      n.unlock_age=q.unlock_age+1'b1;
      if(q.unlock_age>=31) n.unlock_pending=0;
    end
    if(q.credit) begin
      n.credit_age=q.credit_age+1'b1;
      if(q.credit_age>=63) n.credit=0;
    end
    if(!recovery_done) begin n.ack=0; n.recovery_armed=1; end

    if(SAFETY_EN) begin
      if(q.cfg!=~cfg_bar || q.locks!=~locks_bar ||
         (q.cfg_pending && q.pending_cfg!=~pending_cfg_bar)) events[11]=1;
      if((^{q.cfg_pending,q.credit,q.unlock_pending,q.unlock_age,q.credit_age,q.unlock_source,
            q.version,q.submitted_version,q.pending_version,q.resume_state,initialized,
            q.recoveries,q.recovery_armed,q.ack})!=control_parity)
        events[14]=1;
      if(q.count!=~count_bar || q.divider!=~divider_bar || tick!=shadow_tick) events[12]=1;
      if(q.state!=~state_bar || q.state>RESET_PENDING) events[13]=1;
      // The complete qualifier mismatch is retained; all client bits are protected.
      if((^q.clients)!=clients_parity || qualification_error) events[14]=1;
      if(q.fault!=~fault_bar || q.final_req!=~final_bar || q.esc_age!=~esc_bar) events[13]=1;
      if(final_hold==final_hold_bar) events[13]=1;
      if(running && (64'(age)<window_min) != (64'(shadow_age)<window_min)) events[12]=1;
      if(q.fault && !q.final_req &&
         ((sat32(q.esc_age)>=q.cfg.word[14]) !=
          ((~esc_bar)==32'hffffffff || ((~esc_bar)+32'b1)>=(~cfg_bar.word[14])))) events[12]=1;
      if(cdc_error) events[17]=1;
      if(running && (((64'(age)>=threshold)^inject_compare) !=
          (64'(shadow_age)>=((q.state==BOOT) ? {~cfg_bar.word[9],~cfg_bar.word[8]} :
           {~cfg_bar.word[5],~cfg_bar.word[4]})))) events[12]=1;
    end else if(q.state>RESET_PENDING) events[13]=1;
    if(running && 64'(age)>=threshold) begin
      timed_out=1;
      if(sup==2) begin
        if(missing==0) do_refresh=1;
        else events[6]=1;
      end else events[1]=1;
    end

    if(cmd_valid && warm_reset_evt) result=CANCELED_RESET;
    if(cmd_allowed) begin
      // Authorization is checked again in the authoritative clock domain.
      if(cmd.opcode==SERVICE ? !cmd.service_auth :
        ((cmd.opcode==IRQ_CLEAR || cmd.opcode==IRQ_TEST || cmd.opcode==DIAG_CLEAR || cmd.opcode==INJECT)
        ? !cmd.diag_auth : !cmd.cfg_auth)) begin
        if(cmd.opcode!=SNAPSHOT) begin result=ACCESS_DENIED; cmd_allowed=0; events[10]=1; end
      end
      if(sensitive) begin
        n.credit=0;
        if(!q.credit || q.credit_age>=63 || cmd.source!=q.unlock_source) begin
          result=EXPIRED_UNLOCK; cmd_allowed=0;
        end
      end
    end
    if(cmd_allowed) begin
      case(cmd.opcode)
        UNLOCK: begin
          if(cmd.data==UNLOCK1) begin
            n.unlock_pending=1; n.unlock_age=0; n.unlock_source=cmd.source; n.credit=0;
          end else if(cmd.data==UNLOCK2 && q.unlock_pending && q.unlock_age<32 &&
                      cmd.source==q.unlock_source) begin
            n.unlock_pending=0; n.credit=1; n.credit_age=0;
          end else begin n.unlock_pending=0; n.credit=0; result=ACCESS_DENIED; end
        end
        COMMIT: begin
          result=validate_config(cmd_config,W,P,NUM_CLIENTS,SOURCE_WIDTH,SUPPORT_TOKEN_QA,
            SUPPORT_SUPERVISION,SUPPORT_HW_EVENT,SAFETY_EN);
          if(q.locks[0]) result=LOCKED;
          else if(q.cfg_pending) result=BUSY;
          else if(q.state!=DISABLED && !(q.state==RUN && ALLOW_RUNTIME_UPDATE)) result=BAD_STATE;
          else if(q.state==RUN && result==OK) begin
            cmp_cfg.word[1]=q.cfg.word[1];
            for(int k=2;k<=7;k++) cmp_cfg.word[k]=q.cfg.word[k];
            if(cmp_cfg!=q.cfg) result=BAD_CONFIG;
          end
          if(result==OK) begin
            n.submitted_version=q.submitted_version+1'b1;
            if(q.state==DISABLED) begin
              n.cfg=cmd_config; cfg_bar_n=~cmd_config; n.version=n.submitted_version;
            end else begin
              n.pending_cfg=cmd_config; n.pending_version=n.submitted_version;
              n.cfg_pending=1; result=PENDING_APPLY;
            end
          end else if(result==BAD_CONFIG || result==UNSUPPORTED) events[18]=1;
        end
        START: begin
          if(q.state!=DISABLED) result=BAD_STATE;
          else do_restart=1;
        end
        STOP: begin
          if(NO_STOP || q.locks[1]) result=LOCKED;
          else if(!running) result=BAD_STATE;
          else begin
            n.state=DISABLED;
            for(int i=0;i<NUM_CLIENTS;i++) begin cn[i].pending=0; cn[i].flow_active=0; end
          end
        end
        CANCEL: begin
          if(!q.cfg_pending) result=NO_PENDING;
          else n.cfg_pending=0;
        end
        LOCK_SET: n.locks=q.locks | cmd.data[3:0];
        IRQ_ENABLE: n.irq_mask=cmd.data & 32'h7ffff;
        IRQ_CLEAR: n.raw=q.raw & ~cmd.data;
        IRQ_TEST: if(cmd.data[0]) events[15]=1;
        DIAG_CLEAR: begin
          if(q.fault) result=BAD_STATE;
          else begin
            if(cmd.data[0]) n.first_valid=0;
            if(cmd.data[1]) n.fault_count=0;
          end
        end
        INJECT: begin
          if(!SAFETY_EN || !DIAG_INJECT_EN) result=UNSUPPORTED;
          else if(q.locks[3]) result=LOCKED;
          else if(!test_auth || !cmd.cfg_auth) result=ACCESS_DENIED;
          else begin
            case(cmd.data[3:0])
              0: if(int'(cmd.data[9:4])<W) n.count=n.count ^ (W'(1)<<cmd.data[9:4]); else result=BAD_CONFIG;
              1: if(int'(cmd.data[9:4])<P) n.divider=n.divider ^ (P'(1)<<cmd.data[9:4]); else result=BAD_CONFIG;
              2: if(int'(cmd.data[9:4])<W) begin
                   if(cmd.data[9:4]<32) cfg_bar_n.word[4]=cfg_bar.word[4] ^ (32'b1<<cmd.data[9:4]);
                   else cfg_bar_n.word[5]=cfg_bar.word[5] ^ (32'b1<<(cmd.data[9:4]-32));
                 end else result=BAD_CONFIG;
              3: if(cmd.data[9:4]==0) n.state=7; else result=BAD_CONFIG;
              4: if(cmd.data[9:4]==0) inject_compare_n=1; else result=BAD_CONFIG;
              5: if(cmd.data[9:4]==0) inject_service_n=1; else result=BAD_CONFIG;
              default: result=BAD_CONFIG;
            endcase
            if(result==OK) n.test_context=1;
          end
        end
        SERVICE: begin
          if(q.state==PAUSED_STATE) result=PAUSED;
          else if(!running) result=BAD_STATE;
          else if(sup==2 && timed_out) result=EPOCH_BOUNDARY;
          else if(cl>=NUM_CLIENTS || !q.cfg.word[11][cl]) result=BAD_CLIENT;
          else if(cmd.hardware!=ctrl[12] || 32'(cmd.source)!=q.cfg.client[cl][0]) begin
            result=ACCESS_DENIED; events[10]=1;
          end else begin
            event_client_valid=1; event_source_valid=1;
            if(sup==3) begin
              if(cmd.event_type==1 && cmd.data==0 && !cq[cl].flow_active && !cq[cl].seen) begin
                cn[cl].flow_active=1; cn[cl].last_step=0; cn[cl].elapsed=0; accepted=1;
              end else if(cmd.event_type==2 && cq[cl].flow_active &&
                  cmd.data==32'(cq[cl].last_step)+1 && cmd.data<q.cfg.client[cl][2]) begin
                cn[cl].last_step=cmd.data[7:0]; accepted=1;
              end else if(cmd.event_type==3 && cq[cl].flow_active &&
                  cmd.data==q.cfg.client[cl][2] && cmd.data==32'(cq[cl].last_step)+1) begin
                if(64'(deadline_age[cl])<{q.cfg.client[cl][4],q.cfg.client[cl][3]} ||
                   64'(deadline_age[cl])>={q.cfg.client[cl][6],q.cfg.client[cl][5]}) events[9]=1;
                else completed=1;
              end else events[8]=1;
            end else if(cmd.event_type!=0) events[3]=1;
            else case(mode)
              0: if(cmd.data==KEY1) completed=1; else events[3]=1;
              1: begin
                if(!cq[cl].pending && cmd.data==KEY1) begin
                  cn[cl].pending=1; cn[cl].seq_age=0; cn[cl].source=cmd.source; accepted=1;
                end else if(cq[cl].pending && cmd.data==KEY2 && cq[cl].source==cmd.source &&
                   sat32(cq[cl].seq_age)<=q.cfg.word[10]) begin
                  completed=1; cn[cl].pending=0;
                end else begin events[3]=1; cn[cl].pending=0; end
              end
              2,3: begin
                expected=(mode==2) ? cq[cl].token : response(cq[cl].token,CHANNEL_ID,cl);
                if(cmd.data==expected) completed=1; else events[3]=1;
              end
            endcase
            if(completed) begin
              if(64'(age)<window_min) events[2]=1;
              else if((sup==1 || sup==3) && cq[cl].seen) events[5]=1;
              else if(sup==2 && cq[cl].alive>=q.cfg.client[cl][1][31:16]) events[7]=1;
              else if(!timed_out && (events & (32'h3fe | FATAL_MASK))==0) begin
                accepted=1;
                n.service_seq=q.service_seq+1'b1;
                if(mode>=2) cn[cl].token=next_token(cq[cl].token);
                if(sup==2) cn[cl].alive=(&cq[cl].alive) ? cq[cl].alive : cq[cl].alive+1'b1;
                else if(sup==0) do_refresh=1;
                else begin
                  cn[cl].seen=1; cn[cl].flow_active=0;
                  if(((seen | (32'b1<<cl)) & q.cfg.word[11])==q.cfg.word[11]) do_refresh=1;
                end
              end
            end
            if(!accepted) result=BAD_SERVICE;
          end
        end
        SNAPSHOT: result=OK;
        default: result=BAD_CONFIG;
      endcase
    end
    // Sequence expiry is independent of bus traffic; inclusive second-word edge.
    for(int i=0;i<NUM_CLIENTS;i++) begin
      if(running && cq[i].pending && cn[i].pending && sat32(cq[i].seq_age)>=q.cfg.word[10]) begin
        events[4]=1; cn[i].pending=0; event_client_valid=1; event_client=5'(i);
        event_source_valid=0;
      end
    end
    fatal=|(events & FATAL_MASK);
    new_fault=|(events & q.cfg.word[12]) || fatal;
    if(q.fault) begin
      n.esc_age=sat32(q.esc_age); esc_bar_n=~sat32(~esc_bar);
      if(n.esc_age>=q.cfg.word[13]) n.local_req=ctrl[7];
      if(final_due) begin n.final_req=1; n.state=RESET_PENDING; end
    end
    if(fatal || final_due || new_fault) begin
      do_refresh=0; do_restart=0;
      if(cmd_valid && (cmd.opcode==START || cmd.opcode==STOP || cmd.opcode==COMMIT || cmd.opcode==SERVICE))
        result=CANCELED_FAULT;
      n.cfg=q.cfg; cfg_bar_n=cfg_bar; n.version=q.version;
      n.cfg_pending=0;
      // Failed commands/partial client activity never affect the fault snapshot.
      for(int i=0;i<NUM_CLIENTS;i++) begin cn[i]=cq[i]; cn[i].pending=0; end
      n.service_seq=q.service_seq;
      n.fault=1;
      if(!q.fault) begin
        n.esc_age=0; esc_bar_n='1; n.fault_count=sat32(q.fault_count);
        n.state=FAULT;
        n.local_req=ctrl[7] && q.cfg.word[13]==0;
      end
      if(fatal || final_due || !ctrl[7]) begin n.final_req=1; n.state=RESET_PENDING; end
      if(!q.first_valid && new_fault) begin
        n.first_valid=1; n.first_cause=events; n.first_count=age; n.first_state=q.state;
        n.first_version=q.version; n.first_missing=missing; n.first_service_seq=q.service_seq;
        n.first_client=event_client; n.first_source=event_source;
        n.first_client_valid=event_client_valid && !events[1] && !events[6];
        n.first_source_valid=event_source_valid && !events[1] && !events[6];
        n.first_test=q.test_context;
      end
    end else if(warm_reset_evt) begin
      n.cfg_pending=0; n.recoveries=0; n.fault=0; n.local_req=0; n.final_req=0;
      n.esc_age=0; esc_bar_n='1; n.credit=0; n.unlock_pending=0;
      if(q.state!=DISABLED) do_restart=1;
    end else if(q.state==FAULT && q.local_req && ctrl[7] && ctrl[8] &&
                recovery_done && q.recovery_armed && !q.ack) begin
      n.ack=1; n.recovery_armed=0;
      if(q.recoveries>=q.cfg.word[15][7:0]) begin
        events[16]=1; n.final_req=1; n.state=RESET_PENDING;
      end else begin
        n.recoveries=q.recoveries+1'b1;
        n.fault=0; n.local_req=0; n.esc_age=0; esc_bar_n='1; n.cfg_pending=0;
        do_restart=1;
      end
    end
    if(do_restart || do_refresh) begin
      n.count=0; n.divider=0; n.prewarn=0;
      n.state=(do_restart && n.cfg.word[0][2]) ? BOOT : RUN;
      if(do_refresh && q.cfg_pending) begin
        n.cfg=q.pending_cfg; cfg_bar_n=~q.pending_cfg;
        n.version=q.pending_version; n.cfg_pending=0;
      end
      for(int i=0;i<NUM_CLIENTS;i++) begin
        cn[i].pending=0; cn[i].seq_age=0; cn[i].alive=0; cn[i].seen=0;
        cn[i].flow_active=0; cn[i].last_step=0; cn[i].elapsed=0;
        if(do_restart) cn[i].token=seed(CHANNEL_ID,i);
      end
    end else if(!n.fault) begin
      if(running && n.state!=DISABLED && (pause_sleep || pause_debug)) begin
        n.resume_state=q.state; n.state=PAUSED_STATE;
      end else if(q.state==PAUSED_STATE && !(pause_sleep || pause_debug)) n.state=q.resume_state;
      if(q.state==RUN && ctrl[1] && !q.prewarn && 64'(age)>=pretime &&
        (sup!=2 || missing!=0)) begin n.prewarn=1; events[0]=1; end
    end
    if(!initialized) begin
      for(int i=0;i<NUM_CLIENTS;i++) cn[i].token=seed(CHANNEL_ID,i);
    end
    n.raw=n.raw | events;
    for(int i=0;i<NUM_CLIENTS;i++) n.clients[i]=cn[i];

    protected_qualification=qualify_protected(q,~cfg_bar,~state_bar,shadow_age,
      |(events & FATAL_MASK),cmd,cmd_valid,warm_reset_evt,access_error,recovery_done,
      initialized,~fault_bar,~final_bar,~esc_bar);
    // Each timebase clears from its own qualified intent, never from a common
    // unverified refresh wire. A mismatch reaches independent final storage now
    // and the sticky diagnostic event on the next edge (within the 2-cycle bound).
    if(SAFETY_EN ? (protected_qualification.refresh || protected_qualification.restart) :
                  (do_refresh || do_restart)) begin
      count_bar_n='1; divider_bar_n='1;
    end

    // Atomic post-update image; all reads in APB subsequently use the held copy.
    snapshot_next='0;
    snapshot_next.word['h70/4]=32'(n.state) | (32'(n.fault)<<3) | (32'(n.prewarn)<<4) |
      (32'(n.cfg_pending)<<5) | (32'(n.credit)<<6) | (32'(&n.fault_count)<<7) |
      (32'(n.locks)<<8) | (32'(n.state==PAUSED_STATE && pause_sleep)<<12) |
      (32'(n.state==PAUSED_STATE && pause_debug)<<13);
    snapshot_next.word['h74/4]=n.version;
    {snapshot_next.word['h7c/4],snapshot_next.word['h78/4]}=64'(n.count);
    snapshot_next.word['h80/4]=n.raw; snapshot_next.word['h84/4]=n.irq_mask;
    snapshot_next.word['h90/4]=n.service_seq; snapshot_next.word['h94/4]=n.fault_count;
    snapshot_next.word['h98/4]=32'(n.recoveries); snapshot_next.word['h9c/4]=n.esc_age;
    if(n.first_valid) begin
      snapshot_next.word['ha0/4]=1 | (32'(n.first_client_valid)<<1) |
        (32'(n.first_source_valid)<<2) | (32'(n.first_test)<<3) | (32'(CHANNEL_ID)<<8) |
        (32'(n.first_client)<<12) | (32'(primary_cause(n.first_cause))<<17);
      snapshot_next.word['ha4/4]=n.first_cause;
      {snapshot_next.word['hac/4],snapshot_next.word['ha8/4]}=64'(n.first_count);
      snapshot_next.word['hb0/4]=32'(n.first_source); snapshot_next.word['hb4/4]=n.first_version;
      snapshot_next.word['hb8/4]=n.first_missing; snapshot_next.word['hbc/4]=n.first_service_seq;
      snapshot_next.word['hc0/4]=32'(n.first_state);
    end
    for(int k=0;k<16;k++) snapshot_next.word['h100/4+k]=n.cfg.word[k];
    for(int i=0;i<NUM_CLIENTS;i++) begin
      if(n.cfg.word[0][6:5]==1 || n.cfg.word[0][6:5]==3)
        snapshot_next.word['h88/4][i]=cn[i].seen;
      snapshot_next.word['h8c/4][i]=n.cfg.word[11][i] && ((n.cfg.word[0][6:5]==2) ?
        cn[i].alive<n.cfg.client[i][1][15:0] : !cn[i].seen);
      snapshot_next.client[i][0]=32'(n.cfg.word[11][i]) | (32'(cn[i].seen)<<1) |
        (32'(cn[i].pending)<<2) | (32'(cn[i].flow_active)<<3) | (32'(cn[i].last_step)<<8);
      snapshot_next.client[i][1]=(SUPPORT_TOKEN_QA && n.cfg.word[0][4:3]>=2) ? cn[i].token : 0;
      snapshot_next.client[i][2]=32'(cn[i].alive);
      if(n.cfg.word[0][6:5]==3)
        {snapshot_next.client[i][4],snapshot_next.client[i][3]}=64'(cn[i].elapsed);
      for(int k=0;k<7;k++) snapshot_next.client[i][8+k]=n.cfg.client[i][k];
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      q<=reset_state(); initialized<=0; qualification_error<=0;
      count_bar<='1; divider_bar<='1; cfg_bar<=~DEFAULT_CFG;
      locks_bar<=~{3'b0,HARD_CFG_LOCK};
      state_bar<=~(3'(AUTO_START ? (DEFAULT_CFG.word[0][2] ? BOOT : RUN) : DISABLED));
      pending_cfg_bar<='1; control_parity<=0;
      inject_compare<=0; inject_service<=0; esc_bar<='1; fault_bar<=1; final_bar<=1; clients_parity<=0;
    end else begin
      initialized<=1; qualification_error<=qualification_mismatch; q<=n; count_bar<=count_bar_n; divider_bar<=divider_bar_n;
      cfg_bar<=cfg_bar_n; locks_bar<=~n.locks; state_bar<=~n.state;
      if(n.cfg_pending && !q.cfg_pending) pending_cfg_bar<=~cmd_config;
      control_parity<=^{n.cfg_pending,n.credit,n.unlock_pending,n.unlock_age,n.credit_age,n.unlock_source,
        n.version,n.submitted_version,n.pending_version,n.resume_state,1'b1,
        n.recoveries,n.recovery_armed,n.ack};
      esc_bar<=esc_bar_n; fault_bar<=~n.fault; final_bar<=~n.final_req; clients_parity<=^n.clients;
      inject_compare<=inject_compare_n; inject_service<=inject_service_n;
    end
  end
  // Independent set-dominant request storage. Neither next-state mux nor q.final_req
  // drives this latch. Complement storage evolves independently from its old value.
  assign qualification_mismatch=SAFETY_EN &&
    ((accepted ^ inject_service)!=protected_qualification.accepted ||
     completed!=protected_qualification.completed ||
     do_refresh!=protected_qualification.refresh || do_restart!=protected_qualification.restart);
  assign shadow_final_due=SAFETY_EN && !fault_bar && final_bar &&
    ((~esc_bar)==32'hffffffff || ((~esc_bar)+32'b1)>=(~cfg_bar.word[14]));
  assign final_set=qualification_mismatch || |(events & FATAL_MASK) || final_due || shadow_final_due ||
    (new_fault && !q.cfg.word[0][7]) || events[16];
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin final_hold<=0; final_hold_bar<=1; end
    else begin
      final_hold<=final_set || (final_hold && !warm_reset_evt);
      final_hold_bar<=!final_set && (final_hold_bar || warm_reset_evt);
    end
  end
  assign active_fault=q.fault;
  assign irq=|(q.raw & q.irq_mask);
  assign pause_ack=q.state==PAUSED_STATE;
  assign recovery_ack=q.ack;
  assign nmi_req=q.fault;
  assign local_reset_req=q.local_req;
  assign system_reset_req=q.final_req || final_hold;
  assign safe_state_req=q.final_req || final_hold;
  assign safety_alert=q.fault || final_hold;
  assign wake_req=(q.raw[0] && q.cfg.word[0][11]) || q.fault;
endmodule
