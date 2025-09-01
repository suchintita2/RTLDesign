module shift_register (
    input           PCLK, PRESETn,
    input           load_tx_reg, enable, lsbfe,
    input           shift_event, sample_event,
    input           miso,
    input   [7:0]   tx_data_in,
    output  [7:0]   rx_data_out,
    output reg      mosi
);
    reg [7:0] tx_shift_reg, rx_shift_reg;
    assign rx_data_out = rx_shift_reg;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) {tx_shift_reg <= 8'b0; mosi <= 1'b0;}
        else if (load_tx_reg) {tx_shift_reg <= tx_data_in; mosi <= lsbfe ? tx_data_in[0] : tx_data_in[7];}
        else if (enable && shift_event)
            if (lsbfe) {mosi <= tx_shift_reg[1]; tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};}
            else       {mosi <= tx_shift_reg[6]; tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};}
    end
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) rx_shift_reg <= 8'b0;
        else if (enable && sample_event)
            if (lsbfe) rx_shift_reg <= {miso, rx_shift_reg[7:1]};
            else       rx_shift_reg <= {rx_shift_reg[6:0], miso};
    end
endmodule
