// $ID: mg 82
// File name: tcu.sv 
// Author: Akshay Raj
// Lab Section: Wednesday
module tcu (
	 
	input wire 	clk,
	 		n_rst,
	 		tx_ena,
	 		tx_nack, 
	 		tx_ack,
	 		cnt_done, 
	 		stall,
			ack_prep,
	
	 output reg	
			tx_complete,
			eop,
			start_read,
			load_ena, 
			load_sync, 
			load_data_pid , 
			load_data_1_crc, 
			load_data_2_crc, 
			load_ack , 
			load_nack,
			load_stall,
			ack_done,
			clear
	);	
	
		typedef enum reg [4:0] {
		IDLE,
		TRANSMIT_DATA_SYNC,
		SHIFT_DATA_SYNC, 
		TRANSMIT_DATA_PID,
		SHIFT_DATA_PID,  
		LOAD_PTS, 
		CHK_BUFF, 
	 	TRANSMIT_DATA_1_CRC,
		SHIFT_DATA_1_CRC,
	 	TRANSMIT_DATA_2_CRC,
		SHIFT_DATA_2_CRC,
	 	TRANSMIT_DATA_EOP,
		TRANSMIT_HS_SYNC,
		SHIFT_HS_SYNC,
	 	TRANSMIT_ACK,
		SHIFT_ACK, 
	 	TRANSMIT_NACK,
		SHIFT_NACK, 
		TRANSMIT_STALL,
		SHIFT_STALL,
	 	TRANSMIT_HS_EOP,
		SHIFT_DATA,
		COMPLETE
		} state_type ;
		
		state_type	next_state, curr_state ;
		
	 always_ff @ (posedge clk, negedge n_rst) begin
		if (n_rst == 1'b0)
		curr_state <= IDLE ;
		else
		curr_state <= next_state ;
		end
	
		always_comb 
		begin
	
		next_state = curr_state ;
	 
		case (curr_state)
	
		IDLE: begin
		if (tx_ena) 
		next_state = TRANSMIT_DATA_SYNC ; 
		
		else if (ack_prep && (tx_ack || tx_nack || stall))
		next_state = TRANSMIT_HS_SYNC ;
		else
		next_state = IDLE;	
		
		end
	
		TRANSMIT_DATA_SYNC: begin
		next_state = SHIFT_DATA_SYNC ; 
	 	end
	
		SHIFT_DATA_SYNC: begin
		if (cnt_done)
		next_state = TRANSMIT_DATA_PID ; 
		end
	
	 	TRANSMIT_DATA_PID: begin
	 	next_state = SHIFT_DATA_PID ; 
		end
	
		SHIFT_DATA_PID: begin
		if (cnt_done)
		next_state = LOAD_PTS ;
		end
	
		LOAD_PTS: begin
		next_state = SHIFT_DATA ; 
		end
	
		SHIFT_DATA: begin
		if (cnt_done)
		next_state = TRANSMIT_DATA_1_CRC;
		end
	
	
		TRANSMIT_DATA_1_CRC: begin
	 	next_state = SHIFT_DATA_1_CRC ; 
	 	end
	
		SHIFT_DATA_1_CRC: begin
		if (cnt_done)
		next_state = TRANSMIT_DATA_2_CRC ;
		end
	
	 	TRANSMIT_DATA_2_CRC: begin
	 	next_state = SHIFT_DATA_2_CRC ; 
	 	end
	
		SHIFT_DATA_2_CRC: begin
		if (cnt_done)
		next_state = TRANSMIT_DATA_EOP ; 
		end
	
	 	TRANSMIT_DATA_EOP: begin
	 	next_state = COMPLETE ; 
	 	end
	
		TRANSMIT_HS_SYNC: begin
		next_state = SHIFT_HS_SYNC ; 
	 	end
	
		SHIFT_HS_SYNC: begin
			
	 		if (tx_ack)
	 		next_state = TRANSMIT_ACK ; 
	 		else if (tx_nack)
	 		next_state = TRANSMIT_NACK ; 
			else if (stall)
			next_state = TRANSMIT_STALL;
			
		end
	
	 	TRANSMIT_ACK: begin
		next_state = SHIFT_ACK ; 
	 	end
	
		SHIFT_ACK: begin
		if (cnt_done)
		next_state = TRANSMIT_HS_EOP ;
		end
	
	 	TRANSMIT_NACK: begin
	 	next_state = SHIFT_NACK ; 
	 	end
	
		SHIFT_NACK: begin
		if (cnt_done)
		next_state = TRANSMIT_HS_EOP ; 
		end
	
		TRANSMIT_STALL: begin
		next_state = SHIFT_STALL;
		end

		SHIFT_STALL: begin 
		if(cnt_done)
	 	next_state = TRANSMIT_HS_EOP;
	 	end
	
	 	TRANSMIT_HS_EOP: begin
	 	next_state = COMPLETE ; 
	 	end
	
		COMPLETE: begin
		next_state = IDLE;
		end
	
		endcase
		end
	
		always_comb 
		begin
	
		load_sync = 0;
		load_data_pid = 0; 
		load_data_1_crc = 0;
		load_data_2_crc = 0;
		load_ack = 0;
		load_nack = 0;
		load_stall = 0;
		clear = 0;
		eop = 0 ; 
		start_read = 0 ; 
		load_ena = 0; 
		ack_done = 0;
	 	tx_complete = 0;
		case (curr_state)
	
		SHIFT_DATA: begin
		start_read = 1;
		end
	
		IDLE: begin
		end
	
		TRANSMIT_DATA_SYNC: begin
		load_sync = 1;
		clear = 1;
	 	end
	
		SHIFT_DATA_SYNC: begin
		start_read = 1 ; 
		end
	
	 	TRANSMIT_DATA_PID: begin
		clear = 1;
		load_data_pid = 1; 
	 	end
	
		SHIFT_DATA_PID: begin
		start_read = 1 ; 
		end
	
	
		LOAD_PTS: begin
		load_ena = 1;
		clear = 1;
		end
	
	 	TRANSMIT_DATA_1_CRC: begin
		clear = 1;
		load_data_1_crc = 1;
	 	end
	
		SHIFT_DATA_1_CRC: begin
		start_read = 1 ; 
		end
	
	 	TRANSMIT_DATA_2_CRC: begin
		clear = 1;
		load_data_2_crc = 1;
	 	end
	
		SHIFT_DATA_2_CRC: begin
		start_read = 1 ; 
		end
	
	 	TRANSMIT_DATA_EOP: begin
	 	eop = 1 ; 
	 	end
	
		TRANSMIT_HS_SYNC: begin
		clear = 1;
		load_sync = 1;
	 	end
	
		SHIFT_HS_SYNC: begin
		start_read = 1 ; 
		end
	
	 	TRANSMIT_ACK: begin
		clear = 1;
		load_ack = 1;
	 	end
	
		SHIFT_ACK: begin
		start_read = 1 ;
		end
	
	 	TRANSMIT_NACK: begin
		clear = 1;
	 	load_nack = 1;
	 	end
	
		SHIFT_NACK: begin
		start_read = 1 ; 
		end
		
		TRANSMIT_STALL: begin
		clear = 1;
		load_stall = 1;
		end

		SHIFT_STALL: begin 
		start_read = 1;
		end

	 	TRANSMIT_HS_EOP: begin
	 	eop = 1 ;
		ack_done = 1;
	 	end
		
		COMPLETE: begin
		tx_complete = 1;
		end
	
		endcase
		end
	
	endmodule
