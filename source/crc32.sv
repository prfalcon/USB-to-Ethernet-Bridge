// $Id: $
// File name:   crc32.sv
// Created:     12/5/2017
// Author:      Vishnu Gopal
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: .

module crc32 (
  input  logic        clk,
  input  logic        reset,
  input  logic        crc_en,
  input  logic [7:0]  data_in,
  output logic [31:0] crc_out
  );

  localparam DATA_WIDTH = 8;
  localparam POLY_BITS = 32;
  localparam POLYNOMIAL = 33'h104C11DB7;

  function [POLY_BITS-1:0] update_crc;
    input [POLY_BITS-1:0] old_crc;
    input data_in;
    input [POLY_BITS-0:0] polynomial;
    reg [POLY_BITS-1:0] new_crc;
    reg feedback;
    begin
      feedback = old_crc[POLY_BITS-1] ^ data_in;
      new_crc = old_crc << 1;
      update_crc = feedback ? new_crc ^ polynomial[POLY_BITS-1:0] : new_crc;
    end
  endfunction

  function [POLY_BITS-1:0] update_crc_parallel;
    input [POLY_BITS-1:0] old_crc;
    input [DATA_WIDTH-1:0] data_in;
    input [POLY_BITS-0:0] polynomial;
    reg [POLY_BITS-1:0] new_crc;
    integer i;
    begin
      new_crc = old_crc;
      for (i=0; i<DATA_WIDTH; i=i+1) begin
        new_crc = update_crc(new_crc, data_in[i], polynomial);
      end
      update_crc_parallel = new_crc;
	//$info("crc updated: %b", new_crc);
    end
  endfunction
  
  always_ff @(posedge clk) begin
    if (reset) begin
      crc_out <= {32{1'b1}};
    end else if (crc_en) begin
      crc_out <= update_crc_parallel(crc_out,data_in,POLYNOMIAL);
    end
  end
  
endmodule