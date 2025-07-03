module Baud_Rate_Generator(
    input        PCLK,
    input        PRESETn,
    input        spiswai,
    input        cpol,
    input        cpha,
    input        ss,
    input  [1:0] spi_mode,
    input  [2:0] sppr,
    input  [2:0] spr,
    output reg   sclk,
    output reg   flag_low,
    output reg   flags_low,
    output reg   flag_high,
    output reg   flags_high,
    output [11:0] baud_rate_divisor
);

    // Internal counter for baud rate division
    reg [11:0] count;
    wire pre_sclk;
    wire select;
    wire sel;

    // Baud rate divisor calculation: (sppr+1) * 2^(spr+1)
    assign baud_rate_divisor = ((sppr + 1) * (2 ** (spr + 1)));

    // Initial sclk state based on clock polarity
    assign pre_sclk = cpol;

    // Enable clock generation when SPI is active and not in stop-wait mode
    assign select = ((~ss) && (~spiswai) && (spi_mode == 2'b00 || spi_mode == 2'b01));
    // Select flag logic branch based on SPI mode
    assign sel = (cpha ^ cpol);

    // ==========================
    // Clock Generation Logic
    // ==========================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sclk  <= pre_sclk;
            count <= 12'b0;
        end
        else if (select) begin
            if (count == (baud_rate_divisor - 1'b1)) begin
                count <= 12'b0;
                sclk  <= ~sclk;
            end
            else begin
                count <= count + 1'b1;
            end
        end
        else if (!select) begin
            count <= 12'b0;
            sclk  <= pre_sclk;
        end
    end

    // ==========================
    // Flag Generation Logic
    // ==========================
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            flag_low   <= 1'b0;
            flags_low  <= 1'b0;
            flag_high  <= 1'b0;
            flags_high <= 1'b0;
        end
        else if (sel) begin
            // SPI Modes 1 and 3: flag_high/flags_high during high sclk
            if (sclk) begin
                if (count == (baud_rate_divisor - 1'b1))
                    flag_high <= 1'b1;
                else if (count == (baud_rate_divisor - 2'b10))
                    flags_high <= 1'b1;
                else begin
                    flag_high  <= 1'b0;
                    flags_high <= 1'b0;
                end
            end
            else begin
                flag_high  <= 1'b0;
                flags_high <= 1'b0;
            end
        end
        else if (!sel) begin
            // SPI Modes 0 and 2: flag_low/flags_low during low sclk
            if (!sclk) begin
                if (count == (baud_rate_divisor - 1'b1))
                    flag_low <= 1'b1;
                else if (count == (baud_rate_divisor - 2'b10))
                    flags_low <= 1'b1;
                else begin
                    flag_low  <= 1'b0;
                    flags_low <= 1'b0;
                end
            end
            else begin
                flag_low  <= 1'b0;
                flags_low <= 1'b0;
            end
        end
    end

endmodule
