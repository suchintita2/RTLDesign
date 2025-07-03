module decode_cycle(
    input clk, rst,
    input FlushE,
    input RegWriteW,
    input [4:0] RDW,
    input [31:0] InstrD, PCD, PCPlus4D, ResultW,
    output RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE,
    output [1:0] ResultSrcE,
    output [2:0] ALUControlE,
    output [31:0] RD1_E, RD2_E, Imm_Ext_E,
    output [4:0] RS1_E, RS2_E, RD_E,
    output [31:0] PCE, PCPlus4E
);
    wire RegWriteD, ALUSrcD, MemWriteD, BranchD, JumpD;
    wire [2:0] ImmSrcD;
    wire [1:0] ResultSrcD;
    wire [2:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    reg RegWriteD_r, ALUSrcD_r, MemWriteD_r, BranchD_r, JumpD_r;
    reg [1:0] ResultSrcD_r;
    reg [2:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [31:0] PCD_r, PCPlus4D_r;

    // Control Unit
    Control_Unit_Top control (
        .Op(InstrD[6:0]),
        .funct3(InstrD[14:12]),
        .funct7(InstrD[31:25]),
        .RegWrite(RegWriteD),
        .ImmSrc(ImmSrcD),
        .ALUSrc(ALUSrcD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .Jump(JumpD),
        .ALUControl(ALUControlD)
    );

    // Register File
    Register_File rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .WD3(ResultW),
        .A1(InstrD[19:15]),
        .A2(InstrD[24:20]),
        .A3(RDW),
        .RD1(RD1_D),
        .RD2(RD2_D)
    );

    // Sign Extension
    Sign_Extend extension (
        .In(InstrD),
        .ImmSrc(ImmSrcD),
        .Imm_Ext(Imm_Ext_D)
    );

    // Pipeline Register
    always @(posedge clk or negedge rst) begin
        if (!rst || FlushE) begin
            RegWriteD_r   <= 1'b0;
            ALUSrcD_r     <= 1'b0;
            MemWriteD_r   <= 1'b0;
            ResultSrcD_r  <= 2'b00;
            BranchD_r     <= 1'b0;
            JumpD_r       <= 1'b0;
            ALUControlD_r <= 3'b000;
            RD1_D_r       <= 32'h0;
            RD2_D_r       <= 32'h0;
            Imm_Ext_D_r   <= 32'h0;
            RD_D_r        <= 5'h0;
            PCD_r         <= 32'h0;
            PCPlus4D_r    <= 32'h0;
            RS1_D_r       <= 5'h0;
            RS2_D_r       <= 5'h0;
        end else begin
            RegWriteD_r   <= RegWriteD;
            ALUSrcD_r     <= ALUSrcD;
            MemWriteD_r   <= MemWriteD;
            ResultSrcD_r  <= ResultSrcD;
            BranchD_r     <= BranchD;
            JumpD_r       <= JumpD;
            ALUControlD_r <= ALUControlD;
            RD1_D_r       <= RD1_D;
            RD2_D_r       <= RD2_D;
            Imm_Ext_D_r   <= Imm_Ext_D;
            RD_D_r        <= InstrD[11:7];
            PCD_r         <= PCD;
            PCPlus4D_r    <= PCPlus4D;
            RS1_D_r       <= InstrD[19:15];
            RS2_D_r       <= InstrD[24:20];
        end
    end

    assign RegWriteE   = RegWriteD_r;
    assign ALUSrcE     = ALUSrcD_r;
    assign MemWriteE   = MemWriteD_r;
    assign ResultSrcE  = ResultSrcD_r;
    assign BranchE     = BranchD_r;
    assign JumpE       = JumpD_r;
    assign ALUControlE = ALUControlD_r;
    assign RD1_E       = RD1_D_r;
    assign RD2_E       = RD2_D_r;
    assign Imm_Ext_E   = Imm_Ext_D_r;
    assign RD_E        = RD_D_r;
    assign PCE         = PCD_r;
    assign PCPlus4E    = PCPlus4D_r;
    assign RS1_E       = RS1_D_r;
    assign RS2_E       = RS2_D_r;
endmodule
