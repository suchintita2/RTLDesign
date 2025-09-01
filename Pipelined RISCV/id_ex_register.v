// ID/EX Register: Connects Decode and Execute stages
module id_ex_register (
    input                       clk,
    input                       reset,
    input                       flush_e, // Flush signal from Hazard Unit

    // Control Signals from ID Stage
    input                       reg_write_d,
    input      [1:0]            result_src_d,
    input                       mem_write_d,
    input                       jump_d,
    input                       branch_d,
    input      [2:0]            alu_control_d,
    input                       alu_src_d,
    
    // Data from ID Stage
    input      [31:0]           rd1_d,
    input      [31:0]           rd2_d,
    input      [31:0]           pc_d,
    input      [31:0]           pc_plus_4_d,
    input      [31:0]           imm_ext_d,
    input      [4:0]            rs1_d,
    input      [4:0]            rs2_d,
    input      [4:0]            rd_d,

    // Outputs to EX Stage
    output reg                  reg_write_e,
    output reg [1:0]            result_src_e,
    output reg                  mem_write_e,
    output reg                  jump_e,
    output reg                  branch_e,
    output reg [2:0]            alu_control_e,
    output reg                  alu_src_e,
    output reg [31:0]           rd1_e,
    output reg [31:0]           rd2_e,
    output reg [31:0]           pc_e,
    output reg [31:0]           pc_plus_4_e,
    output reg [31:0]           imm_ext_e,
    output reg [4:0]            rs1_e,
    output reg [4:0]            rs2_e,
    output reg [4:0]            rd_e
);

    always @(posedge clk) begin
        if (reset || flush_e) begin
            // Flush the pipeline by de-asserting control signals to create a bubble
            reg_write_e   <= 1'b0;
            result_src_e  <= 2'b0;
            mem_write_e   <= 1'b0;
            jump_e        <= 1'b0;
            branch_e      <= 1'b0;
            alu_src_e     <= 1'b0;
            // Data values don't matter when control is zero, but clearing is good practice
            rd_e <= 5'b0; 
        } else begin
            // Latch all signals for the next stage
            reg_write_e   <= reg_write_d;
            result_src_e  <= result_src_d;
            mem_write_e   <= mem_write_d;
            jump_e        <= jump_d;
            branch_e      <= branch_d;
            alu_control_e <= alu_control_d;
            alu_src_e     <= alu_src_d;
            rd1_e         <= rd1_d;
            rd2_e         <= rd2_d;
            pc_e          <= pc_d;
            pc_plus_4_e   <= pc_plus_4_d;
            imm_ext_e     <= imm_ext_d;
            rs1_e         <= rs1_d;
            rs2_e         <= rs2_d;
            rd_e          <= rd_d;
        end
    end

endmodule
