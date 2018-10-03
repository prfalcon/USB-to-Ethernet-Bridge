// $ID: mg 82
// File name: tx_timer.sv 
// Author: Akshay Raj
// Lab Section: Wednesday
module tx_timer (
		input wire	clk,
				n_rst,
				pause,
				count_up,
				clear_64, 
	
		output reg	shift_en,
				byte_rcvd,
				flag_8
	);
	
		wire clear_8 = 0;
		reg [3:0] count_up_8, count_up_64;
		
	
		flex_counter_tx #(4) BIT_TX (.clk(clk), .n_rst(n_rst), .clear(clear_8), .count_enable(count_up), .rollover_val(4'b1000), .rollover_flag(flag_8), .count_out(count_up_8)) ; //assert shift_en for 8 cycles
	
		flex_counter_tx #(4) BYTE_TX (.clk(clk), .n_rst(n_rst), .clear(clear_64), .count_enable(flag_8), .rollover_val(4'b1000), .rollover_flag(byte_rcvd), .count_out(count_up_64)) ; //wait 8 cycles to compare a bit
	
		always_comb
		begin	
			shift_en=flag_8	;
			if(pause == 1'b1)
				shift_en = 1'b0;
		end
	
	endmodule
