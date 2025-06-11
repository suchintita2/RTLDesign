module ID_EX_Register(
    input clk, rst, Flush,
    input RegWrite_D, MemWrite_D, ALUSrc_D, Branch_D, Jump_D,
    input [1:0] ResultSrc_D,
    input [2:0] ALUControl_D,
    input [31:0] PC_D, PCPlus4_D, RD1_D, RD2_D, Imm_Ext_D,
    input [4:0] Rs1_D, Rs2_D, Rd_D,
    output reg RegWrite_E, MemWrite_E, ALUSrc_E, Branch_E, Jump_E,
    output reg [1:0] ResultSrc_E,
    output reg [2:0] ALUControl_E,
    output reg [31:0] PC_E, PCPlus4_E, RD1_E, RD2_E, Imm_Ext_E,
    output reg [4:0] Rs1_E, Rs2_E, Rd_E
);
    always @(posedge clk) begin
        if (~rst | Flush) begin
            RegWrite_E <= 1'b0;
            MemWrite_E <= 1'b0;
            ALUSrc_E <= 1'b0;
            Branch_E <= 1'b0;
            Jump_E <= 1'b0;
            ResultSrc_E <= 2'b0;
            ALUControl_E <= 3'b0;
            PC_E <= 32'b0;
            PCPlus4_E <= 32'b0;
            RD1_E <= 32'b0;
            RD2_E <= 32'b0;
            Imm_Ext_E <= 32'b0;
            Rs1_E <= 5'b0;
            Rs2_E <= 5'b0;
            Rd_E <= 5'b0;
        end
        else begin
            RegWrite_E <= RegWrite_D;
            MemWrite_E <= MemWrite_D;
            ALUSrc_E <= ALUSrc_D;
            Branch_E <= Branch_D;
            Jump_E <= Jump_D;
            ResultSrc_E <= ResultSrc_D;
            ALUControl_E <= ALUControl_D;
            PC_E <= PC_D;
            PCPlus4_E <= PCPlus4_D;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            Imm_Ext_E <= Imm_Ext_D;
            Rs1_E <= Rs1_D;
            Rs2_E <= Rs2_D;
            Rd_E <= Rd_D;
        end
    end
endmodule