module Forwarding_Unit(
    input [4:0] Rs1_E, Rs2_E, Rd_M, Rd_W,
    input RegWrite_M, RegWrite_W,
    output [1:0] ForwardA_E, ForwardB_E
);
    // Forward A logic
    assign ForwardA_E = ((RegWrite_M & (Rd_M != 5'b0) & (Rd_M == Rs1_E)) ? 2'b10 :
                        ((RegWrite_W & (Rd_W != 5'b0) & (Rd_W == Rs1_E)) ? 2'b01 : 2'b00));
    // Forward B logic
    assign ForwardB_E = ((RegWrite_M & (Rd_M != 5'b0) & (Rd_M == Rs2_E)) ? 2'b10 :
                        ((RegWrite_W & (Rd_W != 5'b0) & (Rd_W == Rs2_E)) ? 2'b01 : 2'b00));
endmodule