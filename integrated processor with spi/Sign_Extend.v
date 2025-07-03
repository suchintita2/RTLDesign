module Sign_Extend (In, ImmSrc, Imm_Ext);
    input [31:0] In;
    input [2:0] ImmSrc;
    output [31:0] Imm_Ext;

    assign Imm_Ext = (ImmSrc == 3'b000) ? {{20{In[31]}}, In[31:20]} :                              // I-type
                     (ImmSrc == 3'b001) ? {{20{In[31]}}, In[31:25], In[11:7]} :                   // S-type
                     (ImmSrc == 3'b010) ? {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0} : // B-type
                     (ImmSrc == 3'b011) ? {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0} :    // J-type (JAL)
                     (ImmSrc == 3'b100) ? {In[31:12], 12'b0} :                                    // U-type (LUI/AUIPC)
                     32'h00000000;

endmodule
