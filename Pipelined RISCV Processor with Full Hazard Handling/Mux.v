module Mux(
    input [31:0] a, b,
    input s,
    output [31:0] c
);
    assign c = s ? b : a;
endmodule
