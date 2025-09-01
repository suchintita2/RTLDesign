// Top-Level RISC-V Pipeline Module (Final Version with AUIPC support)
module riscv_pipeline (
    input clk,
    input reset
);

    // --- Wire Declarations ---
    wire        stall_f, stall_d, flush_d, flush_e;
    wire [1:0]  forward_ae, forward_be;
    wire [31:0] pc_f, pc_plus_4_f, inst_f;
    wire [31:0] pc_next, pc_target_e;
    wire        pc_src_e;
    wire [31:0] pc_d, pc_plus_4_d, inst_d;
    wire [31:0] rd1_d, rd2_d, imm_ext_d;
    wire [6:0]  op = inst_d[6:0];
    wire [4:0]  rs1_d = inst_d[19:15];
    wire [4:0]  rs2_d = inst_d[24:20];
    wire [4:0]  rd_d = inst_d[11:7];
    wire [2:0]  funct3 = inst_d[14:12];
    wire        funct7_5 = inst_d[30];
    wire        reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d;
    wire [1:0]  result_src_d, alu_op_d;
    wire        ALUSrcA_d; // New wire for AUIPC support
    wire [31:0] rd1_e, rd2_e, pc_e, pc_plus_4_e, imm_ext_e, src_a_e, src_b_e, alu_in_a, alu_in_b, alu_result_e;
    wire [4:0]  rs1_e, rs2_e, rd_e;
    wire        zero_e, reg_write_e, mem_write_e, jump_e, branch_e, alu_src_e;
    wire [1:0]  result_src_e, alu_op_e;
    wire [3:0]  alu_control_e;
    wire        ALUSrcA_e; // New wire for AUIPC support
    wire [31:0] alu_result_m, write_data_m, pc_plus_4_m, read_data_m;
    wire [4:0]  rd_m;
    wire        reg_write_m, mem_write_m;
    wire [1:0]  result_src_m;
    wire [31:0] alu_result_w, read_data_w, pc_plus_4_w, result_w;
    wire [4:0]  rd_w;
    wire        reg_write_w;
    wire [1:0]  result_src_w;

    //================================================================
    // STAGE 1: INSTRUCTION FETCH (IF)
    //================================================================
    pc pc_reg( .clk(clk), .reset(reset), .stall_f(stall_f), .pc_in(pc_next), .pc_out(pc_f) );
    adder pc_adder( .a(pc_f), .b(32'd4), .y(pc_plus_4_f) );
    instruction_memory imem( .address(pc_f), .instruction(inst_f) );
    assign pc_src_e = (branch_e && zero_e) || jump_e;
    mux2 #(32) pcmux( .d0(pc_plus_4_f), .d1(pc_target_e), .s(pc_src_e), .y(pc_next) );

    //================================================================
    // STAGE 2: INSTRUCTION DECODE (ID)
    //================================================================
    if_id_register if_id_reg (/* connections */);
    register_file reg_file(/* connections */);
    immediate_generator imm_gen(/* connections */);
    control_unit ctrl(
        .op(op), .reg_write_d(reg_write_d), .result_src_d(result_src_d),
        .mem_write_d(mem_write_d), .jump_d(jump_d), .branch_d(branch_d),
        .alu_src_d(alu_src_d), .alu_op_d(alu_op_d), .ALUSrcA_d(ALUSrcA_d)
    );

    //================================================================
    // STAGE 3: EXECUTE (EX)
    //================================================================
    // NOTE: The id_ex_register module must be updated to pass the new ALUSrcA signal
    id_ex_register id_ex_reg (/* connections... including ALUSrcA_d -> ALUSrcA_e */);
    
    mux3 #(32) fwd_mux_a( .d0(rd1_e), .d1(result_w), .d2(alu_result_m), .s(forward_ae), .y(src_a_e) );
    
    // ** New Mux (SrcAMux) to select between register value and PC for AUIPC **
    mux2 #(32) src_a_mux (
        .d0(src_a_e),       // 0: Default path from forwarding unit
        .d1(pc_e),          // 1: Path for AUIPC, selects the PC
        .s(ALUSrcA_e),      // Select line from control unit
        .y(alu_in_a)        // Final output to ALU's first input
    );
    
    mux2 #(32) alu_src_mux( .d0(src_b_e), .d1(imm_ext_e), .s(alu_src_e), .y(alu_in_b) );
    
    alu_control_unit alu_ctrl(
        .alu_op(alu_op_e), .funct3(inst_d[14:12]), .funct7_5(inst_d[30]), .alu_control(alu_control_e)
    );

    // ** ALU's first input 'a' now comes from the new src_a_mux **
    alu alu_unit( .a(alu_in_a), .b(alu_in_b), .alu_control(alu_control_e), .result(alu_result_e), .zero(zero_e) );
    
    adder branch_addr_adder( .a(pc_e), .b(imm_ext_e), .y(pc_target_e) );

    //================================================================
    // STAGE 4: MEMORY (MEM)
    //================================================================
    ex_mem_register ex_mem_reg (
        .clk(clk), .reset(reset),
        .reg_write_e(reg_write_e), .result_src_e(result_src_e), .mem_write_e(mem_write_e),
        .alu_result_e(alu_result_e), .write_data_e(src_b_e), .pc_plus_4_e(pc_plus_4_e), .rd_e(rd_e),
        
        .reg_write_m(reg_write_m), .result_src_m(result_src_m), .mem_write_m(mem_write_m),
        .alu_result_m(alu_result_m), .write_data_m(write_data_m), .pc_plus_4_m(pc_plus_4_m), .rd_m(rd_m)
    );
    
    data_memory dmem(
        .clk(clk), .mem_write(mem_write_m), .address(alu_result_m),
        .write_data(write_data_m), .read_data(read_data_m)
    );

    //================================================================
    // STAGE 5: WRITE BACK (WB)
    //================================================================
    mem_wb_register mem_wb_reg (
        .clk(clk), .reset(reset),
        .reg_write_m(reg_write_m), .result_src_m(result_src_m),
        .read_data_m(read_data_m), .alu_result_m(alu_result_m), .pc_plus_4_m(pc_plus_4_m), .rd_m(rd_m),

        .reg_write_w(reg_write_w), .result_src_w(result_src_w),
        .read_data_w(read_data_w), .alu_result_w(alu_result_w), .pc_plus_4_w(pc_plus_4_w), .rd_w(rd_w)
    );
    
    mux3 #(32) result_mux(
        .d0(alu_result_w), .d1(read_data_w), .d2(pc_plus_4_w),
        .s(result_src_w), .y(result_w)
    );

    //================================================================
    // HAZARD UNIT
    //================================================================
    hazard_unit hazard(
        .rs1_d(rs1_d), .rs2_d(rs2_d), .rd_e(rd_e), .rd_m(rd_m),
        .reg_write_e(reg_write_e), .reg_write_m(reg_write_m),
        .result_src_e(result_src_e), .PCSrcE(pc_src_e),
        .stall_f(stall_f), .stall_d(stall_d), .flush_d(flush_d), .flush_e(flush_e),
        .forward_ae(forward_ae), .forward_be(forward_be)
    );

endmodule
