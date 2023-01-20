// This is a Verilog description for a register file

`timescale 1ns / 1ns

module reg_file#(
		 parameter WIDTH = 1, 
		 parameter DEPTH = 1,
		 parameter ADDR_WIDTH = $clog2(DEPTH),
		 parameter TYPE = 1
		 )(		
				input 		       clk,
				input 		       reset,
				input 		       wr_reg,
        			input [WIDTH-1:0]      wrData,
				input [ADDR_WIDTH-1:0] wrAddr,
				input [ADDR_WIDTH-1:0] rdAddr1,
				input [ADDR_WIDTH-1:0] rdAddr2,
				output reg [WIDTH-1:0] rdData1,
				output reg [WIDTH-1:0] rdData2
				);

   reg [WIDTH-1:0] 				       register [DEPTH];
   integer 					       i;   
   

   always @(*)
     begin
	rdData1 = register[rdAddr1];
	rdData2 = register[rdAddr2];
     end

   always @(posedge clk)
     if(reset)
       begin
	  if(TYPE == 1)
	    begin
	  for (i=0;i<DEPTH;i++)
	    register[i] <= 16'hffff;
	    end
	  else if(TYPE == 2)
	    begin
	     	  for (i=0;i<DEPTH;i++)
		    register[i] <= 2'h1;  
	    end
	  
	  
	  
	    else if(TYPE == 3)
	    begin
	     	  for (i=0;i<DEPTH;i++)
		 case(i)
		   0,1,2,3,4,5,6,7,8,9,10,11,12,15,16,19,20,21,22,23,26: register[i] <= i+1;
		   27,28,29,30,31: register[i] <=  0;
		   13: register[i] <= 10'h30f;
		   14: register[i] <= 10'h211;
		   17: register[i] <= 10'h313;
		   18: register[i] <= 10'h206;
		   24: register[i] <= 10'h31a;
		   25: register[i] <= 10'h204;
		 endcase // case (i)
	       end
	 
	   
	   
	  /*
	   * 
	   else if(TYPE == 3) begin
	      for(i=0;i<DEPTH;i++)
	      register[i] <= 0 ;
	  
	  end
	   */
	   
	  

	  else if(TYPE == 4)
	    for(i=0;i<DEPTH;i++)
	      register[i] <= {{WIDTH}{1'b1}} ;
	    //  register[i] <= 0;
	  
	  
       end // if (reset)
     else if(wr_reg)
       register[wrAddr] <= wrData;
   
endmodule
