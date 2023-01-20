`timescale 1ns/1ns

module adder# (parameter WIDTH = 1
	       )(
		 input [WIDTH-1:0] 	a,
		 input [WIDTH-1:0] 	b,
		 output reg [WIDTH:0] sum_out);

   always @(*)
   sum_out = { {a[WIDTH-1]},{a[WIDTH-1:0]} } +{{b[WIDTH-1]},{b[WIDTH-1:0]} };

endmodule
