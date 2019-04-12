module testbench();
	//function: tests the output of the codeword generator.
	parameter DATA_WIDTH = 16;	
	parameter TOTAL_SYMBOLS = 10;
	parameter ADDR_WIDTH = 4;
	parameter MAXHIGHT = 10;
	reg clk; 									//clock for the top module 
	reg en; 									//enable for module 
	reg d_sload; 								//for top module 
	wire [TOTAL_SYMBOLS*MAXHIGHT-1:0] b; 		//large bus for the data DFF outputs
	wire [TOTAL_SYMBOLS*ADDR_WIDTH-1:0] ab ; 	//large bus for the address DFF outputs
	wire [MAXHIGHT*TOTAL_SYMBOLS-1:0] codeout;	//large bus for the codewords
	wire serialout;								//serial output of codewords
	wire serialready;							//signal to know when seiral begins
	
	treemaker #(DATA_WIDTH,TOTAL_SYMBOLS,ADDR_WIDTH,MAXHIGHT) dut(en, d_sload, clk, codeout, b, ab,serialout,serialready,done); 

	initial begin								//initialize values
		en <= 0; 
		#12 d_sload <= 0;						//give load signal
		#12 d_sload <= 1;
		#12 d_sload <= 0;
		#40;
		
		en <= 1; 								//enable circuit
		$display("Serial out:",);				//display begining of serial output

	end

	always begin 								// clk oscillation
		clk <= 0;#10;
		clk <= 1;#10;
		if (done) begin							//finished show finial print
		$display("\nAlphabet: 		Length: 		Codewords:");
		$display("%c		%d 		%b",ab[3:0]+65,		b[9-:10],	codeout[1*MAXHIGHT-1:0*MAXHIGHT]);
		$display("%c		%d 		%b",ab[7:4]+65,		b[19-:10],	codeout[2*MAXHIGHT-1:1*MAXHIGHT]);
		$display("%c		%d 		%b",ab[11:8]+65,	b[29-:10],	codeout[3*MAXHIGHT-1:2*MAXHIGHT]);
		$display("%c		%d 		%b",ab[15:12]+65,	b[39-:10],	codeout[4*MAXHIGHT-1:3*MAXHIGHT]);
		$display("%c		%d 		%b",ab[19:16]+65,	b[49-:10],	codeout[5*MAXHIGHT-1:4*MAXHIGHT]);
		$display("%c		%d 		%b",ab[23:20]+65,	b[59-:10],	codeout[6*MAXHIGHT-1:5*MAXHIGHT]);
		$display("%c		%d 		%b",ab[27:24]+65,	b[69-:10],	codeout[7*MAXHIGHT-1:6*MAXHIGHT]);
		$display("%c		%d 		%b",ab[31:28]+65,	b[79-:10],	codeout[8*MAXHIGHT-1:7*MAXHIGHT]);
		$display("%c		%d 		%b",ab[35-:4]+65,	b[89-:10],	codeout[9*MAXHIGHT-1:8*MAXHIGHT]);
		$display("%c		%d 		%b",ab[39-:4]+65,	b[99-:10],	codeout[10*MAXHIGHT-1:9*MAXHIGHT]);
		$display();
		$stop;
		end
	end
	
	always @(posedge clk ) begin
		if (serialready)					//wait until serial is ready
			#1 $write("%b",serialout); 		//delay to catch after clkedge
	end 
	endmodule