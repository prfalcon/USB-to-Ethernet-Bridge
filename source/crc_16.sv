// $Id: $
// File name:   crc_16.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 16-bit CRC Checker

module crc_16
(
input clk, n_rst, d_unstuffed, final_enable, init, crc_16_enable, crc_16_check,
output reg crc_16_passed 
);

reg [0:15] check_16;

always_ff @ (posedge clk, negedge n_rst)
begin
	if (!n_rst) begin
		check_16 <= '0;
	end else if (init) begin
		check_16 <= '0;
	end else if (final_enable & crc_16_enable) begin
		check_16[0] <= d_unstuffed ^ check_16[15];
		check_16[1] <= check_16[0];
		check_16[2] <= check_16[1] ^ d_unstuffed ^ check_16[15];
		check_16[3] <= check_16[2];
		check_16[4] <= check_16[3];
		check_16[5] <= check_16[4];
		check_16[6] <= check_16[5];
		check_16[7] <= check_16[6];
		check_16[8] <= check_16[7];
		check_16[9] <= check_16[8];
		check_16[10] <= check_16[9];
		check_16[11] <= check_16[10];
		check_16[12] <= check_16[11];
		check_16[13] <= check_16[12];
		check_16[14] <= check_16[13];
		check_16[15] <= check_16[14] ^ d_unstuffed ^ check_16[15];
	end else begin 
		check_16 <= check_16;
	end
end

assign crc_16_passed = crc_16_check & (check_16 == '0);

endmodule	
	




