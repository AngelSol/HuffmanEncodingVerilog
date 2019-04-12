module sort (d_ena, d_sload, clk, b, ab, done);
	//function sorts the given inputs based on memory file
	parameter DATA_WIDTH = 16;					// size of each input data
	parameter TOTAL_SYMBOLS = 10;				// total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;					// size of address to account for total symbols = log2(TOTAL_SYMBOLS)
	
	input wire d_ena, d_sload, clk;
	
	output wire [TOTAL_SYMBOLS*DATA_WIDTH-1:0] b; //2d arrays not allowed as outputs
	output wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ab ;  // so one large array is used
	output wire done; //signals when the operation is complete 
	
	reg intdone; //internal done register 
	wire ageb [0 : TOTAL_SYMBOLS-1]; // internal comparator outputs 
	wire ena [0 : TOTAL_SYMBOLS-1]; // internal enable signals passed between modules 
	wire [DATA_WIDTH-1:0] din [0 : TOTAL_SYMBOLS-1];// array of input to the Dff 
	wire [ADDR_WIDTH-1:0] addrin [0 : TOTAL_SYMBOLS-1]; // array of inputs to the Address Dff
	wire [ADDR_WIDTH-1:0] temp; // last output from mux not used on the Address module
	
	wire [DATA_WIDTH-1:0] bi [0 : TOTAL_SYMBOLS-1]; // array of connector wires for connecting to the large bus 
	wire [ADDR_WIDTH-1:0] abi [0 : TOTAL_SYMBOLS-1];// intermediary connectors to wide bus
	
	wire [DATA_WIDTH-1:0] muxin; //output from memory module 
	reg [ADDR_WIDTH-1:0] addr;
	// assign Large bus to smaller array wires
	assign b = {bi[15] ,bi[14] ,bi[13] ,bi[12] ,bi[11] ,bi[10] ,bi[9] ,bi[8] ,bi[7] ,  bi[6] ,  bi[5] ,  bi[4] , bi[3] , bi[2] , bi[1] , bi[0]};

	
	// assign Large bus to smaller array wires	1 is subtracted as the stored value is one early
	assign ab = {abi[9]  -1'b1 ,abi[8]  -1'b1 ,abi[7]  -1'b1 , abi[6] -1'b1 , abi[5] -1'b1 , abi[4] -1'b1 , abi[3] -1'b1 ,  abi[2] -1'b1 ,  abi[1] -1'b1 , abi[0] -1'b1};

	
	//addr is the index of the memory location
	assign din[0]=muxin; //first DFF input and MUX input are the same
	assign addrin[0]=addr; //first Address input is the same as its mux input
	assign done = intdone;
	
	// creates the address and data modules 0-8 :
	genvar i;
	generate 
		for (i=0; i<TOTAL_SYMBOLS-1; i=i+1) begin:gen
			addrmodule 	#(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) Ui(addrin[i],addr,clk,ena[i],ageb[i],addrin[i+1],abi[i]);
			submodule 	#(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) Si(din[i], muxin, d_ena, d_sload, clk, din[i+1],ena[i], ageb[i], bi[i]);
		end
	endgenerate
	
	//creates address and data module #9
	addrmodule #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH)	U9(addrin[TOTAL_SYMBOLS-1],addr,clk,ena[TOTAL_SYMBOLS-1],ageb[TOTAL_SYMBOLS-1],temp,abi[TOTAL_SYMBOLS-1]);
	submodule_end #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH)	S9(din[TOTAL_SYMBOLS-1], d_ena, d_sload, clk, ena[TOTAL_SYMBOLS-1], ageb[TOTAL_SYMBOLS-1], bi[TOTAL_SYMBOLS-1]);
	
	Memory_Init_Unit  #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) mem (clk, d_ena, addr, muxin);	
	
	initial begin
		intdone<=0;
		addr <=0;
	end
	
	always @(posedge clk) begin
	//internal counter 
		if (d_ena) begin
			if (addr<= TOTAL_SYMBOLS)
				addr<= addr+1;
			else begin
				addr <= addr;
				intdone <=1;
			end
			
		end
		else 
			addr<=addr;
	end
	 
	 endmodule