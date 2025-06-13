module Mux3to1(input [31:0] a, b, c, input [1:0] s, output reg [31:0] y);
    always @(*) begin
        case(s)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            default: y = 32'b0;
        endcase
    end
endmodule
