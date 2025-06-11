module Mux3to1(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [1:0] s,
    output wire [31:0] y
);
    assign y = (s == 2'b00) ? a :
               (s == 2'b01) ? b :
               (s == 2'b10) ? c : a;
endmodule
