module ControlUnit (
    input [5:0] opcode,        // Instruction opcode
    input [5:0] funct,         // Function code for R-type instructions
    output reg RegWriteD,      // Register write enable
    output reg MemtoRegD,      // Memory to register
    output reg MemWriteD,      // Memory write enable
    output reg JumpD,          // Jump control
    output reg BranchD,        // Branch control
    output reg [1:0] ALUControlD, // ALU control
    output reg ALUSrcD,        // ALU source select
    output reg RegDstD,        // Register destination select
    output reg [4:0] WBControl  // Write-back control (simplified)
);

    always @(*) begin
        // Default values
        RegWriteD = 1'b0;
        MemtoRegD = 1'b0;
        MemWriteD = 1'b0;
        JumpD = 1'b0;
        BranchD = 1'b0;
        ALUControlD = 2'b00;
        ALUSrcD = 1'b0;
        RegDstD = 1'b0;
        WBControl = 5'b00000;

        case (opcode)
            6'b000000: begin // R-type instructions
                RegWriteD = 1'b1;
                RegDstD = 1'b1;
                ALUControlD = (funct == 6'b100000) ? 2'b10 : // ADD
                              (funct == 6'b100010) ? 2'b11 : // SUB
                              (funct == 6'b100100) ? 2'b00 : // AND
                              (funct == 6'b100101) ? 2'b01 : // OR
                              2'b00; // Default
            end
            6'b100011: begin // LW
                RegWriteD = 1'b1;
                ALUSrcD = 1'b1;
                MemtoRegD = 1'b1;
                ALUControlD = 2'b10; // ADD
            end
            6'b101011: begin // SW
                ALUSrcD = 1'b1;
                MemWriteD = 1'b1;
                ALUControlD = 2'b10; // ADD
            end
            6'b000100: begin // BEQ
                BranchD = 1'b1;
                ALUControlD = 2'b11; // SUB
            end
            6'b000010: begin // J
                JumpD = 1'b1;
            end
            // Add other instruction types as needed
            default: begin
                // Default case, all outputs remain 0
            end
        endcase
    end
endmodule
