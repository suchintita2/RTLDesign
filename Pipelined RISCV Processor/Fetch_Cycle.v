module fetch_cycle(
    input clk, rst,
    input StallF, FlushD, StallD,
    input PCSrcE,
    input [31:0] PCTargetE,
    output reg [31:0] InstrD,
    output [31:0] PCD,
    output [31:0] PCPlus4D, PCF_out
);

    reg [31:0] PCF_reg;
    wire [31:0] PCF_next;
    wire [31:0] InstrF;

    assign PCF_next = PCSrcE ? PCTargetE : (PCF_reg + 4);

    Instruction_Memory imem(
        .rst(rst),
        .A(PCF_reg),
        .RD(InstrF)
    );

    // Modified PC update with stall support
    always @(posedge clk or negedge rst) begin
        if (!rst)
            PCF_reg <= 32'b0;
        else if (!StallF)
            PCF_reg <= PCF_next;
    end

    // Modified IF/ID register with FlushD
    always @(posedge clk or negedge rst) begin
        if (!rst || FlushD)
            InstrD <= 32'h00000013; // NOP
        else if (!StallD)
            InstrD <= InstrF;
    end

    assign PCD = PCF_reg;
    assign PCPlus4D = PCF_reg + 4;
assign PCF_out = PCF_reg;
endmodule