// $Id: $
// File name:   re_decoder.sv
// Created:     11/20/2017
// Author:      Alexandria Symanski
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: USB Receiver Decoder

module re_decoder 
(
input clk, n_rst, d_plus, d_minus, data_enable, n_enable,
output reg d_decoded, eop, d_edge
);

reg d_next, d_current, decode1, eop1, eop2, edge_found;

//decoding data
always_ff @ (posedge clk, negedge n_rst) 
begin
	if (!n_rst) begin
		eop1 <= 1;
		eop2 <= 1;
		d_decoded <= 1;
		decode1 <= 1;
	end else begin
		d_decoded <= d_current;
		decode1 <= d_next;
		eop2 <= eop1;
		eop1 <= d_plus;
	end
end

always_comb
begin
	d_next = decode1;	
	if (data_enable & n_enable) begin
		if (eop) begin
			d_next = 1;
		end else begin
			d_next = d_plus;
		end	
	end
end

assign d_edge = (eop1 ^ eop2);
assign eop = (!d_plus) & (!d_minus);
assign d_current = (decode1 ^ d_plus); 

endmodule
		

