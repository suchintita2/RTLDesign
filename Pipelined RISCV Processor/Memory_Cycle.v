module memory_cycle(
    input clk, rst,
    input RegWriteM, MemWriteM,
    input [1:0] ResultSrcM,
    input [4:0] RD_M,
    input [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
    // SPI signals
    output ss_pad_o,
    output sclk_pad_o,
    output mosi_pad_o,
    input  miso_pad_i,
    output RegWriteW,
    output [1:0] ResultSrcW,
    output [4:0] RD_W,
    output [31:0] PCPlus4W, ALU_ResultW, ReadDataW
);

    // Address decode for SPI vs Data Memory
    wire spi_sel  = (ALU_ResultM >= 32'hFFFF0000 && ALU_ResultM <= 32'hFFFF0008);
    wire we_dm    = MemWriteM & ~spi_sel;
    wire we_spi   = MemWriteM & spi_sel;

    // Data Memory wires
    wire [31:0] DM_RD;
    reg  [31:0] DM_RD_r;

    Data_Memory dmem (
        .clk(clk),
        .rst(rst),
        .WE(we_dm),
        .WD(WriteDataM),
        .A(ALU_ResultM),
        .RD(DM_RD)
    );

    // SPI Memory-Mapped Interface wires
    wire [31:0] SPI_RD;
    reg  [31:0] SPI_RD_r;

    SPI_MM_Interface spi_mm (
        .clk(clk),
        .rst(rst),
        .WE(we_spi),
        .Addr(ALU_ResultM),
        .WD(WriteDataM),
        .RD(SPI_RD),
        .ss_pad_o(ss_pad_o),
        .sclk_pad_o(sclk_pad_o),
        .mosi_pad_o(mosi_pad_o),
        .miso_pad_i(miso_pad_i)
    );

    // Pipeline registers for MEM->WB
    reg RegWriteM_r;
    reg [1:0] ResultSrcM_r;
    reg [4:0] RD_M_r;
    reg [31:0] PCPlus4M_r, ALU_ResultM_r;
    reg [31:0] ReadDataM_r;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            RegWriteM_r   <= 1'b0;
            ResultSrcM_r  <= 2'b00;
            RD_M_r        <= 5'd0;
            PCPlus4M_r    <= 32'd0;
            ALU_ResultM_r <= 32'd0;
            ReadDataM_r   <= 32'd0;
            DM_RD_r       <= 32'd0;
            SPI_RD_r      <= 32'd0;
        end else begin
            RegWriteM_r   <= RegWriteM;
            ResultSrcM_r  <= ResultSrcM;
            RD_M_r        <= RD_M;
            PCPlus4M_r    <= PCPlus4M;
            ALU_ResultM_r <= ALU_ResultM;
            DM_RD_r       <= DM_RD;
            SPI_RD_r      <= SPI_RD;
            ReadDataM_r   <= spi_sel ? SPI_RD : DM_RD;
        end
    end

    // Assign outputs to WB stage
    assign RegWriteW   = RegWriteM_r;
    assign ResultSrcW  = ResultSrcM_r;
    assign RD_W        = RD_M_r;
    assign PCPlus4W    = PCPlus4M_r;
    assign ALU_ResultW = ALU_ResultM_r;
    assign ReadDataW   = ReadDataM_r;

    // Optional debug
    always @(posedge clk) begin
        $display("[MEM] ALU=0x%08h, WriteData=0x%08h, ReadData=0x%08h, WE=%b, SPI_sel=%b", 
                  ALU_ResultM, WriteDataM, ReadDataM_r, MemWriteM, spi_sel);
    end

endmodule
