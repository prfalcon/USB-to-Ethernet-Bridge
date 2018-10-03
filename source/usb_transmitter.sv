// $ID: mg 82
// File name: usb_transmitter.sv 
// Author: Akshay Raj
// Lab Section: Wednesday

module usb_transmitter (
	    	input wire    	clk,
	                        n_rst,                 
	                        tx_ena, 
				ack_prep,
		input wire	[7:0]parallel_in,
		input wire 	[1:0]pid,
		output reg	d_plus,
				d_minus,
				ack_done,
				tx_complete
	);
	
	reg tx_ack,tx_nack,stall;
	
	always_comb
	begin
	if(pid == 2'b00) begin
		tx_ack = 1'b1;
		tx_nack = 1'b0;
		stall = 1'b0;
	end
	if(pid == 2'b01) begin
		tx_ack = 1'b0;
		tx_nack = 1'b1;
		stall = 1'b0;
	end
	if(pid == 2'b10) begin
		tx_nack = 1'b0;
		tx_ack = 1'b0;
		stall = 1'b1;
	end
	if(pid == 2'b11) begin 
		stall = 1'b0;
		tx_ack = 1'b0;
		tx_nack = 1'b0;
	end

	end


	reg 	eop, start_read, bit_out,load_ena, load_sync, load_data_pid, load_data_1_crc;
	reg	load_data_2_crc, load_ack,load_nack,load_stall,shift_en,flag_8,pause,byte_rcvd,clear;
	
	
	
		tcu CONTROLLER 
		(
		    		.clk(clk),
			        .n_rst(n_rst),
			        .tx_ena(tx_ena),
				.tx_nack(tx_nack), 
				.tx_ack(tx_ack),
				.cnt_done(byte_rcvd), 
				.stall(stall),
				.ack_prep(ack_prep),
		
				.clear(clear),
				.eop(eop),
				.start_read(start_read), 
				.tx_complete(tx_complete),
				.load_ena(load_enable),     
				.load_sync(load_sync), 
				.load_data_pid(load_data_pid) , 
				.load_data_1_crc(load_data_1_crc), 
				.load_data_2_crc(load_data_2_crc), 
				.load_ack(load_ack) , 
				.load_stall(load_stall),
				.ack_done(ack_done),
				.load_nack(load_nack)
		);
	
	
		flex_pts_sr #(8,0) FLEX_PTS 
		(
				.clk(clk),
				.n_rst(n_rst),
				.shift_enable(shift_en), 
				.load_enable(load_enable), 
				.parallel_in(parallel_in),
				.load_sync(load_sync), 
				.load_data_pid(load_data_pid) , 
				.load_data_1_crc(load_data_1_crc), 
				.load_data_2_crc(load_data_2_crc), 
				.load_ack(load_ack) , 
				.load_nack(load_nack),
				.load_stall(load_stall),
	
				.serial_out(bit_out) 
		);
	
		bit_stuffer STUFF
		(
				.clk(clk), 
				.n_rst(n_rst), 
				.d_orig(bit_out),
				.flag_8(flag_8),
				.pause(pause)
		);
	
	
		tx_timer TIMER
		(
				.clk(clk),
				.n_rst(n_rst),
				.pause(pause),
				.count_up(start_read),
				.clear_64(clear),
			
				.shift_en(shift_en),
				.byte_rcvd(byte_rcvd),
				.flag_8(flag_8)
		);
	
	
		nrzi_encode ENCODE
		(
				.clk(clk),
				.n_rst(n_rst),
				.d_orig(bit_out),
				.eop(eop),
				.pause(pause),
				.flag_8(flag_8),
	
				.d_plus(d_plus),
				.d_minus(d_minus)
		);
	
	
endmodule 
