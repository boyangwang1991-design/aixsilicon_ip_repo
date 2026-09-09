// ut_apb_demux.sv - APB Demux 模块级单元测试
// 白盒验证 apb_demux_top 的译码/PSEL/响应/Decode Miss 组合行为
// 轻量 testbench（非 UVM），由 run_ut.sh 编译运行
module ut_apb_demux;

  localparam int NS = 4;
  logic pclk = 1'b0;
  logic presetn = 1'b0;
  always #5 pclk = ~pclk;

  // 上游
  logic [31:0] paddr;
  logic psel, penable, pwrite, pready, pslverr;
  logic [31:0] pwdata, prdata;
  logic [3:0] pstrb;
  logic [2:0] pprot;
  // 下游
  logic [31:0] m_paddr [NS];
  logic m_psel [NS], m_penable [NS], m_pwrite [NS];
  logic m_pready [NS], m_pslverr [NS];
  logic [31:0] m_pwdata [NS], m_prdata [NS];
  logic [3:0] m_pstrb [NS];
  logic [2:0] m_pprot [NS];

  int errors = 0;

  apb_demux_top #(
    .NUM_SLAVES(NS), .ADDR_WIDTH(32), .DATA_WIDTH(32), .APB_PROFILE(1),
    .ADDR_REMAP_ENABLE(0), .TIMEOUT_ENABLE(0), .TIMEOUT_CYCLES(16), .OUTPUT_REGISTER(0),
    .BASE_ADDR('{32'h4000_0000, 32'h4000_1000, 32'h4000_2000, 32'h4000_3000}),
    .ADDR_MASK('{32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000})
  ) u_dut (
    .pclk(pclk), .presetn(presetn),
    .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
    .pwdata(pwdata), .pstrb(pstrb), .pprot(pprot),
    .prdata(prdata), .pready(pready), .pslverr(pslverr),
    .m_paddr(m_paddr), .m_psel(m_psel), .m_penable(m_penable), .m_pwrite(m_pwrite),
    .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
    .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr)
  );

  task check(input string name, input bit cond);
    if (!cond) begin
      $display("FAIL: %s", name);
      errors++;
    end else begin
      $display("PASS: %s", name);
    end
  endtask

  // 复位
  initial begin
    paddr = '0; psel = 0; penable = 0; pwrite = 0; pwdata = '0;
    pstrb = '1; pprot = '0;
    foreach (m_prdata[i]) m_prdata[i] = '0;
    foreach (m_pready[i]) m_pready[i] = 1;
    foreach (m_pslverr[i]) m_pslverr[i] = 0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
    repeat (2) @(posedge pclk);

    // TC1: 端口 0 命中
    @(negedge pclk);
    paddr = 32'h4000_0000; psel = 1; penable = 0; pwrite = 0;
    @(posedge pclk); @(negedge pclk);
    check("TC1: M_PSEL[0]=1", m_psel[0] == 1);
    check("TC1: M_PSEL[1]=0", m_psel[1] == 0);
    begin
      int nsel;
      nsel = 0;
      foreach (m_psel[i]) if (m_psel[i]) nsel++;
      check("TC1: onehot0", nsel <= 1);
    end
    penable = 1;
    @(posedge pclk); @(negedge pclk);
    check("TC1: pready=1 (PREADY 透传)", pready == 1);
    psel = 0; penable = 0;

    // TC2: Decode Miss
    @(negedge pclk);
    paddr = 32'h5000_0000; psel = 1; penable = 0;
    @(posedge pclk); @(negedge pclk);
    begin
      bit miss_no_psel;
      miss_no_psel = 1;
      foreach (m_psel[i]) if (m_psel[i]) miss_no_psel = 0;
      check("TC2: miss -> no PSEL", miss_no_psel);
    end
    penable = 1;
    @(posedge pclk); @(negedge pclk);
    check("TC2: miss -> PSLVERR=1", pslverr == 1);
    check("TC2: miss -> PREADY=1", pready == 1);
    psel = 0; penable = 0;

    // TC3: 端口 2 命中 + PSLVERR 透传
    @(negedge pclk);
    m_pslverr[2] = 1;
    paddr = 32'h4000_2000; psel = 1; penable = 0;
    @(posedge pclk); @(negedge pclk);
    check("TC3: M_PSEL[2]=1", m_psel[2] == 1);
    penable = 1;
    @(posedge pclk); @(negedge pclk);
    check("TC3: PSLVERR 透传", pslverr == 1);
    psel = 0; penable = 0;

    // TC4: reset 期间无有效事务
    presetn = 0;
    @(posedge pclk); @(negedge pclk);
    begin
      bit rst_no_psel;
      rst_no_psel = 1;
      foreach (m_psel[i]) if (m_psel[i]) rst_no_psel = 0;
      check("TC4: reset 期间 M_PSEL=0", rst_no_psel);
    end
    presetn = 1;

    if (errors == 0)
      $display("UT_apb_demux: PASS (errors=0)");
    else
      $display("UT_apb_demux: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
