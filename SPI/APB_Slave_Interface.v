
module APB_Slave_Interface(
  input PCLK, PRESENTn, PWRITE, PSEL, PENABLE, ss, receive_data, tip,
  input [2:0] PADDR,
  input [7:0] PWDATA, miso_data,
  output mstr, cpol, cpha, lsbfe, spiswai, spi_interrupt_request, PREADY, PSLVERR, send_data, mosi_data,
  output reg [1:0] spi_mode,
  output [2:0] sppr, spr, 
  output [7:0] PRDATA);
  
  reg [7:0] SPI_CR1, SPI_CR2, SPI_SR, SPI_DR, SPI_BR;
  
  wire sptef, spif, spe, modfen, modf, ssoe, wr_enb, rd_enb, spie, sptie;
  
  parameter cr2_mask = 8'b0001_1011;
  parameter br_mask = 8'b0111_0111;
  parameter spi_run = 2'b00;
  parameter spi_wait = 2'b01;
  parameter spi_stop = 2'b10; 

  reg [1:0] next_mode, STATE, next_state; 
  wire sel, select;

  assign sel = ((spi_mode == spi_run) || (spi_mode == spi_wait));
  assign select = ((SPI_DR == PWDATA) && (SPI_DR != miso_data) && sel);

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
  assign PREADY = (STATE == ENABLE);
  assign PSLVERR = (STATE == ENABLE)? tip : 1'b0;
  assign sptef = (SPI_DR == 8'h00);
  assign spif = (SPI_DR != 8'h00);
  assign modf = (~SS) & mstr & modfen & (~ssoe);
  assign SPI_SR = PRESETn? 8'b0010_0000 : ({spif,1'b0, sptef,modf,4'b0});

  always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
      SPI_CR1 <= 8'h04;
      SPI_CR2 <= 8'h00;
      SPI_BR <= 8'h00;
    end
    else if(wr_enb) begin
      if(PADDR == 3'b000)
        SPI_CR1 <= PWDATA;
      else if(PADDR == 3'b001)
        SPI_CR2 <= (PWDATA && cr2_mask);
      else if(PADDR == 3'b010)
        SPI_BR <= (PWDATA && br_mask);
    end else if (!wr_enb) begin
      SPI_CR1 <= 8'h00;
      SPI_CR2 <= 8'h04;
      SPI_BR <= 8'h00;
    end
  end

  always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
      SPI_DR <= 8'b0;
      send_data <= 1'b0;
    end
    else if(wr_enb && (PADDR == 3'b101))
      SPI_DR <= PWDATA;
    else if(!wr_enb) begin
      if(select) begin
        SPI_DR <= 8'b0;
        send_data <= 1'b1;
      end else begin
        if(sel) begin
          SPI_DR <= miso_data;
          send_data <= 1'b0;
        end else
          send_data <= 1'b0;
      end
    end 
  end

  assign spi_interrupt_request = ( !spie && !sptie )?0:
                   ( spie && !sptie )? (spif || modf ):
                 ( !spie && sptie )? sptef :
                 (spif || sptef || modf );

  always@(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
	    mosi_data <= 0;
    else if (((SPI_DR == PWDATA) && SPI_DR != miso_data) && (spi_mode  spi_run || spi_mode  spi_wait) && ~wr_enb) begin
      mosi_data <= SPI_DR;
 	  end 
  end

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
