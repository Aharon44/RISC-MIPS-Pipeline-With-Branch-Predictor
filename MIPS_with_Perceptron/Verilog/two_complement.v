`timescale 1ns / 1ns

module two_complement#(parameter WIDTH =1
		       ) (
			  input [WIDTH-1:0] 	 number,
			  output reg [WIDTH-1:0] twos_comp	   
			  );

   assign      twos_comp = ~number + 1'b1;

endmodule // two_complement



			
