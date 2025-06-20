module APB_Slave_Interface(
  input PClk, PRESENTn, PWRITE, PSEL, PENABLE, SS, receive_data, tip,
  input [2:0] PADDR,
  input [7:0] PWDATA, miso_data,
  output mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, PREADY, PSLVERR, send_data, mosi_data,
  output reg [1:0] spi_mode,
  output [2:0] sppr, spr, 
  output [7:0] PRDATA);
  
  reg [7:0] SPI_CR1, SPI_CR2, SPI_SR, SPI_DR, SPI_BR;
  
  wire sptef, spif, spe, modfen, modf, ssoe, wr_enb, rd_enb, spie, sptie;

  wire [7:0] SPI_CR1_a, SPI_CR1_b, SPI_CR2_a, SPI_CR2_b, SPI_BR_a, SPI_BR_b, PRDATA_a, PRDATA_b, PRDATA_c, PRDATA_d;
  reg [7:0] SPI_CR1_c, SPI_CR2_c, SPI_BR_c;
  wire PWDATA_int, select, reuse;
  wire send_data_a, send_data_b, send_data_c;
  reg send_data_d;
  wire [7:0] SPI_DR_a, SPI_DR_b, SPI_DR_c, SPI_DR_d;
  reg [7:0] SPI_DR_e;

  
  parameter cr2_mask = 8'b0001_1011;
  parameter br_mask = 8'b0111_0111;
  parameter spi_run = 2'b00;
  parameter spi_wait = 2'b01;
  parameter spi_stop = 2'b10; 

  reg [1:0] next_mode, STATE, next_state; 

  parameter IDLE = 2'b00;
  parameter SETUP = 2'b01; // Setup state
  parameter ENABLE = 2'b10; // Enable state

  assign ssoe = SPI_CR1[1];
  assign mstr = SPI_CR1[4];
  assign spe = SPI_CR1[6];
  assign spie = SPI_CR1[7];
  assign sptie= SPI_CR1[5];
  assign cpol = SPI_CR1[3];
  assign cpha = SPI_CR1[2];
  assign lsbfe = SPI_CR1[0];
  assign modfen = SPI_CR2[4];
  assign spiswai = SPI_CR2[1];
  assign sppr = SPI_BR[6:4];
  assign spr = SPI_BR[2:0];

  assign wr_enb = PWRITE && (STATE == ENABLE);
  assign rd_enb = !PWRITE && (STATE == ENABLE);
  assign PREADY = (STATE == ENABLE)? 1'b1 : 1'b0;
  assign PSLVERR = (STATE == ENABLE)? tip : 1'b0;
  assign sptef = (SPI_DR == 8'b0)? 1'b1: 1'b0;
  assign spif = (SPI_DR != 8'b0)? 1'b1: 1'b0;
  assign modf = (~SS) & mstr & modfen & (~ssoe);

  mux8 m1(.a({spif,1'b0, sptef,modf,4'b0}), .b(8'b00100000), .s(PRESETn), .y(SPI_SR));

  mux8 spi_cr1_a(.a(SPI_CR1), .b(PWDATA), .s(PADDR == 3'b0), .y(SPI_CR1_a));
  mux8 spi_cr1_b(.a(8'h00), .b(SPI_CR1_a), .s(wr_enb), .y(SPI_CR1_b));
  always@(posedge PClk)
    SPI_CR1_c <= SPI_CR1_b;
  mux8 spi_cr1(.a(8'h04), .b(SPI_CR1_c), .s(PRESETn), .y(SPI_CR1));
  
  mux8 spi_cr2_a(.a(SPI_CR2), .b(PWDATA & cr2_mask), .s(PADDR == 3'b001), .y(SPI_CR2_a));
  mux8 spi_cr2_b(.a(8'h04), .b(SPI_CR2_a), .s(wr_enb), .y(SPI_CR2_b));
  always@(posedge PClk)
    SPI_CR2_c <= SPI_CR2_b;
  mux8 spi_cr2(.a(8'h00), .b(SPI_CR2_c), .s(PRESETn), .y(SPI_CR2));
  
  mux8 spi_br_a(.a(SPI_BR), .b(PWDATA & br_mask), .s(PADDR == 3'b010), .y(SPI_BR_a));
  mux8 spi_br_b(.a(8'h00), .b(SPI_BR_a), .s(wr_enb), .y(SPI_BR_b));
  always@(posedge PClk)
    SPI_BR_c <= SPI_BR_b;
  mux8 spi_br(.a(8'h00), .b(SPI_BR_c), .s(PRESETn), .y(SPI_BR));
  
  mux8 prdata_a(.a(SPI_DR), .b(SPI_SR), .s(PADDR == 3'b011), .y(PRDATA_a));
  mux8 prdata_b(.a(PRDATA_a), .b(SPI_BR), .s(PADDR == 3'b010), .y(PRDATA_b));
  mux8 prdata_c(.a(PRDATA_b), .b(SPI_CR2), .s(PADDR == 3'b001), .y(PRDATA_c));
  mux8 prdata_d(.a(PRDATA_c), .b(SPI_CR1), .s(PADDR == 3'b000), .y(PRDATA_d));
  mux8 prdata(.a(8'b0), .b(PRDATA_d), .s(rd_enb), .y(PRDATA));

  assign reuse = ((spi_mode == spi_run) | (spi_mode == spi_wait));
  assign PWDATA_int = ((SPI_DR == PWDATA) & (SPI_DR != miso_data) & reuse);
  assign select = (reuse & receive_data);

  assign send_data_a = select? 1'b0:1'b1;
  assign send_data_b = PWDATA_int? 1'b1:send_data_a;
  assign send_data_c = wr_enb? send_data:send_data_b;
  always@(posedge PClk)
    send_data_d <= send_data_c;
  assign send_data = PRESETn? 1'b0:send_data_d;

  mux8 spi_dr_a(.a(SPI_DR), .b(miso_data), .s(select), .y(SPI_DR_a));
  mux8 spi_dr_b(.a(SPI_DR_a), .b(8'b0), .s(PWDATA_int), .y(SPI_DR_b));
  mux8 spi_dr_c(.a(SPI_DR), .b(PWDATA), .s(PADDR == 3'b101), .y(SPI_DR_c));
  mux8 spi_dr_d(.a(SPI_DR_b), .b(SPI_DR_c), .s(wr_enb), .y(SPI_DR_d));
  always@(posedge PClk) 
    SPI_DR_e <= SPI_DR_d;
  mux8 spi_dr(.a(8'b0), .b(SPI_DR_e), .s(PRESETn), .y(SPI_DR));

always @(posedge PClk) begin
    if (!PRESETn) begin  
        STATE <= IDLE;
    end else begin
        STATE <= next_state;
    end
end

// Combinational next_state logic
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
            else
                next_state = SETUP;
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

// Sequential update of spi_mode
always @(posedge PClk) begin
    if (!PRESETn) begin  
        spi_mode <= spi_run;
    end else begin
        spi_mode <= next_mode;
    end
end

// Combinational next_mode logic
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
