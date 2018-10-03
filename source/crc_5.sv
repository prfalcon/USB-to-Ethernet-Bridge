// $Id: $
// File name:  	crc_5.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 5-bit CRC checker

module crc_5
(
input clk, n_rst, d_unstuffed, final_enable, init, crc_5_enable, crc_5_check,
output reg crc_5_passed 
);

reg [0:4] check_5;

always_ff @ (posedge clk, negedge n_rst)
begin
	if (!n_rst) begin
		check_5 <= '0;
	end else if (init) begin
		check_5 <= '0;
	end else if (final_enable & crc_5_enable) begin
		check_5[0] <= d_unstuffed ^ check_5[4];
		check_5[1] <= check_5[0];
		check_5[2] <= check_5[1] ^ d_unstuffed ^ check_5[4];
		check_5[3] <= check_5[2];
		check_5[4] <= check_5[3];
	end else begin
		check_5 <= check_5;
	end
end

assign crc_5_passed = crc_5_check & (check_5 == '0);

endmodule

