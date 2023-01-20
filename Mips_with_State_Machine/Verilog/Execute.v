`timescale 1ns/1ns

module Execute(
	       input 	  clk,
	       input 	  reset,
	       input 	  flush,
	       input 	  wr_en_in,
	       input 	  immediate_en_in,
	       input 	  skip_en_in,
	       input 	  branch_en_in,
	       input 	  halt_en_in,
	       output reg wr_en_out,
	       output reg immediate_en_out,
	       output reg skip_en_out,
	       output reg branch_en_out,
	       output reg halt_en_out
	       );

   always @(posedge clk)
     if (reset || flush)
       begin
	wr_en_out <= 0;    
	immediate_en_out <= 0;     
	skip_en_out <= 0;     
	branch_en_out <= 0;     
	halt_en_out <= 0;
     end  
     else
     begin
	wr_en_out <= wr_en_in;    
	immediate_en_out <= immediate_en_in;     
	skip_en_out <= skip_en_in;     
	branch_en_out <= branch_en_in;     
	halt_en_out <= halt_en_in;
     end

endmodule // Execute
