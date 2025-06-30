module shift_register(
    input        PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol,
    input        flag_low, flag_high, flags_low, flags_high, miso, receive_data,
    input  [7:0] data_mosi,
    output [7:0] data_miso,
    output reg   mosi
);

    wire mode_clk;
    reg [7:0] shift_register;
    reg [7:0] temp_register;
    reg [2:0] tx_count, rx_count;

    assign data_miso = receive_data ? 8'h00 : temp_register;
    assign mode_clk = (cpol ^ cpha);  // SPI mode logic

    // Shift register load and MOSI output logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_register <= 8'b0;
            mosi <= 1'b0;
        end else if (send_data) begin
            shift_register <= data_mosi;
        end else if (!ss) begin
            if (flags_high && mode_clk) begin
                if (lsbfe && (tx_count <= 3'd7)) begin
                    mosi <= shift_register[tx_count];
                end else if (!lsbfe && (tx_count <= 3'd7)) begin
                    mosi <= shift_register[7 - tx_count];
                end
            end else if (flags_high && !mode_clk) begin
                if (lsbfe && (tx_count <= 3'd7)) begin
                    mosi <= shift_register[tx_count];
                end else if (!lsbfe && (tx_count <= 3'd7)) begin
                    mosi <= shift_register[7 - tx_count];
                end
            end
        end
    end

    // TX counter: counts up for LSB-first, down for MSB-first
    countx tx_counter (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flags_low), .f_high(flags_high),
        .count(tx_count)
    );

    // RX counter: counts up for LSB-first, down for MSB-first
    countx rx_counter (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flag_low), .f_high(flag_high),
        .count(rx_count)
    );

    // Temp register bit update: only one bit updated per cycle, based on rx_count and lsbfe
    temp_regx temp_reg_inst (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .miso(miso), .f_low(flag_low), .f_high(flag_high),
        .rx_count(rx_count),
        .temp_register(temp_register)
    );

endmodule

// Counter module: up for LSB, down for MSB
module countx(
    input        PCLK, PRESETn, mode_clk, ss, lsbfe, f_low, f_high,
    output reg [2:0] count
);
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count <= 3'd0;
        end else if (!ss) begin
            if (mode_clk) begin
                if (lsbfe) begin
                    if (count < 3'd7 && f_high)
                        count <= count + 1'b1;
                    else if (count == 3'd7 && f_high)
                        count <= 3'd0;
                end else begin
                    if (count > 3'd0 && f_high)
                        count <= count - 1'b1;
                    else if (count == 3'd0 && f_high)
                        count <= 3'd7;
                end
            end else begin // mode_clk == 0
                if (lsbfe) begin
                    if (count < 3'd7 && f_low)
                        count <= count + 1'b1;
                    else if (count == 3'd7 && f_low)
                        count <= 3'd0;
                end else begin
                    if (count > 3'd0 && f_low)
                        count <= count - 1'b1;
                    else if (count == 3'd0 && f_low)
                        count <= 3'd7;
                end
            end
        end
    end
endmodule

// Temp register update: only one bit per cycle, based on rx_count and lsbfe
module temp_regx(
    input        PCLK, PRESETn, mode_clk, ss, lsbfe, miso, f_low, f_high,
    input  [2:0] rx_count,
    output reg [7:0] temp_register
);
    integer i;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            temp_register <= 8'b0;
        end else if (!ss) begin
            if (mode_clk) begin
                if (lsbfe && f_high) begin
                    temp_register[rx_count] <= miso;
                end else if (!lsbfe && f_high) begin
                    temp_register[7 - rx_count] <= miso;
                end
            end else begin
                if (lsbfe && f_low) begin
                    temp_register[rx_count] <= miso;
                end else if (!lsbfe && f_low) begin
                    temp_register[7 - rx_count] <= miso;
                end
            end
        end
    end
endmodule
