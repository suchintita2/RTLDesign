module Hazard_Unit(
  input wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
  input wire RegWriteE, RegWriteM, RegWriteW,
  output reg StallF, StallD, FlushD,
  output reg [1:0] ForwardAE, ForwardBE
);
  always @(*) begin
    // Default values
    StallF = 0;
    StallD = 0;
    FlushD = 0;
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forwarding logic
    if (RegWriteM && (RdM != 0) && (RdM == Rs1E))
      ForwardAE = 2'b10;
    else if (RegWriteW && (RdW != 0) && (RdW == Rs1E))
      ForwardAE = 2'b01;

    if (RegWriteM && (RdM != 0) && (RdM == Rs2E))
      ForwardBE = 2'b10;
    else if (RegWriteW && (RdW != 0) && (RdW == Rs2E))
      ForwardBE = 2'b01;

    // Load-use hazard
    if ((RdE != 0) && RegWriteE && ((RdE == Rs1D) || (RdE == Rs2D))) begin
      StallF = 1;
      StallD = 1;
      FlushD = 1;
    end
  end
endmodule
