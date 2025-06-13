`include "ALU_Decoder.v"
`include "Main_Decoder.v"
`include "ALU.v"

module Control_Unit_Top(
    input [6:0] Op, funct7,
    input [2:0] funct3,
    input Zero,
    output RegWrite, ALUSrc, MemWrite, Branch, PCSrc,
    output [1:0] ImmSrc, ResultSrc,
    output [2:0] ALUControl
);
    wire [1:0] ALUOp;

    Main_Decoder Main_Decoder(
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    ALU_Decoder ALU_Decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    assign PCSrc = (Branch & Zero) | (Op == 7'b1101111);
endmodule
