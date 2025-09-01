// Handles register access and orchestrates SPI transfers.
module APB_Slave_Interface(
    input           PCLK, PRESETn,
    input           PWRITE, PSEL, PENABLE,
    input   [2:0]   PADDR,
    input   [7:0]   PWDATA,
    input   [7:0]   rx_data_in,      // Data received from shift register
    input           transfer_complete, // Pulse indicating transfer is done
    input           spi_busy,        // Indicates an SPI transfer is in progress

    output          mstr, cpol, cpha, lsbfe,
    output  [2:0]   sppr, spr,
    output          spi_interrupt_request,
    output          PREADY,
    output          load_tx_reg,    // Pulse to load data into shift register
    output  [7:0]   tx_data_out,    // Data to send to shift register
    output  [7:0]   PRDATA
);

    // --- Internal Registers ---
    reg [7:0] SPI_CR1;  // Control Register 1
    reg [7:0] SPI_CR2;  // Control Register 2
    reg [7:0] SPI_DR;   // Data Register
    reg [7:0] SPI_BR;   // Baud Rate Register

    // --- Status Flags ---
    reg tx_buffer_empty; // 1 = CPU can write, 0 = Busy
    reg rx_buffer_full;  // 1 = CPU can read, 0 = No new data
    reg modf;            // Mode fault flag

    // --- APB State Machine ---
    reg [1:0] state, next_state;
    parameter IDLE = 2'b00, SETUP = 2'b01, ACCESS = 2'b10;

    // --- APB control signals ---
    wire wr_enb = PWRITE && (state == ACCESS);
    wire rd_enb = !PWRITE && (state == ACCESS);
    assign PREADY = (state == ACCESS);

    // --- Control signal assignments from registers ---
    assign mstr  = SPI_CR1[4];
    assign cpol  = SPI_CR1[3];
    assign cpha  = SPI_CR1[2];
    assign lsbfe = SPI_CR1[0];
    assign sppr  = SPI_BR[6:4];
    assign spr   = SPI_BR[2:0];
    wire   spe   = SPI_CR1[6]; // SPI Enable
    wire   spie  = SPI_CR1[7]; // Interrupt Enable
    wire   sptie = SPI_CR1[5]; // Tx Interrupt Enable

    // --- Data path assignment ---
    assign tx_data_out = SPI_DR;

    // --- Transfer initiation logic ---
    assign load_tx_reg = spe && !tx_buffer_empty && !spi_busy;

    // --- Status Register (combinational read) ---
    wire [7:0] SPI_SR = {rx_buffer_full, 1'b0, tx_buffer_empty, modf, 4'b0};

    // --- Register file write logic ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            SPI_CR1 <= 8'h04;
            SPI_CR2 <= 8'h00;
            SPI_BR  <= 8'h00;
            SPI_DR  <= 8'h00;
        end else begin
            if (wr_enb) begin
                case (PADDR)
                    3'b000: SPI_CR1 <= PWDATA;
                    3'b001: SPI_CR2 <= PWDATA; // Masks can be added if needed
                    3'b010: SPI_BR  <= PWDATA;
                    3'b101: SPI_DR  <= PWDATA; // Write to Data Register
                endcase
            end else if (transfer_complete) begin
                SPI_DR <= rx_data_in; // Load received data
            end
        end
    end

    // --- Status flag and transfer control logic (CORRECTED) ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_buffer_empty <= 1'b1;
            rx_buffer_full  <= 1'b0;
        end else begin
            // Transmit flag logic with priority
            if (wr_enb && PADDR == 3'b101) begin
                tx_buffer_empty <= 1'b0; // Buffer is now full
            end else if (load_tx_reg) begin
                tx_buffer_empty <= 1'b1; // Buffer is now empty
            end

            // Receive flag logic with priority
            if (transfer_complete) begin
                rx_buffer_full <= 1'b1; // Buffer is now full
            end else if (rd_enb && PADDR == 3'b101) begin
                rx_buffer_full <= 1'b0; // Buffer has been read
            end
        end
    end

    // --- Read data multiplexer ---
    always @(*) begin
        // Local PRDATA to avoid latches if not all PADDR are specified
        reg [7:0] prdata_mux; 
        if (rd_enb) begin
            case (PADDR)
                3'b000: prdata_mux = SPI_CR1;
                3'b001: prdata_mux = SPI_CR2;
                3'b010: prdata_mux = SPI_BR;
                3'b011: prdata_mux = SPI_SR;
                3'b101: prdata_mux = SPI_DR;
                default: prdata_mux = 8'h00;
            endcase
        end else begin
            prdata_mux = 8'h00;
        end
        PRDATA = prdata_mux;
    end
    
    // --- Interrupt request logic ---
    assign spi_interrupt_request = (spie && rx_buffer_full) || (sptie && tx_buffer_empty) || (spie && modf);

    // --- APB State Machine ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) state <= IDLE;
        else          state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE:   next_state = PSEL ? SETUP : IDLE;
            SETUP:  next_state = PENABLE ? ACCESS : SETUP;
            ACCESS: next_state = (PSEL && PENABLE) ? ACCESS : IDLE; // Corrected APB transition
            default: next_state = IDLE;
        endcase
    end

endmodule
