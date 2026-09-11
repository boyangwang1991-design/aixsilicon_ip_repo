`ifndef WATCHDOG_VIRTUAL_SEQUENCE__SV
`define WATCHDOG_VIRTUAL_SEQUENCE__SV

class watchdog_apb_transfer extends uvm_sequence #(apb_item);
  `uvm_object_utils(watchdog_apb_transfer)
  bit wr;bit[31:0] address,data;bit[3:0] strobe=15;bit[2:0] protection=0;
  apb_item response;
  extern function new(string name="watchdog_apb_transfer");
  extern task body();
endclass
function watchdog_apb_transfer::new(string name="watchdog_apb_transfer");super.new(name);endfunction
task watchdog_apb_transfer::body();
  apb_item req;req=apb_item::type_id::create("req");start_item(req);
  req.direction=wr?APB_WRITE:APB_READ;req.addr=address;req.wdata=data;
  req.strb=wr?strobe:0;req.prot=apb_protection'(protection);
  // Owner VIP requires edge-aligned requests and returns data in the request.
  req.start_delay=1;finish_item(req);response=req;
endtask
class watchdog_control_sequence extends uvm_sequence #(watchdog_control_item);
  `uvm_object_utils(watchdog_control_sequence)
  watchdog_control_item item;
  extern function new(string name="watchdog_control_sequence");
  extern task body();
endclass
function watchdog_control_sequence::new(string name="watchdog_control_sequence");super.new(name);endfunction
task watchdog_control_sequence::body();start_item(item);finish_item(item);endtask
class watchdog_virtual_sequence extends uvm_sequence;
  `uvm_object_utils(watchdog_virtual_sequence)
  `uvm_declare_p_sequencer(watchdog_virtual_sequencer)
  string group_name="bus";
  virtual watchdog_control_if vif;
  extern function new(string name="watchdog_virtual_sequence");
  extern task bus(bit wr,bit[31:0] address,bit[31:0] data,output bit[31:0] value,input bit[3:0] strobe=15,bit[2:0] prot=0);
  extern task write_reg(bit[31:0] address,bit[31:0] data,bit[3:0] strobe=15,bit[2:0] prot=0);
  extern task read_reg(bit[31:0] address,output bit[31:0] value);
  extern task control(watchdog_control_kind kind,int cycles=1,bit value=0,bit aux=0,int channel=0);
  extern task drain();
  extern task command(int ch,bit[31:0] offset,bit[31:0] data);
  extern task configure(int ch,config_t conf);
  extern task unlock(int ch);
  extern task snapshot(int ch);
  extern task bus_scenario();
  extern task exercise();
  extern task body();
endclass
function watchdog_virtual_sequence::new(string name="watchdog_virtual_sequence");super.new(name);endfunction
task watchdog_virtual_sequence::bus(bit wr,bit[31:0] address,bit[31:0] data,output bit[31:0] value,input bit[3:0] strobe=15,bit[2:0] prot=0);
  watchdog_apb_transfer s;s=watchdog_apb_transfer::type_id::create("transfer");
  s.wr=wr;s.address=address;s.data=data;s.strobe=strobe;s.protection=prot;s.start(p_sequencer.apb_sqr);value=s.response.rdata;
endtask
task watchdog_virtual_sequence::write_reg(bit[31:0] address,bit[31:0] data,bit[3:0] strobe=15,bit[2:0] prot=0);
  bit[31:0] ignored;bus(1,address,data,ignored,strobe,prot);
endtask
task watchdog_virtual_sequence::read_reg(bit[31:0] address,output bit[31:0] value);bus(0,address,0,value);endtask
task watchdog_virtual_sequence::control(watchdog_control_kind kind,int cycles=1,bit value=0,bit aux=0,int channel=0);
  watchdog_control_sequence s;s=watchdog_control_sequence::type_id::create("control");
  s.item=watchdog_control_item::type_id::create("control_item");s.item.kind=kind;s.item.cycles=cycles;
  s.item.value=value;s.item.aux=aux;s.item.channel=channel;s.start(p_sequencer.control_sqr);
endtask
task watchdog_virtual_sequence::drain();
  bit[31:0] status;
  for(int k=0;k<10000;k++) begin read_reg('h10,status);if(!status[0]) return;end
  `uvm_fatal("DRAIN","mailbox did not complete")
endtask
task watchdog_virtual_sequence::command(int ch,bit[31:0] offset,bit[31:0] data);
  if((offset=='h44 && data inside {1,2,3}) || offset inside {'h48,'h60,'h64}) unlock(ch);
  write_reg('h1000+ch*'h400+offset,data);drain();
endtask
task watchdog_virtual_sequence::configure(int ch,config_t conf);
  for(int k=0;k<16;k++) write_reg('h1000+ch*'h400+4*k,conf.word[k]);
  for(int c=0;c<p_sequencer.cfg.dut.clients;c++) begin
    write_reg('h1000+ch*'h400+'h140,c);
    for(int k=0;k<7;k++) write_reg('h1000+ch*'h400+'h144+4*k,conf.client[c][k]);
  end
  command(ch,'h44,1);
endtask
task watchdog_virtual_sequence::bus_scenario();
  bit[31:0] value;
  control(CTRL_POR);
  for(int k=0;k<11;k++) read_reg(4*k,value);
  for(int p=0;p<8;p++) begin
    write_reg('h1004,32'(p),15,3'(p));read_reg('h1004,value);
  end
  for(int s=0;s<15;s++) write_reg('h1004,'hfeed,4'(s));
  read_reg('h1001,value);read_reg('h7ffc,value);write_reg(0,1);
  for(int k=0;k<16;k++) read_reg('h1000+4*k,value);
  command(0,'h44,5);
  for(int k='h68;k<='h13c;k+=4) read_reg('h1000+k,value);
  control(CTRL_WAIT,20);drain();
endtask


task watchdog_virtual_sequence::unlock(int ch);
  write_reg('h1000+ch*'h400+'h40,32'hc0de1234);drain();
  write_reg('h1000+ch*'h400+'h40,32'h3f21edcb);drain();
endtask
task watchdog_virtual_sequence::snapshot(int ch);
  bit[31:0] value;command(ch,'h44,5);
  for(int k='h68;k<='h13c;k+=4) read_reg('h1000+ch*'h400+k,value);
  for(int c=0;c<p_sequencer.cfg.dut.clients;c++) begin
    write_reg('h1000+ch*'h400+'h140,c);
    for(int k='h180;k<='h1b8;k+=4) read_reg('h1000+ch*'h400+k,value);
  end
  write_reg('h1000+ch*'h400+'h140,0);
endtask
task watchdog_virtual_sequence::body();
  if(group_name=="bus") bus_scenario();else exercise();
endtask
task watchdog_virtual_sequence::exercise();
  config_t c;bit[31:0] value,answer;watchdog_control_sequence ctrl;
  c='0;c.word[4]=2000;c.word[10]=128;c.word[11]=1;c.word[12]='h3de;
  control(CTRL_POR);
  case(group_name)
    "service": begin
      for(int algorithm=0;algorithm<4;algorithm++) begin
        control(CTRL_POR);c.word[0]=32'(algorithm<<3);configure(0,c);command(0,'h44,2);
        for(int repetition=0;repetition<3;repetition++) begin
          case(algorithm)
            0:command(0,'h50,32'ha5c35a3c);
            1:begin command(0,'h50,32'ha5c35a3c);command(0,'h50,32'h5a3ca5c3);end
            2,3:begin
              snapshot(0);read_reg('h1184,answer);
              if(algorithm==3) answer={answer[24:0],answer[31:25]}^32'h6d2b79f5;
              command(0,'h50,answer);
            end
          endcase
        end
        snapshot(0);read_reg('h1090,value);
        if((algorithm<2 || p_sequencer.cfg.dut.token_support) && value!=3)
          `uvm_error("STIMULUS_GOAL",$sformatf("algorithm %0d did not complete three valid services: %0d",algorithm,value))
        command(0,'h50,32'hdeadbeef);snapshot(0);
      end
    end
    "state": begin
      c.word[0]=4;c.word[8]=80;configure(0,c);snapshot(0);command(0,'h44,2);
      command(0,'h50,32'ha5c35a3c);snapshot(0);command(0,'h44,2);command(0,'h44,3);snapshot(0);
      control(CTRL_WAIT,2100);snapshot(0);command(0,'h50,32'ha5c35a3c);snapshot(0);
    end
    "timing": begin
      for(int divider=0;divider<3;divider++) begin
        control(CTRL_POR);c.word[1]=divider;c.word[4]=32;c.word[6]=16;c.word[0]='h802;
        configure(0,c);command(0,'h44,2);control(CTRL_WAIT,110);snapshot(0);
      end
      control(CTRL_POR);c.word[1]=0;c.word[4]=2000;c.word[6]=0;c.word[0]=1;c.word[2]=1000;
      configure(0,c);command(0,'h44,2);command(0,'h50,32'ha5c35a3c);snapshot(0);
    end
    "commit": begin
      configure(0,c);snapshot(0);command(0,'h44,2);
      c.word[4]=3000;configure(0,c);snapshot(0);command(0,'h50,32'ha5c35a3c);snapshot(0);
      c.word[4]=0;configure(0,c);snapshot(0);command(0,'h44,4);snapshot(0);
    end
    "lock": begin
      write_reg('h1044,1);drain();snapshot(0);
      command(0,'h40,32'h3f21edcb);command(0,'h40,32'hc0de1234);
      control(CTRL_WAIT,33);command(0,'h40,32'h3f21edcb);snapshot(0);
      unlock(0);control(CTRL_WAIT,65);write_reg('h1044,1);drain();snapshot(0);
      for(int mask=1;mask<16;mask<<=1) begin command(0,'h48,mask);snapshot(0);end
      configure(0,c);command(0,'h44,2);snapshot(0);
    end
    "snapshot": begin
      configure(0,c);command(0,'h44,2);snapshot(0);control(CTRL_PRESET,4);
      for(int k='h68;k<='h13c;k+=4) read_reg('h1000+k,value);
      control(CTRL_CLOCKS,1,1,0);
      for(int k='h68;k<='h13c;k+=4) read_reg('h1000+k,value);
      control(CTRL_CLOCKS,1,1,1);snapshot(0);
    end
    "fault": begin
      for(int cause=0;cause<4;cause++) begin
        control(CTRL_POR);c.word[4]=(cause==0)?30:2000;configure(0,c);command(0,'h44,2);
        case(cause)
          0:control(CTRL_WAIT,35);
          1:command(0,'h50,32'hbad);
          2:command(0,'h5c,1);
          3:write_reg('h1004,0,1);
        endcase
        command(0,'h54,'hfffff);snapshot(0);command(0,'h58,'hfffff);snapshot(0);
      end
    end
    "recovery": begin
      c.word[0]='h180;c.word[14]=500;c.word[15]=2;configure(0,c);command(0,'h44,2);command(0,'h50,32'hbad);
      snapshot(0);control(CTRL_RECOVERY,1,1);control(CTRL_WAIT,10);snapshot(0);
      control(CTRL_RECOVERY,1,0);control(CTRL_WAIT,5);command(0,'h50,32'hbad);snapshot(0);
      control(CTRL_WAIT,600);snapshot(0);control(CTRL_WARM);snapshot(0);
    end
    "reset": begin
      configure(0,c);command(0,'h44,2);command(0,'h50,32'hbad);command(0,'h54,'hfffff);
      control(CTRL_PRESET,4);snapshot(0);control(CTRL_CLOCKS,1,0,1);control(CTRL_WAIT,10);
      control(CTRL_CLOCKS,1,1,1);control(CTRL_WARM);snapshot(0);control(CTRL_POR);snapshot(0);
    end
    "pause": begin
      for(int permission=0;permission<4;permission++) begin
        control(CTRL_POR);c.word[0]=32'(permission<<9);configure(0,c);command(0,'h44,2);
        control(CTRL_SLEEP,1,1);control(CTRL_WAIT,20);snapshot(0);command(0,'h50,32'ha5c35a3c);
        control(CTRL_SLEEP,1,0);control(CTRL_DEBUG,1,1,0);control(CTRL_WAIT,5);snapshot(0);
        control(CTRL_DEBUG,1,1,1);control(CTRL_WAIT,20);snapshot(0);control(CTRL_DEBUG,1,0,0);snapshot(0);
      end
    end
    "dfx","safety": begin
      for(int target=0;target<6;target++) begin
        control(CTRL_POR);configure(0,c);command(0,'h44,2);
        command(0,'h64,32'(target));control(CTRL_WAIT,4);snapshot(0);control(CTRL_WARM);snapshot(0);
      end
    end
    "hw_event": begin
      for(int path=0;path<2;path++) begin
        control(CTRL_POR);c.word[0]=32'(path<<12);configure(0,c);command(0,'h44,2);
        if(p_sequencer.cfg.dut.hw_support) begin
          ctrl=watchdog_control_sequence::type_id::create("hw");ctrl.item=watchdog_control_item::type_id::create("event");
          ctrl.item.kind=CTRL_HW_EVENT;ctrl.item.data=32'ha5c35a3c;ctrl.start(p_sequencer.control_sqr);
        end
        command(0,'h50,32'ha5c35a3c);snapshot(0);
      end
    end
    "group","alive","flow": begin
      c.word[0]=(group_name=="group")?'h20:(group_name=="alive")?'h40:'h60;
      c.word[11]=(32'b1<<p_sequencer.cfg.dut.clients)-1;
      for(int cl=0;cl<p_sequencer.cfg.dut.clients;cl++) begin
        c.client[cl][0]=0;c.client[cl][1]='h00020001;c.client[cl][2]=2;c.client[cl][3]=0;c.client[cl][5]=1200;
      end
      configure(0,c);command(0,'h44,2);
      for(int round=0;round<2;round++) for(int cl=0;cl<p_sequencer.cfg.dut.clients;cl++) begin
        if(group_name=="flow") begin
          write_reg('h104c,'h100|cl);command(0,'h50,0);
          write_reg('h104c,'h200|cl);command(0,'h50,1);
          write_reg('h104c,'h300|cl);command(0,'h50,2);
        end else begin write_reg('h104c,cl);command(0,'h50,32'ha5c35a3c);end
      end
      snapshot(0);control(CTRL_WAIT,2100);snapshot(0);
    end
    "cdc": begin
      control(CTRL_CLOCKS,1,1,0);write_reg('h1044,5);write_reg('h1044,5);
      read_reg('h10,value);control(CTRL_PRESET,4);read_reg('h10,value);
      control(CTRL_CLOCKS,1,1,1);drain();snapshot(0);
      write_reg('h1044,5);control(CTRL_WARM);drain();snapshot(0);
      for(int k=0;k<20;k++) command(0,'h44,5);
    end
    default:`uvm_fatal("SCENARIO","unimplemented testcase")
  endcase
  `uvm_info("SCENARIO_EXECUTED",group_name,UVM_NONE)
  control(CTRL_WAIT,10);drain();
endtask
`endif
