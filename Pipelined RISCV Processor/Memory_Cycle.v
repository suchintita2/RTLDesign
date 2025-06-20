module memory_cycle(
    input clk, rst, RegWriteM, MemWriteM,
    input [1:0] ResultSrcM,
    input [4:0] RD_M,
    input [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
    output RegWriteW,
    output [1:0] ResultSrcW,
    output [4:0] RD_W,
    output [31:0] PCPlus4W, ALU_ResultW, ReadDataW
);
    wire [31:0] ReadDataM;
    reg RegWriteM_r;
    reg [1:0] ResultSrcM_r;
    reg [4:0] RD_M_r;
    reg [31:0] PCPlus4M_r, ALU_ResultM_r, ReadDataM_r;

    Data_Memory dmem (
        .clk(clk),
        .rst(rst),
        .WE(MemWriteM),
        .WD(WriteDataM),
        .A(ALU_ResultM),
        .RD(ReadDataM)
    );

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteM_r   <= 1'b0;
            ResultSrcM_r  <= 2'b00;
            RD_M_r        <= 5'h0;
            PCPlus4M_r    <= 32'h0;
            ALU_ResultM_r <= 32'h0;
            ReadDataM_r   <= 32'h0;
        end else begin
            RegWriteM_r   <= RegWriteM;
            ResultSrcM_r  <= ResultSrcM;
            RD_M_r        <= RD_M;
            PCPlus4M_r    <= PCPlus4M;
            ALU_ResultM_r <= ALU_ResultM;
            ReadDataM_r   <= ReadDataM;
        end
$display("[MEM] ALU=%h, WriteData=%h, ReadData=%h, WE=%b", ALU_ResultM, WriteDataM, ReadDataM, MemWriteM);
    end

    assign RegWriteW   = RegWriteM_r;
    assign ResultSrcW  = ResultSrcM_r;
    assign RD_W        = RD_M_r;
    assign PCPlus4W    = PCPlus4M_r;
    assign ALU_ResultW = ALU_ResultM_r;
    assign ReadDataW   = ReadDataM_r;
endmodule