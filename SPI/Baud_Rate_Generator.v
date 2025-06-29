module Baud_Rate_Generator(
  input PCLK, PRESETn, spiswai, cpol, cpha, ss,
  input [1:0] spi_mode,
  input [2:0] sppr, spr,
  output reg sclk, flag_low, flags_low, flag_high, flags_high,
  output [11:0] baud_rate_divisor
);

  reg [11:0] count;
  wire pre_sclk;
  
  assign baud_rate_divisor = ((sppr+1) * (2**(spr+1)));
  assign pre_sclk = cpol;
  
  assign select = ((~ss) && (~spiswai) && (spi_mode == 2'b00 || spi_mode == 2'b01));
  assign sel = (cpha ^ cpol);

  always@(posedge PCLK or nedgedge PRESETn) begin
    if(!PRESETn) begin
      sclk <= pre_sclk;
      count <= 12'b0;
    end
    else if(select) begin
      if(count == (baud_rate_divisor - 1'b1)) begin
        count <= 12'b0;
        sclk <= ~sclk;
      end
      else
        count <= (count+1'b1);
    end
    else if(!select) begin
      count <= 12'b0;
      sclk <= pre_sclk;
    end
  end

  always@(posedge PCLK or nedgedge PRESETn) begin
    if(!PRESETn) begin
      flag_low <= 1'b0;
      flags_low <= 1'b0;
      flag_high <= 1'b0;
      flags_high <= 1'b0;
    end
    else if(sel) begin
      if(sclk) begin
        if(count == (baud_rate_divisor - 1'b1))
          flag_high <= 1'b1;
        else if(count == (baud_rate_divisor - 2'b10))
          flags_high <= 1'b1;
        else begin
          flag_high <= 1'b0;
          flags_high <= 1'b0;
        end
      end else begin
        flag_high <= 1'b0;
        flags_high <= 1'b0;
      end
    end else if (!sel) begin
      if(!sclk) begin
        if(count == (baud_rate_divisor - 1'b1))
          flag_low <= 1'b1;
        else if(count == (baud_rate_divisor - 2'b10))
          flags_low <= 1'b1;
        else begin
          flag_low <= 1'b0;
          flags_low <= 1'b0;
        end
      end else begin
        flag_low <= 1'b0;
        flags_low <= 1'b0;
      end
    end
  end
endmodule



