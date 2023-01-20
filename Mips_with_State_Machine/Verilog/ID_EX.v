`timescale 1ns/1ns


module ID_EX#(
	      parameter PC_WIDTH = 1,
	      parameter DATA_WIDTH = 1,
	      parameter ADDR_WIDTH = 1,
	      parameter REG_ADDR_WIDTH = 1,
	      parameter IMMED_ADDR_WIDTH = 1,
	      parameter ALU_OPCODE_WIDTH = 1
	      )(
		input 				  clk,
		input 				  reset,
		input 				  flush,
		input [PC_WIDTH-1:0] 		  pc_in,
		input [DATA_WIDTH-1:0] 		  rd_data1_in,
		input [DATA_WIDTH-1:0] 		  rd_data2_in,
		input [ADDR_WIDTH-1:0] 		  extended_addr_in,
		input [REG_ADDR_WIDTH-1:0] 	  reg_addr_wr_in,
		input [IMMED_ADDR_WIDTH-1:0] 	  immediate_in,
		input [ALU_OPCODE_WIDTH-1:0] 	  alu_opcode_in,
	        input 				  prediction_in,
		input [PC_WIDTH-1:0] 		  save_pc_in,
		output reg [PC_WIDTH-1:0] 	  pc_out,
		output reg [DATA_WIDTH-1:0] 	  rd_data1_out,
		output reg [DATA_WIDTH-1:0] 	  rd_data2_out,
		output reg [ADDR_WIDTH-1:0] 	  extended_addr_out,
		output reg [REG_ADDR_WIDTH-1:0]   reg_addr_wr_out,
		output reg [IMMED_ADDR_WIDTH-1:0] immediate_out,
		output reg [ALU_OPCODE_WIDTH-1:0] alu_opcode_out,
		output reg 			  prediction_out,
		output reg [PC_WIDTH-1:0] 	  save_pc_out
		);

always @(posedge clk)
  if (reset)
    begin
       pc_out <= 0; 
       rd_data1_out <= 0;       
       rd_data2_out <= 0;       
       extended_addr_out <= 0 ;       
       reg_addr_wr_out <= 0;
       immediate_out <= 0;      
       alu_opcode_out <= 0;
       save_pc_out <= 0;	  
       prediction_out <= 0;
    end 
  else if(flush)
    begin
       pc_out <= 0;
    //   pc_out <= pc_in; 
       rd_data1_out <= 0;       
       rd_data2_out <= 0;       
       extended_addr_out <= 0 ;       
       reg_addr_wr_out <= 0;
       immediate_out <= 0;      
       alu_opcode_out <= 0;
     //  save_pc_out <= 0;	
       save_pc_out <= save_pc_in;
       prediction_out <= 0;
    end 
   else
    begin
       pc_out <= pc_in; 
       rd_data1_out <= rd_data1_in;       
       rd_data2_out <= rd_data2_in;       
       extended_addr_out <= extended_addr_in ;       
       reg_addr_wr_out <= reg_addr_wr_in;
       immediate_out <= immediate_in;      
       alu_opcode_out <= alu_opcode_in; 
       save_pc_out <= save_pc_in;	  
       prediction_out <= prediction_in;
    end
endmodule
