// $Id: $
// File name:   re_timer.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB Receiver Timer

module re_timer
(
input clk, n_rst, d_edge, receiving, data_enable, unstuff_hold, 
output reg byte_processed, final_enable, n_enable
);
reg [3:0] count, temprary;
reg [3:0] shift_count;
reg ignore, temp;

assign n_enable = (shift_count == 4'b0100) ? 1 : 0;

always_ff @ (posedge clk, negedge n_rst) 
begin
	if (!n_rst) begin
		final_enable <= 0;
	end else begin
		if (data_enable & !unstuff_hold) begin
			final_enable <= n_enable;
		end else begin
			final_enable <= 0;
		end
	end
end

re_flex_counter SHIFT (.clk(clk), .n_rst(n_rst), .clear(d_edge), .count_enable(receiving), .rollover_val(4'd16), .rollover_flag(ignore), .count_out(shift_count));

re_flex_counter BYTE (.clk(clk), .n_rst(n_rst), .clear(!receiving), .count_enable(final_enable), .rollover_val(4'd8), .rollover_flag(byte_processed), .count_out(count));

assign temp = ignore & 1;
assign temporary = count & 4'b1111;

endmodule
		 
