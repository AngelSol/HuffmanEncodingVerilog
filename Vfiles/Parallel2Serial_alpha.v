module Parallel2Serial_alpha (length, codeword, clk,enable,internal,done);
	//function: given parallel inputs serially output the codewords
	parameter DATA_WIDTH = 8;																	//expected data width
	parameter TOTAL_SYMBOLS = 10;																//TOtal lenght of alphabet
	parameter ADDR_WIDTH = 4;																	//width of address bits
	parameter MAXHIGHT = 10;																	//maximum hight of tree
	
	input wire [TOTAL_SYMBOLS*DATA_WIDTH-1:0] length;											//input of all lengths   (sorted)
	input wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] codeword;											//input of all codewords (sorted)
	input wire clk;																				//clk input 
	input wire enable;																			//enable signal
	output reg internal;																		//internal register to hold serial output
	output wire done;																			//done signal to show when finished
	
	integer i;																					//used to traverse the parralel buffer
	reg donei;																					//internal done register
	reg [MAXHIGHT-1:0] parallelin1;																//hold the current codeword to parse
	assign done = donei;																	
	
	initial begin																				//set initial values
		internal <=0;
		donei <=0;
		i = 0;
	end // initial
	
	always @(posedge clk) begin
		if(i>TOTAL_SYMBOLS*MAXHIGHT) begin														//this condition means we are finished
			donei<=1;
		end
		else if(enable) begin
			parallelin1 = codeword[MAXHIGHT*((i/MAXHIGHT)+1)-1 -:MAXHIGHT];						//grab the next codeword length
			case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])							//depending on the length start at a different bit
				1:begin																				
					
					if (i%MAXHIGHT == 1) begin													//if we are done with the codeword
						i= i+MAXHIGHT-1;														//set i to the next codeword set
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];		//set buffer to next codeword set 
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])				//look ahead and prepare internal buffer for next output 
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;											//if we are out of range send z to show we are done
						endcase 
					end
					else
						 internal = parallelin1[i%MAXHIGHT+:1];
				end // 1
				2:begin																			//same as above set of comments
					
					if (i%MAXHIGHT == 2) begin
						i= i+MAXHIGHT-2;
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						 	
						endcase 
					end 
					else 
						internal = parallelin1[1 - i%MAXHIGHT+:1];
				end // 2
				3:begin
					
					if (i%MAXHIGHT == 3) begin
						i= i+MAXHIGHT-3;
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						endcase 
					end
					else 
						internal = parallelin1[2-i%MAXHIGHT+:1];
						
				end // 3
				4:begin
					
					if (i%MAXHIGHT == 4)begin
						i= i+MAXHIGHT-4;
						 parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						endcase 
					end
					else 
						internal = parallelin1[3-i%MAXHIGHT+:1];
				end // 4
				5:begin
					if (i%MAXHIGHT == 5) begin
						i= i+MAXHIGHT-5;
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						endcase 
					end
					else 
						internal = parallelin1[4-i%MAXHIGHT+:1];
				end // 5
				6:begin
					
					if (i%MAXHIGHT == 6) begin
						i= i+MAXHIGHT-6;
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						endcase 
					end
					else 
						internal = parallelin1[5-i%MAXHIGHT+:1];
					
						
				end // 6
				7:begin
					
					if (i%MAXHIGHT == 7) begin
						i= i+MAXHIGHT-7;
						parallelin1 = codeword[MAXHIGHT*(((i+1)/MAXHIGHT)+1)-1 -:MAXHIGHT];
						case(length[DATA_WIDTH*((i/MAXHIGHT)+1)-1 -:DATA_WIDTH ])
						 	1: internal <= parallelin1[0-:1];
						 	2: internal <= parallelin1[1-:1];
						 	3: internal <= parallelin1[2-:1];
						 	4: internal <= parallelin1[3-:1];
						 	5: internal <= parallelin1[4-:1];
						 	6: internal <= parallelin1[5-:1];
						 	7: internal <= parallelin1[6-:1];
						 	default: internal <= 1'bz;
						endcase 
					end
					else 
						internal = parallelin1[6-i%MAXHIGHT+:1];
				end // 7
				default : $display("error in case(serial)");
			endcase // length[DATA_WIDTH*(i/DATA_WIDTH+1)-1 -:DATA_WIDTH ]
			 i = i +1;
		end // if(enable)
	end // always @(posedge clk)
	
	endmodule // Parallel2Serial