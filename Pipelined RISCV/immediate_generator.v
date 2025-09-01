// Immediate Generator
module immediate_generator (
    input      [31:0]           instruction, // Input instruction from ID stage
    output     [31:0]           imm_ext      // Output: sign-extended immediate
);
    // Extract opcode to determine immediate format
    wire [6:0] op = instruction[6:0];

    // RISC-V Opcodes
    parameter LUI     = 7'b0110111;
    parameter AUIPC   = 7'b0010111;
    parameter JAL     = 7'b1101111;
    parameter JALR    = 7'b1100111;
    parameter BRANCH  = 7'b1100011;
    parameter LOAD    = 7'b0000011;
    parameter STORE   = 7'b0100011;
    parameter I_TYPE  = 7'b0010011;

    // Generate immediate based on type
    assign imm_ext =
           (op == LUI || op == AUIPC) ? {instruction[31:12], 12'b0} : // U-Type
           (op == JAL)                 ? {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0} : // J-Type
           (op == JALR || op == I_TYPE || op == LOAD) ? {{21{instruction[31]}}, instruction[30:20]} : // I-Type
           (op == BRANCH)              ? {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0} : // B-Type
           (op == STORE)               ? {{21{instruction[31]}}, instruction[30:25], instruction[11:7]} : // S-Type
           32'b0; // Default case
endmodule
