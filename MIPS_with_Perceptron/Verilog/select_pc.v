`timescale 1ns/1ns

module select_pc#(parameter PC_WIDTH = 1,
		  parameter STATE_WIDTH = 1,
		  parameter LUT_DEPTH = 1,
		  parameter LUT_ADDR_WIDTH = 1,
		  parameter SAVE_PC = 1
		  )(
		    input 			  clk,
		    input 			  reset,
		    input [PC_WIDTH-1:0] 	  pc_addr,
		    input [PC_WIDTH-1:0] 	  pc_addr_idex,
		    input [PC_WIDTH-1:0] 	  immediate_addr,
	            input 			  branch_inst,
		    input 			  prediction,
		    input 			  skip_en,
		    output reg [STATE_WIDTH-1:0] branch_inst_from_lut,
		    output reg [PC_WIDTH-1:0] 	  next_pc,
		    output reg [PC_WIDTH-1:0] 	  save_pc
		    );


   /*LUT Addresses */
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_addr;
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_idex_addr;


 /*PC Addresses to select*/
   wire [PC_WIDTH-1:0] 				     pc_plus1;
   wire [PC_WIDTH-1:0] 				     branch_pc_from_lut;
   wire [PC_WIDTH-1:0] 				     branch_pc_to_lut;
   wire [PC_WIDTH-1:0] 				     branch_pc;
   wire [PC_WIDTH-1:0] 				     pc_idex_plus1;
   wire [PC_WIDTH-1:0] 				     pc_idex_plus2;


   /*LUT2 input/output Signals*/
   wire [PC_WIDTH+1:0] 				     pc_data_in;
   wire [PC_WIDTH+1:0] 				     pc_data_out1;
   wire [PC_WIDTH+1:0] 				     pc_data_out2;		


   
   reg_file#(.WIDTH(PC_WIDTH+2),
	     .DEPTH(LUT_DEPTH),
	     .TYPE(SAVE_PC)) 
   lut_select_pc(
		 .clk(clk),
		 .reset(reset),
		 .wr_reg(first_itr),
		 .wrData(pc_data_in),
		 .wrAddr(lut_pc_idex_addr),
		 .rdAddr1(lut_pc_addr),
		 .rdAddr2(lut_pc_idex_addr),
		 .rdData1(pc_data_out1),
		 .rdData2(pc_data_out2)
		 );

   /*LUT ADDERS DEFINTIONS*/
   assign lut_pc_addr = pc_addr[LUT_ADDR_WIDTH-1:0];
   
   assign lut_pc_idex_addr = pc_addr_idex[LUT_ADDR_WIDTH-1:0];
   

   /*ADDERS*/
   assign pc_plus1 = pc_addr + 8'h1;
   
   assign pc_idex_plus1 = pc_addr_idex + 8'h1;

   assign pc_idex_plus2 = pc_addr_idex + 8'h2;
  
   
   /*MUXES*/
   assign next_pc = prediction ?  branch_pc_from_lut : pc_plus1;

   assign save_pc = prediction ?  pc_plus1 : branch_pc_from_lut;

   assign branch_pc_to_lut = branch_inst ? branch_pc : pc_idex_plus1;

   assign branch_pc = skip_en ? pc_idex_plus2 : immediate_addr;


   /*Separator*/
   assign branch_pc_from_lut = pc_data_out1[PC_WIDTH-1:0];

   assign branch_inst_from_lut = pc_data_out1[PC_WIDTH+1:PC_WIDTH];

  
   /*Comperator*/
   assign first_itr = (pc_data_out2 == 0);


   /*Marger*/
   assign pc_data_in = {branch_inst,skip_en,branch_pc_to_lut[PC_WIDTH-1:0]};

   endmodule
