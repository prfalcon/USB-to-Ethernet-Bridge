// $Id: $
// File name:   addr_counter.sv
// Created:     12/3/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: address counter with rollback functionality
module addr_counter 
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk, n_rst, clear, count_enable,  start, error,  //Added start, error, and success to update or roll back the count
	input wire [NUM_CNT_BITS - 1:0] rollover_val,
	output wire [NUM_CNT_BITS - 1:0] count_out,
	output reg rollover_flag
);
	// Input "start" must be strobed for one cycle to set the rollback count in case of an error

	reg [NUM_CNT_BITS - 1:0] count;
	reg [NUM_CNT_BITS - 1:0] nxt_count;
	reg [NUM_CNT_BITS - 1:0] start_count;
	reg [NUM_CNT_BITS - 1:0] nxt_start_count;
	reg rf;

	assign count_out = count;

	always_ff @(posedge clk, negedge n_rst) begin
		if(n_rst == 0) begin
			count <= 0;
			rollover_flag <= 0;
			start_count <= 0;
		end
		else begin			
			count <= nxt_count;
			rollover_flag <= rf;
			start_count <= nxt_start_count;
		end
	end
	
	always_comb begin
		if(start == 1) begin
			nxt_start_count = count;
		end
		else begin
			nxt_start_count = start_count;
		end
		if(clear == 1) begin
			nxt_count = count - 2;
			//nxt_start_count = 0;
		end
		else if(error == 1) begin
			nxt_count = start_count;
		end
		else if(count_enable) begin
			if(rollover_flag == 1) begin
				nxt_count = 1;
			end
			else begin
				nxt_count = count + 1;
			end
		end
		else begin
			nxt_count = count;
		end
		if(nxt_count == rollover_val) begin
			rf = 1;
		end	
		else begin
			rf = 0;
		end		

	end
endmodule
