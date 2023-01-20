`timescale 1ns/1ns

module perceptron_prediction#(parameter HISTORY=1,
			      parameter STATE_WIDTH = 1,
			      parameter BIAS = 1,
			      parameter WIDTH_WORD = 1,
			      parameter WEIGTH=1,   
			      parameter NUMBER_OF_WORDS = HISTORY,
			      parameter SPACE = NUMBER_OF_WORDS-1
			      ) (
				 input [HISTORY-1:0] 	 global_history_reg,
				 input [WEIGTH-1:0] 	 weigth,
				 input [STATE_WIDTH-1:0] branch_inst, 
				 output reg 		 prediction
				 );
   
   /* Bias Signals */
   wire [BIAS-1:0] 			  bias;
   wire [WIDTH_WORD+SPACE:0] 		  extended_bias;
   wire [BIAS-1:0] 			  new_bias;
   
   
   /* Word Signals */
   reg [WIDTH_WORD-1:0] 		  word [NUMBER_OF_WORDS];
   reg [WIDTH_WORD:0] 			  new_word [NUMBER_OF_WORDS];
   reg [WIDTH_WORD:0] 			  positive_word [NUMBER_OF_WORDS];
   reg [WIDTH_WORD:0] 			  negative_word [NUMBER_OF_WORDS];
   reg [WIDTH_WORD+SPACE:0] 		  extended_word [NUMBER_OF_WORDS];
   
   /* Sum Signals */
   reg [WIDTH_WORD+SPACE:0] 		  sum_words;
   reg [WIDTH_WORD+SPACE+1:0] 		  total_sum;


   integer 	       index1;
   
 
   assign bias = weigth[WEIGTH-1:WEIGTH-BIAS];

always @(branch_inst) begin
   case (branch_inst) 
     0 : prediction = 1'b0;  
     2 : prediction = 1'b1; 
     3 : prediction = ~total_sum[WIDTH_WORD+SPACE+1]; 
     default : prediction = 1'b0;     
   endcase // case (branch_inst)
end
   
     
   
  //  assign prediction = branch_inst? ~total_sum[WIDTH_WORD+SPACE+1] : 1'b0;
  //  assign prediction = branch_inst? total_sum[WIDTH_WORD+SPACE+1] : 1'b0;
   
   always @(*)  
     begin
//	total_sum = extended_bias;
	sum_words = 0 ;
	for (index1 = 0; index1 < NUMBER_OF_WORDS; index1 = index1 + 1)
	  begin
	     word[index1] = weigth[WIDTH_WORD * index1 +: WIDTH_WORD];
	     positive_word[index1] = {1'd0,word[index1]};
	     negative_word[index1] = -positive_word[index1];
	     sum_words = sum_words + extended_word[index1];
	 //    total_sum = total_sum + extended_word[index1]; 
	  end
     end

   
   genvar ii1;
   generate
      for (ii1 = 0 ; ii1 < NUMBER_OF_WORDS ; ii1 = ii1 + 1)
	begin: mux_loop
	   mux #(.WIDTH(WIDTH_WORD+1))
	   mux(.select(global_history_reg[ii1]),
	       .in0(negative_word[ii1]),
	       .in1(positive_word[ii1]),
	       .mux_out(new_word[ii1]));
	   
	   sign_extender#(.WIDTH(WIDTH_WORD+1),
			  .NEW_WIDTH(WIDTH_WORD+1+SPACE))
	   sign_extender_matrix(.extend(new_word[ii1]),
				.extended(extended_word[ii1]));	   
	end
   endgenerate

  // assign new_bias = bias - 5'b11111;
      
   sign_extender#(.WIDTH(BIAS),
		  .NEW_WIDTH(WIDTH_WORD+1+SPACE))
   sign_extender_bias(.extend(bias),
		      .extended(extended_bias));

  // assign total_sum = sum_words + new_bias;
   
   
   
     adder #(.WIDTH(WIDTH_WORD+1+SPACE))
   adder_totalsum(.a(sum_words),
		  .b(extended_bias),
		  .sum_out(total_sum));
    
   

  endmodule // perceptron


	 
