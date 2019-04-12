module dffa (D,clk,ENA,Q);
	// function: holds value when clk is rising and ena is active; 
//parameters
  parameter DATA_WIDTH = 4;// size of each input data

  input wire [DATA_WIDTH-1:0] D; //input to FF
  input wire clk; //clock singnal
  input wire ENA; // enable for flipflop
  output wire [DATA_WIDTH-1:0] Q; //output

  reg [DATA_WIDTH-1:0]dreg; //internal register

  initial
	dreg<=0;  //inital value of 0
  assign Q = dreg;

  always@(posedge clk) begin  //at clock positive edge
		if (ENA)
			dreg<=D;
	end
	endmodule
