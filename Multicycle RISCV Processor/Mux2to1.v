module Mux2to1(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire s,
    output wire [31:0] y
);
    assign y = s ? b : a;
endmodule
