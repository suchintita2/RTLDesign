`include "PC_Module.v"
`include "Adder.v"
`include "Instruction_Memory.v"
`include "Mux.v"
`include "Mux_3to1.v"
`include "IF_ID_Register.v"
`include "Register_File.v"
`include "Sign_Extend.v"
`include "Control_Unit_Top.v"
`include "ID_EX_Register.v"
`include "ALU.v"
`include "EX_MEM_Register.v"
`include "Data_Memory.v"
`include "MEM_WB_Register.v"
`include "Hazard_Unit.v"
`include "Forwarding_Unit.v"

module Pipelined_Processor_Top(clk, rst);
    input clk, rst;

    // Pipeline Stage Wires
    wire [31:0] PC_F, PCPlus4_F, Instr_F;
    wire [31:0] PC_D, PCPlus4_D, Instr_D, Imm_Ext_D;
    wire [31:0] PC_E, PCPlus4_E, RD1_E, RD2_E, Imm_Ext_E, PCTarget_E;
    wire [31:0] ALUResult_M, WriteData_M, PCTarget_M;
    wire [31:0] ALUResult_W, ReadData_W, PCTarget_W;
    wire [31:0] RD1_D, RD2_D;
    wire [31:0] Result_W;

    // Control Signals
    wire RegWrite_D, MemWrite_D, ALUSrc_D, Branch_D, Jump_D;
    wire [1:0] ResultSrc_D, ImmSrc_D;
    wire [2:0] ALUControl_D;

    wire RegWrite_E, MemWrite_E, ALUSrc_E, Branch_E, Jump_E;
    wire [1:0] ResultSrc_E;
    wire [2:0] ALUControl_E;

    wire RegWrite_M, MemWrite_M, Branch_M, Jump_M;
    wire [1:0] ResultSrc_M;

    wire RegWrite_W;
    wire [1:0] ResultSrc_W;

    // Register addresses
    wire [4:0] Rs1_D, Rs2_D, Rd_D;
    wire [4:0] Rs1_E, Rs2_E, Rd_E;
    wire [4:0] Rd_M, Rd_W;

    // Hazard control signals
    wire Stall_F, Stall_D, Flush_D, Flush_E;
    wire [1:0] ForwardA_E, ForwardB_E;

    // ALU inputs after forwarding
    wire [31:0] SrcA_E, SrcB_E, WriteData_E;
    wire [31:0] ALUResult_E;
    wire Zero_E;

    // PC control
    wire [31:0] PC_Next_F;
    wire PCSrc_E;

    // FETCH STAGE (IF)
    
    PC_Module PC(
        .clk(clk),
        .rst(rst),
        .Stall(Stall_F),
        .PC(PC_F),
        .PC_Next(PC_Next_F)
    );

    Adder PC_Adder(
        .a(PC_F),
        .b(32'd4),
        .c(PCPlus4_F)
    );

    Instruction_Memory Instruction_Memory(
        .rst(rst),
        .A(PC_F),
        .RD(Instr_F)
    );

    // PC Source Selection (for branches/jumps)
    assign PCSrc_E = (Branch_E & Zero_E) | Jump_E;

    Mux PC_Mux(
        .a(PCPlus4_F),
        .b(PCTarget_E),
        .s(PCSrc_E),
        .c(PC_Next_F)
    );

    // IF/ID PIPELINE REGISTER

    IF_ID_Register IF_ID_Reg(
        .clk(clk),
        .rst(rst),
        .Stall(Stall_D),
        .Flush(Flush_D),
        .PC_F(PC_F),
        .PCPlus4_F(PCPlus4_F),
        .Instr_F(Instr_F),
        .PC_D(PC_D),
        .PCPlus4_D(PCPlus4_D),
        .Instr_D(Instr_D)
    );

    // DECODE STAGE (ID)

    assign Rs1_D = Instr_D[19:15];
    assign Rs2_D = Instr_D[24:20];
    assign Rd_D = Instr_D[11:7];

    Register_File Register_File(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite_W),
        .WD3(Result_W),
        .A1(Rs1_D),
        .A2(Rs2_D),
        .A3(Rd_W),
        .RD1(RD1_D),
        .RD2(RD2_D)
    );

    Sign_Extend Sign_Extend(
        .In(Instr_D),
        .ImmSrc(ImmSrc_D),
        .Imm_Ext(Imm_Ext_D)
    );

    Control_Unit_Top Control_Unit_Top(
        .Op(Instr_D[6:0]),
        .RegWrite(RegWrite_D),
        .ImmSrc(ImmSrc_D),
        .ALUSrc(ALUSrc_D),
        .MemWrite(MemWrite_D),
        .ResultSrc(ResultSrc_D),
        .Branch(Branch_D),
        .Jump(Jump_D),
        .funct3(Instr_D[14:12]),
        .funct7(Instr_D[31:25]),
        .ALUControl(ALUControl_D)
    );

    // ID/EX PIPELINE REGISTER

    ID_EX_Register ID_EX_Reg(
        .clk(clk),
        .rst(rst),
        .Flush(Flush_E),
        .RegWrite_D(RegWrite_D),
        .MemWrite_D(MemWrite_D),
        .ALUSrc_D(ALUSrc_D),
        .Branch_D(Branch_D),
        .Jump_D(Jump_D),
        .ResultSrc_D(ResultSrc_D),
        .ALUControl_D(ALUControl_D),
        .PC_D(PC_D),
        .PCPlus4_D(PCPlus4_D),
        .RD1_D(RD1_D),
        .RD2_D(RD2_D),
        .Imm_Ext_D(Imm_Ext_D),
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rd_D(Rd_D),
        .RegWrite_E(RegWrite_E),
        .MemWrite_E(MemWrite_E),
        .ALUSrc_E(ALUSrc_E),
        .Branch_E(Branch_E),
        .Jump_E(Jump_E),
        .ResultSrc_E(ResultSrc_E),
        .ALUControl_E(ALUControl_E),
        .PC_E(PC_E),
        .PCPlus4_E(PCPlus4_E),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .Rd_E(Rd_E)
    );

    // EXECUTE STAGE (EX)
    
    Mux_3to1 Forward_A_Mux(
        .a(RD1_E),
        .b(Result_W),
        .c(ALUResult_M),
        .s(ForwardA_E),
        .out(SrcA_E)
    );

    Mux_3to1 Forward_B_Mux(
        .a(RD2_E),
        .b(Result_W),
        .c(ALUResult_M),
        .s(ForwardB_E),
        .out(WriteData_E)
    );

    Mux ALU_Src_Mux(
        .a(WriteData_E),
        .b(Imm_Ext_E),
        .s(ALUSrc_E),
        .c(SrcB_E)
    );

    ALU ALU(
        .A(SrcA_E),
        .B(SrcB_E),
        .Result(ALUResult_E),
        .ALUControl(ALUControl_E),
        .Zero(Zero_E)
    );

    Adder Branch_Adder(
        .a(PC_E),
        .b(Imm_Ext_E),
        .c(PCTarget_E)
    );

    // EX/MEM PIPELINE REGISTER

    EX_MEM_Register EX_MEM_Reg(
        .clk(clk),
        .rst(rst),
        .RegWrite_E(RegWrite_E),
        .MemWrite_E(MemWrite_E),
        .Branch_E(Branch_E),
        .Jump_E(Jump_E),
        .ResultSrc_E(ResultSrc_E),
        .ALUResult_E(ALUResult_E),
        .WriteData_E(WriteData_E),
        .PCTarget_E(PCTarget_E),
        .Rd_E(Rd_E),
        .RegWrite_M(RegWrite_M),
        .MemWrite_M(MemWrite_M),
        .Branch_M(Branch_M),
        .Jump_M(Jump_M),
        .ResultSrc_M(ResultSrc_M),
        .ALUResult_M(ALUResult_M),
        .WriteData_M(WriteData_M),
        .PCTarget_M(PCTarget_M),
        .Rd_M(Rd_M)
    );

    // MEMORY STAGE (MEM)

    Data_Memory Data_Memory(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite_M),
        .WD(WriteData_M),
        .A(ALUResult_M),
        .RD(ReadData_M)
    );

    // MEM/WB PIPELINE REGISTER

    MEM_WB_Register MEM_WB_Reg(
        .clk(clk),
        .rst(rst),
        .RegWrite_M(RegWrite_M),
        .ResultSrc_M(ResultSrc_M),
        .ALUResult_M(ALUResult_M),
        .ReadData_M(ReadData_M),
        .PCTarget_M(PCTarget_M),
        .Rd_M(Rd_M),
        .RegWrite_W(RegWrite_W),
        .ResultSrc_W(ResultSrc_W),
        .ALUResult_W(ALUResult_W),
        .ReadData_W(ReadData_W),
        .PCTarget_W(PCTarget_W),
        .Rd_W(Rd_W)
    );

    // WRITEBACK STAGE (WB)

    Mux_3to1 Result_Mux(
        .a(ALUResult_W),
        .b(ReadData_W),
        .c(PCTarget_W),
        .s(ResultSrc_W),
        .out(Result_W)
    );

    // HAZARD DETECTION AND FORWARDING

    Hazard_Unit Hazard_Unit(
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rd_E(Rd_E),
        .PCSrc_E(PCSrc_E),
        .ResultSrc_E(ResultSrc_E[0]),
        .Stall_F(Stall_F),
        .Stall_D(Stall_D),
        .Flush_D(Flush_D),
        .Flush_E(Flush_E)
    );

    Forwarding_Unit Forwarding_Unit(
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .Rd_M(Rd_M),
        .Rd_W(Rd_W),
        .RegWrite_M(RegWrite_M),
        .RegWrite_W(RegWrite_W),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E)
    );
endmodule
