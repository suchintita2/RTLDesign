module Enhanced_Data_Memory(
    input clk, rst, WE,
    input [31:0] A, WD,
    output [31:0] RD,
    output mem_ready,
    
    // SPI interface
    output sclk, ss, mosi, spi_interrupt,
    input miso
);
    
    // Regular memory
    reg [31:0] mem [0:1023];
    wire [31:0] mem_rd;
    wire mem_access;
    
    // SPI signals
    wire spi_select;
    wire [31:0] spi_read_data;
    wire spi_ready;
    wire [7:0] spi_prdata;
    wire spi_pready, spi_pslverr;
    wire spi_pwrite, spi_psel, spi_penable;
    wire [2:0] spi_paddr;
    wire [7:0] spi_pwdata;
    
    // Address decode
    parameter SPI_BASE = 32'h1000_0000;
    parameter SPI_END  = 32'h1000_0020;
    
    assign spi_select = (A >= SPI_BASE) && (A < SPI_END);
    assign mem_access = !spi_select;
    
    // Regular memory access
    always @(posedge clk) begin
        if (WE && mem_access && rst) begin
            mem[A[31:2]] <= WD;
        end
    end
    
    assign mem_rd = (rst == 0) ? 32'd0 : mem[A[31:2]];
    
    // APB Bridge instance
    APB_Bridge apb_bridge(
        .clk(clk),
        .rst(rst),
        .mem_write(WE && spi_select),
        .mem_read(!WE && spi_select),
        .mem_addr(A),
        .mem_write_data(WD),
        .mem_read_data(spi_read_data),
        .mem_ready(spi_ready),
        .PCLK(),
        .PRESETn(),
        .PWRITE(spi_pwrite),
        .PSEL(spi_psel),
        .PENABLE(spi_penable),
        .PADDR(spi_paddr),
        .PWDATA(spi_pwdata),
        .PRDATA(spi_prdata),
        .PREADY(spi_pready),
        .PSLVERR(spi_pslverr)
    );
    
    // SPI IP Core instance
    spi_top spi_master(
        .PCLK(clk),
        .PRESETn(rst),
        .PWRITE(spi_pwrite),
        .PSEL(spi_psel),
        .PENABLE(spi_penable),
        .PADDR(spi_paddr),
        .PWDATA(spi_pwdata),
        .PRDATA(spi_prdata),
        .PREADY(spi_pready),
        .PSLVERR(spi_pslverr),
        .miso(miso),
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .spi_interrupt_request(spi_interrupt)
    );
    
    // Output multiplexing
    assign RD = spi_select ? spi_read_data : mem_rd;
    assign mem_ready = spi_select ? spi_ready : 1'b1;
    
    // Initialize memory
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'd0;
        mem[5] = 32'h11;
    end
endmodule
