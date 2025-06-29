module tb;

  reg PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso;
  reg [2:0] PADDR;
  reg [7:0] PWDATA;
  wire [7:0] PRDATA;
  wire PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request;

  integer i;

  top DUT(PCLK, PRESETn, PWRITE, PSEL, PENABLE, miso, PADDR, PWDATA,
          PRDATA, PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request);
  
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
  end

  task reset;
    begin
      #10;
      PRESETn = 1'b0;
      #10;
      PRESETn = 1'b1;
    end
  endtask

  task miso_bits_lsb (input [7:0] miso_data);
    begin
      wait(~ss)
      for(i=0; i<8; i=i+1) begin
        @(posedge sclk)
        miso = miso_data[i];
      end
    end
  endtask

  task miso_bits_msb (input [7:0] miso_data);
    begin
      wait(~ss)
      for(i=7; i>=0; i=i-1) begin
        @(posedge sclk)
        miso = miso_data[i];
      end
    end
  endtask

  task write_registers(input[7:0] contr1_data, input [7:0] contr2_data, input [7:0] baud_data);
    begin
      @(posedge PCLK)
      PADDR = 3'b0;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b0;
      PWDATA = contr1_data;

      @(posedge PCLK)
      PADDR = 3'b0;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;
      PWDATA = contr1_data;

      @(posedge PCLK)
      wait(PREADY)
      PENABLE = 1'b0;

      @(posedge PCLK)
      PADDR = 3'b1;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;
      PWDATA = contr2_data;

      @(posedge PCLK)
      wait(PREADY)
      PENABLE = 1'b0;

      @(posedge PCLK)
      PADDR = 3'b010;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;
      PWDATA = baud_data;

      @(posedge PCLK)
      wait(PREADY)
      PENABLE = 1'b0;

    end
  endtask

  task write_data_register(input[7:0] write_data);
    begin
      @(posedge PCLK)
      PADDR = 3'b101;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;
      PWDATA = write_data;

      @(posedge PCLK)
      PADDR = 3'b101;
      PWRITE = 1'b1;
      PSEL = 1'b1;
      PENABLE = 1'b1;
      PWDATA = write_data;

      @(posedge PCLK)
      wait(PREADY);
      PADDR = 3'b101;
      PWRITE = 1'b0;
      PSEL = 1'b0;
      PENABLE = 1'b0;
      PWDATA = write_data;
    
    end
  endtask

  initial begin
    miso = 0;
    reset;
    //write_registers(8'b1111_0101, 8'b1100_0001, 8'b0000_0001);
    write_registers(8'b1011_0000, 8'b1100_0001, 8'b0000_0001);
    write_registers(8'b1011_0000, 8'b1100_0011, 8'b0000_0001);
    write_registers(8'b1111_0000, 8'b1100_0001, 8'b0000_0001);
    write_registers(8'b1010_1010);
    //miso_bits_lsb(8'b10101010);
    miso_bits_msb(8'b10101010);
  end

  initial #2000 $finish;

endmodule
