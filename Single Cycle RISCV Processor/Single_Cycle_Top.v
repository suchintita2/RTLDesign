`include "PC_Module.v"
`include "Instruction_Memory.v"
`include "Register_File.v"
`include "Sign_Extend.v"
`include "ALU.v"
`include "Control_Unit_Top.v"
`include "Data_Memory.v"
`include "Adder.v"
`include "Mux.v"
`include "Mux3to1.v"

module Single_Cycle_Top(clk, rst);
    input clk, rst;

    wire [31:0] PC_Top, RD_Instr, RD1_Top, Imm_Ext_Top, ALUResult, ReadData;
    wire [31:0] PCPlus4, RD2_Top, SrcB, Result, PCTarget, PC_Next;
    wire RegWrite, MemWrite, ALUSrc, PCSrc, Zero;
    wire [1:0] ImmSrc, ResultSrc;
    wire [2:0] ALUControl_Top;

    PC_Module PC(
        .clk(clk),
        .rst(rst),
        .PC(PC_Top),
        .PC_Next(PC_Next)
    );

    Adder PC_Adder(
        .a(PC_Top),
        .b(32'd4),
        .c(PCPlus4)
    );

    Instruction_Memory Instruction_Memory(
        .rst(rst),
        .A(PC_Top),
        .RD(RD_Instr)
    );

    Register_File Register_File(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite),
        .WD3(Result),
        .A1(RD_Instr[19:15]),
        .A2(RD_Instr[24:20]),
        .A3(RD_Instr[11:7]),
        .RD1(RD1_Top),
        .RD2(RD2_Top)
    );

    Sign_Extend Sign_Extend(
        .In(RD_Instr),
        .ImmSrc(ImmSrc),
        .Imm_Ext(Imm_Ext_Top)
    );

    Mux Mux_Register_to_ALU(
        .a(RD2_Top),
        .b(Imm_Ext_Top),
        .s(ALUSrc),
        .c(SrcB)
    );

    ALU ALU(
        .A(RD1_Top),
        .B(SrcB),
        .Result(ALUResult),
        .ALUControl(ALUControl_Top),
        .OverFlow(),
        .Carry(),
        .Zero(Zero),
        .Negative()
    );

    Control_Unit_Top Control_Unit_Top(
        .Op(RD_Instr[6:0]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .PCSrc(PCSrc),
        .funct3(RD_Instr[14:12]),
        .funct7(RD_Instr[31:25]),
        .Zero(Zero),
        .ALUControl(ALUControl_Top)
    );

    Data_Memory Data_Memory(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .WD(RD2_Top),
        .A(ALUResult),
        .RD(ReadData)
    );

    // --- 3-to-1 mux for Result ---
    Mux3to1 Result_Mux(
        .a(ALUResult),
        .b(ReadData),
        .c(PCPlus4),
        .s(ResultSrc),
        .y(Result)
    );

    Adder Adder_Register_to_PC(
        .a(PC_Top),
        .b(Imm_Ext_Top),
        .c(PCTarget)
    );

    Mux Mux_Register_to_PC(
        .a(PCPlus4),
        .b(PCTarget),
        .s(PCSrc),
        .c(PC_Next)
    );
endmodule
