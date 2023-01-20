`timescale 1ns/1ns

module flusher#(
		parameter WIDTH=1
		)(
		  input 	    clk,
		  input 	    reset,
		  input 	    branch_inst,
		  input 	    result,
		  input 	    prediction,
		  input [WIDTH-1:0] save_pc,
		  output reg 	    flush
		  );

   reg 				    check;


   /*
    * always @(posedge clk)
     if (reset)
       flush <= 0;
	else if (branch_inst)
          begin
	     if(result != prediction)
	       flush <= 1;
	  end
	else
	  flush <= 0;
    */

   always @(*)
     begin
     flush = 0;
     if (branch_inst)
          begin
	     if(result != prediction)
	       flush = 1;
	  end
     end
   
   

endmodule // flush
