// $Id: $
// File name:   sync_high.sv
// Created:     9/6/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Reset to Logic High Synchronizer

module sync_high
(
input wire clk,
input wire n_rst,
input wire async_in,
output reg sync_out
);

reg out_1;

always_ff @ (posedge clk, negedge n_rst)
begin : logichigh
	if(1'b0 == n_rst)
	begin 
		out_1 <= 1'b1;
	end
	else
	begin
		out_1 <= async_in;
	end
end


always_ff @ (posedge clk, negedge n_rst)
begin : logichigh2
	if(1'b0 == n_rst)
	begin 
		sync_out <= 1'b1;
	end
	else
	begin
		sync_out <= out_1;
	end
end
endmodule
