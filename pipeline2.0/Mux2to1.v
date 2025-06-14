module Mux2to1(input wire sel, input wire [31:0] in0, in1, output wire [31:0] out);
  assign out = sel ? in1 : in0;
endmodule
