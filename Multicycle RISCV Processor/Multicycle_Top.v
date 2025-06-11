module Multicycle_Top(
    input wire clk,
    input wire rst
);
    // Control signals
    wire PCWrite, AdrSrc, MemWrite, IRWrite, RegWrite;
    wire [1:0] ResultSrc;
    wire ALUSrcA;
    wire [1:0] ALUSrcB, ImmSrc;
    wire [2:0] ALUControl;
    wire Zero;
    
    // Datapath wires
    wire [31:0] PC, OldPC, Instr, Data, ALUOut;
    wire [31:0] ALUResult, RD1, RD2, ImmExt;
    wire [31:0] MemAddr, ReadData, Result, SrcA, SrcB;
    
    // PC with enable
    PC_Module pc(
        .clk(clk),
        .rst(rst),
        .EN(PCWrite),
        .PC_Next(Result),
        .PC(PC)
    );
    
    // OldPC register
    Register_EN oldpc_reg(
        .clk(clk),
        .rst(rst),
        .EN(1'b1),
        .D(PC),
        .Q(OldPC)
    );
    
    // Address Mux
    Mux2to1 adrmux(
        .a(PC),
        .b(ALUOut),
        .s(AdrSrc),
        .y(MemAddr)
    );
    
    // Unified Memory
    Memory memory(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .A(MemAddr),
        .WD(RD2),  // Directly from RD2 as per diagram
        .RD(ReadData)
    );
    
    // Instruction Register
    Register_EN ir(
        .clk(clk),
        .rst(rst),
        .EN(IRWrite),
        .D(ReadData),
        .Q(Instr)
    );
    
    // Data Register
    Register_EN dr(
        .clk(clk),
        .rst(rst),
        .EN(1'b1),
        .D(ReadData),
        .Q(Data)
    );
    
    // Register File
    Register_File rf(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite),
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WD3(Result),
        .RD1(RD1),
        .RD2(RD2)
    );
    
    // Immediate Extend
    Extend extend(
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );
    
    // ALU Source A Mux (2:1)
    Mux2to1 srcamux(
        .a(OldPC),  // From OldPC register
        .b(RD1),    // From RD1
        .s(ALUSrcA),
        .y(SrcA)
    );
    
    // ALU Source B Mux (3:1)
    Mux3to1 srcbmux(
        .a(RD2),
        .b(32'd4),
        .c(ImmExt),
        .s(ALUSrcB),
        .y(SrcB)
    );
    
    // ALU
    ALU alu(
        .A(SrcA),
        .B(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .Zero(Zero)
    );
    
    // ALU Output Register
    Register_EN aluout_reg(
        .clk(clk),
        .rst(rst),
        .EN(1'b1),
        .D(ALUResult),
        .Q(ALUOut)
    );
    
    // Result Mux (3:1)
    Mux3to1 resultmux(
        .a(ALUOut),
        .b(Data),
        .c(OldPC),  // From OldPC as per diagram
        .s(ResultSrc),
        .y(Result)
    );
    
    // Control Unit
    Control_Unit control(
        .clk(clk),
        .rst(rst),
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7(Instr[30]),
        .Zero(Zero),
        .PCWrite(PCWrite),
        .AdrSrc(AdrSrc),
        .MemWrite(MemWrite),
        .IRWrite(IRWrite),
        .ResultSrc(ResultSrc),
        .ALUControl(ALUControl),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite)
    );
endmodule
