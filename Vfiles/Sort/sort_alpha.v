module sort_alpha (d_ena, d_sload, clk, muxin, addr, codein, ob, oab, ocodeout, done); 
	//function sorts alphabet, length and code word based on alphabet.
	
	parameter DATA_WIDTH = 16;							//size of each input data
	parameter TOTAL_SYMBOLS = 10;						//total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;							//size of address to account for total symbols = log2(TOTAL_SYMBOLS)
	parameter MAXHIGHT = 10;
	
	input wire d_ena, d_sload, clk;
	input wire [DATA_WIDTH-1:0] muxin;					//serial input of addresses
	input wire [ADDR_WIDTH-1:0] addr; 					//serial input of lengths
	input wire [MAXHIGHT-1:0] codein; 					//serial input of codewords
	
	output wire [TOTAL_SYMBOLS*DATA_WIDTH-1:0] ob; 		//Parallel output of addresses 
	output wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] oab ;    //parallel output of lengths
	output wire [MAXHIGHT*TOTAL_SYMBOLS-1:0] ocodeout; 	//parallel output of codewords
	output wire done; 									//signals when the operation is complete 
	
	reg intdone; 										//internal done register 
	wire ageb [0 : TOTAL_SYMBOLS-1]; 					//internal comparator outputs 
	wire ena [0 : TOTAL_SYMBOLS-1]; 					//internal enable signals passed between modules 
	wire [DATA_WIDTH-1:0] din [0 : TOTAL_SYMBOLS-1];	//array of input to the Dff
	wire [ADDR_WIDTH-1:0] addrin [0 : TOTAL_SYMBOLS-1];	//array of inputs to the second set Dff
	wire [MAXHIGHT-1:0] codein1 [0 : TOTAL_SYMBOLS-1]; 	//array of inputs to the third set Dff
	wire [ADDR_WIDTH-1:0] temp;							//last output from mux not used on the lengths module
	wire [MAXHIGHT-1:0] temp2; 							//last output from mux not used on the codeword module
	
	
	wire [TOTAL_SYMBOLS*DATA_WIDTH-1:0] bi; 			//array of connector wires for connecting to the large bus 
	wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] abi;			//intermediary connectors to wide bus
	wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] codeout;			//intermediary connectors to wide bus
	integer count;										//count to keep track when data is finished comming in
	assign ob = bi;										//internal to output
	assign oab = abi;									//internal to output
	assign ocodeout = codeout;							//internal to output
	assign din[0]=muxin; 								//first DFF input and MUX input are the same
	assign addrin[0]=addr;								//first Address input is the same as its mux input
	assign codein1[0] = codein;							//first input is shared
	assign done = intdone;								//external done = internal done
	
	// creates the address and data modules 0-8 :
	genvar i;
	generate 
		for (i=0; i<TOTAL_SYMBOLS-1; i=i+1) begin:gen
			addrmodule 	#(DATA_WIDTH,TOTAL_SYMBOLS,MAXHIGHT) Ci(codein1[i],codein,clk,ena[i],ageb[i],codein1[i+1],codeout[ (i+1) * MAXHIGHT -1 -:MAXHIGHT]);
			
			addrmodule 	#(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) Ui(addrin[i],addr,clk,ena[i],ageb[i],addrin[i+1],abi[ (i+1) * ADDR_WIDTH -1 -:ADDR_WIDTH]);
			submodule 	#(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) Si(din[i], muxin, d_ena, d_sload, clk, din[i+1],ena[i], ageb[i], bi[(i+1) * DATA_WIDTH -1 -:DATA_WIDTH]);
		end
	endgenerate
	
	//creates address and data module #9
	addrmodule #(DATA_WIDTH,TOTAL_SYMBOLS,MAXHIGHT)	C9(codein1[TOTAL_SYMBOLS-1],codein,clk,ena[TOTAL_SYMBOLS-1],ageb[TOTAL_SYMBOLS-1],temp2,codeout[ TOTAL_SYMBOLS*MAXHIGHT -1 -:MAXHIGHT]);
	
	addrmodule #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH)	U9(addrin[TOTAL_SYMBOLS-1],addr,clk,ena[TOTAL_SYMBOLS-1],ageb[TOTAL_SYMBOLS-1],temp,abi[ TOTAL_SYMBOLS*ADDR_WIDTH -1 -:ADDR_WIDTH]);
	submodule_end #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH)	S9(din[TOTAL_SYMBOLS-1], d_ena, d_sload, clk, ena[TOTAL_SYMBOLS-1], ageb[TOTAL_SYMBOLS-1], bi[TOTAL_SYMBOLS*DATA_WIDTH -1 -:DATA_WIDTH]);
	
	initial begin										//initialize values
		intdone<=0;
		count <=0;
	end
	
	always @(posedge d_sload) begin
		intdone <=0;
		count <=0;
	end
	
	always @(posedge clk) begin							//internal counter 
		
		if (d_ena) begin
			if (count<= TOTAL_SYMBOLS)
				count<= count+1;
			else begin
				count <= count;
				intdone <=1;
			end
			
		end
		else 
			count<=count;
	end
endmodule