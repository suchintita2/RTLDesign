module f_low(input s1, sclk, s2, PCLK, PRESETn, output reg y);

  wire a,b,c;
  reg d;

  assign a = s1? 1'b1 : 1'b0;
  assign b = sclk? 1'b0 : a;
  assign c = s2? y : b;
  always@(posedge PClk)
    d<=c;
  assign y = PRESETn? d:1'b0;

endmodule
