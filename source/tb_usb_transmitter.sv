// $ID: mg 82
// File name: tb_usb_transmitter.sv 
// Author: Akshay Raj
// Lab Section: Wednesday
`timescale 1ns / 10ps
	
module tb_usb_transmitter() ; 
	
		// Define parameters
		// basic test bench parameters
		localparam	CLK_PERIOD	= 5.2;
	
		reg tb_clk;
	 	reg tb_n_rst;
		reg tb_tx_ena; 
		reg [7:0] tb_parallel_in;
		reg tb_d_plus; 
		reg tb_d_minus;
		reg [1:0]tb_pid;
		reg tb_ack_prep;
		reg tb_ack_done;
		reg tb_tx_complete;


		initial begin
		tb_pid = 2'b11;
		tb_ack_prep = 1'b0;
		end
	
		always
		begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
		end
	
		usb_transmitter DUT (
	 	.clk(tb_clk),
	 	.n_rst(tb_n_rst),
		.tx_ena(tb_tx_ena), 
		.pid(tb_pid),
		.parallel_in(tb_parallel_in),
		.ack_prep(tb_ack_prep),
		.ack_done(tb_ack_done),
		.d_plus(tb_d_plus),
		.d_minus(tb_d_minus), 
		.tx_complete(tb_tx_complete)
		); 
	
		initial
		begin
		tb_n_rst = 1;
		tb_tx_ena = 0; 

		@(negedge tb_clk)
		tb_n_rst = 0;
	
		@(negedge tb_clk)
		tb_n_rst = 1;	
		tb_tx_ena = 1;
	
		tb_parallel_in = 8'b10101010;
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		tb_parallel_in = 8'b11001100;
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)
		@(negedge tb_clk)



		////////////////////
		@(negedge tb_clk)
		
		repeat(700) begin
		@(negedge tb_clk);
		end
		tb_n_rst = 0;
		tb_tx_ena = 0;	


		@(negedge tb_clk)
		tb_n_rst = 1;
		tb_ack_prep = 1;
		tb_pid = 2'b00;
		
		@(negedge tb_clk)
		tb_ack_prep = 0;
		
		repeat(100) begin
		@(negedge tb_clk);
		end

		tb_ack_prep = 1;
		tb_pid = 2'b01;	
		
		@(negedge tb_clk)
		tb_ack_prep = 0;


		repeat(100) begin
		@(negedge tb_clk);
		end

		tb_ack_prep = 1;
		tb_pid = 2'b10;	
	
		@(negedge tb_clk)
		tb_ack_prep = 0;

		repeat(100) begin
		@(negedge tb_clk);
		end

		tb_ack_prep = 1;
		tb_pid = 2'b11;
		
		@(negedge tb_clk)
		tb_ack_prep = 0;	
		
		repeat (150) begin
		@(negedge tb_clk); 
		end
		repeat (80 * 80) begin
		@(negedge tb_clk); 

		end

		@(negedge tb_clk); 
		
		
		end
	
endmodule
