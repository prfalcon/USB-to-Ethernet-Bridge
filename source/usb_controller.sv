// $Id: $
// File name:   usb_controller.sv
// Created:     12/5/2017
// Author:      Alejandro Orozco
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB Protocol Controller
module usb_controller
(
	input wire clk,
	input wire n_rst,
	input wire ack_done,
	input wire crc_error,
	input wire ack_rcvd,
	input wire nak_rcvd,
	input wire byte_ready,
	input wire eop_found,
	input wire fifo_empty,
	input wire fifo_full,
	input wire in_token,
	input wire out_token,
	output reg read_enable,
	output reg read_start,
	output reg read_error,
	output reg write_enable,
	output reg write_start,
	output reg write_error,
	output reg tx_enable,
	output reg handshake_prep,
	output reg [1:0] handshake // 00 = ACK, 01 = NAK, 10 = STALL		 			
);
	reg clear_counter, count_enable, rollover_flag;
	reg [8:0] byte_count;
	flex_counter #(9) BYTE_CNT (.clk(clk), .n_rst(n_rst), .clear(clear_counter), .count_enable(count_enable), .rollover_val(9'd511), .rollover_flag(rollover_flag), .count_out(byte_count)) ;

	typedef enum logic [3:0] 
	{
		IDLE,
		OUT_TOKEN,
		WRITE_FIRST,
		WRITE_ALL,
		WRITE_NEXT,
		WRITE_ERROR,
		NAK_PREP,
		ACK_PREP,
		IN_TOKEN,
		SEND_FIRST,
		SEND_ALL,
		WAIT,
		UNDO_READ
		
	} stateType;

	stateType state, nextstate;

	always_ff @ (posedge clk, negedge n_rst) begin: StateReg
		if (n_rst == 0) begin
			state <= IDLE;
		end
		else begin
			state <= nextstate;
		end
	end
	
	always_comb begin
		nextstate = state;
		case(state)
			IDLE: begin
				if(out_token)
					nextstate = OUT_TOKEN;
				else if(in_token)
					nextstate = IN_TOKEN;
			end

			OUT_TOKEN: begin
				if(crc_error | fifo_full)
					nextstate = NAK_PREP;
				else if(eop_found)
					nextstate = IDLE;
				else if(byte_ready)
					nextstate = WRITE_FIRST;

			end

			WRITE_FIRST: begin
				 nextstate = WRITE_ALL;
			end

			WRITE_ALL: begin

				if(fifo_full)
					nextstate = NAK_PREP;
				else if(crc_error)
					nextstate = WRITE_ERROR;
				else if(eop_found)
					nextstate = ACK_PREP;
				else if(byte_ready)
					nextstate = WRITE_NEXT;
			end
			
			WRITE_NEXT: begin
				nextstate = WRITE_ALL;
			end

			WRITE_ERROR: begin
				nextstate = NAK_PREP;
			end

			NAK_PREP: begin
				nextstate = IDLE;
			end

			ACK_PREP: begin
				nextstate = IDLE;
			end

			IN_TOKEN: begin
				if(fifo_empty)
					nextstate = NAK_PREP;
				else
					nextstate = SEND_FIRST;
			end

			SEND_FIRST: begin
				nextstate = SEND_ALL;
			end

			SEND_ALL: begin
				if(fifo_empty | rollover_flag)
					nextstate = WAIT;
				else
					nextstate = SEND_ALL;
			end
			
			WAIT: begin
				if(ack_rcvd)
					nextstate = IDLE;
				else if(nak_rcvd)
					nextstate = UNDO_READ;
			end

			UNDO_READ: begin
				nextstate = IDLE;
			end

		endcase
	end

	always_comb begin
		read_enable = 0;
		read_start = 0;
		read_error = 0;
		write_enable = 0;
		write_start = 0;
		write_error = 0;
		tx_enable = 0;
		handshake_prep = 0;
		handshake = 3;
		count_enable = 0;
		clear_counter = 0;

		case(state)
			WRITE_FIRST: begin
				write_enable = 1;
				write_start = 1;
			end

			WRITE_NEXT: begin
				write_enable = 1;
			end

			WRITE_ERROR: begin
				write_error = 1;
			end

			NAK_PREP: begin
				handshake_prep = 1;
				handshake = 1;
			end

			ACK_PREP: begin
				handshake_prep = 1;
				handshake = 0;
			end

			IN_TOKEN: begin
				clear_counter = 1;
			end

			SEND_FIRST: begin
				tx_enable = 1;
				read_enable = 1;
				read_start = 1;
				count_enable = 1;

			end

			SEND_ALL: begin
				tx_enable = 1;
				read_enable = 1;
				count_enable = 1;
			end

			UNDO_READ: begin
				read_error = 1;
			end

		endcase
	
	end



endmodule












