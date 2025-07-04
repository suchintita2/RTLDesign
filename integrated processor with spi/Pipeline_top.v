module Pipeline_top(
    input clk, rst,
    output wire [31:0] ResultW,
    output wire [31:0] ALUResultW,
    output wire [31:0] ReadDataW,
    output wire [31:0] PCPlus4W,
    output wire RegWriteW,
    output wire [4:0] RDW,
    output wire [1:0] ResultSrcW,
    output wire [31:0] PCF_out,
    
    // SPI interface
    output sclk, ss, mosi, spi_interrupt,
    input miso,
    
    // NEW: Debug interface
    input [31:0] debug_addr,
    input debug_read, debug_write,
    input [31:0] debug_write_data,
    output [31:0] debug_read_data,
    
    // NEW: Status outputs
    output spi_transaction,
    output mem_error
);
    // Internal signals
    wire PCSrcE, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE;
    wire RegWriteM, MemWriteM;
    wire [1:0] ResultSrcE, ResultSrcM;
    wire [2:0] ALUControlE;
    wire [4:0] RD_E, RD_M;
    wire [31:0] InstrD, PCD, PCPlus4D;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    wire [4:0] RS1_E, RS2_E;
    wire [1:0] ForwardBE, ForwardAE;
    wire StallF, StallD, FlushD, FlushE;
    wire [31:0] PCTargetE;
    wire ZeroE;

    // NEW: Performance monitoring signals
    wire instruction_executed = RegWriteW;  // Simplified
    wire pipeline_stall = StallF || StallD;
    wire branch_taken = PCSrcE;

    fetch_cycle Fetch (
        .clk(clk),
        .rst(rst),
        .StallF(StallF),
        .FlushD(FlushD),
        .StallD(StallD),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .PCF_out(PCF_out)
    );

    decode_cycle Decode (
        .clk(clk),
        .rst(rst),
        .FlushE(FlushE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E)
    );

    execute_cycle Execute (
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .ResultW(ResultW),
        .ForwardA_E(ForwardAE),
        .ForwardB_E(ForwardBE),
        .ALU_ResultM_in(ALU_ResultM),
        .PCSrcE(PCSrcE),
        .ZeroE(ZeroE),
        .PCTargetE(PCTargetE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM)
    );

    memory_cycle Memory (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .RD_W(RDW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .spi_interrupt(spi_interrupt),
        .miso(miso),
        // NEW connections
        .debug_addr(debug_addr),
        .debug_read(debug_read),
        .debug_write(debug_write),
        .debug_write_data(debug_write_data),
        .debug_read_data(debug_read_data),
        .instruction_executed(instruction_executed),
        .pipeline_stall(pipeline_stall),
        .branch_taken(branch_taken),
        .spi_transaction(spi_transaction),
        .mem_error(mem_error)
    );


    writeback_cycle WriteBack (
        .clk(clk),
        .rst(rst),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .ResultW(ResultW)
    );

    hazard_unit Forwarding_block (
        .rst(rst),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RDW),
        .RD_E(RD_E),
        .Rs1_E(RS1_E),
        .Rs2_E(RS2_E),
        .RS1_D(InstrD[19:15]),
        .RS2_D(InstrD[24:20]),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ZeroE(ZeroE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

endmodule
