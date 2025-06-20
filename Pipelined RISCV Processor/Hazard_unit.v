module hazard_unit(
    input rst,
    input RegWriteM, RegWriteW,
    input [4:0] RD_M, RD_W, RD_E,
    input [4:0] Rs1_E, Rs2_E,
    input [4:0] RS1_D, RS2_D,
    input [1:0] ResultSrcE,
    input BranchE,
    input ZeroE,
    output [1:0] ForwardAE, ForwardBE,
    output StallF, StallD, FlushD, FlushE
);

    // Forwarding Logic
    assign ForwardAE = (RegWriteM && (RD_M != 0) && (RD_M == Rs1_E)) ? 2'b10 :
                       (RegWriteW && (RD_W != 0) && (RD_W == Rs1_E)) ? 2'b01 :
                       2'b00;

    assign ForwardBE = (RegWriteM && (RD_M != 0) && (RD_M == Rs2_E)) ? 2'b10 :
                       (RegWriteW && (RD_W != 0) && (RD_W == Rs2_E)) ? 2'b01 :
                       2'b00;

    // Load-Use Hazard Detection
    wire lw_stall = (ResultSrcE == 2'b01) && ((RD_E == RS1_D) || (RD_E == RS2_D));

    // Branch Flush Detection
    wire branch_taken = BranchE && ZeroE;

    // Stall/Flush Signals
    assign StallF  = lw_stall;
    assign StallD  = lw_stall;
    assign FlushD  = branch_taken;
    assign FlushE  = lw_stall || branch_taken;

endmodule