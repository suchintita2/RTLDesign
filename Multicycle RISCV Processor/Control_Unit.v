module Control_Unit(
    input wire clk,
    input wire rst,
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7,
    input wire Zero,
    output reg PCWrite,
    output reg AdrSrc,
    output reg MemWrite,
    output reg IRWrite,
    output reg [1:0] ResultSrc,
    output reg [2:0] ALUControl,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ImmSrc,
    output reg RegWrite
);
    // FSM state definitions
    parameter FETCH        = 4'b0000;
    parameter DECODE       = 4'b0001;
    parameter MEMADR       = 4'b0010;
    parameter MEMREAD      = 4'b0011;
    parameter MEMWRITEBACK = 4'b0100;
    parameter MEMWRITE     = 4'b0101;
    parameter EXECUTE      = 4'b0110;
    parameter ALUWB        = 4'b0111;
    parameter BRANCH       = 4'b1000;
    parameter JRESET       = 4'b1001;
    
    reg [3:0] state, next_state;
    reg [1:0] ALUOp;
    
    // State register
    always @(posedge clk) begin
        if (~rst)
            state <= FETCH;
        else
            state <= next_state;
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (op)
                    7'b0000011: next_state = MEMADR;     // lw
                    7'b0100011: next_state = MEMADR;     // sw
                    7'b0110011: next_state = EXECUTE;    // R-type
                    7'b1100011: next_state = BRANCH;     // beq/bne
                    7'b1101111: next_state = JRESET;     // jal
			7'b0010011: next_state = EXECUTE; //I-type
                    default: next_state = FETCH;
                endcase
            end
            MEMADR: begin
                if (op == 7'b0000011) next_state = MEMREAD;
                else if (op == 7'b0100011) next_state = MEMWRITE;
                else next_state = FETCH;
            end
            MEMREAD: next_state = MEMWRITEBACK;
            MEMWRITEBACK: next_state = FETCH;
            MEMWRITE: next_state = FETCH;
            EXECUTE: next_state = ALUWB;
            ALUWB: next_state = FETCH;
            BRANCH: next_state = FETCH;
            JRESET: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end
    
    // Control signal assignments
    always @(*) begin
        // Default values
        PCWrite = 0;
        AdrSrc = 0;
        MemWrite = 0;
        IRWrite = 0;
        ResultSrc = 2'b00;
        ALUSrcA = 0;
        ALUSrcB = 2'b00;
        ImmSrc = 2'b00;
        RegWrite = 0;
        ALUOp = 2'b00;
        
        case (state)
            FETCH: begin
                AdrSrc = 0;
                IRWrite = 1;
                ALUSrcA = 0;      // OldPC
                ALUSrcB = 2'b01;  // 4
                ALUOp = 2'b00;    // ADD
                ResultSrc = 2'b10; // ALUResult directly to PC
                PCWrite = 1;
            end
            DECODE: begin
                ALUSrcA = 0;      // OldPC
                ALUSrcB = 2'b10;  // ImmExt
                ALUOp = 2'b00;    // ADD
                
                case (op)
                    7'b0000011: ImmSrc = 2'b00;  // lw
                    7'b0100011: ImmSrc = 2'b01;  // sw
                    7'b1100011: ImmSrc = 2'b10;  // beq/bne
                    7'b1101111: ImmSrc = 2'b11;  // jal
                    default:    ImmSrc = 2'b00;
                endcase
            end
            MEMADR: begin
                ALUSrcA = 1;      // RD1
                ALUSrcB = 2'b10;  // ImmExt
                ALUOp = 2'b00;    // ADD
            end
            MEMREAD: begin
                AdrSrc = 1;
                ResultSrc = 2'b00;  // ALUOut
            end
            MEMWRITEBACK: begin
                ResultSrc = 2'b01;  // Data
                RegWrite = 1;
            end
            MEMWRITE: begin
                AdrSrc = 1;
                MemWrite = 1;
            end
            EXECUTE: begin
    			ALUSrcA = 1; // RD1
    			if (op == 7'b0010011) // I-type arithmetic
        		ALUSrcB = 2'b10; // ImmExt
    			else
        		ALUSrcB = 2'b00; // RD2 for R-type
    			ALUOp = 2'b10;
		end
            ALUWB: begin
                ResultSrc = 2'b00;  // ALUOut
                RegWrite = 1;
            end
            BRANCH: begin
                ALUSrcA = 1;      // RD1
                ALUSrcB = 2'b00;  // RD2
                ALUOp = 2'b01;    // SUB
                
                if (Zero) PCWrite = 1;
            end
            JRESET: begin
                ResultSrc = 2'b10;  // OldPC
                PCWrite = 1;
                RegWrite = 1;
            end
        endcase
    end
    
    // ALU Decoder
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000;  // ADD
            2'b01: ALUControl = 3'b001;  // SUB
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (op[5] && funct7) 
                            ALUControl = 3'b001;  // SUB
                        else 
                            ALUControl = 3'b000;  // ADD
                    end
                    3'b010: ALUControl = 3'b101;  // SLT
                    3'b110: ALUControl = 3'b011;  // OR
                    3'b111: ALUControl = 3'b010;  // AND
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
endmodule
