module APB_Slave_Interface(
  input PClk, PRESENTn, PWRITE, PSEL, PENABLE, SS, receive_data, tip,
  input [2:0] PADDR,
  input [7:0] PWDATA, miso_data,
  output mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, PREADY, PSLVERR, send_data, mosi_data, spi_mode,
  output [2:0] sppr, spr, 
  output [7:0] PRDATA);
  
  reg [7:0] SPI_CR1, SPI_CR2, SPI_SR, SPI_DR, SPI_BR;
  

  wire sptef, spif, spe, modfen, modf, ssoe, wr_enb, rd_enb, spie, sptie;

  wire SPI_CR1_a, SPI_CR1_b,
  reg SPI_CR1_c, 
  
  parameter cr2_mask = 8'b0001_1011;
  parameter br_mask = 8'b0111_0111;
  parameter spi_run 2'b00;
  parameter spi_wait 2'b01;
  parameter spi_stop 2'b10; 

  reg [1:0] next_mode, STATE, next_state; 

  parameter IDLE = 2'600;
  parameter SETUP 2'601; // Setup state
  parameter ENABLE 2'b10; // Enable state

  assign ssoe = SPI_CR1[1];
  assign mstr = SPI_CR1[4];
  assign spe SPI_CR1[6];
  assign spie = SPI_CR1[7];
  assign sptie= SPI_CR1[5];
  assign cpol = SPI_CR1[3];
  assign cpha= SPI_CR1[2];
  assign lsbfe = SPI_CR1[0];
  assign modfen = SPI_CR2[4];
  assign spiswai = SPI_CR2[1]; //to
  assign sppr= SPI_BR[6:4];
  assign spr = SPI_BR[2:0];

  assign wr_enb = PWRITE && (STATE ENABLE);
  assign rd_enb = !PWRITE && (STATE ENABLE);
  assign PREADY = (STATE == ENABLE)? 1'b1 : 1'b0;
  assign PSLVERR = (STATE == ENABLE)? tip : 1'b0;
  assign sptef = (SPI_DR == 8'b0)? 1'b1: 1'b0;
  assign spif = (SPI_DR != 8'b0)? 1'b1: 1'b0;
  assign modf = (~SS) & mstr & modfen & (~ssoe);

  mux m1(.a({spif,1'b0, sptef,modf,4'b0}), .b(8'b00100000), .s(PRESETn), .y(SPI_SR));

  mux spi_cr1_a(.a(SPI_CR1), .b(PWDATA), .s(PADDR == 3'b0), .y(SPI_CR1_a));
  mux spi_cr1_b(.a(8'b0), .b(SPI_CR1_a), .s(wr_enb), .y(SPI_CR1_b));
  always@(posedge clk)
    SPI_CR1_c <= SPI_CR1_b;
  mux spi_cr1(.a(8'b0), .b(SPI_CR1_c), .s(PRESETn), .y(SPI_CR_1));

  
