// IF/ID Register: Connects Fetch and Decode stages
module if_id_register (
    input                       clk,
    input                       reset,
    input                       stall_d, // Stall signal from Hazard Unit
    input                       flush_d, // Flush signal from Hazard Unit

    // Inputs from IF Stage
    input      [31:0]           pc_f,
    input      [31:0]           pc_plus_4_f,
    input      [31:0]           inst_f,

    // Outputs to ID Stage
    output reg [31:0]           pc_d,
    output reg [31:0]           pc_plus_4_d,
    output reg [31:0]           inst_d
);

    always @(posedge clk) begin
        if (reset || flush_d) begin
            // On reset or flush, insert a bubble (a NOP instruction)
            pc_d          <= 32'b0;
            pc_plus_4_d   <= 32'b0;
            inst_d        <= 32'h00000013; // NOP: addi x0, x0, 0
        end else if (!stall_d) begin
            // If not stalled, latch the inputs from the IF stage
            pc_d          <= pc_f;
            pc_plus_4_d   <= pc_plus_4_f;
            inst_d        <= inst_f;
        end
        // If stalled (stall_d is high), do nothing, effectively freezing the stage.
    end

endmodule
