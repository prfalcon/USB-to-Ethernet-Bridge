// $Id: $
// File name:   tb_crc_16.sv
// Created:     11/28/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for 16-bit CRC Checker
`timescale 1ns / 10ps

module tb_crc_16();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 1;
	reg s_bit;	
	// Declare DUT portmap signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_d_decoded;
	reg tb_enable;
	reg tb_init;
	wire [0:15] tb_check_16;
	
	// Declare test bench signals
	integer tb_test_num;
	string tb_test_case;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	// DUT Port map
	crc_16 DUT
	(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.d_decoded(tb_d_decoded), 
		.check_16(tb_check_16), 
		.enable(tb_enable), 
		.init(tb_init)
	);

	// Tasks
	task send_bit(n_bit);
	begin
		tb_d_decoded = n_bit;
		#(CLK_PERIOD);
	end
	endtask

	task send_address([7:0]n_byte);
		integer i;
	begin
		for(i=7; i >= 0; i = i - 1) 
		begin
			s_bit = n_byte[i];
			send_bit(s_bit);
		end
	end
	endtask

	task send_crc([15:0]n_byte);
		integer i;
	begin
		for(i=15; i >= 0; i = i - 1) 
		begin
			s_bit = n_byte[i];
			send_bit(s_bit);
		end
	end
	endtask


	// Test bench main process
	initial
	begin
		// Initialize all of the test inputs
		tb_n_rst	= 1'b1;		// Initialize to be inactive
		tb_d_decoded 	= 1'b1;
		tb_enable 	= 1'b0;
		tb_init		= 1'b0;
		tb_test_num = 0;
		tb_test_case = "Test bench initializaton";
		#(0.1);

		// Test Case 1: Restart 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Restart";
		tb_n_rst	= 1'b0; 	
		tb_d_decoded	= 1'b1;		
		tb_enable	= 1'b0;
		tb_init		= 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 16'b0000000000000000 == tb_check_16)
			$info("Correct check_16 output");
		else
			$error("Incorrect check_16 output");

		// Test Case 1: test crc calculation 
		//Only address is tested to find correct crc
		//Most cases endpoints would be used but they are excluded from design
		//address tested 8'b11001111
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Data send 1";
		tb_n_rst	= 1'b1; 	
		tb_d_decoded	= 1'b1;		
		tb_enable	= 1'b1;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		tb_d_decoded	= 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		tb_d_decoded	= 1'b1;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b1;
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b0;
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b1;
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b0;
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b1;
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		tb_d_decoded 	= 1'b1;
		#(CLK_PERIOD);
		tb_d_decoded	= 1'b0;
		#(CLK_PERIOD);
		tb_enable	= 1'b0;
		// Check that correct crc was generated/checked 
		if( 16'b0000000000000000 == tb_check_16)
			$info("Correct check_16 output");
		else
			$error("Incorrect check_16 output");

		// Test Case 1: test crc calculation 
		//Only address is tested to find correct crc
		//Most cases endpoints would be used but they are excluded from design
		//address tested 8'b11001111
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Data send 1";
		tb_n_rst	= 1'b1; 	
		tb_d_decoded	= 1'b1;		
		tb_enable	= 1'b1;
		tb_init		= 1'b1;
		#(CLK_PERIOD);
		tb_init		= 1'b0;	
		send_address(8'b11001111);
		send_crc(16'b0000001010100010);
		tb_enable 	= 1'b0;
		// Check that correct crc was generated/checked 
		if( 16'b0000000000000000 == tb_check_16)
			$info("Correct check_16 output");
		else
			$error("Incorrect check_16 output");

	end
endmodule

