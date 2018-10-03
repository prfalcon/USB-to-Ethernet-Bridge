// $ID: mg 82
// File name: flex_pts_sr.sv 
// Author: Akshay Raj
// Lab Section: Wednesday

module flex_pts_sr
	#(
		parameter NUM_BITS = 4,
		parameter SHIFT_MSB = 1
	)
	(
		input wire 	clk,
		input wire 	n_rst,
		input wire 	shift_enable,
		input wire 	load_enable, 
				load_sync, 
				load_data_pid , 
				load_data_1_crc, 
				load_data_2_crc, 
				load_ack , 
				load_nack, 
				load_stall,
		input wire 	[(NUM_BITS-1):0] parallel_in,

		output wire 	serial_out 
	);
	
	
		localparam 	SYNC_BYTE_PID 	= 8'b10000000 , 
	    			DATA0_PID   	= 8'b11000011 ,
	    			ACK_PID    	= 8'b10110100 , 
	    			NACK_PID    	= 8'b10100101 ,
				STALL_PID	= 8'b00110011 ,
				CRC_1_PACK	= 8'b00000000 ,
				CRC_2_PACK	= 8'b00000000 ;
	
	reg [(NUM_BITS-1):0] mid_state = 0;
	reg [(NUM_BITS-1):0] curr_state = 0;
	
	always_comb
	begin
		
		if(load_enable == 1'b1)
			mid_state = parallel_in; 
		else if (load_sync) 
			mid_state = SYNC_BYTE_PID; 
		else if (load_data_pid) 
			mid_state = DATA0_PID; 
		else if (load_data_1_crc) 
			mid_state = CRC_1_PACK; 
		else if (load_data_2_crc) 
			mid_state = CRC_2_PACK; 
		else if (load_ack) 
			mid_state = ACK_PID; 
		else if (load_nack) 
			mid_state = NACK_PID; 
		else if (load_stall)
			mid_state = STALL_PID;
		else
		begin
			if(shift_enable == 1)
			begin
				if(SHIFT_MSB == 1)
				begin
					mid_state = {curr_state[(NUM_BITS-2):0], 1'b0}; 
				end
				else
				begin
					mid_state = {1'b0, curr_state[(NUM_BITS-1):1]};
				end
			end
			else
			begin
				mid_state = curr_state;
			end
		end
	end
	
	always_ff @ (posedge clk, negedge n_rst)
	begin
		if(1'b0 == n_rst)
		begin
			curr_state <= '0;
		end
		else
		begin
			curr_state <= mid_state;
		end
	end
	
	if(SHIFT_MSB == 1)
	begin
		assign serial_out = curr_state[(NUM_BITS-1)];
	end
	else
	begin
		assign serial_out = curr_state[0];
	end
	
	endmodule
