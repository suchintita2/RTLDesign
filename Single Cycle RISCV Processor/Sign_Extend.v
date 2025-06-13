module Sign_Extend (
    input [31:0] In,
    input [1:0] ImmSrc,
    output reg [31:0] Imm_Ext
);
    always @(*) begin
        case (ImmSrc)
            2'b00: // I-type (e.g., lw)
                Imm_Ext = {{20{In[31]}}, In[31:20]};
            2'b01: // S-type (e.g., sw)
                Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};
            2'b10: // B-type (e.g., beq)
                Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0};
		2'b11: // J-type (e.g., jal)
                Imm_Ext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0};	
        endcase
    end
endmodule
