////////////////////////////////////////////////////////////////////////////////////
// Memory Initialization Module
//
// ---------------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------------------
// This module initializes memory to the provided text file of symbols.
// 
// Revision History :
// ---------------------------------------------------------------------------------
//   Ver  :| Author(s)     :| Mod. Date  :| Changes Made:
//   V1.0 :| Reiner Dizon  :| 08/31/2017 :| Initial Code
//   V2.0 :| Reiner Dizon  :| 01/31/2018 :| Change Image Init to Symbol Init
// ---------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////

module Memory_Init_Unit(rClk, rEn, rAddr, rData);
//=======================================================
//  PARAMETER declarations
//=======================================================
parameter DATA_WIDTH = 16;					// size of each input data
parameter TOTAL_SYMBOLS = 10;				// total number of symbols to be initialized
parameter ADDR_WIDTH = 4;					// size of address to account for total symbols = log2(TOTAL_SYMBOLS)
//parameter RAM_DEPTH = (1 << ADDR_WIDTH);	// size of RAM module



//=======================================================
//  PORT declarations
//=======================================================
input rClk, rEn;
input [ADDR_WIDTH-1:0] rAddr;
output wire [DATA_WIDTH-1:0] rData;

//=======================================================
//  REG/Wire declarations
//=======================================================
reg [DATA_WIDTH-1 : 0] memory [0 : TOTAL_SYMBOLS-1];	// INTERNAL MEMORY was RAM_DEPTH
reg [DATA_WIDTH-1:0] read_data;



//=======================================================
//  Structural coding
//=======================================================

// Memory Initialization Code - change the file name & size parameters for different input sequence
initial $readmemh ("memfile2.dat", memory);

// CODE - Read & Write
assign rData = read_data;

always @ (posedge rClk) begin
	if(rEn) read_data <= memory[rAddr];
end

endmodule
