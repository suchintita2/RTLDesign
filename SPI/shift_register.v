// Handles parallel-to-serial (MOSI) and serial-to-parallel (MISO) conversion.
module shift_register (
    input           PCLK, PRESETn,
    input           load_tx_reg,    // Pulse to load data for transmission
    input           enable,         // Enable shifting
    input           lsbfe, cpha, cpol,
    input           posedge_sclk_event,
    input           negedge_sclk_event,
    input           miso,
    input   [7:0]   tx_data_in,

    output  [7:0]   rx_data_out,
    output reg      mosi
);

    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;

    assign rx_data_out = rx_shift_reg;

    // Determine the correct clock edge for shifting and sampling based on SPI mode
    wire shift_event  = cpha ? posedge_sclk_event : negedge_sclk_event;
    wire sample_event = cpha ? negedge_sclk_event : posedge_sclk_event;

    // Transmit Logic (MOSI)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_shift_reg <= 8'b0;
            mosi         <= 1'b0;
        end else if (load_tx_reg) begin
            tx_shift_reg <= tx_data_in; // Load data to be sent
            mosi         <= lsbfe ? tx_data_in[0] : tx_data_in[7]; // Output first bit
        end else if (enable && shift_event) begin
            if (lsbfe) begin // LSB First
                tx_shift_reg <= {1'b0, tx_shift_reg[7:1]};
                mosi         <= tx_shift_reg[1];
            end else begin   // MSB First
                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                mosi         <= tx_shift_reg[6];
            end
        end
    end

    // Receive Logic (MISO)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rx_shift_reg <= 8'b0;
        end else if (enable && sample_event) begin
            if (lsbfe) begin // LSB First
                rx_shift_reg <= {miso, rx_shift_reg[7:1]};
            end else begin   // MSB First
                rx_shift_reg <= {rx_shift_reg[6:0], miso};
            end
        end
    end

endmodule
