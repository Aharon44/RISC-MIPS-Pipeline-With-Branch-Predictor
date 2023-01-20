`timescale 1ns/1ns

module branch_predictor#(parameter PC_WIDTH = 1,
			 parameter STATE_WIDTH = 1,
			 parameter LUT_DEPTH = 1,
			 parameter LUT_ADDR_WIDTH = $clog2(LUT_DEPTH),
			 parameter PREDICTION = 1,
			 parameter SAVE_PC = 1		 
			 )(
			   input 		     clk,
			   input 		     reset,
			   input [PC_WIDTH-1:0]      pc_addr,
			   input [PC_WIDTH-1:0]      pc_addr_idex,
			   input [PC_WIDTH-1:0]      branch_pc,
			   input 		     branch_result,
			   input 		     branch_inst,
			   output reg 		     prediction,
			   output reg [PC_WIDTH-1:0] next_pc,
			   output reg [PC_WIDTH-1:0] save_pc
			   );

   /*Read Addresses */
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_addr;
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_idex_addr;
   
   /*PC Addresses to select*/
   wire [PC_WIDTH-1:0] 				     pc_plus1;
   wire [PC_WIDTH-1:0] 				     branch_pc_from_lut;

   /*STATE & Prediction wires*/
   wire [STATE_WIDTH-1:0] 			     p_state;
   wire [STATE_WIDTH-1:0] 			     n_state;
   wire [STATE_WIDTH-1:0] 			     lut_prediction;
   
   /*Write LUT1 wires*/
   reg 						     branch_inst_d;
   reg [LUT_ADDR_WIDTH-1:0] 			     lut_pc_idex_addr_d;

   /*Unused Signal*/
   wire [PC_WIDTH-1:0] 				     nothing;
   
   reg_file#(.WIDTH(STATE_WIDTH),
	     .DEPTH(LUT_DEPTH),
	     .TYPE(PREDICTION)) 
   lut1(
	.clk(clk),
	.reset(reset),
	.wr_reg(branch_inst_d),
	.wrData(n_state),
	.wrAddr(lut_pc_idex_addr_d),
	.rdAddr1(lut_pc_addr),
	.rdAddr2(lut_pc_idex_addr),
	.rdData1(lut_prediction),
	.rdData2(p_state)
	);
   
  reg_file#(.WIDTH(PC_WIDTH),
	     .DEPTH(LUT_DEPTH),
	     .TYPE(SAVE_PC)) 
   lut2(
	.clk(clk),
	.reset(reset),
	.wr_reg(branch_inst),
	.wrData(branch_pc),
	.wrAddr(lut_pc_idex_addr),
	.rdAddr1(lut_pc_addr),
	.rdAddr2(5'h0),
	.rdData1(branch_pc_from_lut),
	.rdData2(nothing)
	);


   fsm_logic  fsm_logic(
			.clk(clk),
			.reset(reset),
			.previous_state(p_state),
			.taken(branch_result),
			.next_state(n_state)
			);
   	     	
always @(posedge clk)
  if (reset)
    begin
       branch_inst_d <= 0;
       lut_pc_idex_addr_d <= 0;
    end
  else
    begin
       branch_inst_d <= branch_inst;
       lut_pc_idex_addr_d <= lut_pc_idex_addr;
      end
   
   
   assign prediction = lut_prediction[STATE_WIDTH-1];
  
   assign lut_pc_addr = pc_addr[LUT_ADDR_WIDTH-1:0];
   
   assign lut_pc_idex_addr = pc_addr_idex[LUT_ADDR_WIDTH-1:0];
       
   assign pc_plus1 = pc_addr + 8'h1;

   assign next_pc = prediction ?  branch_pc_from_lut : pc_plus1;

   assign save_pc = prediction ?  pc_plus1 : branch_pc_from_lut; 

       

       endmodule // brnach_predictor

	 
