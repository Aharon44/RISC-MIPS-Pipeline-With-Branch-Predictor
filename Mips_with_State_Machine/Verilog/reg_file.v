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
			//	input [TYPE_WIDTH-1:0] reg_type,
				output reg [WIDTH-1:0] rdData1,
				output reg [WIDTH-1:0] rdData2
				);

   reg [WIDTH-1:0] 				       register [DEPTH];
   integer 					       i;

  // reg [TYPE_WIDTH-1:0] 			       reg_type;
   

   
   /*
    * generate
   if (TYPE_WIDTH == 1)
     reg_type <= 1;
   else if (TYPE_WIDTH == 2)
     reg_type <= 2;
   else if (TYPE_WIDTH == 3)
     reg_type <= 3;
   else
     reg_type <= 0;
   endgenerate
    */
   

   always @(*)
     begin
	rdData1 = register[rdAddr1];
	rdData2 = register[rdAddr2];
     end

   always @(posedge clk)
     if(reset)
     //  reg_type = 0;
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
		    register[i] <= 0;  
	    end
	  
       end // if (reset)
     else if(wr_reg)
       register[wrAddr] <= wrData;
   
endmodule
