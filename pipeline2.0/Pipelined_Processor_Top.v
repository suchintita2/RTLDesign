// Top-level module for the pipelined processor with full hazard handling (based on Fig. 7.61)
module Pipelined_Processor_Top(input wire clk, rst);

  // IF Stage wires
  wire [31:0] PCF, PCPlus4F, InstrD;
  wire StallF;

  // ID Stage wires
  wire [31:0] PCD, RD1, RD2, ImmExtD, PCPlus4D;
  wire [4:0] Rs1D, Rs2D, RdD;
  wire RegWriteD, MemWriteD, BranchD, JumpD;
  wire [1:0] ResultSrcD, ImmSrcD;
  wire [2:0] ALUControlD;
  wire StallD, FlushD;

  // EX Stage wires
  wire [31:0] RD1E, RD2E, ImmExtE, PCPlus4E, SrcAE, SrcBE, ALUResultE, WriteDataE, PCTargetE;
  wire [4:0] Rs1E, Rs2E, RdE;
  wire [2:0] ALUControlE;
  wire [1:0] ForwardAE, ForwardBE;
  wire RegWriteE, MemWriteE, BranchE, JumpE, ZeroE, PCSrcE;
  wire [1:0] ResultSrcE;

  // MEM Stage wires
  wire [31:0] ALUResultM, WriteDataM, ReadDataW, PCPlus4M;
  wire [4:0] RdM;
  wire RegWriteM, MemWriteM;
  wire [1:0] ResultSrcM;

  // WB Stage wires
  wire [31:0] ResultW, PCPlus4W;
  wire [4:0] RdW;
  wire RegWriteW;
  wire [1:0] ResultSrcW;

  // PC Logic
  PC_Module pc(.clk(clk), .rst(rst), .EN(~StallF), .PC_Next(PCSrcE ? PCTargetE : PCPlus4F), .PC(PCF));

  // Instruction Memory
  Instruction_Memory imem(.rst(rst), .A(PCF), .RD(InstrD));

  // Adder for PC+4
  Adder pc_adder(.a(PCF), .b(32'd4), .c(PCPlus4F));

  // IF/ID pipeline register
  IF_ID_Register if_id(
    .clk(clk), .rst(rst), .EN(~StallD), .Flush(FlushD),
    .PCF(PCF), .InstrF(InstrD), .PCPlus4F(PCPlus4F),
    .PCD(PCD), .InstrD(), .PCPlus4D(PCPlus4D)
  );

  // Instruction fields
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  // Control Unit
  Control_Unit cu(
    .op(InstrD[6:0]), .funct3(InstrD[14:12]), .funct7(InstrD[30]),
    .RegWrite(RegWriteD), .ResultSrc(ResultSrcD), .MemWrite(MemWriteD),
    .Jump(JumpD), .Branch(BranchD), .ALUControl(ALUControlD), .ALUSrc(ALUSrcD),
    .ImmSrc(ImmSrcD)
  );

  // Register File
  Register_File rf(
    .clk(clk), .A1(Rs1D), .A2(Rs2D), .A3(RdW), .WD3(ResultW), .WE3(RegWriteW),
    .RD1(RD1), .RD2(RD2)
  );

  // Sign Extension
  Extend imm_ext(.Instr(InstrD), .ImmSrc(ImmSrcD), .ImmExt(ImmExtD));

  // Hazard Unit
  Hazard_Unit hazard(
    .Rs1D(Rs1D), .Rs2D(Rs2D), .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .RegWriteE(RegWriteE),
    .RdM(RdM), .RegWriteM(RegWriteM), .RdW(RdW), .RegWriteW(RegWriteW),
    .StallF(StallF), .StallD(StallD), .FlushD(FlushD),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
  );

  // ID/EX Register
  ID_EX_Register id_ex(
    .clk(clk), .RegWriteD(RegWriteD), .ResultSrcD(ResultSrcD), .MemWriteD(MemWriteD),
    .JumpD(JumpD), .BranchD(BranchD), .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD), .RD1(RD1), .RD2(RD2), .ImmExtD(ImmExtD), .Rs1D(Rs1D), .Rs2D(Rs2D),
    .RdD(RdD), .PCPlus4D(PCPlus4D),
    .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE),
    .JumpE(JumpE), .BranchE(BranchE), .ALUControlE(ALUControlE),
    .ALUSrcE(ALUSrcE), .RD1E(RD1E), .RD2E(RD2E), .ImmExtE(ImmExtE),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE), .PCPlus4E(PCPlus4E)
  );

  // Forwarding Muxes and ALU
  Mux3to1 srcA_mux(.sel(ForwardAE), .in0(RD1E), .in1(ResultW), .in2(ALUResultM), .out(SrcAE));
  Mux3to1 srcB_mux(.sel(ForwardBE), .in0(RD2E), .in1(ResultW), .in2(ALUResultM), .out(WriteDataE));
  Mux2to1 srcB_final(.sel(ALUSrcE), .in0(WriteDataE), .in1(ImmExtE), .out(SrcBE));
  ALU alu(.A(SrcAE), .B(SrcBE), .ALUControl(ALUControlE), .Result(ALUResultE), .Zero(ZeroE));
  Adder branch_adder(.a(PCPlus4E), .b(ImmExtE), .c(PCTargetE));
  assign PCSrcE = BranchE & ZeroE | JumpE;

  // EX/MEM Register
  EX_MEM_Register ex_mem(
    .clk(clk), .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE),
    .ALUResultE(ALUResultE), .WriteDataE(WriteDataE), .RdE(RdE), .PCPlus4E(PCPlus4E),
    .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .MemWriteM(MemWriteM),
    .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .RdM(RdM), .PCPlus4M(PCPlus4M)
  );

  // Data Memory
  Data_Memory dmem(.clk(clk), .WE(MemWriteM), .A(ALUResultM), .WD(WriteDataM), .RD(ReadDataW));

  // MEM/WB Register
  MEM_WB_Register mem_wb(
    .clk(clk), .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .RdM(RdM),
    .ReadDataW(ReadDataW), .ALUResultM(ALUResultM), .PCPlus4M(PCPlus4M),
    .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW), .RdW(RdW),
    .ResultW(ResultW), .PCPlus4W(PCPlus4W)
  );

  // Writeback result mux
  Mux4to1 result_mux(
    .sel(ResultSrcW), .in0(ALUResultM), .in1(ReadDataW), .in2(PCPlus4W), .in3(32'b0),
    .out(ResultW)
  );

endmodule
