module addrmodule (din,muxin,clk,ena,ageb,muxout,ab);
	
	//function: sorts the addresses accoring to the values of the counts
	parameter DATA_WIDTH = 16;					// size of each input data
	parameter TOTAL_SYMBOLS = 10;				// total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;					// size of address to account for total symbols
	
	input wire [ADDR_WIDTH-1:0] din; //input to the DFF
	input wire [ADDR_WIDTH-1:0] muxin; // input to the mux (on schematic DATA)
	input wire clk; //clk input for the DFF
	input wire ena; // enable signal for DFF
	input wire ageb; // True when A is greater than or equal to B (or reverse for ascending order)
	output wire [ADDR_WIDTH-1:0] muxout; //output from the mux to next unit
	output wire [ADDR_WIDTH-1:0]ab; // output from DFF which holds the stored value
	
	assign muxout = ageb ? ab : muxin; // if (AGEB) then muxout = ab; else muxout = muxin
	
	dffa 	#(ADDR_WIDTH)	dat(din,clk,ena,ab);
	
	endmodule