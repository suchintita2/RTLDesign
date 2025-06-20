module Baud_Rate_Generator(
  input PClk, PRESETn, spiswwai, cpol, cpha, SS,
  input [1:0] spi_mode,
  input [2:0] sppr, spr,
  output sclk, flag_low, flags_low, flag_high, flags_high,
  output [11:0] baud_rate_divisor
);

  wire select1, count, select2;
  wire count_a, count_b, sclk_a, sclk_b;
  reg count_c, sclk_c;
  
  assign baud_rate_divisor = ((sppr+1)*(2^(spr+1)));

  assign select = (~SS) & (~spiswai) & (spi_mode == 2'b00 | spi_mode == 2'b01));
  
  assign count_a = ((count == (baud_rate_divisor - 1'b1))? 12'b0:count+1'b1);
  assign count_b = (select ? count_a : 12'b0);
  always@(posedge PClk)
    count_c <= count_b;
  assign count = (PRESETn ? count_c : 12'b0);

  assign sclk_a = ((count == (baud_rate_divisor - 1'b1)) ? (~sclk) : sclk);
  assign sclk_b = (select ? sclk_a : pre_sclk);
  always@(posedge PClk)
    sclk_c <= sclk_b;
  assign sclk = (PRESETn ? sclk_c : pre_sclk);

  assign select2 = ((cpha & (~cpol)) | ((~cpha) & cpol));

  
