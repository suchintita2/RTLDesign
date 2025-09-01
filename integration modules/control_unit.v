module control_unit (
    input      [6:0]            op,
    output reg                  reg_write_d,
    output reg [1:0]            result_src_d,
    output reg                  mem_write_d,
    output reg                  mem_read_d, // New output for loads
    output reg                  jump_d,
    output reg                  branch_d,
    output reg                  alu_src_d,
    output reg [1:0]            alu_op_d,
    output reg                  ALUSrcA_d
);
    parameter R_TYPE=7'b0110011, I_TYPE=7'b0010011, LOAD=7'b0000011, STORE=7'b0100011,
              BRANCH=7'b1100011, JALR=7'b1100111, JAL=7'b1101111, LUI=7'b0110111, AUIPC=7'b0010111;

    always @(*) begin
        reg_write_d = 1'b0; result_src_d = 2'b00; mem_write_d = 1'b0; mem_read_d = 1'b0;
        jump_d = 1'b0; branch_d = 1'b0; alu_src_d = 1'b0; alu_op_d = 2'b00; ALUSrcA_d = 1'b0;

        case (op)
            R_TYPE:   begin reg_write_d=1'b1; alu_src_d=1'b0; alu_op_d=2'b10; end
            I_TYPE:   begin reg_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b11; end
            LOAD:     begin reg_write_d=1'b1; result_src_d=2'b01; alu_src_d=1'b1; alu_op_d=2'b00; mem_read_d=1'b1; end
            STORE:    begin mem_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b00; end
            BRANCH:   begin branch_d=1'b1;    alu_src_d=1'b0; alu_op_d=2'b01; end
            JALR:     begin reg_write_d=1'b1; jump_d=1'b1; result_src_d=2'b10; alu_src_d=1'b1; alu_op_d=2'b00; end
            JAL:      begin reg_write_d=1'b1; jump_d=1'b1; result_src_d=2'b10; end
            LUI:      begin reg_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b11; end
            AUIPC:    begin reg_write_d=1'b1; alu_src_d=1'b1; alu_op_d=2'b00; ALUSrcA_d=1'b1; end
        endcase
    end
endmodule
