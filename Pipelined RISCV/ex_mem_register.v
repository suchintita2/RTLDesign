// EX/MEM Register: Connects Execute and Memory stages (Corrected)
module ex_mem_register (
    input                       clk,
    input                       reset,

    // Control Signals from EX Stage
    input                       reg_write_e,
    input      [1:0]            result_src_e,
    input                       mem_write_e,
    
    // Data from EX Stage
    input      [31:0]           alu_result_e,
    input      [31:0]           write_data_e,
    input      [31:0]           pc_plus_4_e,
    input      [4:0]            rd_e,

    // Outputs to MEM Stage
    output reg                  reg_write_m,
    output reg [1:0]            result_src_m,
    output reg                  mem_write_m,
    output reg [31:0]           alu_result_m,
    output reg [31:0]           write_data_m,
    output reg [31:0]           pc_plus_4_m,
    output reg [4:0]            rd_m
);

    always @(posedge clk) begin
        if (reset) begin
            reg_write_m  <= 1'b0;
            result_src_m <= 2'b0;
            mem_write_m  <= 1'b0;
        } else {
            // Latch all signals for the next stage (without Zero)
            reg_write_m  <= reg_write_e;
            result_src_m <= result_src_e;
            mem_write_m  <= mem_write_e;
            alu_result_m <= alu_result_e;
            write_data_m <= write_data_e;
            pc_plus_4_m  <= pc_plus_4_e;
            rd_m         <= rd_e;
        }
    end

endmodule
