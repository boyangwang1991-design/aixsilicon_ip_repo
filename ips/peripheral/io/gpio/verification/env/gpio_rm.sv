class gpio_rm extends uvm_subscriber#(apb_xaction);
 `uvm_component_utils(gpio_rm)
 logic[31:0] output_value[4];
 int width=32,transactions=0,comparisons=0;
 extern function new(string name,uvm_component parent);
 extern function void reset();
 extern function void write(apb_xaction t);
endclass
function gpio_rm::new(string name,uvm_component parent);super.new(name,parent);reset();endfunction
function void gpio_rm::reset();foreach(output_value[i]) output_value[i]=0;endfunction
function void gpio_rm::write(apb_xaction t);
 int bank,offset;logic[31:0] mask,valid_mask;
 transactions++;
 bank=(int'(t.addr)-'h100)/256;offset=int'(t.addr)&255;
 if(t.addr<'h100 || bank<0 || bank>=((width+31)/32)) return;
 valid_mask=(width-bank*32>=32)?32'hffffffff:((64'd1<<(width-bank*32))-1);
 mask=0;for(int i=0;i<4;i++) if(t.strb[i]) mask[i*8+:8]='1;
 if(t.error) return;
 if(t.write) begin
  case(offset)
   'h18:output_value[bank]=(output_value[bank]&~mask)|(t.data&mask);
   'h1c:output_value[bank]|=t.data&mask;
   'h20:output_value[bank]&=~(t.data&mask);
   'h24:output_value[bank]^=t.data&mask;
   default: ;
  endcase
  output_value[bank]&=valid_mask;
 end else if(offset=='h18) begin
  comparisons++;
  if(t.data!==output_value[bank]) `uvm_error("RM_OUT",$sformatf("bank=%0d expected=%h actual=%h",bank,output_value[bank],t.data))
 end
endfunction
