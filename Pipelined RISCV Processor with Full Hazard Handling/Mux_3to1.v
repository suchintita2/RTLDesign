module Mux_3to1(
    input [31:0] a, b, c,
    input [1:0] s,
    output [31:0] out
);
    assign out = (s == 2'b00) ? a :
                 (s == 2'b01) ? b :
                 (s == 2'b10) ? c : a;
endmodule