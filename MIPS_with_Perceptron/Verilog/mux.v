`timescale 1ns/1ns

module mux#(parameter WIDTH=1
	    
	    )(
	      input 		      select,
	      input [WIDTH-1:0]       in0,
	      input [WIDTH-1:0]       in1,
	      output wire [WIDTH-1:0] mux_out
	      );

 assign  mux_out = select ? in1 : in0;

endmodule // mux
