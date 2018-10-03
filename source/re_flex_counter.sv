// $Id: $
// File name:   flex_counter.sv
// Created:     9/16/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter

module re_flex_counter
#(
parameter NUM_CNT_BITS = 4
)
(
input clk, n_rst, clear, count_enable, 
input [(NUM_CNT_BITS - 1):0] rollover_val,
output reg [(NUM_CNT_BITS -1):0] count_out,
output reg rollover_flag
);

reg [(NUM_CNT_BITS - 1):0] count;
reg [(NUM_CNT_BITS - 1):0] n_count;
reg rollover;

assign count_out = count;

always_ff @ (posedge clk, negedge n_rst)
begin 
	if (!n_rst) begin
		count <= '0;
		rollover_flag <= 0;
	end else begin
		count <= n_count;
		rollover_flag <= rollover;
	end
end

always_comb
begin
	if (clear) begin
		n_count = '0;
		rollover = 0;
	end else if (count_enable) begin
		if (count == rollover_val) begin
			n_count = 1;
		end else begin
			n_count = count + 1;	
		end
	end else begin
		n_count = count;
	end

	if ((n_count == rollover_val) && (count_enable)) begin
		rollover = 1'b1;
	end else begin 
		rollover = 1'b0;
	end
end 
endmodule




	
	
