module IF_ID_Register(
    input clk, rst, Stall, Flush,
    input [31:0] PC_F, PCPlus4_F, Instr_F,
    output reg [31:0] PC_D, PCPlus4_D, Instr_D
);
    always @(posedge clk) begin
        if (~rst | Flush) begin
            PC_D <= 32'b0;
            PCPlus4_D <= 32'b0;
            Instr_D <= 32'b0;
        end
        else if (~Stall) begin
            PC_D <= PC_F;
            PCPlus4_D <= PCPlus4_F;
            Instr_D <= Instr_F;
        end
    end
endmodule
