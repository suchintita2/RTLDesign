module riscv_pipeline (
    input         clk, reset, stall_in,
    input  [31:0] mem_rdata,
    output [31:0] mem_addr, mem_wdata,
    output        mem_write, mem_read
);
    wire stall_f, stall_d_internal, stall_d, flush_d, flush_e;
    wire [1:0] forward_ae, forward_be;
    wire [31:0] pc_f, pc_plus_4_f, inst_f, pc_next, pc_target_e;
    wire pc_src_e;
    wire [31:0] pc_d, pc_plus_4_d, inst_d, rd1_d, rd2_d, imm_ext_d;
    wire [6:0] op=inst_d[6:0]; wire [4:0] rs1_d=inst_d[19:15], rs2_d=inst_d[24:20], rd_d=inst_d[11:7];
    wire [2:0] funct3=inst_d[14:12]; wire funct7_5=inst_d[30];
    wire reg_write_d, mem_write_d, mem_read_d, jump_d, branch_d, alu_src_d, ALUSrcA_d;
    wire [1:0] result_src_d, alu_op_d;
    wire [31:0] rd1_e, rd2_e, pc_e, pc_plus_4_e, imm_ext_e, src_a_e, src_b_e, alu_in_a, alu_in_b, alu_result_e;
    wire [4:0] rs1_e, rs2_e, rd_e;
    wire zero_e, reg_write_e, mem_write_e, mem_read_e, jump_e, branch_e, alu_src_e, ALUSrcA_e;
    wire [1:0] result_src_e, alu_op_e; wire [3:0] alu_control_e;
    wire [31:0] alu_result_m, write_data_m, pc_plus_4_m;
    wire [4:0] rd_m; wire reg_write_m, mem_write_m, mem_read_m; wire [1:0] result_src_m;
    wire [31:0] alu_result_w, read_data_w, pc_plus_4_w, result_w;
    wire [4:0] rd_w; wire reg_write_w; wire [1:0] result_src_w;

    assign stall_d = stall_d_internal || stall_in; assign stall_f = stall_d;
    assign pc_src_e = (branch_e && zero_e) || jump_e;
    assign mem_addr = alu_result_m; assign mem_wdata = write_data_m;
    assign mem_write = mem_write_m; assign mem_read = mem_read_m;

    pc pc_reg(clk, reset, stall_f, pc_next, pc_f);
    adder pc_adder(pc_f, 32'd4, pc_plus_4_f);
    instruction_memory imem(pc_f, inst_f);
    mux2 #(32) pcmux(pc_plus_4_f, pc_target_e, pc_src_e, pc_next);
    if_id_register if_id_reg(clk, reset, stall_d, flush_d, pc_f, pc_plus_4_f, inst_f, pc_d, pc_plus_4_d, inst_d);
    register_file reg_file(clk, reg_write_w, rs1_d, rs2_d, rd_w, result_w, rd1_d, rd2_d);
    immediate_generator imm_gen(inst_d, imm_ext_d);
    control_unit ctrl(op, reg_write_d, result_src_d, mem_write_d, mem_read_d, jump_d, branch_d, alu_src_d, alu_op_d, ALUSrcA_d);
    id_ex_register id_ex_reg(clk, reset, flush_e, reg_write_d, mem_write_d, mem_read_d, jump_d, branch_d, alu_src_d, ALUSrcA_d,
        result_src_d, alu_op_d, rd1_d, rd2_d, pc_d, pc_plus_4_d, imm_ext_d, rs1_d, rs2_d, rd_d, reg_write_e, mem_write_e, mem_read_e,
        jump_e, branch_e, alu_src_e, ALUSrcA_e, result_src_e, alu_op_e, rd1_e, rd2_e, pc_e, pc_plus_4_e, imm_ext_e, rs1_e, rs2_e, rd_e);
    mux3 #(32) fwd_mux_a(rd1_e, result_w, alu_result_m, forward_ae, src_a_e);
    mux2 #(32) src_a_mux(src_a_e, pc_e, ALUSrcA_e, alu_in_a);
    mux3 #(32) fwd_mux_b(rd2_e, result_w, alu_result_m, forward_be, src_b_e);
    mux2 #(32) alu_src_mux(src_b_e, imm_ext_e, alu_src_e, alu_in_b);
    alu_control_unit alu_ctrl(alu_op_e, funct3, funct7_5, alu_control_e);
    alu alu_unit(alu_in_a, alu_in_b, alu_control_e, alu_result_e, zero_e);
    adder branch_addr_adder(pc_e, imm_ext_e, pc_target_e);
    ex_mem_register ex_mem_reg(clk, reset, reg_write_e, mem_write_e, mem_read_e, result_src_e, alu_result_e,
        src_b_e, pc_plus_4_e, rd_e, reg_write_m, mem_write_m, mem_read_m, result_src_m, alu_result_m, write_data_m, pc_plus_4_m, rd_m);
    mem_wb_register mem_wb_reg(clk, reset, reg_write_m, result_src_m, mem_rdata, alu_result_m, pc_plus_4_m, rd_m,
        reg_write_w, result_src_w, read_data_w, alu_result_w, pc_plus_4_w, rd_w);
    mux3 #(32) result_mux(alu_result_w, read_data_w, pc_plus_4_w, result_src_w, result_w);
    hazard_unit hazard(rs1_d, rs2_d, rd_e, rd_m, reg_write_e, reg_write_m, result_src_e, pc_src_e,
        stall_d_internal, flush_d, flush_e, forward_ae, forward_be);
endmodule
