// Hazard Detection Unit (with PCSrcE input)
module hazard_unit (
    // Inputs
    input      [4:0]            rs1_d, rs2_d,      // Reg sources from ID stage
    input      [4:0]            rd_e, rd_m,        // Reg destinations from EX and MEM stages
    input                       reg_write_e, reg_write_m,
    input                       result_src_e,      // To detect if instruction in EX is a load
    input                       PCSrcE,            // New unified control hazard input

    // Outputs
    output                      stall_f, stall_d,
    output                      flush_d, flush_e,
    output     [1:0]            forward_ae, forward_be
);

    // --- Data Hazard Detection (Stalling for Load-Use) ---
    // This logic remains unchanged.
    wire load_use_hazard = (result_src_e == 2'b01) && reg_write_e &&
                           (rd_e != 0) && ((rd_e == rs1_d) || (rd_e == rs2_d));

    assign stall_d = load_use_hazard;
    assign stall_f = load_use_hazard; // Stall PC and IF/ID register

    // --- Control Hazard Detection (Flushing) ---
    // This logic is now simpler. A flush is needed whenever PCSrcE is high.
    assign flush_d = PCSrcE;
    assign flush_e = PCSrcE;

    // --- Data Forwarding Logic ---
    // This logic remains unchanged.
    wire ex_hazard_rs1 = reg_write_e && (rd_e != 0) && (rd_e == rs1_d);
    wire ex_hazard_rs2 = reg_write_e && (rd_e != 0) && (rd_e == rs2_d);

    wire mem_hazard_rs1 = reg_write_m && (rd_m != 0) && (rd_m == rs1_d);
    wire mem_hazard_rs2 = reg_write_m && (rd_m != 0) && (rd_m == rs2_d);

    // Mux select for ForwardA
    assign forward_ae = (ex_hazard_rs1) ? 2'b10 : // Forward from EX
                        (mem_hazard_rs1) ? 2'b01 : // Forward from MEM
                        2'b00;

    // Mux select for ForwardB
    assign forward_be = (ex_hazard_rs2) ? 2'b10 : // Forward from EX
                        (mem_hazard_rs2) ? 2'b01 : // Forward from MEM
                        2'b00;

endmodule
