// Memory Map Decoder and Bus Arbiter
module memory_map_decoder (
    input           PCLK, PRESETn,
    input  [31:0]   cpu_addr, cpu_wdata,
    input           cpu_mem_write, cpu_mem_read,
    input  [31:0]   ram_rdata,
    input  [7:0]    spi_prdata,
    input           spi_pready,
    output [31:0]   cpu_rdata,
    output reg      cpu_stall,
    output          ram_cs, ram_we,
    output reg      spi_psel, spi_penable,
    output          spi_pwrite,
    output [2:0]    spi_paddr,
    output [7:0]    spi_pwdata
);
    wire is_ram_addr = (cpu_addr >= 32'h0000_0000 && cpu_addr < 32'h0001_0000);
    wire is_spi_addr = (cpu_addr >= 32'h1000_0000 && cpu_addr < 32'h1000_0100);
    assign ram_cs = is_ram_addr && (cpu_mem_read || cpu_mem_write);
    assign ram_we = is_ram_addr && cpu_mem_write;
    assign spi_pwrite = cpu_mem_write;
    assign spi_paddr  = cpu_addr[4:2];
    assign spi_pwdata = cpu_wdata[7:0];
    reg [1:0] apb_state, next_apb_state;
    parameter APB_IDLE = 2'b00, APB_SETUP = 2'b01, APB_ACCESS = 2'b10;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) apb_state <= APB_IDLE;
        else          apb_state <= next_apb_state;
    end
    always @(*) begin
        next_apb_state = APB_IDLE; spi_psel = 1'b0; spi_penable = 1'b0; cpu_stall = 1'b0;
        case(apb_state)
            APB_IDLE:
                if (is_spi_addr && (cpu_mem_read || cpu_mem_write)) {
                    next_apb_state = APB_SETUP; spi_psel = 1'b1; cpu_stall = 1'b1;
                }
            APB_SETUP:
                begin
                    next_apb_state = APB_ACCESS; spi_psel = 1'b1; spi_penable = 1'b1;
                    if (!spi_pready) {cpu_stall = 1'b1; next_apb_state = APB_SETUP;}
                end
            APB_ACCESS:
                begin
                    spi_psel = 1'b0; spi_penable = 1'b0; next_apb_state = APB_IDLE;
                end
        endcase
    end
    assign cpu_rdata = is_ram_addr ? ram_rdata : {24'b0, spi_prdata};
endmodule
