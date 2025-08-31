module SPI_MM_Interface(
    input clk, rst,
    input WE,              // write enable from pipeline
    input [31:0] Addr,     // ALU result as address
    input [31:0] WD,       // data to write
    output reg [31:0] RD,  // data to CPU
    // SPI pins
    output ss_pad_o,
    output sclk_pad_o,
    output mosi_pad_o,
    input miso_pad_i
);

    // Internal SPI registers
    reg [31:0] SPI_TX, SPI_CTRL, SPI_DIV;

    // Instantiate your SPI core
    SPI_Master spi_core (
        .clk(clk),
        .rst(rst),
        .ss_pad_o(ss_pad_o),
        .sclk_pad_o(sclk_pad_o),
        .mosi_pad_o(mosi_pad_o),
        .miso_pad_i(miso_pad_i),
        .Tx(SPI_TX),
        .Rx(SPI_TX),     // adjust based on your core
        .Control(SPI_CTRL),
        .Divider(SPI_DIV)
    );

    // Write logic
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            SPI_TX <= 32'd0;
            SPI_CTRL <= 32'd0;
            SPI_DIV <= 32'd0;
        end else if (WE) begin
            case(Addr)
                32'hFFFF0000: SPI_TX <= WD;
                32'hFFFF0004: SPI_CTRL <= WD;
                32'hFFFF0008: SPI_DIV <= WD;
            endcase
        end
    end

    // Read logic
    always @(*) begin
        case(Addr)
            32'hFFFF0000: RD = SPI_TX; // read received data
            32'hFFFF0004: RD = SPI_CTRL;
            32'hFFFF0008: RD = SPI_DIV;
            default: RD = 32'd0;
        endcase
    end
endmodule
