module ID_EX_Register(
  input wire clk,
  input wire RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
  input wire [1:0] ResultSrcD, ImmSrcD,
  input wire [2:0] ALUControlD,
  input wire [31:0] RD1, RD2, ImmExtD, PCPlus4D,
  input wire [4:0] Rs1D, Rs2D, RdD,
  output reg RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
  output reg [1:0] ResultSrcE,
  output reg [2:0] ALUControlE,
  output reg [31:0] RD1E, RD2E, ImmExtE, PCPlus4E,
  output reg [4:0] Rs1E, Rs2E, RdE
);
  always @(posedge clk) begin
    RegWriteE <= RegWriteD;
    MemWriteE <= MemWriteD;
    JumpE     <= JumpD;
    BranchE   <= BranchD;
    ALUSrcE   <= ALUSrcD;
    ResultSrcE<= ResultSrcD;
    ALUControlE <= ALUControlD;
    RD1E <= RD1;
    RD2E <= RD2;
    ImmExtE <= ImmExtD;
    PCPlus4E <= PCPlus4D;
    Rs1E <= Rs1D;
    Rs2E <= Rs2D;
    RdE  <= RdD;
  end
endmodule
