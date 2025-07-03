module APB_Bridge(
    // RISC-V side (memory interface)
    input clk, rst,
    input mem_write, mem_read,
    input [31:0] mem_addr, mem_write_data,
    output reg [31:0] mem_read_data,
    output reg mem_ready,
    
    // APB side (SPI interface)
    output PCLK, PRESETn,
    output reg PWRITE, PSEL, PENABLE,
    output reg [2:0] PADDR,
    output reg [7:0] PWDATA,
    input [7:0] PRDATA,
    input PREADY, PSLVERR
);

    // SPI base address
    parameter SPI_BASE_ADDR = 32'h1000_0000;
    parameter SPI_END_ADDR  = 32'h1000_0020;
    
    // APB state machine
    reg [1:0] apb_state;
    parameter APB_IDLE = 2'b00, APB_SETUP = 2'b01, APB_ACCESS = 2'b10;
    
    // Address decode
    wire spi_select = (mem_addr >= SPI_BASE_ADDR) && (mem_addr < SPI_END_ADDR);
    
    // Clock and reset passthrough
    assign PCLK = clk;
    assign PRESETn = rst;
    
    // APB Bridge Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            apb_state <= APB_IDLE;
            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
            PADDR <= 3'b0;
            PWDATA <= 8'b0;
            mem_ready <= 1'b1;
            mem_read_data <= 32'b0;
        end
        else begin
            case (apb_state)
                APB_IDLE: begin
                    mem_ready <= 1'b1;
                    if (spi_select && (mem_write || mem_read)) begin
                        PSEL <= 1'b1;
                        PWRITE <= mem_write;
                        PADDR <= mem_addr[4:2];
                        PWDATA <= mem_write_data[7:0];
                        apb_state <= APB_SETUP;
                        mem_ready <= 1'b0;
                    end
                end
                
                APB_SETUP: begin
                    PENABLE <= 1'b1;
                    apb_state <= APB_ACCESS;
                end
                
                APB_ACCESS: begin
                    if (PREADY) begin
                        mem_read_data <= {24'b0, PRDATA};
                        PSEL <= 1'b0;
                        PENABLE <= 1'b0;
                        apb_state <= APB_IDLE;
                        mem_ready <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule
