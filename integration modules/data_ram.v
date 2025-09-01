// Data RAM
module data_ram (
    input           clk, cs, we,
    input   [31:0]  addr, wdata,
    output  [31:0]  rdata
);
    reg [31:0] mem [0:16383]; // 64KB RAM
    assign rdata = (cs) ? mem[addr[15:2]] : 32'b0;
    always @(posedge clk) begin
        if (cs && we) mem[addr[15:2]] <= wdata;
    end
endmodule
