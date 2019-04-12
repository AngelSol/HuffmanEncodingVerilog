module treemaker (d_ena, d_sload, clk, ocodeout, ob, oab, serialout, serialready, odone); 
	//Function: This module generates the codewords given the length
	//assumes a max hight of 10
	parameter DATA_WIDTH = 16;							//size of each input data
	parameter TOTAL_SYMBOLS = 10;						//total number of symbols to be initialized
	parameter ADDR_WIDTH = 4;							//size of address to account for total symbols = log2(TOTAL_SYMBOLS)
		
	parameter REGS = 1;	 								//Number of regesters in the level 
	parameter BITS = 1;									//number of bits per regmodule 
	
	parameter MAXHIGHT = 10;							//assumed max hight of tree
	
	input wire d_ena, d_sload,clk;
	output wire [MAXHIGHT*TOTAL_SYMBOLS-1:0] ocodeout; 	//codeword output

	output wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] ob;    	//output wire of B
	output wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] oab ;  	//output wire of AB
	output wire serialout;								//serial output wire
	output wire serialready;							//serial ready output wire
	output wire odone;									//output done signal 
	
	wire done;											//internal done signal to know when initial sort is done
	wire [TOTAL_SYMBOLS*DATA_WIDTH-1:0] b; 				//Lengths array used to pass signals (frequency)
	wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ab ;  			//addresses array used to pass signals
	wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] codei ;  			//codewords array used to pass signals
	
	wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] b1; 				//Lengths array used to set output
	wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ab1; 			//addresses array used to set output
	wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ab2; 			//used to set outputs
	wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] code1;  			//Codewords array used to set outputs
	
	wire [MAXHIGHT*TOTAL_SYMBOLS-1:0] lengths;			//wire to hold lengths connects length generator to final sort
	
	reg shftenable;										//enable for all shiftregs 
	reg [TOTAL_SYMBOLS*DATA_WIDTH-1:0] tempb;			//temporary alphabet location to pass to length finder
	
	wire [MAXHIGHT-1:0] shftout [0:MAXHIGHT-1];			//ouput from shiftregs
	reg [9:0] shamt [0:MAXHIGHT];						//shift amount 
	reg [MAXHIGHT*TOTAL_SYMBOLS-1:0] codeout; 			//codeword register
	reg done1;											//done signal for alphabet sort to start
	reg lenstart;										//start signal for length generation
	wire lendone;										//done signal for the length
	wire sort2done;										//done signal meaning alphabet sort is over
	wire serialdone;									//serial output finished last values will be z
	
	integer count; 										//counter for knowing which module needs to shift
	integer count2;										//counter for providing alpha sorts inputs by memory location
	
	assign ob = b1;
	assign oab =ab2;
	assign codei = codeout;
	assign ocodeout= code1;
	assign odone = serialdone;
	assign serialready = sort2done;
	
														//sorts based on lengths
	sort #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH) sort1(d_ena, d_sload, clk, b, ab, done);
	//fix last sort 
	sort_alpha #(ADDR_WIDTH,TOTAL_SYMBOLS,MAXHIGHT,MAXHIGHT) 	// this sorts lengths, alphabet and codewords based on alphabet
	sort2(
			done1, 
			d_sload, 
			clk, 
			ab1[count2 * ADDR_WIDTH-1 -:ADDR_WIDTH],
			lengths[count2 * MAXHIGHT-1 -:MAXHIGHT], //lengths are max hight 
			codei[count2 * MAXHIGHT-1 -:MAXHIGHT],  //codein
			ab2,		//ob
			b1,			//oab
			code1,		//ocodeout
			sort2done); //done
	
	length_finder_fsm #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH,MAXHIGHT) length_find(
		lenstart,
		clk,
		ab,
		tempb,
		ab1,
		lengths,
		lendone);
														//converts the parallel to serial output
	Parallel2Serial_alpha  #(MAXHIGHT,TOTAL_SYMBOLS,MAXHIGHT,MAXHIGHT) p2s(
		b1,
		code1,
		clk,
		sort2done,
		serialout,
		serialdone);		
		
	
	genvar i;										// creates the shiftregisters modules 0-9 :
	generate 
		for (i=1; i<=MAXHIGHT; i=i+1) begin:gen 	//highest amount based on addr
			shiftreg #(1<<i,i) S1(shftenable, shamt[i-1], shftout[i-1]); 
		end
	endgenerate	
	
	initial begin //set count to one  
		lenstart<=0;
		count <=1;
		count2 <=0;
		codeout <=0;
		shftenable <=0;
		done1 <=0;
		
		//sort2done <=0;
	end
	
	always @ (posedge clk) begin 
		if (done1) begin		
			count2 = count2 + 1;
		end 
		if (d_ena & done & !lendone & ~lenstart) begin //enabled and done with everything but length generation
			tempb <=b;
			#1 lenstart <=1;
		end
			
		if (d_ena & done &lendone) begin			//done with everything used for parrallel to serial
			
			if (count == TOTAL_SYMBOLS+1) begin 	// done calculating codewords
				done1 <=1;
				
			end 
			
			else begin  
				case (lengths[MAXHIGHT*count-1-:MAXHIGHT]) // based on the length shifts the correct abount of registers
					1: begin
					 	shamt[0] <= 1;
						shamt[1] <= (1 <<1)*2;
						shamt[2] <= (1 <<2)*3;
						shamt[3] <= (1 <<3)*4;
						shamt[4] <= (1 <<4)*5;
						shamt[5] <= (1 <<5)*6;
						shamt[6] <= (1 <<6)*7;
						shamt[7] <= (1 <<7)*8;
						shamt[8] <= (1 <<8)*9;
						shamt[9] <= (1 <<9)*10;
						#1 shftenable =1;
						codeout[MAXHIGHT *count-1 -:MAXHIGHT] <= shftout[0][0];
						#1 shftenable =0;
						count  = count +1;
						
					end
					
					2: begin 
						shamt[1] <= (1 <<0)*2;
						shamt[2] <= (1 <<1)*3;
						shamt[3] <= (1 <<2)*4;
						shamt[4] <= (1 <<3)*5;
						shamt[5] <= (1 <<4)*6;
						shamt[6] <= (1 <<5)*7;
						shamt[7] <= (1 <<6)*8;
						shamt[8] <= (1 <<7)*9;
						shamt[9] <= (1 <<8)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[1][1:0];
						
						 count = count +1;
					end 
					3: begin 					
						shamt[2] <= (1 <<0)*3;
						shamt[3] <= (1 <<1)*4;
						shamt[4] <= (1 <<2)*5;
						shamt[5] <= (1 <<3)*6;
						shamt[6] <= (1 <<4)*7;
						shamt[7] <= (1 <<5)*8;
						shamt[8] <= (1 <<6)*9;
						shamt[9] <= (1 <<7)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[2][2:0];

						count = count +1;
					end 	
					4: begin 					
						shamt[3] <= (1 <<0)*4;
						shamt[4] <= (1 <<1)*5;
						shamt[5] <= (1 <<2)*6;
						shamt[6] <= (1 <<3)*7;
						shamt[7] <= (1 <<4)*8;
						shamt[8] <= (1 <<5)*9;
						shamt[9] <= (1 <<7)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[3][3:0];

						count = count +1;
					end 
					5: begin 					
						shamt[4] <= (1 <<0)*5;
						shamt[5] <= (1 <<1)*6;
						shamt[6] <= (1 <<2)*7;
						shamt[7] <= (1 <<3)*8;
						shamt[8] <= (1 <<4)*9;
						shamt[9] <= (1 <<5)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[4][4:0];
						count = count +1;
					end 
					6: begin 					
						shamt[5] <= (1 <<0)*6;
						shamt[6] <= (1 <<1)*7;
						shamt[7] <= (1 <<2)*8;
						shamt[8] <= (1 <<3)*9;
						shamt[9] <= (1 <<4)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[5][5:0];
						count = count +1;
					end 
					7: begin 					
						shamt[6] <= (1 <<0)*7;
						shamt[7] <= (1 <<1)*8;
						shamt[8] <= (1 <<2)*9;
						shamt[9] <= (1 <<3)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[6][6:0];
						count = count +1;
					end 
					8: begin 					
						shamt[7] <= (1 <<0)*8;
						shamt[8] <= (1 <<1)*9;
						shamt[9] <= (1 <<2)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[7][7:0];
						count = count +1;
					end 
					9: begin 		
						shamt[8] <= (1 <<0)*9;
						shamt[9] <= (1 <<1)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[8][8:0];
						count = count +1;
					end 
					10: begin 		
						shamt[9] <= (1 <<0)*10;
						#1 shftenable =1;
						#1 shftenable =0;
						codeout[MAXHIGHT *count -1 -:MAXHIGHT] <= shftout[9][9:0];
						count = count +1;
					end 
					default : $display("error in case top length: %x",lengths[DATA_WIDTH*count-1-:DATA_WIDTH]);
				endcase 
												
				shamt[0]=0;											//reset shift amounts
				shamt[1]=0;
				shamt[2]=0;
				shamt[3]=0;
				shamt[4]=0;
				shamt[5]=0;
				shamt[6]=0;
				shamt[7]=0;
				shamt[8]=0;
				shamt[9]=0;
				
			end  
		end
	end 
endmodule 
	