module comparator (a,b,ageb);
	//function: compairs the inputs and sets ageb accordingly
	parameter DATA_WIDTH = 8;	//width of the data
	
	input wire [DATA_WIDTH-1:0] a,b; //values to be compaired 
	output wire ageb; //output showing if A>=B
	
	assign ageb = a<=b; //For ascending order us <= for descending order use >=
	
	endmodule