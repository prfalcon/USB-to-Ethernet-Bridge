// $Id: $
// File name:   bit_unstuff.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB Receiver Bit-Unstuffer

module bit_unstuff
(
input clk, n_rst, d_decoded, data_enable,
output reg d_unstuffed, unstuff_hold
);

reg [2:0] count;

always_ff @ (posedge clk, negedge n_rst)
begin
	if (!n_rst) begin
		d_unstuffed <= 1'b1;
	end else begin
		d_unstuffed <= d_decoded;
	end 
end

re_flex_counter #(3) BCNT (.clk(clk), .n_rst(n_rst), .clear(d_decoded), .count_enable(data_enable & !d_decoded), .rollover_val(3'b110), .rollover_flag(unstuff_hold), .count_out(count));

endmodule
