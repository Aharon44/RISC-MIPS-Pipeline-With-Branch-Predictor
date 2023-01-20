`timescale 1ns / 1ns

module pc#(
	   parameter WIDTH = 1
	   )(
	     input 		    clk,
	     input 		    reset,
	     input 		    flush,
	     input [WIDTH-1:0] 	    next_pc,
	     input [WIDTH-1:0] 	    save_pc,
	     input [WIDTH-1:0] 	    branch_pc,
	     output reg [WIDTH-1:0] pc_add
	     );
   
   
   always @(posedge clk)
     if(reset)
	  pc_add <= 0;
     else if(flush)
       begin
	  if(save_pc == 0)
	    pc_add <= branch_pc;
	  else
	    pc_add <= save_pc;
       end
     else
       pc_add <= next_pc;
   
 

endmodule // pc
   


	  
