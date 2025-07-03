module APB_Slave_Interface(
    // Clock and reset
    input PCLK, PRESETn,
    // APB control signals
    input PWRITE, PSEL, PENABLE,
    // SPI status inputs
    input ss, receive_data, tip,
    // Address and data buses
    input [2:0] PADDR,
    input [7:0] PWDATA, miso_data,
    
    // Control outputs to SPI core
    output mstr, cpol, cpha, lsbfe, spiswai,
    // Interrupt and APB status
    output spi_interrupt_request, PREADY, PSLVERR,
    // Data transfer control
    output reg send_data,
    // SPI mode and configuration
    output reg [1:0] spi_mode,
    output [2:0] sppr, spr, 
    // Read data and MOSI output
    output reg [7:0] PRDATA, mosi_data
);
    // SPI Configuration Registers
    reg [7:0] SPI_CR1;  // Control Register 1
    reg [7:0] SPI_CR2;  // Control Register 2
    reg [7:0] SPI_SR;   // Status Register
    reg [7:0] SPI_DR;   // Data Register
    reg [7:0] SPI_BR;   // Baud Rate Register
    
    // Internal signals
    wire sptef, spif;    // Status flags
    wire spe, modfen;    // Control flags
    wire ssoe, spie, sptie;  // Control bits
    wire wr_enb, rd_enb; // Write/read enable
    wire sel, select;    // Selection conditions
    
    // Parameter definitions
    parameter cr2_mask = 8'b0001_1011;  // CR2 write mask
    parameter br_mask  = 8'b0111_0111;   // BR write mask
    parameter spi_run  = 2'b00;          // SPI run mode
    parameter spi_wait = 2'b01;          // SPI wait mode
    parameter spi_stop = 2'b10;          // SPI stop mode
    
    // FSM states
    parameter IDLE   = 2'b00;
    parameter SETUP  = 2'b01;
    parameter ENABLE = 2'b10;
    
    reg [1:0] next_mode;  // Next SPI mode
    reg [1:0] STATE;      // Current APB state
    reg [1:0] next_state; // Next APB state

    // Control signal assignments from registers
    assign ssoe    = SPI_CR1[1];   // Slave Select Output Enable
    assign mstr    = SPI_CR1[4];   // Master Mode Select
    assign spe     = SPI_CR1[6];   // SPI Enable
    assign spie    = SPI_CR1[7];   // SPI Interrupt Enable
    assign sptie   = SPI_CR1[5];   // SPI Transfer Interrupt Enable
    assign cpol    = SPI_CR1[3];   // Clock Polarity
    assign cpha    = SPI_CR1[2];   // Clock Phase
    assign lsbfe   = SPI_CR1[0];   // LSB First Enable
    assign modfen  = SPI_CR2[4];   // Mode Fault Enable
    assign spiswai = SPI_CR2[1];   // SPI Stop in Wait Mode
    assign sppr    = SPI_BR[6:4];  // SPI Prescale Rate
    assign spr     = SPI_BR[2:0];  // SPI Bit Rate
    
    // Selection logic for SPI modes
    assign sel = ((spi_mode == spi_run) || (spi_mode == spi_wait));
    assign select = ((SPI_DR == PWDATA) && (SPI_DR != miso_data) && sel);
    
    // APB control signals
    assign wr_enb = PWRITE && (STATE == ENABLE);  // Write enable
    assign rd_enb = !PWRITE && (STATE == ENABLE); // Read enable
    assign PREADY = (STATE == ENABLE);            // Transfer ready
    assign PSLVERR = (STATE == ENABLE) ? tip : 1'b0; // Slave error
    
    // Status flags
    assign sptef = (SPI_DR == 8'h00);  // SPI Transmit Empty Flag
    assign spif  = (SPI_DR != 8'h00);  // SPI Interrupt Flag
    assign modf  = (~ss) & mstr & modfen & (~ssoe); // Mode Fault
    
    // Status register with reset value
    assign SPI_SR = !PRESETn ? 8'b0010_0000 : 
                   {spif, 1'b0, sptef, modf, 4'b0};
    
    // Configuration Register Writes
    // Handles writes to CR1, CR2, and BR registers
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset values
            SPI_CR1 <= 8'h04;
            SPI_CR2 <= 8'h00;
            SPI_BR  <= 8'h00;
        end
        else if (wr_enb) begin
            case (PADDR)
                3'b000: SPI_CR1 <= PWDATA;         // Write to CR1
                3'b001: SPI_CR2 <= PWDATA & cr2_mask; // Masked write to CR2
                3'b010: SPI_BR  <= PWDATA & br_mask;  // Masked write to BR
            endcase
        end
    end

    // Data Register and Send Control
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            SPI_DR    <= 8'b0;
            send_data <= 1'b0;
        end
        else if (wr_enb && (PADDR == 3'b101)) begin
            // Write to data register
            SPI_DR <= PWDATA;
        end
        else if (!wr_enb) begin
            if (select) begin
                // Prepare to send data
                SPI_DR    <= 8'b0;
                send_data <= 1'b1;
            end 
            else if (sel) begin
                // Receive data from MISO
                SPI_DR    <= miso_data;
                send_data <= 1'b0;
            end 
            else begin
                send_data <= 1'b0;
            end
        end 
    end
      
    // Interrupt Request Logic
    assign spi_interrupt_request = 
        (!spie && !sptie) ? 1'b0 :
        (spie && !sptie)  ? (spif || modf) :
        (!spie && sptie)  ? sptef :
        (spif || sptef || modf);
    
    // MOSI Data Output 
always@(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn)
		    mosi_data <= 0;
		else if (((SPI_DR == PWDATA) && SPI_DR != miso_data) && (spi_mode == spi_run || spi_mode == spi_wait) && ~wr_enb) begin
			  mosi_data <= SPI_DR;
		end 
	end
    // PRDATA Read Multiplexer
    always @(*) begin
        if (rd_enb) begin
            case (PADDR)
                3'b000: PRDATA = SPI_CR1;  // Read CR1
                3'b001: PRDATA = SPI_CR2;  // Read CR2
                3'b010: PRDATA = SPI_BR;   // Read BR
                3'b011: PRDATA = SPI_SR;   // Read Status
                3'b101: PRDATA = SPI_DR;   // Read Data
                default: PRDATA = 8'h00;   // Default
            endcase
        end
        else begin
            PRDATA = 8'b0;  // Drive 0 when not reading
        end
    end

    // APB State Machine (Sequential)
    always @(posedge PCLK) begin
        if (!PRESETn) begin
            STATE <= IDLE;
        end
        else begin
            STATE <= next_state;
        end
    end
      
    // APB State Machine (Combinational)
    always @(*) begin
        case (STATE)
            IDLE: begin
                if (PSEL && !PENABLE) 
                    next_state = SETUP;
                else 
                    next_state = IDLE;
            end
            SETUP: begin
                if (PSEL && PENABLE)
                    next_state = ENABLE;
                else if (PSEL && !PENABLE)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            ENABLE: begin
                if (PSEL)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
      
    // SPI Mode Control (Sequential)
    always @(posedge PCLK) begin
        if (!PRESETn) begin  
            spi_mode <= spi_run;  // Default to run mode
        end 
        else begin
            spi_mode <= next_mode;
        end
    end
      
    // SPI Mode Control (Combinational)
    always @(*) begin
        case (spi_mode)
            spi_run: begin
                if (!spe)
                    next_mode = spi_wait;
                else
                    next_mode = spi_run;
            end
            spi_wait: begin
                if (spe)
                    next_mode = spi_run;
                else if (spiswai)
                    next_mode = spi_stop;
                else
                    next_mode = spi_wait;
            end
            spi_stop: begin
                if (!spiswai)
                    next_mode = spi_wait;
                else if (spe)
                    next_mode = spi_run;
                else
                    next_mode = spi_stop;
            end
            default: next_mode = spi_run;
        endcase
    end
endmodule
