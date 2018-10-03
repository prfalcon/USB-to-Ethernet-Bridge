// $ID: mg 82
// File name: bit_stuffer.sv 
// Author: Akshay Raj
// Lab Section: Wednesday
module bit_stuffer (
		input wire 	clk, 
				n_rst, 
				d_orig,
				flag_8,
	
		output reg  	pause
	);
	
		reg 	temp_pause = 0; 
		reg 	[2:0] num_ones; 
		reg 	found_6; 
		reg 	temp_out = d_orig; 
		
		flex_counter_tx #(3) BIT_STUFFER_CNTR
		(
			.clk(clk),
			.n_rst(n_rst),
			.clear(!d_orig ),
			.count_enable(d_orig & flag_8),
			.rollover_val(3'b110),
			.count_out(num_ones),
			.rollover_flag(pause)
		);
endmodule
