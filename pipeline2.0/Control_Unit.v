module Control_Unit(
  input wire [6:0] op,
  input wire [2:0] funct3,
  input wire funct7,
  output reg RegWrite,
  output reg [1:0] ResultSrc,
  output reg MemWrite,
  output reg Jump,
  output reg Branch,
  output reg [2:0] ALUControl,
  output reg ALUSrc,
  output reg [1:0] ImmSrc
);
  always @(*) begin
    // Defaults
    RegWrite = 0;
    ResultSrc = 2'b00;
    MemWrite = 0;
    Jump = 0;
    Branch = 0;
    ALUControl = 3'b000;
    ALUSrc = 0;
    ImmSrc = 2'b00;

    case (op)
      7'b0010011: begin // addi
        RegWrite = 1;
        ALUSrc = 1;
        ALUControl = 3'b000;
        ImmSrc = 2'b00;
      end
      7'b0110011: begin // add
        RegWrite = 1;
        ALUSrc = 0;
        ALUControl = (funct3 == 3'b000 && funct7 == 1'b0) ? 3'b000 : 3'b000;
      end
      7'b0000011: begin // lw
        RegWrite = 1;
        ALUSrc = 1;
        ResultSrc = 2'b01;
        ALUControl = 3'b000;
        ImmSrc = 2'b00;
      end
      7'b0100011: begin // sw
        MemWrite = 1;
        ALUSrc = 1;
        ALUControl = 3'b000;
        ImmSrc = 2'b01;
      end
      7'b1100011: begin // beq
        Branch = 1;
        ALUSrc = 0;
        ALUControl = 3'b001; // subtract for comparison
        ImmSrc = 2'b10;
      end
      7'b1101111: begin // jal
        Jump = 1;
        RegWrite = 1;
        ResultSrc = 2'b10;
      end
    endcase
  end
endmodule
