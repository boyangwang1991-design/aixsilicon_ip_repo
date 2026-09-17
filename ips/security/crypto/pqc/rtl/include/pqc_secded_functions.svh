// Module-scope shared SECDED(39,32) functions; intentionally no global include guard.
  localparam int unsigned SECDED_BITS = 39;   // 32 data + 6 Hamming + 1 overall
  localparam int unsigned SECDED_HAM  = 38;   // positions 1..38 carry the code

  // A bit position (1-based) carries data when it is not a power of two; the
  // power-of-two positions 1,2,4,8,16,32 carry the Hamming parity bits and
  // position 39 carries the overall parity bit.
  function automatic logic secded_is_data(input int unsigned p);
    return ((p <= SECDED_HAM) && ((p & (p - 1)) != 0));
  endfunction

  function automatic logic [SECDED_BITS-1:0] secded_enc(input logic [31:0] d);
    logic [SECDED_BITS-1:0] c;
    int di;
    c  = '0;
    di = 0;
    for (int p = 1; p <= SECDED_HAM; p++) begin
      if (secded_is_data(p)) begin
        c[p-1] = d[di];
        di++;
      end
    end
    for (int k = 0; k < 6; k++) begin
      logic x;
      x = 1'b0;
      for (int p = 1; p <= SECDED_HAM; p++) if (p & (1 << k)) x ^= c[p-1];
      c[(1 << k)-1] = x;
    end
    c[SECDED_BITS-1] = ^c[SECDED_HAM-1:0];
    return c;
  endfunction

  function automatic logic [5:0] secded_syn(input logic [SECDED_BITS-1:0] c);
    logic [5:0] s;
    s = 6'h0;
    for (int k = 0; k < 6; k++) begin
      logic x;
      x = 1'b0;
      for (int p = 1; p <= SECDED_HAM; p++) if (p & (1 << k)) x ^= c[p-1];
      s[k] = x;
    end
    return s;
  endfunction

  function automatic logic [31:0] secded_data(input logic [SECDED_BITS-1:0] c);
    logic [31:0] d;
    int di;
    d  = '0;
    di = 0;
    for (int p = 1; p <= SECDED_BITS; p++) begin
      if (((p & (p - 1)) != 0) && (di < 32)) begin
        d[di] = c[p-1];
        di++;
      end
    end
    return d;
  endfunction

  function automatic logic [31:0] secded_corr(input logic [SECDED_BITS-1:0] c,
                                              input logic [5:0] syn);
    logic [SECDED_BITS-1:0] f;
    f = c;
    if ((syn != 6'h0) && (syn <= 6'(SECDED_HAM))) f[syn-1] = ~f[syn-1];
    return secded_data(f);
  endfunction

