module shift_register(
    input        PCLK, PRESETn, ss, send_data, lsbfe, cpha, cpol,
    input        flag_low, flag_high, flags_low, flags_high, miso, receive_data,
    input  [7:0] data_mosi,
    output [7:0] data_miso,
    output reg   mosi
);

    wire mode_clk;
    reg [7:0] shift_register, temp_register;
    reg [2:0] count, count1, count2, count3;

    assign data_miso = receive_data ? 8'h00 : temp_register;
    assign mode_clk = (cpol ^ cpha);  // SPI mode logic

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            shift_register <= 8'b0;
            mosi <= 1'b0;
        end else if (send_data) begin
            shift_register <= data_mosi;
        end else if (!ss && mode_clk) begin
            if (flags_high && (count <= 3'd7) && lsbfe) begin
                mosi <= shift_register[count];
            end
        end else if (!ss && !mode_clk) begin
            if (flags_high && (count1 <= 3'd7)) begin
                mosi <= shift_register[count1];
            end
        end
    end

    countx co (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flags_low), .f_high(flags_high),
        .count_a(count), .count_b(count1), .count_x(count)
    );

    countx c1 (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flags_low), .f_high(flags_high),
        .count_a(count), .count_b(count1), .count_x(count1)
    );

    countx c2 (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flag_low), .f_high(flag_high),
        .count_a(count2), .count_b(count3), .count_x(count2)
    );

    countx c3 (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .f_low(flag_low), .f_high(flag_high),
        .count_a(count2), .count_b(count3), .count_x(count3)
    );

    temp_regx t1 (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .miso(miso), .f_low(flag_low), .f_high(flag_high),
        .count_a(count2), .count_b(count3), .temp_reg_x(temp_register[count2])
    );

    temp_regx t2 (
        .PCLK(PCLK), .PRESETn(PRESETn), .mode_clk(mode_clk), .ss(ss), .lsbfe(lsbfe),
        .miso(miso), .f_low(flag_low), .f_high(flag_high),
        .count_a(count2), .count_b(count3), .temp_reg_x(temp_register[count3])
    );

endmodule

module countx(
    input        PCLK, PRESETn, mode_clk, ss, lsbfe, f_low, f_high,
    input  [2:0] count_a, count_b,
    output reg [2:0] count_x
);

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            count_x <= 3'd0;
        end else if (!ss) begin
            if (mode_clk) begin
                if (lsbfe) begin
                    if (count_a <= 3'd7) begin
                        if (f_high) begin
                            count_x <= count_a + 1'b1;
                        end
                    end else begin
                        count_x <= 3'd0;
                    end
                end else begin
                    if (count_b >= 3'd0) begin
                        if (f_high) begin
                            count_x <= count_b - 1'b1;
                        end
                    end else begin
                        count_x <= 3'd7;
                    end
                end
            end else begin // mode_clk == 0
                if (lsbfe) begin
                    if (count_a <= 3'd7) begin
                        if (f_low) begin
                            count_x <= count_a + 1'b1;
                        end
                    end else begin
                        count_x <= 3'd0;
                    end
                end else begin
                    if (count_b >= 3'd0) begin
                        if (f_low) begin
                            count_x <= count_b - 1'b1;
                        end
                    end else begin
                        count_x <= 3'd7;
                    end
                end
            end
        end
    end
endmodule

module temp_regx(
    input        PCLK, PRESETn, mode_clk, ss, lsbfe, miso, f_low, f_high,
    input  [2:0] count_a, count_b,
    output reg   temp_reg_x
);

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            temp_reg_x <= 0;
        end else if (!ss) begin
            if (mode_clk) begin
                if (lsbfe) begin
                    if (count_a <= 3'd7) begin
                        if (f_high) begin
                            temp_reg_x <= miso;
                        end
                    end
                end else begin
                    if (count_b >= 3'd0) begin
                        if (f_high) begin
                            temp_reg_x <= miso;
                        end
                    end
                end
            end else begin // mode_clk == 0
                if (lsbfe) begin
                    if (count_a <= 3'd7) begin
                        if (f_low) begin
                            temp_reg_x <= miso;
                        end
                    end
                end else begin
                    if (count_b >= 3'd0) begin
                        if (f_low) begin
                            temp_reg_x <= miso;
                        end
                    end
                end
            end
        end
    end
endmodule
