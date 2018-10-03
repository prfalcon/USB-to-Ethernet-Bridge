// $Id: $
// File name:   tb_mac_transmitter.sv
// Created:     12/5/2017
// Author:      Vishnu Gopal
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: .
`timescale 1ns / 10ps

module tb_mac_transmitter();

	// Define local parameters used by the test bench
	localparam	CLK_PERIOD		= 5.3;
	
	// Declare DUT portmap signals
	logic       tb_clk;
	logic       tb_reset;
	logic [7:0] tb_rd_data;
	logic       tb_data_ready;
	logic       tb_fifo_empty;

	logic       tb_rd_en;
	logic       tb_rd_start;
	logic       tb_txen;
	logic [7:0] tb_txd;
        logic [2:0] tb_mac_tr_state;
	
	// Declare test bench signals
	integer tb_test_num;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	// DUT Port map
	mac_transmitter DUT
	(
        .clk(tb_clk),
	    .reset(tb_reset),
	    .rd_data(tb_rd_data),
	    .data_ready(tb_data_ready),
	    .fifo_empty(tb_fifo_empty),
	   
	    .mac_tr_state(tb_mac_tr_state),
	    .rd_en(tb_rd_en),
	    .rd_start(tb_rd_start),
	    .txen(tb_txen),
	    .txd(tb_txd)
	);

	// Tasks
	task data_byte([7:0]d_byte);
		tb_rd_data = d_byte;
		#(CLK_PERIOD);
	endtask

	task start_transmit();
		tb_data_ready = 1'b1;
		#(CLK_PERIOD);
		tb_data_ready = 1'b0;
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
		#(CLK_PERIOD);
	endtask


	// Test bench main process
	initial
	begin
	// Initialize all of the test inputs
	tb_test_num = 0;
	tb_fifo_empty = 1'b0;
	#(0.1);
        tb_reset = 1'b1;
	#(CLK_PERIOD);
	tb_reset = 1'b0;

        // Test Case 1: Reset 
	tb_test_num = tb_test_num + 1;
	$info("Test %d", tb_test_num);
        start_transmit();
	data_byte(8'hAB);
    	data_byte(8'hCD);
    	data_byte(8'hEF);
	tb_fifo_empty = 1'b1;
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
			
	// Test Case 1: Reset 
	tb_test_num = tb_test_num + 1;
	tb_fifo_empty = 1'b0;
	$info("Test %d", tb_test_num);
	start_transmit();
	data_byte(8'hAB);
    	data_byte(8'hCD);
    	data_byte(8'hEF);
	data_byte(8'hAB);
	tb_fifo_empty = 1'b1;
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
end
endmodule