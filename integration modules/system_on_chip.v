module system_on_chip(
    input clk,
    input reset,
    // --- SPI Pins for external connection ---
    input  miso,
    output sclk,
    output ss,
    output mosi
);
    // --- Wires for RISC-V Core Memory Interface ---
    wire [31:0] cpu_addr, cpu_wdata, cpu_rdata;
    wire        cpu_mem_write, cpu_mem_read, cpu_stall;
    // --- Wires for RAM Interface ---
    wire        ram_cs, ram_we;
    wire [31:0] ram_rdata;
    // --- Wires for SPI APB Interface ---
    wire        spi_psel, spi_penable, spi_pwrite;
    wire [2:0]  spi_paddr;
    wire [7:0]  spi_pwdata, spi_prdata;
    wire        spi_pready;
    wire        spi_interrupt_request;

    // --- INSTANTIATE THE RISC-V CPU CORE ---
    riscv_pipeline cpu_core (
        .clk(clk), .reset(reset), .stall_in(cpu_stall), .mem_rdata(cpu_rdata),
        .mem_addr(cpu_addr), .mem_wdata(cpu_wdata), .mem_write(cpu_mem_write), .mem_read(cpu_mem_read)
    );

    // --- INSTANTIATE THE DATA RAM ---
    data_ram main_ram (
        .clk(clk), .cs(ram_cs), .we(ram_we), .addr(cpu_addr), .wdata(cpu_wdata), .rdata(ram_rdata)
    );

    // --- INSTANTIATE THE SPI CONTROLLER ---
    spi_controller spi_peripheral (
        .PCLK(clk), .PRESETn(reset), .PSEL(spi_psel), .PENABLE(spi_penable), .PWRITE(spi_pwrite),
        .PADDR(spi_paddr), .PWDATA(spi_pwdata), .PREADY(spi_pready), .PRDATA(spi_prdata),
        .miso(miso), .sclk(sclk), .ss(ss), .mosi(mosi), .spi_interrupt_request(spi_interrupt_request)
    );

    // --- INSTANTIATE THE MEMORY MAP DECODER ---
    memory_map_decoder decoder (
        .PCLK(clk), .PRESETn(reset), .cpu_addr(cpu_addr), .cpu_wdata(cpu_wdata),
        .cpu_mem_write(cpu_mem_write), .cpu_mem_read(cpu_mem_read), .ram_rdata(ram_rdata),
        .spi_prdata(spi_prdata), .spi_pready(spi_pready), .cpu_rdata(cpu_rdata),
        .cpu_stall(cpu_stall), .ram_cs(ram_cs), .ram_we(ram_we), .spi_psel(spi_psel),
        .spi_penable(spi_penable), .spi_pwrite(spi_pwrite), .spi_paddr(spi_paddr), .spi_pwdata(spi_pwdata)
    );
endmodule
