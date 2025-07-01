// ====================================================
// SPI Shift Register (clean, robust, new implementation)
// Author: 22BEC0413
// ====================================================

module shift_register(
    input        PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol,
    input        flag_high, flags_high, miso, receive_data,
    input  [7:0] data_mosi,
    output [7:0] data_miso,
    output reg   mosi
);

    // Internal registers
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] tx_bit_idx;
    reg [2:0] rx_bit_idx;

    assign data_miso = rx_shift_reg;

    // Transmission logic (MOSI)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_shift_reg <= 8'b0;
            tx_bit_idx   <= 3'd7;
            mosi         <= 1'b0;
        end else if (send_data) begin
            tx_shift_reg <= data_mosi;
            tx_bit_idx   <= lsbfe ? 3'd0 : 3'd7;
        end else if (!ss && flags_high) begin
            if (lsbfe) begin
                mosi <= tx_shift_reg[tx_bit_idx];
                tx_bit_idx <= (tx_bit_idx == 3'd7) ? 3'd0 : tx_bit_idx + 1'b1;
            end else begin
                mosi <= tx_shift_reg[tx_bit_idx];
                tx_bit_idx <= (tx_bit_idx == 3'd0) ? 3'd7 : tx_bit_idx - 1'b1;
            end
        end
    end

    // Reception logic (MISO)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rx_shift_reg <= 8'b0;
            rx_bit_idx   <= 3'd7;
        end else if (!ss && flag_high) begin
            if (lsbfe) begin
                rx_shift_reg[rx_bit_idx] <= miso;
                rx_bit_idx <= (rx_bit_idx == 3'd7) ? 3'd0 : rx_bit_idx + 1'b1;
            end else begin
                rx_shift_reg[rx_bit_idx] <= miso;
                rx_bit_idx <= (rx_bit_idx == 3'd0) ? 3'd7 : rx_bit_idx - 1'b1;
            end
        end
    end

endmodule
