module performance_counter(
    input clk, rst,
    input instruction_executed,
    input pipeline_stall,
    input branch_taken,
    input spi_transaction,
    input [31:0] debug_addr,
    input debug_read,
    output reg [31:0] debug_data,
    output reg [31:0] cycle_count,
    output reg [31:0] instruction_count,
    output reg [31:0] stall_count,
    output reg [31:0] branch_count,
    output reg [31:0] spi_transaction_count
);
    
    parameter PERF_BASE = 32'h3000_0000;
    
    // Performance counters
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cycle_count <= 0;
            instruction_count <= 0;
            stall_count <= 0;
            branch_count <= 0;
            spi_transaction_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (instruction_executed) instruction_count <= instruction_count + 1;
            if (pipeline_stall) stall_count <= stall_count + 1;
            if (branch_taken) branch_count <= branch_count + 1;
            if (spi_transaction) spi_transaction_count <= spi_transaction_count + 1;
        end
    end
    
    // Debug read interface
    always @(*) begin
        if (debug_read) begin
            case (debug_addr)
                PERF_BASE + 0:  debug_data = cycle_count;
                PERF_BASE + 4:  debug_data = instruction_count;
                PERF_BASE + 8:  debug_data = stall_count;
                PERF_BASE + 12: debug_data = branch_count;
                PERF_BASE + 16: debug_data = spi_transaction_count;
                PERF_BASE + 20: debug_data = (instruction_count > 0) ? 
                                            (cycle_count * 100) / instruction_count : 0; // CPI * 100
                default: debug_data = 32'h0;
            endcase
        end else begin
            debug_data = 32'h0;
        end
    end
endmodule
