module alu (
    input      [31:0]           a, b,            // Operands
    input      [3:0]            alu_control,     // 4-bit control signal
    output reg [31:0]           result,          // ALU result
    output reg                  zero             // Zero flag (if result is 0)
);
    // The shift amount is the lower 5 bits of operand 'b'
    wire [4:0] shift_amount = b[4:0];

    always @(*) begin
        case (alu_control)
            4'b0000: result = a + b;                  // ADD, ADDI
            4'b0001: result = a - b;                  // SUB
            4'b0010: result = a & b;                  // AND, ANDI
            4'b0011: result = a | b;                  // OR, ORI
            4'b0100: result = a ^ b;                  // XOR, XORI
            4'b0101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT, SLTI
            4'b0110: result = (a < b) ? 32'd1 : 32'd0; // SLTU, SLTIU
            4'b0111: result = a << shift_amount;      // SLL, SLLI
            4'b1000: result = a >> shift_amount;      // SRL, SRLI
            4'b1001: result = $signed(a) >>> shift_amount; // SRA, SRAI
            default: result = 32'b0;
        endcase
        zero = (result == 32'b0);
    end

endmodule
