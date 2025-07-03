module shift_register (
    input PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol,
    input flag_high, flags_high, flag_low, flags_low,
    input miso, receive_data,
    input [7:0] data_mosi,
    output [7:0] data_miso,
    output reg [7:0] rx_shift_reg_out,
    output reg mosi
);

    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;

    assign data_miso = rx_shift_reg;

    wire shift_flag = (cpha ^ cpol) ? flags_high : flags_low;
    wire sample_flag = (cpha ^ cpol) ? flag_high : flag_low;

    // Transmit shift register
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_shift_reg <= 8'b0;
            mosi <= 1'b0;
        end else if (send_data) begin
            tx_shift_reg <= data_mosi;
            mosi <= lsbfe ? data_mosi[0] : data_mosi[7];
        end else if (!ss && shift_flag) begin
            if (lsbfe) begin
                mosi <= tx_shift_reg[0];
                tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
            end else begin
                mosi <= tx_shift_reg[7];
                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
            end
        end
    end

    // Receive shift register
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rx_shift_reg <= 8'b0;
            rx_shift_reg_out <= 8'b0; 
        end else if (send_data) begin
            rx_shift_reg <= 8'b0;
            rx_shift_reg_out <= 8'b0;
        end else if (!ss && sample_flag) begin
            if (lsbfe) begin
                rx_shift_reg <= {miso, rx_shift_reg[7:1]};
            end else begin
                rx_shift_reg <= {rx_shift_reg[6:0], miso};
            end
            rx_shift_reg_out <= rx_shift_reg;
        end
    end

endmodule
