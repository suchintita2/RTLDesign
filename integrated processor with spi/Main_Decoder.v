module Main_Decoder(
    input  [6:0] Op,
    output       RegWrite,
    output [2:0] ImmSrc,
    output       ALUSrc,
    output       MemWrite,
    output [1:0] ResultSrc,
    output       Branch,
    output       Jump,
    output [1:0] ALUOp
);
    assign RegWrite  = (Op == 7'b0000011) ||  // Load
                       (Op == 7'b0110011) ||  // R-type
                       (Op == 7'b0010011) ||  // I-type
                       (Op == 7'b1101111) ||  // JAL
                       (Op == 7'b1100111) ||  // JALR
                       (Op == 7'b0110111) ||  // LUI
                       (Op == 7'b0010111);    // AUIPC

    assign ImmSrc    = (Op == 7'b0100011) ? 3'b001 :  // Store (S-type)
                       (Op == 7'b1100011) ? 3'b010 :  // Branch (B-type)
                       (Op == 7'b1101111) ? 3'b011 :  // JAL (J-type)
                       (Op == 7'b1100111) ? 3'b000 :  // JALR (I-type)
                       (Op == 7'b0110111) ? 3'b100 :  // LUI (U-type)
                       (Op == 7'b0010111) ? 3'b100 :  // AUIPC (U-type)
                       3'b000;                         // I-type default

    assign ALUSrc    = (Op == 7'b0000011) ||  // Load
                       (Op == 7'b0100011) ||  // Store
                       (Op == 7'b0010011) ||  // I-type
                       (Op == 7'b1100111) ||  // JALR
                       (Op == 7'b0110111) ||  // LUI
                       (Op == 7'b0010111);    // AUIPC

    assign MemWrite  = (Op == 7'b0100011);    // Store

    assign ResultSrc = (Op == 7'b0000011) ? 2'b01 :   // Load
                       (Op == 7'b1101111) ? 2'b10 :   // JAL
                       (Op == 7'b1100111) ? 2'b10 :   // JALR
                       2'b00;                          // ALU default

    assign Branch    = (Op == 7'b1100011);    // Branch

    assign Jump      = (Op == 7'b1101111) ||  // JAL
                       (Op == 7'b1100111);    // JALR

    assign ALUOp     = (Op == 7'b0110011) ? 2'b10 :   // R-type
                       (Op == 7'b1100011) ? 2'b01 :   // Branch
                       (Op == 7'b0010011) ? 2'b10 :   // I-type ALU
                       2'b00;                          // Default
endmodule
