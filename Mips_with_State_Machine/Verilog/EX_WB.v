`timescale 1ns/1ns


module EX_WB#(
	      parameter DATA_WIDTH = 1,
	      parameter ADDR_WIDTH = 1,
	      parameter REG_ADDR_WIDTH = 1
	      )(
		input 				clk,
		input 				reset,
		input 				flush,
		input [DATA_WIDTH-1:0] 		alu_output_in,
		input [ADDR_WIDTH-1:0] 		ram_addr_in, 
		input [REG_ADDR_WIDTH-1:0] 	reg_addr_wr_in,
		input 				wr_reg_in,
		input 				mem_to_reg_in,
		output reg [DATA_WIDTH-1:0] 	alu_output_out,
		output reg [ADDR_WIDTH-1:0] 	ram_addr_out, 
		output reg [REG_ADDR_WIDTH-1:0] reg_addr_wr_out,
		output reg 			wr_reg_out,
		output reg 			mem_to_reg_out

		);

always @(posedge clk)
  if (reset || flush)
    begin
       alu_output_out <= 0;       
       ram_addr_out <= 0; 
       reg_addr_wr_out <= 0;       
       wr_reg_out <= 0;       
       mem_to_reg_out <= 0;       
    end 
   else
    begin
       alu_output_out <= alu_output_in;       
       ram_addr_out <= ram_addr_in; 
       reg_addr_wr_out <= reg_addr_wr_in;       
       wr_reg_out <= wr_reg_in;       
       mem_to_reg_out <= mem_to_reg_in;   
    end
endmodule
