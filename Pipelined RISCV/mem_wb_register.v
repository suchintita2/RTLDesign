// MEM/WB Register: Connects Memory and Write Back stages
module mem_wb_register (
    input                       clk,
    input                       reset,

    // Control Signals from MEM Stage
    input                       reg_write_m,
    input      [1:0]            result_src_m,
    
    // Data from MEM Stage
    input      [31:0]           read_data_m,  // Data from Data Memory
    input      [31:0]           alu_result_m,
    input      [31:0]           pc_plus_4_m,
    input      [4:0]            rd_m,

    // Outputs to WB Stage
    output reg                  reg_write_w,
    output reg [1:0]            result_src_w,
    output reg [31:0]           read_data_w,
    output reg [31:0]           alu_result_w,
    output reg [31:0]           pc_plus_4_w,
    output reg [4:0]            rd_w
);

    always @(posedge clk) begin
        if (reset) begin
            reg_write_w  <= 1'b0;
            result_src_w <= 2'b0;
        } else {
            // Latch all signals for the final stage
            reg_write_w  <= reg_write_m;
            result_src_w <= result_src_m;
            read_data_w  <= read_data_m;
            alu_result_w <= alu_result_m;
            pc_plus_4_w  <= pc_plus_4_m;
            rd_w         <= rd_m;
        }
    end

endmodule
