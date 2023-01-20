`timescale 1ns/1ns

module WB(
	  input      clk,
	  input      reset,
	  input      flush,
	  input      mem_to_reg_in,
	  input      wr_reg_in,
	  output reg mem_to_reg_out,
	  output reg wr_reg_out
	  );

   always @(posedge clk)
     if (reset || flush)
       begin
	  mem_to_reg_out <= 0;	
	  wr_reg_out <= 0;
       end
     else
       begin
	  mem_to_reg_out <= mem_to_reg_in;
	  wr_reg_out <= wr_reg_in;	
       end
   

endmodule // WB

