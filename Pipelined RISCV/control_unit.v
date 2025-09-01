// Main Control Unit (Complete for RV32I, including AUIPC)
module control_unit (
    input      [6:0]            op,           // Instruction opcode [6:0]

    // Outputs
    output reg                  reg_write_d,  // Enable register write in WB stage
    output reg [1:0]            result_src_d, // Selects the source for write-back
    output reg                  mem_write_d,  // Enable data memory write
    output reg                  jump_d,       // Indicates a jump instruction
    output reg                  branch_d,     // Indicates a branch instruction
    output reg                  alu_src_d,    // Selects the ALU's second operand (SrcB)
    output reg [1:0]            alu_op_d,     // High-level command for the ALU Control Unit
    output reg                  ALUSrcA_d     // New output: Selects the ALU's first operand (SrcA)
);

    // Define RISC-V Opcodes for clarity
    parameter R_TYPE  = 7'b0110011;
    parameter I_TYPE  = 7'b0010011;
    parameter LOAD    = 7'b0000011;
    parameter STORE   = 7'b0100011;
    parameter BRANCH  = 7'b1100011;
    parameter JALR    = 7'b1100111;
    parameter JAL     = 7'b1101111;
    parameter LUI     = 7'b0110111;
    parameter AUIPC   = 7'b0010111;

    always @(*) begin
        // --- Set default values ---
        reg_write_d   = 1'b0;
        result_src_d  = 2'b00;
        mem_write_d   = 1'b0;
        jump_d        = 1'b0;
        branch_d      = 1'b0;
        alu_src_d     = 1'b0;
        alu_op_d      = 2'b00;
        ALUSrcA_d     = 1'b0; // Default to selecting the register value for SrcA

        // --- Decode the opcode ---
        case (op)
            R_TYPE:   begin reg_write_d=1'b1; alu_src_d=1'b0; alu_op_d=2'b10; end
            I_TYPE:   begin reg_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b11; end
            LOAD:     begin reg_write_d=1'b1; result_src_d=2'b01; alu_src_d=1'b1; alu_op_d=2'b00; end
            STORE:    begin mem_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b00; end
            BRANCH:   begin branch_d=1'b1;    alu_src_d=1'b0; alu_op_d=2'b01; end
            JALR:     begin reg_write_d=1'b1; jump_d=1'b1; result_src_d=2'b10; alu_src_d=1'b1; alu_op_d=2'b00; end
            JAL:      begin reg_write_d=1'b1; jump_d=1'b1; result_src_d=2'b10; end
            LUI:      begin reg_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b11; end
            AUIPC:    begin
                reg_write_d   = 1'b1;
                alu_src_d     = 1'b1;
                alu_op_d      = 2'b00;  // ALU must perform ADD
                ALUSrcA_d     = 1'b1;   // **Set for AUIPC: Select PC for ALU input A**
            end
        endcase
    end
endmodule
