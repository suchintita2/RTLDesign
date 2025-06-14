module Mux3to1(input wire [1:0] sel, input wire [31:0] in0, in1, in2, output wire [31:0] out);
  assign out = (sel == 2'b00) ? in0 : (sel == 2'b01) ? in1 : in2;
endmodule
