module shiftreg (ena, shamt, out);
	//function: variable left shift register after a pulse to the enable signal
	
	parameter REGS = 8; 							//Number of regesters in the level 
	parameter BITS = 3;								//number of bits per regmodule 
	parameter SHIFTS = 10;							//number of bits for the shift varaiable
	
	input wire ena;									//enable signal for the shfitreg, pulse to run
	input wire [SHIFTS-1:0] shamt; 					//this is the number of shifts to do 
	output wire [BITS-1:0] out; 					//output for shift register 
		
	reg [BITS-1:0] iout; 							//internal output register 
	reg [BITS*REGS-1:0] ishift; 					//internal shift register 
	integer i; 										//for the initializiation
	
	assign out =  iout;
	
	initial begin 									//setup the inital values
		for (i = 0; i< REGS; i=i+1)  				//shifts bits in for loop
			 ishift[(BITS * i)+:BITS] <= REGS-1 - i;
	iout <= 0;
	end
	
	// if ishift[0] == ishift [1] then there is an error when trying to shift
	
	always @ (posedge ena) begin 						//use enable pulse to shift 
		if (ena) begin 
			iout <= ishift[REGS*BITS-1:REGS*BITS-BITS]; //shift out nessisary number of bits
			ishift <= ishift << shamt;					//shift bits out of internal register
			
		end 
	end
	
endmodule 

