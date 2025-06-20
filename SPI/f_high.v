module f_high(input s1, sclk, s2, PCLK, PRESETn, output y);

  wire a,b,c;
  reg d;

  assign a = s1? 1'b1 : 1'b0;
  assign b = sclk? a : 1'b0;
  assign c = s2? b : y;
  always@(posedge PClk)
    d<=c;
  assign y = PRESETn? d:1'b0;

endmodule
