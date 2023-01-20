`timescale 1ns / 1ns

module alu#(
	    parameter NOPE = 0,
	    parameter LOADI = 1,
	    parameter LOAD = 2,
	    parameter STORE = 3,
	    parameter INC = 4,
	    parameter DEC = 5,
	    parameter SNIB = 6,
	    parameter SNIE = 7,
	    parameter MOVE = 8,
	    parameter BUN = 9,
	    parameter HALT = 10,
	    parameter SNIEV = 11,
	    parameter SNIOD = 12,
	    parameter RESET = 13,
	    parameter ADD = 14,
	    parameter SNIZ = 15,

	    parameter OPCODE_WIDTH = 1,
	    parameter WIDTH =1
	    )(
	      input [OPCODE_WIDTH-1:0] opcode,
	      input [WIDTH-1:0]        alu_input1,
	      input [WIDTH-1:0]        alu_input2,
	      output reg [WIDTH-1:0]   alu_output	
	      );


   always @(*)
     begin
	alu_output = 16'hffff; // defualt
	case(opcode)
	  NOPE: begin
	  end
	  STORE: begin 
	     alu_output = alu_input1;
	  end
	  INC: begin
	     alu_output = alu_input1 + 1;
	  end
	  DEC: begin
	     alu_output = alu_input1 - 1;
	  end
	  SNIB: begin
	     alu_output[15] =(alu_input1 > alu_input2);
	  end
	  SNIE: begin
	     alu_output[15] = (alu_input1 == alu_input2);
	  end
	  MOVE: begin
	     alu_output = alu_input2;
	  end
	  SNIEV: begin
	     alu_output[15] = (alu_input1 % 2 == 0);
	  end
	  SNIOD: begin
	     alu_output[15] = (alu_input1 % 2 == 1);
	  end
	  RESET: begin
	     alu_output = 0;
	  end
	  ADD: begin
	     alu_output = alu_input1 + alu_input2;
	  end
	  SNIZ: begin
	     alu_output[15] = (alu_input1 == 0);
	  end
	  
	  
	  default: begin
	  end 
	endcase // case (opcode)
     end // always @ (*)
   
  
   
   
endmodule // alu
