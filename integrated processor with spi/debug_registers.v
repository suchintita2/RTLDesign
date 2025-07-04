module debug_registers(
    input clk, rst,
    input [31:0] debug_addr,
    input debug_read, debug_write,
    input [31:0] debug_write_data,
    output reg [31:0] debug_read_data,
    
    // SPI status inputs
    input spi_interrupt,
    input spi_busy,
    input [7:0] spi_status,
    input ss, sclk,
    
    // Error status
    input mem_error,
    input pipeline_error
);
    
    parameter DBG_BASE = 32'h2000_0000;
    reg [31:0] error_count;
    reg [31:0] debug_control;
    
    // Error counter
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            error_count <= 0;
            debug_control <= 0;
        end else begin
            if (mem_error || pipeline_error) 
                error_count <= error_count + 1;
            if (debug_write && debug_addr == DBG_BASE + 24)
                debug_control <= debug_write_data;
        end
    end
    
    // Debug read interface
    always @(*) begin
        if (debug_read) begin
            case (debug_addr)
                DBG_BASE + 0:  debug_read_data = {24'b0, spi_status};
                DBG_BASE + 4:  debug_read_data = {29'b0, spi_busy, spi_interrupt, ss};
                DBG_BASE + 8:  debug_read_data = error_count;
                DBG_BASE + 12: debug_read_data = {30'b0, pipeline_error, mem_error};
                DBG_BASE + 16: debug_read_data = {31'b0, sclk};
                DBG_BASE + 20: debug_read_data = 32'hDEBUG_ID; // Debug ID
                DBG_BASE + 24: debug_read_data = debug_control;
                default: debug_read_data = 32'h0;
            endcase
        end else begin
            debug_read_data = 32'h0;
        end
    end
endmodule
