module length_finder_fsm (ena, clk,ialpha, ifrequency, oalpha, olengths, odone);
	//function given the frequency of the item a lenght is assigned. 
	//will then sort both the alphabet and the length to get ready for the codeword generation
	parameter DATA_WIDTH = 16;									//size of each input data
	parameter TOTAL_SYMBOLS = 10;								//total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;									//size of address to account for total symbols = log2(TOTAL_SYMBOLS)	
	parameter MAXHIGHT = 10;									//assumed max hight of tree
	
	input wire ena, clk;										//wires for the clock and enable
	input [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ialpha;				//input alphabet
	input [DATA_WIDTH*TOTAL_SYMBOLS-1:0] ifrequency;			//input ferquency
	output [MAXHIGHT*TOTAL_SYMBOLS-1:0] olengths;				//output lengths
	output [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] oalpha;				//output alphabet
	
	output odone;												//output done when finished
	integer i,j,k;												//used for the loops and sorting
	
	reg [DATA_WIDTH*TOTAL_SYMBOLS-1:0] frequency;				//internal frequency register to store and manipulate values
	reg [MAXHIGHT*TOTAL_SYMBOLS-1:0] lengths;					//internal lengths register to store and manipulate values
	reg [MAXHIGHT*TOTAL_SYMBOLS-1:0] addresses;					//internal addresses register to store and manipulate values
	reg [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] alpha;					//internal alphabet register to store and manipulate values
	
	reg [DATA_WIDTH-1:0] temp_frequency;						//temporary regester used for swaping values
	reg [MAXHIGHT-1:0] temp_addresses;							//temporary regester used for swaping values
	reg [ADDR_WIDTH-1:0] temp_alpha;							//temporary regester used for swaping values
	
	reg done;													// set done when lenghts are generated
	reg [1:0] cs;												// current state 
	
	assign olengths = lengths;
	assign odone = done;
	assign oalpha = alpha;
	
	initial begin												//set current state
		cs <=0;
		done <=0;											
		frequency <= ifrequency;								//set frequency 
		for (i = 0; i<TOTAL_SYMBOLS; i= i+1) begin				
			addresses [MAXHIGHT*(i+1)-1-:MAXHIGHT] <= 1<<i;		//set up onehot encodings
			lengths [MAXHIGHT*(i+1)-1-:MAXHIGHT] <= 0;			//set up lengths to 0 
		end 													// for (i = 0; i<TOTAL_SYMBOLS; i= i+1)
	end
	
	always @(posedge clk) begin 
		case (cs) 
			0: begin 											//initial state
				if (ena)begin
					cs <= 1;									//choose next state 
					frequency <= ifrequency;					//set frequency again
					alpha     <= ialpha;						//set alphabet internally
				end 
				
			end
			
			1: begin 											//combine frequenies and lenghts state
				//because the addresses are 1-hot using or on the lowest two will still show which are combined
				//frequencies of the two lowest are added together and the sencond lowest is reset
					addresses [MAXHIGHT-1-:MAXHIGHT] = addresses [MAXHIGHT-1-:MAXHIGHT] | addresses [MAXHIGHT*2-1-:MAXHIGHT]; 				// or both lowest addresses 
					frequency [DATA_WIDTH-1-:DATA_WIDTH] = frequency [DATA_WIDTH-1-:DATA_WIDTH] + frequency [DATA_WIDTH*2-1-:DATA_WIDTH]; 	// add both lowest frequencies.
					
					addresses [MAXHIGHT*2-1-:MAXHIGHT] = 0; 																				// set sencodn lowest address to 0  
					frequency [DATA_WIDTH*2-1-:DATA_WIDTH] = {DATA_WIDTH{1'b1}}; 															// set second lowest frequency to max
					 #1 
					
					 for (i= 0; i < TOTAL_SYMBOLS; i=i+1) begin																				//incriment the combined lengths 
						if (addresses [i] == 1 ) begin
							lengths[MAXHIGHT*(i+1)-1-:MAXHIGHT] = lengths[MAXHIGHT*(i+1)-1-:MAXHIGHT] + 1; 

						end 
					end 
				cs <=2; 																													// go to state 2 

			end
			
			2: begin 											//sort state			
				for(j=0;j<TOTAL_SYMBOLS; j=j+1) begin					
						for(k=0;k<TOTAL_SYMBOLS;k=k+1) begin
							if(frequency[DATA_WIDTH*(j+1)-1-:DATA_WIDTH] <=frequency[DATA_WIDTH*(k+1)-1-:DATA_WIDTH]) begin					//sort based on new lowest frequency 
								temp_addresses = addresses [MAXHIGHT*(j+1)-1-:MAXHIGHT];													
								temp_frequency = frequency[DATA_WIDTH*(j+1)-1-:DATA_WIDTH];
								
								addresses [MAXHIGHT*(j+1)-1-:MAXHIGHT] = addresses [MAXHIGHT*(k+1)-1-:MAXHIGHT];
								frequency[DATA_WIDTH*(j+1)-1-:DATA_WIDTH] = frequency[DATA_WIDTH*(k+1)-1-:DATA_WIDTH];
								
								
								addresses [MAXHIGHT*(k+1)-1-:MAXHIGHT] = temp_addresses;
								frequency[DATA_WIDTH*(k+1)-1-:DATA_WIDTH] = temp_frequency;
							end
						end
				end
				
				if (frequency[DATA_WIDTH*2-1-:DATA_WIDTH]=={DATA_WIDTH{1'b1}}) 																//if second lowest is still set then we are done
					cs <= 3;
				else
					cs <= 1;																												//not done yet go back to state 1
			end
			
			3: begin 											//done state 
				if(!done) begin 																											//first time in state 3 sort 
					for(j=0;j<TOTAL_SYMBOLS; j=j+1) begin																					//sort lengths and alphabet based on lowest lenght			
						for(k=0;k<TOTAL_SYMBOLS;k=k+1) begin
							if(lengths[MAXHIGHT*(j+1)-1-:MAXHIGHT] <=lengths[MAXHIGHT*(k+1)-1-:MAXHIGHT]) begin
								temp_addresses =lengths[MAXHIGHT*(j+1)-1-:MAXHIGHT];
								temp_alpha 	   =alpha[ADDR_WIDTH*(j+1)-1-:ADDR_WIDTH];
								
								
								lengths [MAXHIGHT*(j+1)-1-:MAXHIGHT] = lengths [MAXHIGHT*(k+1)-1-:MAXHIGHT];
								alpha[ADDR_WIDTH*(j+1)-1-:ADDR_WIDTH]=alpha[ADDR_WIDTH*(k+1)-1-:ADDR_WIDTH];
								
								lengths [MAXHIGHT*(k+1)-1-:MAXHIGHT] = temp_addresses;
								alpha[ADDR_WIDTH*(k+1)-1-:ADDR_WIDTH] = temp_alpha; 	   
							end
						end
					end
				end
				done<=1;																													//set done and stay in this state
				cs <=3;
			end
		endcase // cs

			
	
	end

endmodule