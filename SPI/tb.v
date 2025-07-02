`timescale 1ns / 1ps

module tb_spi_master();

    //======================================================================
    // 1. Parameters and Constants
    //======================================================================
    // Using parameters makes the testbench easier to read and maintain.
    localparam PCLK_PERIOD = 10;

    // APB Register Addresses
    localparam ADDR_CR1   = 3'h0; // Control Register 1
    localparam ADDR_CR2   = 3'h1; // Control Register 2
    localparam ADDR_BR    = 3'h2; // Baud Rate Register
    localparam ADDR_SR    = 3'h3; // Status Register
    localparam ADDR_DR    = 3'h5; // Data Register

    // Test Data
    localparam DATA_TO_TRANSMIT = 8'h3C;
    localparam DATA_TO_RECEIVE  = 8'hA5; // The alternating pattern `10100101` is excellent for testing.

    //======================================================================
    // 2. Signals and Wires
    //======================================================================
    reg  PCLK, PRESETn;
    reg  PWRITE, PSEL, PENABLE;
    reg  [2:0] PADDR;
    reg  [7:0] PWDATA;
    wire [7:0] PRDATA;
    wire PREADY, PSLVERR;
wire [7:0] rx_shift_debug;

    wire sclk, ss, mosi;
    reg  miso; // This represents the data line from the slave.
    wire spi_interrupt_request;

    // Testbench-specific variables
    reg [7:0] received_data;
    reg [2:0] miso_bit_count;

    //======================================================================
    // 3. DUT Instantiation
    //======================================================================
    top DUT (
        .PCLK(PCLK), .PRESETn(PRESETn), .PWRITE(PWRITE), .PSEL(PSEL),
        .PENABLE(PENABLE), .PADDR(PADDR), .PWDATA(PWDATA), .PRDATA(PRDATA),
        .PREADY(PREADY), .PSLVERR(PSLVERR), .sclk(sclk), .ss(ss),
        .mosi(mosi), .miso(miso), .spi_interrupt_request(spi_interrupt_request),
        .rx_shift_debug(rx_shift_debug)     );

    //======================================================================
    // 4. Core Testbench Logic
    //======================================================================

    // --- Clock and Reset Generators ---
    initial begin
        PCLK = 0;
        forever #(PCLK_PERIOD/2) PCLK = ~PCLK;
    end

    initial begin
        // This prevents the 'miso' line from being unknown ('X') at time 0.
        miso = 1'b1;
        
        $display("22bec0413");
        $display("=== SPI Master Testbench Start ===");
        PRESETn = 1'b0;
        #(PCLK_PERIOD * 2);
        PRESETn = 1'b1;
        $display("[T=%0t] Reset Released", $time);
    end

    // --- Robust APB Tasks ---
    task apb_write(input [2:0] addr, input [7:0] data);
        begin
            @(posedge PCLK);
            PADDR   <= addr;
            PWDATA  <= data;
            PWRITE  <= 1'b1;
            PSEL    <= 1'b1;
            PENABLE <= 1'b0;
            @(posedge PCLK);
            PENABLE <= 1'b1;
            wait(PREADY);
            @(posedge PCLK);
            $display("[T=%0t] APB WRITE -> Addr: 0x%0h, Data: 0x%02h", $time, addr, data);
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
        end
    endtask

    
task apb_read(input [2:0] addr, output [7:0] data);
    begin
        @(posedge PCLK);
        PADDR   <= addr;
        PWRITE  <= 1'b0;
        PSEL    <= 1'b1;
        PENABLE <= 1'b0;
        @(posedge PCLK);
        PENABLE <= 1'b1;
        wait(PREADY);
        // This is the CRITICAL fix for the testbench race condition.
        // 1. Use non-blocking assignment to sample PRDATA.
        // 2. Use a #0 delay to let the value propagate before the task returns.
        data <= PRDATA;
        #0;
        // THE FIX IS HERE: Added the 'addr' variable to the argument list.
        $display("[T=%0t] APB READ  <- Addr: 0x%0h, Data: 0x%02h", $time, addr, data);
        @(posedge PCLK);
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;
    end
endtask

    // --- SPI Slave Model ---
    // This model correctly drives the 'miso' line for SPI Mode 0/1.
    // It changes data on the falling edge, ensuring it is stable for the
    // DUT to sample on the rising edge, thus avoiding race conditions.
    
    // Reset the bit counter when the slave is de-selected.
    always @(posedge ss) begin
        miso_bit_count <= 0;
    end

    // Shift out data on the falling edge of the clock when selected.
    always @(negedge sclk) begin
        if (!ss) begin
            miso <= DATA_TO_RECEIVE[7 - miso_bit_count];
            miso_bit_count <= miso_bit_count + 1;
        end
    end

    //======================================================================
    // 5. Main Test Sequence
    //======================================================================
    initial begin
        // Wait for reset to complete
        wait(PRESETn === 1'b1);
        #10;

        // --- 5.1 Configure the SPI Master ---
        $display("\n[INFO] Configuring SPI Master for Mode 0 (CPOL=0, CPHA=0)...");
        apb_write(ADDR_CR1, 8'hF0); // SPE=1, MSTR=1, CPOL=0, CPHA=0, SPIE=1
        apb_write(ADDR_CR2, 8'h00);
        apb_write(ADDR_BR,  8'h01); // Set a baud rate divisor

        // --- 5.2 Transmit Data ---
        $display("[INFO] Writing 0x%02h to Data Register to start transfer...", DATA_TO_TRANSMIT);
        apb_write(ADDR_DR, DATA_TO_TRANSMIT);

        // --- 5.3 Wait for Completion ---
        $display("[INFO] Waiting for Transfer Complete interrupt...");
wait(DUT.SLAVE_INTERFACE.spif == 1'b1);        $display("[INFO] Transfer Complete Interrupt Detected at T=%0t.", $time);

        // --- 5.4 Read Back and Verify ---
        $display("[INFO] Reading back received data from Data Register...");
// And add a #0 delay like this:
apb_read(ADDR_DR, received_data);
#0; // Let the 'received_data' register update before we check it.

$display("\n--- VERIFICATION ---");
if (received_data == DATA_TO_RECEIVE) begin
$display("✅ PASS: Received data (0x%02h) matches expected data (0x%02h).", received_data, DATA_TO_RECEIVE);
        end else begin
            $display("❌ FAIL: Received data (0x%02h) does NOT match expected data (0x%02h).", received_data, DATA_TO_RECEIVE);
        end
        $display("--------------------\n");

        $display("=== SPI Master Test Complete ===");
        $finish;
    end

    //======================================================================
    // 6. Signal Monitoring
    //======================================================================
    initial begin
        // This monitor is excellent for debugging. No changes needed.
        $monitor("T=%0t | ss=%b | sclk=%b | mosi=%b | miso=%b | PREADY=%b | PRDATA=0x%02h",
                 $time, ss, sclk, mosi, miso, PREADY, PRDATA);
    end

endmodule
