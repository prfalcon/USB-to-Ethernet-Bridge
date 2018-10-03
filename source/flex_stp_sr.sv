// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/13/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scalable Serial-to-Parallel Shift Register Design

`timescale 1ns / 10ps

module flex_stp_sr
#(
parameter NUM_BITS = 4,
parameter SHIFT_MSB = 1
)
(
input wire clk, n_rst, shift_enable, serial_in,
output reg [(NUM_BITS-1):0] parallel_out
);

reg [(NUM_BITS-1):0] poutput;

assign parallel_out = poutput;

always_ff @ (posedge clk, negedge n_rst) 
begin
	if(! n_rst) begin 
		poutput <= '1;
	end else begin
		if (shift_enable) begin
			if (SHIFT_MSB) begin
				poutput <= {poutput[(NUM_BITS-2):0],serial_in};
			end else if (!SHIFT_MSB) begin 
				poutput <= {serial_in,poutput[(NUM_BITS-1):1]};
			end
		end else begin 
			poutput <= poutput;
		end
	end
end

endmodule
			



