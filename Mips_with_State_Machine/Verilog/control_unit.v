`timescale 1ns / 1ns

module control_unit#(
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
		       input 			clk,		  
		       input [OPCODE_WIDTH-1:0] opcode,
		       input [WIDTH-1:0] 	instruction,
		       output reg 		wr_reg,
		       output reg 		wr_en,
		       output reg 		mem_to_reg,
		       output reg 		immediate_en,
		       output reg 		skip_en,
		       output reg 		branch_en,
		       output reg 		halt_en
		       );
   

   always @(*)
     begin
	wr_en = 0;
	wr_reg = 0;
	mem_to_reg = 0;
	immediate_en = 0;
	skip_en = 0; 
	branch_en = 0;
	halt_en = 0;
	case(opcode)
	  NOPE: begin
	  end
	  LOADI: begin
	     wr_reg = 1;
	     mem_to_reg = 1;
	     immediate_en = 1;
	  end
	  LOAD: begin
	     wr_reg = 1;
	     mem_to_reg = 1;
	  end
	  STORE: begin
	     wr_en = 1;
	  end
	  INC: begin
	     wr_reg = 1;
	  end
	  DEC: begin
	     wr_reg = 1;
	  end
	  SNIB: begin
	     skip_en = 1;
	  end
	  SNIE:begin
	     skip_en = 1;
	  end
	  MOVE: begin
	     wr_reg = 1;
	  end
	  BUN: begin 
	     branch_en = 1;
	  end
	  HALT: begin
	     halt_en = 1;
	  end
	  SNIEV: begin
	     skip_en = 1;
	  end
	  SNIOD: begin
	     skip_en = 1;
	  end
	   INC: begin
	     wr_reg = 1;
	  end
	  DEC: begin
	     wr_reg = 1;
	  end
	  SNIB: begin
	     skip_en = 1;
	  end
	  SNIE:begin
	     skip_en = 1;
	  end
	  MOVE: begin
	     wr_reg = 1;
	  end
	  BUN: begin 
	     branch_en = 1;
	  end
	  HALT: begin
	     halt_en = 1;
	  end
	  SNIEV: begin
	     skip_en = 1;
	  end
	  SNIOD: begin
	     skip_en = 1;
	  end
	  RESET: begin
	     wr_reg = 1;
	  end
	   ADD: begin
	     wr_reg = 1;
	  end
	   SNIZ: begin
	     skip_en = 1;
	  end

	  
	  default:begin
	    end
	  
	  
	endcase // case (opcode)
     end // always @ (*)
   
   

   
   
endmodule // alu
