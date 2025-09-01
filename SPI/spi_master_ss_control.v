// Manages the SS line and transfer timing when in master mode.
module spi_master_ss_control(
    input           PCLK, PRESETn,
    input           mstr,           // Master mode enable
    input           start_transfer, // Pulse to start a transfer
    input           shift_event,    // New input: The specific sclk edge on which data is shifted

    output reg      ss,
    output          transfer_complete,
    output          spi_busy
);

    reg [3:0] bit_counter;
    reg       busy_flag;

    assign spi_busy = busy_flag;
    // This is now correct because we are counting 8 shift events for the 8 bits.
    assign transfer_complete = (bit_counter == 4'd8) && busy_flag;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            ss          <= 1'b1; // Slave select is active low, idle high
            busy_flag   <= 1'b0;
            bit_counter <= 4'b0;
        end else begin
            if (start_transfer && !busy_flag && mstr) begin
                // Start of a new transfer
                busy_flag   <= 1'b1;
                ss          <= 1'b0; // Assert SS low
                bit_counter <= 4'b0; // Reset counter for the new transfer
            end
            else if (busy_flag) begin
                if (shift_event) begin
                    bit_counter <= bit_counter + 1;
                end

                // End the transfer when 8 bits have been shifted.
                if (transfer_complete) begin
                    busy_flag <= 1'b0;
                    ss        <= 1'b1; // De-assert SS high
                end
            end
        end
    end

endmodule
