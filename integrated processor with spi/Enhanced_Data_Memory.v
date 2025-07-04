module Enhanced_Data_Memory(
    input clk, rst, WE,
    input [31:0] A, WD,
    output [31:0] RD,
    output mem_ready,
    output mem_error,        // NEW
    
    // SPI interface
    output sclk, ss, mosi, spi_interrupt,
    input miso,
    
    // Debug interface - NEW
    input [31:0] debug_addr,
    input debug_read, debug_write,
    input [31:0] debug_write_data,
    output [31:0] debug_read_data,
    
    // Performance monitoring - NEW
    output spi_transaction,
    output pipeline_error,
    
    // Pipeline monitoring inputs - NEW
    input instruction_executed,
    input pipeline_stall,
    input branch_taken
);
    
    // Regular memory
    reg [31:0] mem [0:1023];
    wire [31:0] mem_rd;
    wire mem_access;
    
    // SPI signals
    wire spi_select;
    wire [31:0] spi_read_data;
    wire spi_ready, spi_error;
    wire [7:0] spi_prdata;
    wire spi_pready, spi_pslverr;
    wire spi_pwrite, spi_psel, spi_penable;
    wire [2:0] spi_paddr;
    wire [7:0] spi_pwdata;
    
    // Debug signals - NEW
    wire debug_select;
    wire perf_select;
    wire [31:0] debug_data, perf_data;
    
    // Address decode - ENHANCED
    parameter SPI_BASE = 32'h1000_0000;
    parameter SPI_END  = 32'h1000_0020;
    parameter DBG_BASE = 32'h2000_0000;
    parameter DBG_END  = 32'h2000_0100;
    parameter PERF_BASE = 32'h3000_0000;
    parameter PERF_END  = 32'h3000_0100;
    
    assign spi_select = (A >= SPI_BASE) && (A < SPI_END);
    assign debug_select = (A >= DBG_BASE) && (A < DBG_END);
    assign perf_select = (A >= PERF_BASE) && (A < PERF_END);
    assign mem_access = !spi_select && !debug_select && !perf_select;
    
    // Memory bounds checking - NEW
    wire mem_bounds_ok = (A[31:2] < 1024) && mem_access;
    assign pipeline_error = mem_access && !mem_bounds_ok;
    
    // Regular memory access with bounds checking - ENHANCED
    always @(posedge clk) begin
        if (WE && mem_bounds_ok && rst) begin
            mem[A[31:2]] <= WD;
        end
    end
    
    assign mem_rd = (!rst) ? 32'd0 : 
                   mem_bounds_ok ? mem[A[31:2]] : 32'hDEADBEEF;
    
    // Enhanced APB Bridge instance - CHANGED
    Enhanced_APB_Bridge apb_bridge(
        .clk(clk),
        .rst(rst),
        .mem_write(WE && spi_select),
        .mem_read(!WE && spi_select),
        .mem_addr(A),
        .mem_write_data(WD),
        .mem_read_data(spi_read_data),
        .mem_ready(spi_ready),
        .mem_error(spi_error),           // NEW
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
    
    // SPI IP Core instance - UNCHANGED
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
    
    // Performance Counter - NEW
    performance_counter perf_counter(
        .clk(clk),
        .rst(rst),
        .instruction_executed(instruction_executed),
        .pipeline_stall(pipeline_stall),
        .branch_taken(branch_taken),
        .spi_transaction(spi_psel && spi_penable && spi_pready),
        .debug_addr(A),
        .debug_read(!WE && perf_select),
        .debug_data(perf_data),
        .cycle_count(),
        .instruction_count(),
        .stall_count(),
        .branch_count(),
        .spi_transaction_count()
    );
    
    // Debug Registers - NEW
    debug_registers debug_regs(
        .clk(clk),
        .rst(rst),
        .debug_addr(A),
        .debug_read(!WE && debug_select),
        .debug_write(WE && debug_select),
        .debug_write_data(WD),
        .debug_read_data(debug_data),
        .spi_interrupt(spi_interrupt),
        .spi_busy(~spi_ready),
        .spi_status(spi_prdata),
        .ss(ss),
        .sclk(sclk),
        .mem_error(spi_error || pipeline_error),
        .pipeline_error(pipeline_error)
    );
    
    // Output multiplexing - ENHANCED
    assign RD = spi_select ? spi_read_data : 
               debug_select ? debug_data :
               perf_select ? perf_data : 
               mem_rd;
    
    assign mem_ready = spi_select ? spi_ready : 1'b1;
    assign mem_error = spi_select ? spi_error : pipeline_error;
    assign spi_transaction = spi_psel && spi_penable && spi_pready;
    
    // Initialize memory - UNCHANGED
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'd0;
        mem[5] = 32'h11;
    end
endmodule
