// $Id: $
// File name:   updown_counter.sv
// Created:     12/2/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Up/down counter for FIFO space
module updown_counter 
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk, n_rst, clear, count_up, count_down, start, error,  //Added start, error, and success to update or roll back the count
	input wire [NUM_CNT_BITS - 1:0] rollover_val,
	output wire [NUM_CNT_BITS - 1:0] count_out,
	output reg fifo_full, fifo_empty
);
	// Input "start" must be strobed for one cycle to set the rollback count in case of an error

	reg [NUM_CNT_BITS - 1:0] count;
	reg [NUM_CNT_BITS - 1:0] nxt_count;
	reg [NUM_CNT_BITS - 1:0] start_count;
	reg [NUM_CNT_BITS - 1:0] nxt_start_count;
	reg ff, fe;

	assign count_out = count;

	always_ff @(posedge clk, negedge n_rst) begin
		if(n_rst == 0) begin
			count <= 0;
			fifo_full <= 0;
			fifo_empty <= 1;
			start_count <= 0;
		end
		else begin			
			count <= nxt_count;
			fifo_full <= ff;
			fifo_empty <= fe;
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
		else if(count_up) begin
			if(fifo_full == 1) begin
				nxt_count = rollover_val;
			end
			else begin
				nxt_count = count + 1;
			end
		end
		else if(count_down) begin
			if(fifo_empty == 1) begin
				nxt_count = 0;
			end
			else begin
				nxt_count = count - 1;
			end
		end
		else begin
			nxt_count = count;
		end
		if(nxt_count == rollover_val) begin
			ff = 1;
		end	
		else begin
			ff = 0;
		end	
		if(nxt_count == 0) begin
			fe = 1;
		end	
		else begin
			fe = 0;
		end	

	end
endmodule
