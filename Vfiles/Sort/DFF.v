
module dff_s (D,clk,ENA,sload,Q);
	// function: holds value when clk is rising and ena is active; 
	//sload is for reseting to known value
//parameters 
  parameter DATA_WIDTH = 8;					// size of each input data
  
  input wire [DATA_WIDTH-1:0] D; //input to dff
  input wire clk; //clock signal
  input wire ENA; //enable for the flipflop
  input wire sload; //serial load which sets flipflop to known value
  output wire [DATA_WIDTH-1:0] Q; //output of flipflop
  
  reg [DATA_WIDTH-1:0]dreg; // internal register for FF
  initial 
	dreg<=0; //initially make the flipflop 0
  assign Q = dreg;
  
  always@(posedge clk) begin 
		if (sload)
      dreg<={DATA_WIDTH{1'b1}}; //s_load sets the register to FF
		//	dreg<=8'hff; //s_load sets the register to FF
		if (ENA) // if enable then Q becomes D
			dreg<=D;
	end
	endmodule 
