`timescale 1ns/1ns

module branch_predictor#(parameter PC_WIDTH = 1,
			 parameter STATE_WIDTH = 1,
			 parameter LUT_DEPTH = 1,
			 parameter LUT_ADDR_WIDTH = $clog2(LUT_DEPTH),
			 parameter PREDICTION = 1,
			 parameter SAVE_PC = 1,
			 parameter HISTORY = 1,
			 parameter BIAS = 1,
			 parameter WIDTH_WORD = 1,
			 parameter WEIGTH = 1,  
			 parameter TYPE_PERCEPTRON = 1
			 )(
			   input 		     clk,
			   input 		     reset,
			   input [PC_WIDTH-1:0]      pc_addr,
			   input [PC_WIDTH-1:0]      pc_addr_idex,
			   input [PC_WIDTH-1:0]      immediate_addr,
			   input 		     branch_result,
			   input 		     branch_inst,
			   input 		     prediction_idex,
			   input 		     skip_en,
			   input 		     flush,
			   output reg 		     prediction,
			   output reg [PC_WIDTH-1:0] next_pc,
			   output reg [PC_WIDTH-1:0] save_pc
			   );

   /*Read Addresses */
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_addr;
   wire [LUT_ADDR_WIDTH-1:0] 			     lut_pc_idex_addr;
   
   /*STATE & Prediction wires*/
   wire [WEIGTH-1:0] 				     p_state;
   wire [WEIGTH-1:0] 				     n_state;
   wire [WEIGTH-1:0] 				     lut_out_reg;
   wire [STATE_WIDTH -1:0] 			     branch_inst_from_lut;
   
   
   /*Write LUT WEIGHT wires*/
   reg 						     branch_inst_d;
   reg [LUT_ADDR_WIDTH-1:0] 			     lut_pc_idex_addr_d;

   /*Global History Registers*/
   reg [HISTORY-1:0] 				     global_history_reg;
   reg [HISTORY-1:0] 				     speculative_ghr;
   reg [HISTORY-1:0] 				     prediction_history;
   reg [HISTORY-1:0] 				     prediction_history_d;
   reg [HISTORY-1:0] 				     prediction_history_2d;
 
   
   /*LUT ADDERS DEFINTIONS*/   
   assign lut_pc_addr = pc_addr[LUT_ADDR_WIDTH-1:0];
   assign lut_pc_idex_addr = pc_addr_idex[LUT_ADDR_WIDTH-1:0];
       
//   assign  prediction_history =  global_history_reg;
   assign prediction_history = flush ? global_history_reg :prediction_history_2d;
   

   select_pc#(.PC_WIDTH(PC_WIDTH),
	      .STATE_WIDTH(STATE_WIDTH),
	      .LUT_DEPTH(LUT_DEPTH),
	      .LUT_ADDR_WIDTH(LUT_ADDR_WIDTH),
	      .SAVE_PC(SAVE_PC))
   select_pc(
	     .clk(clk),
	     .reset(reset),
	     .pc_addr(pc_addr),
	     .pc_addr_idex(pc_addr_idex),
	     .immediate_addr(immediate_addr),
	     .branch_inst(branch_inst),
	     .prediction(prediction),
	     .skip_en(skip_en),
	     .branch_inst_from_lut(branch_inst_from_lut),
	     .next_pc(next_pc),
	     .save_pc(save_pc)
	     );

   
   reg_file#(.WIDTH(WEIGTH),
	     .DEPTH(LUT_DEPTH),
	     .TYPE(TYPE_PERCEPTRON)) 
   lut_weight(
	      .clk(clk),
	      .reset(reset),
	      .wr_reg(branch_inst_d),
	      .wrData(n_state),
              .wrAddr(lut_pc_idex_addr_d),
	      .rdAddr1(lut_pc_addr),
	      .rdAddr2(lut_pc_idex_addr),
	      .rdData1(lut_out_reg),
	      .rdData2(p_state)
	      );
   

   learn_perceptron#(.WEIGTH(WEIGTH),
		     .WIDTH_WORD(WIDTH_WORD), 
		     .HISTORY(HISTORY),
		     .BIAS(BIAS))
   learn_perceptron(
		    .clk(clk),
		    .reset(reset),
		    .global_history_reg(prediction_history),
	            .weigth(p_state),
		    .result(branch_result),
		    .prediction(prediction_idex),
		    .next_state(n_state)
		    );
   
   perceptron_prediction#(.HISTORY(HISTORY),
			  .STATE_WIDTH(STATE_WIDTH),
			  .WEIGTH(WEIGTH),
			  .BIAS(BIAS),
			  .WIDTH_WORD(WIDTH_WORD))
   perceptron_prediction(
			 .global_history_reg(prediction_history),
			 .weigth(lut_out_reg),
			 .branch_inst(branch_inst_from_lut),
			 .prediction(prediction)
			 );

   always @(posedge clk)
     begin
	if(reset)
	  begin
  	     speculative_ghr <= 0;
	  end
	else
	  if(branch_inst_from_lut ==2'h3)
	    speculative_ghr <= {speculative_ghr[HISTORY-2:0],prediction};
     end

    	
always @(posedge clk)
  begin
  if(reset)
    begin
       branch_inst_d <= 0;
       lut_pc_idex_addr_d <= 0;
       global_history_reg <= 0;
       prediction_history_d <= 0;
       prediction_history_2d <= 0;
     //  learning_cnt <= 0;
    //   speculative_ghr <= 0;
    end
  else
    begin
       branch_inst_d <= branch_inst;
       lut_pc_idex_addr_d <= lut_pc_idex_addr;
       prediction_history_d <= speculative_ghr;
    //   prediction_history_d <= prediction_history;
       prediction_history_2d <= prediction_history_d;
       if(branch_inst && skip_en)
	 global_history_reg <= {global_history_reg[HISTORY-2:0],branch_result};
   //    if(branch_inst_from_lut == 2'h3)
//1	 speculative_ghr <= {speculative_ghr[HISTORY-1:0],prediction_idex};
    //   if(flsuh)
//	 learning_cnt <= learning_cnt + 1;
    end
  end // always @ (posedge clk)
   
       endmodule // brnach_predictor

	 
