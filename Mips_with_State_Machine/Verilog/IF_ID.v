`timescale 1ns/1ns

  module IF_ID#(
		parameter INST_WIDTH = 1,
		parameter PC_WIDTH = 1
		)(
		  input 		      clk,
		  input 		      reset,
		  input 		      flush,
		  input [PC_WIDTH-1:0] 	      pc_in,
		  input 		      prediction_in,
		  input [PC_WIDTH-1:0] 	      save_pc_in,
		  input [INST_WIDTH-1:0]      inst_in, 
	          output reg [PC_WIDTH-1:0]   pc_out,
		  output reg [INST_WIDTH-1:0] inst_out,
		  output reg 		      prediction_out,
		  output reg [PC_WIDTH-1:0]   save_pc_out
		  );

   always @(posedge clk)
     if (reset)
       begin
	  pc_out <= 0 ;
	  inst_out <= 0;
	  save_pc_out <= 0;	  
	  prediction_out <= 0;	  
       end
     else if(flush)
       begin
//	  pc_out <= pc_in ;
	  pc_out <= 0 ;
	  inst_out <= 0;	  
	  prediction_out <= 0;
//	  save_pc_out <= 0;
	  save_pc_out <= save_pc_in;
       end  
     else   
       begin
	  pc_out <= pc_in ;
	  inst_out <= inst_in;
	  save_pc_out <= save_pc_in;	  
	  prediction_out <= prediction_in;
       end
   
     endmodule
