// $Id: $
// File name:   tb_re_decoder.sv
// Created:     11/28/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: Test Bench for USB Receiver Decoder 
`timescale 1ns / 10ps

module tb_re_decoder();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 1;
	reg s_bit;
	
	// Declare DUT portmap signals
	reg tb_clk;
	reg tb_n_rst;
	reg tb_d_plus;
	reg tb_d_minus;
	reg tb_data_enable;
	wire tb_d_decoded;
	wire tb_eop;
	wire tb_d_edge;
	
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
	re_decoder DUT
	(
		.clk(tb_clk), 
		.n_rst(tb_n_rst), 
		.d_plus(tb_d_plus),
		.d_minus(tb_d_minus),
		.data_enable(tb_data_enable),	
		.d_decoded(tb_d_decoded), 
		.eop(tb_eop), 
		.d_edge(tb_d_edge)
	);

	// Tasks
	task send_bit(n_bit);
	begin
		tb_d_plus = n_bit;
		tb_d_minus = !n_bit;
		#(CLK_PERIOD);
	end
	endtask

	task send_byte([7:0]n_byte);
		integer i;
	begin
		for(i=7; i >= 0; i = i - 1) 
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
		tb_d_plus 	= 1'b1;
		tb_d_minus 	= 1'b0;
		tb_data_enable	= 1'b0;
		tb_test_num = 0;
		tb_test_case = "Test bench initializaton";
		#(0.1);

		// Test Case 1: Restart 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Restart";
		tb_n_rst	= 1'b0; 	
		tb_d_plus	= 1'b1;		
		tb_d_minus	= 1'b0;
		tb_data_enable	= 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 1'b1 == tb_d_decoded)
			$info("Correct d_decoded output");
		else
			$error("WRONG d_decoded output");

		if(1'b0 == tb_eop)
			$info("Correct eop output");
		else
			$error("WRONG eop output");

		if(1'b0 == tb_d_edge)
			$info("Correct d_edge output");
		else
			$error("WRONG d_edge output");


		// Test Case 2: Edge Detect  
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Edge Detect";
		tb_n_rst	= 1'b1; 	
		tb_d_plus	= 1'b1;		
		tb_d_minus	= 1'b0;
		tb_data_enable	= 1'b1;
		#(CLK_PERIOD);
		tb_d_plus = 1'b0;
		tb_d_minus = 1'b1;
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 1'b1 == tb_d_decoded)
			$info("Correct d_decoded output");
		else
			$error("WRONG d_decoded output");

		if(1'b0 == tb_eop)
			$info("Correct eop output");
		else
			$error("WRONG eop output");

		if(1'b1 == tb_d_edge)
			$info("Correct d_edge output");
		else
			$error("WRONG d_edge output");

		// Test Case 3: No Edge Detect 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Edge Detect Continuous";
		tb_n_rst	= 1'b1; 	
		tb_d_plus	= 1'b1;		
		tb_d_minus	= 1'b0;
		tb_data_enable	= 1'b1;
		#(CLK_PERIOD);
		tb_d_plus = 1'b0;
		tb_d_minus = 1'b1;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 1'b0 == tb_d_decoded)
			$info("Correct d_decoded output");
		else
			$error("WRONG d_decoded output");

		if(1'b0 == tb_eop)
			$info("Correct eop output");
		else
			$error("WRONG eop output");

		if(1'b0 == tb_d_edge)
			$info("Correct d_edge output");
		else
			$error("WRONG d_edge output");

		// Test Case 4: End of Packet 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "End of Packet";
		tb_n_rst	= 1'b1; 	
		tb_d_plus	= 1'b1;		
		tb_d_minus	= 1'b0;
		tb_data_enable	= 1'b1;
		#(CLK_PERIOD);
		tb_d_plus = 1'b0;
		tb_d_minus = 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 1'b1 == tb_d_decoded)
			$info("Correct d_decoded output");
		else
			$error("WRONG d_decoded output");

		if(1'b1 == tb_eop)
			$info("Correct eop output");
		else
			$error("WRONG eop output");

		if(1'b0 == tb_d_edge)
			$info("Correct d_edge output");
		else
			$error("WRONG d_edge output");

		// Test Case 5: Full Byte of data 
		tb_test_num = tb_test_num + 1;
		$info("Test %d", tb_test_num);
		tb_test_case = "Byte of data";
		tb_n_rst	= 1'b0; 	
		tb_d_plus	= 1'b1;		
		tb_d_minus	= 1'b0;
		tb_data_enable	= 1'b1;
		#(CLK_PERIOD);
		tb_n_rst = 1'b1;
		send_byte(8'b00101110);	
		#(CLK_PERIOD);
		// Check that internal state was correctly reset
		if( 1'b0 == tb_d_decoded)
			$info("Correct d_decoded output");
		else
			$error("WRONG d_decoded output");

		if(1'b0 == tb_eop)
			$info("Correct eop output");
		else
			$error("WRONG eop output");

		if(1'b0 == tb_d_edge)
			$info("Correct d_edge output");
		else
			$error("WRONG d_edge output");


	end

endmodule

