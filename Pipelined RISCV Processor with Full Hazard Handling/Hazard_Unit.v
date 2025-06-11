module Hazard_Unit(
    input [4:0] Rs1_D, Rs2_D, Rd_E,
    input PCSrc_E, ResultSrc_E,
    output Stall_F, Stall_D, Flush_D, Flush_E
);
    wire lw_stall;
    // Load-use hazard detection
    assign lw_stall = ResultSrc_E & ((Rs1_D == Rd_E) | (Rs2_D == Rd_E));
    // Control hazard handling
    assign Stall_F = lw_stall;
    assign Stall_D = lw_stall;
    assign Flush_D = PCSrc_E;
    assign Flush_E = lw_stall | PCSrc_E;
endmodule