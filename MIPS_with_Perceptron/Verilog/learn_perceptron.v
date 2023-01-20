`timescale 1ns/1ns

module learn_perceptron#(
			 parameter HISTORY =1,
			 parameter BIAS =1,
			 parameter WIDTH_WORD =1,
			 parameter WEIGTH=1, 
			 parameter UNSIGNED_BIAS = BIAS -1 ,
			 parameter NUMBER_OF_WORDS =HISTORY		
			 ) (
			    input 		    clk,
			    input 		    reset,
			    input [HISTORY-1:0]     global_history_reg,
			    input [WEIGTH-1:0] 	    weigth,
			    input 		    result, 
			    input 		    prediction,
			    output reg [WEIGTH-1:0] next_state
			    );

   /*Word Signals*/
   reg [WIDTH_WORD-1:0] 		      word_plus_1[NUMBER_OF_WORDS];
   reg [WIDTH_WORD-1:0] 		      word_minus_1[NUMBER_OF_WORDS];
   reg [WIDTH_WORD-1:0] 		      new_word[NUMBER_OF_WORDS];
   reg [WIDTH_WORD-1:0] 		      word[NUMBER_OF_WORDS] ;
   reg [WIDTH_WORD-1:0] 		      max_word;
   reg [WIDTH_WORD-1:0] 		      min_word;

  // reg 					      history_bits[HISTORY];
  // reg 					      true_min[NUMBER_OF_WORDS];
  // reg 					      true_max[NUMBER_OF_WORDS];

   integer learn_count;
   
   
  
   /*Bias Signals*/
   reg [BIAS-1:0] 			      bias;
   reg [BIAS-1:0] 			      new_bias;
   reg [UNSIGNED_BIAS-1:0] 		      signed_bias;
   reg [BIAS-1:0] 		      min_signed_bias;
   reg [BIAS-1:0] 		      max_signed_bias;
  // reg [BIAS-1:0] 			      max_bias;
  // reg [BIAS-1:0] 			      min_bias;
   reg 					      signed_bit;
   reg 					      bias_plus1;
   reg 					      bias_minus1;
  
   /*Weigth Signals*/
   reg [NUMBER_OF_WORDS*WIDTH_WORD -1:0]      temp_new_weigth;
   reg [WEIGTH-1:0] 			      new_weigth;
   reg [WEIGTH-1:0] 			      state;
   			      

   integer 				  i;
   integer 				  ii;
   
   


   /*Bias Assignment */
   assign bias = weigth[WEIGTH-1:WEIGTH-BIAS];
   assign signed_bias = bias[UNSIGNED_BIAS-1:0];
   
   /*Weigth Assignment */
   assign state = (prediction==result) ? weigth : new_weigth;
   assign new_weigth = {new_bias , temp_new_weigth};

   /*Max/Min Statements*/  
   assign max_word = {{WIDTH_WORD}{1'b1}};
   assign min_word = {{WIDTH_WORD}{1'b0}};
 //  assign max_bias = {{BIAS}{1'b1}};
  // assign min_bias = {{BIAS}{1'b0}};
   
   assign max_signed_bias = {{1'b0},{{UNSIGNED_BIAS}{1'b1}}};
   assign min_signed_bias = {{1'b1},{{UNSIGNED_BIAS}{1'b0}}};
   
  // assign min_signed_bias = {{1'b1},{{UNSIGNED_BIAS-1}{1'b0}},{1'b1}};

 


   always @(*)
     begin
	for (i = 0; i < NUMBER_OF_WORDS; i = i + 1)
	  begin
	     word[i] = weigth[WIDTH_WORD * i +: WIDTH_WORD];
	     word_minus_1[i] = word[i] === min_word ? word[i] : word[i] - 1;
	     word_plus_1[i] = word[i] === max_word ? word[i] : word[i] + 1;
   	     temp_new_weigth[WIDTH_WORD * i+:WIDTH_WORD] = new_word[i];
	     
	  end
     end // always @ (*)   
   
     genvar ii1;
      generate
      for (ii1 = 0 ; ii1 < NUMBER_OF_WORDS ; ii1 = ii1 + 1)
	begin: mux_loop
	   mux #(.WIDTH(WIDTH_WORD))
	   mux(.select(global_history_reg[ii1]),
	       .in0(word_minus_1[ii1]),
	       .in1(word_plus_1[ii1]),
	       .mux_out(new_word[ii1]));
	end
   endgenerate

   
   always @(*)
     begin
	 if(result && bias == max_signed_bias)
	  new_bias = bias;
	else if(!result && bias == min_signed_bias)
	  new_bias = bias;
	/*
	 * if(result && bias == max_bias)
	  new_bias = bias;
	else if(!result && bias == min_bias)
	  new_bias = bias;
	 */
	else if(result)
	  new_bias = bias + 1;
	else if(!result)
	  new_bias = bias - 1;
     end // always @ (*)
   

   always @(posedge clk)
     begin
   if (reset)
     next_state <= 0;
   else if(prediction == result)
     next_state <= weigth;
   else
     next_state <= new_weigth;     
     end   
   

endmodule // lern_perceptron

  



	 
