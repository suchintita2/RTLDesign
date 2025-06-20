module Main_Decoder(
    input  [6:0] Op,
    output       RegWrite,
    output [1:0] ImmSrc,
    output       ALUSrc,
    output       MemWrite,
    output [1:0] ResultSrc,
    output       Branch,
    output [1:0] ALUOp
);
    assign RegWrite  = (Op == 7'b0000011) || // Load
                       (Op == 7'b0110011) || // R-type
                       (Op == 7'b0010011) || // I-type
                       (Op == 7'b1101111);   // JAL

    assign ImmSrc    = (Op == 7'b0100011) ? 2'b01 : // Store
                       (Op == 7'b1100011) ? 2'b10 : // Branch
                       2'b00;                       // I-type default

    assign ALUSrc    = (Op == 7'b0000011) || // Load
                       (Op == 7'b0100011) || // Store
                       (Op == 7'b0010011);   // I-type

    assign MemWrite  = (Op == 7'b0100011);   // Store

    assign ResultSrc = (Op == 7'b0000011) ? 2'b01 : // Load
                       (Op == 7'b1101111) ? 2'b10 : // JAL
                       2'b00;                       // ALU default

    assign Branch    = (Op == 7'b1100011);   // Branch

    assign ALUOp     = (Op == 7'b0110011) ? 2'b10 : // R-type
                       (Op == 7'b1100011) ? 2'b01 : // Branch
                       2'b00;                       // Default
endmodule