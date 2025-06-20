module execute_cycle(
    input clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE,
input[1:0] ResultSrcE,
    input [2:0] ALUControlE,
    input [31:0] RD1_E, RD2_E, Imm_Ext_E,
    input [4:0] RD_E,
    input [31:0] PCE, PCPlus4E,
    input [31:0] ResultW,
    input [1:0] ForwardA_E, ForwardB_E,
    input [31:0] ALU_ResultM_in,  // <-- ADD THIS
    output PCSrcE, RegWriteM, MemWriteM, 
    output [1:0] ResultSrcM,
    output [4:0] RD_M,
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM, PCTargetE
);
    wire [31:0] Src_A, Src_B_interim, Src_B, ResultE;
    wire ZeroE;

    // Pipeline Registers
    reg RegWriteE_r, MemWriteE_r;
    reg [1:0] ResultSrcE_r;            // 2-bit register
    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

    // Forwarding Muxes (32-bit inputs)
    Mux_3_by_1 srca_mux (
        .a(RD1_E),          // 32-bit
        .b(ResultW),        // 32-bit
        .c(ALU_ResultM_in), // 32-bit forwarded value
        .s(ForwardA_E),     // 2-bit select
        .d(Src_A)           // 32-bit
    );
    
    Mux_3_by_1 srcb_mux (
        .a(RD2_E),          // 32-bit
        .b(ResultW),        // 32-bit
        .c(ALU_ResultM_in), // 32-bit forwarded value
        .s(ForwardB_E),     // 2-bit select
        .d(Src_B_interim)   // 32-bit
    );

    // ALU Source Selection
    Mux alu_src_mux (
        .a(Src_B_interim),  // 32-bit
        .b(Imm_Ext_E),      // 32-bit
        .s(ALUSrcE),        // 1-bit
        .c(Src_B)           // 32-bit
    );

    // ALU Unit
    ALU alu (
        .A(Src_A),          // 32-bit
        .B(Src_B),          // 32-bit
        .Result(ResultE),   // 32-bit
        .ALUControl(ALUControlE),
        .OverFlow(),
        .Carry(),
        .Zero(ZeroE),
        .Negative()
    );

    // Branch Target Calculator
    PC_Adder branch_adder (
        .a(PCE),            // 32-bit
        .b(Imm_Ext_E),      // 32-bit
        .c(PCTargetE)       // 32-bit
    );

    // Pipeline Register Updates
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteE_r   <= 1'b0;
            MemWriteE_r   <= 1'b0;
            ResultSrcE_r  <= 2'b00;  // Reset to 2'b00
            RD_E_r        <= 5'h0;
            PCPlus4E_r    <= 32'h0;
            RD2_E_r       <= 32'h0;
            ResultE_r     <= 32'h0;
        end else begin
            RegWriteE_r   <= RegWriteE;
            MemWriteE_r   <= MemWriteE;
            ResultSrcE_r  <= ResultSrcE;
            RD_E_r        <= RD_E;
            PCPlus4E_r    <= PCPlus4E;
            RD2_E_r       <= Src_B_interim;
            ResultE_r     <= ResultE;
        end
$display("[EX] PC=%h, ALU_Result=%h, SrcA=%h, SrcB=%h, Imm=%h", PCE, ResultE, Src_A, Src_B_interim, Imm_Ext_E);
    end

    // Output Assignments
    assign PCSrcE      = ZeroE & BranchE;
    assign RegWriteM   = RegWriteE_r;
    assign MemWriteM   = MemWriteE_r;
    assign ResultSrcM  = ResultSrcE_r;
    assign RD_M        = RD_E_r;
    assign PCPlus4M    = PCPlus4E_r;
    assign WriteDataM  = RD2_E_r;
    assign ALU_ResultM = ResultE_r;  // EX/MEM pipeline output

endmodule