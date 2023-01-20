//This is a Verilog description for a ram
`timescale 1ns/1ns

module ram#(
	   
	   parameter	WIDTH		= 1,
	   parameter	DEPTH		= 1,
	   parameter	ADDR_WIDTH	= $clog2(DEPTH)
	    )(

	      input 		     clk, // clock
	      input 		     reset, // Reset
	      input [WIDTH-1:0]      data_in, // Data In
	      input [ADDR_WIDTH-1:0] addr, // Write Address
	      input 		     wr_en, // Write Enable
	      output reg [WIDTH-1:0] data_out // Data Out
	      );
   
   
   reg [WIDTH-1:0] 		     mem	[DEPTH];
 
   
   


   always@(posedge clk)
     if(wr_en)
       mem[addr] <= data_in;

 always @ (*)
       data_out = mem[addr];
   
   
   
endmodule
