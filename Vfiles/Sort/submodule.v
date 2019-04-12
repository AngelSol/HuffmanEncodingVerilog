module submodule (din, muxin, d_ena, d_sload, clk, muxout,ena, ageb, b);
//function saves smallest of the two and stores it in the flipflop
	parameter DATA_WIDTH = 16;					// size of each input data
	parameter TOTAL_SYMBOLS = 10;				// total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;					// size of address to account for total symbols
	
	input wire [DATA_WIDTH-1:0] din; //input to the flipflops
	input wire [DATA_WIDTH-1:0] muxin; //input  to the mux
	input wire d_ena; //enable signal for the FF
	input wire d_sload; // load/set signal for FF
	input wire clk; // input clock
	output wire [DATA_WIDTH-1:0] muxout; // output from the mux to next submodule
	output wire ena; // output  enable for the Address modules
	output wire ageb; // output from the comparator
	output wire [DATA_WIDTH-1:0]b; // output from the FF

	assign ena = ageb & d_ena;
	assign muxout = ageb ? b : muxin; // if (ageb) muxout = b else muxout = muxin

	dff_s 	#(DATA_WIDTH)	dat(din,clk,ena,d_sload,b);
	comparator #(DATA_WIDTH)	comp(din,b,ageb);

	endmodule

module submodule_end (din, d_ena, d_sload, clk, ena, ageb, b);
 //this module is the same as the last one but without the mux
//function saves smallest of the two and stores it in the flipflop
	parameter DATA_WIDTH = 16;					// size of each input data
	parameter TOTAL_SYMBOLS = 8;				// total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;					// size of address to account for total symbols

	input wire [DATA_WIDTH-1:0] din; // input to FF
	input wire d_ena;// input enable to be &ed with ageb
	input wire d_sload; // load/set signal for FF
	input wire clk; // input Clock
	output wire ena; // enable output
	output wire ageb; // output from the comparator
	output wire [DATA_WIDTH-1:0]b; // dff output

	assign ena = ageb & d_ena;

	dff_s 	#(DATA_WIDTH)	dat(din,clk,ena,d_sload,b);
	comparator #(DATA_WIDTH)	comp(din,b,ageb);

	endmodule
