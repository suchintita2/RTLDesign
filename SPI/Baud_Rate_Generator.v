// Baud Rate Generator (Corrected)
// Generates the SPI clock and robust edge-detection events.
module Baud_Rate_Generator(
    input           PCLK,
    input           PRESETn,
    input           enable,         // Enable signal for clock generation
    input           cpol,
    input   [2:0]   sppr,
    input   [2:0]   spr,

    output          sclk,
    output          posedge_sclk_event,
    output          negedge_sclk_event
);

    reg  [11:0] count;
    reg         sclk_reg;
    reg         sclk_delayed;

    // Baud rate divisor calculation
    wire [11:0] baud_rate_divisor = ((sppr + 1) * (1 << (spr + 1))) / 2;

    assign sclk = sclk_reg;

    // Generate the SPI clock (sclk)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sclk_reg <= cpol; // Set initial state based on clock polarity
            count    <= 12'b0;
        end else if (enable) begin
            if (count == baud_rate_divisor - 1) begin
                count    <= 12'b0;
                sclk_reg <= ~sclk_reg; // Toggle clock
            end else begin
                count <= count + 1;
            end
        end else begin
            count    <= 12'b0;
            sclk_reg <= cpol; // Reset to idle state
        end
    end

    // Create single-cycle event pulses on the edges of sclk
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            sclk_delayed <= cpol;
        end else begin
            sclk_delayed <= sclk_reg;
        end
    end

    assign posedge_sclk_event = (sclk_reg == 1'b1) && (sclk_delayed == 1'b0);
    assign negedge_sclk_event = (sclk_reg == 1'b0) && (sclk_delayed == 1'b1);

endmodule
