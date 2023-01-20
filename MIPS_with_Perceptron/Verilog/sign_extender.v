`timescale 1ns / 1ns

module sign_extender#(
		      parameter WIDTH =1,
		      parameter NEW_WIDTH = 2*WIDTH
		      ) (
			 input [WIDTH-1:0] 	extend,
			 output reg [NEW_WIDTH-1:0] extended	   
			 );

   always @(*)
      extended[NEW_WIDTH-1:0] = { {WIDTH{extend[WIDTH-1]}}, extend[WIDTH-1:0] };
   
endmodule // sign_extender


			
