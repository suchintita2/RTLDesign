module Processor (
    input clk,
    input reset
);

    // Declare all wires and registers needed for connections
    wire [31:0] PC, nextPC, PCPlus4, PCBranch;
    wire [31:0] Instruction;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    wire [15:0] immediate;
    wire [31:0] SignImm, SignImmShifted;
    wire [31:0] SrcA, SrcB, ALUResult, ALUOut;
    wire [31:0] ReadData1, ReadData2, WriteData;
    wire [31:0] ReadData;
    wire Zero, PCSrc;
    wire RegWrite, MemtoReg, MemWrite, Jump, Branch;
    wire [1:0] ALUOp;
    wire ALUSrc, RegDst;
    wire [3:0] ALUControlSignal;
    wire [4:0] WriteReg;

    // Instantiate all modules
    ProgramCounter pc (
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .PC(PC)
    );

    InstructionMemory imem (
        .Address(PC),
        .Instruction(Instruction)
    );

    // Parse instruction fields
    assign opcode = Instruction[31:26];
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
    assign shamt = Instruction[10:6];
    assign funct = Instruction[5:0];
    assign immediate = Instruction[15:0];

    ControlUnit ctrl (
        .opcode(opcode),
        .funct(funct),
        .RegWriteD(RegWrite),
        .MemtoRegD(MemtoReg),
        .MemWriteD(MemWrite),
        .JumpD(Jump),
        .BranchD(Branch),
        .ALUControlD(ALUOp),
        .ALUSrcD(ALUSrc),
        .RegDstD(RegDst),
        .WBControl() // Not used in this simple implementation
    );

    ALUControl alu_ctrl (
        .ALUOp(ALUOp),
        .Funct(funct),
        .ALUControl(ALUControlSignal)
    );

    RegisterFile regfile (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .ReadReg1(rs),
        .ReadReg2(rt),
        .WriteReg(WriteReg),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    SignExtend signext (
        .immediate(immediate),
        .extended(SignImm)
    );

    ALU alu (
        .SrcA(ReadData1),
        .SrcB(SrcB),
        .ALUControl(ALUControlSignal),
        .Zero(Zero),
        .ALUResult(ALUResult)
    );

    DataMemory dmem (
        .clk(clk),
        .MemWrite(MemWrite),
        .Address(ALUResult),
        .WriteData(ReadData2),
        .ReadData(ReadData)
    );

    // Additional logic
    assign PCPlus4 = PC + 4;
    assign SignImmShifted = SignImm << 2;
    assign PCBranch = PCPlus4 + SignImmShifted;
    assign PCSrc = Branch & Zero;
    assign nextPC = Jump ? {PCPlus4[31:28], Instruction[25:0], 2'b00} :
                    PCSrc ? PCBranch : PCPlus4;
    assign WriteReg = RegDst ? rd : rt;
    assign SrcB = ALUSrc ? SignImm : ReadData2;
    assign WriteData = MemtoReg ? ReadData : ALUResult;

endmodule
