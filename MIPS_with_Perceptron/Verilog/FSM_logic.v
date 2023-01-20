`timescale 1ns/1ns

module fsm_logic#( parameter SNT = 0,
		   parameter WNT = 1,
		   parameter WT = 2,
		   parameter ST = 3
		   )(
		     input 	      clk,
		     input 	      reset,
		     input [1:0]      previous_state,
		     input 	      taken,
		     output reg [1:0] next_state
		     );

   reg [1:0] 			      state;
   
   
    always @(posedge clk)    
      begin
	 if (reset)
	   state <= WNT;
	 else
	   next_state <= state;
     end
    
   

   always @(*) begin
     state = previous_state; // Default next state
      case (state)
      SNT: begin
	  state = taken ? WNT : SNT;
       end
       WNT: begin
	  state = taken ? WT : SNT;
       end
       WT: begin
	 state = taken ? ST : WNT;
       end
       ST: begin
	  state = taken ? ST : WT;
       end
      endcase
   end 

   endmodule
