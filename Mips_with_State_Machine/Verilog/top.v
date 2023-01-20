//                              -*- Mode: Verilog -*-
// Filename        : top.v
// Description     : TOP module


`timescale 1ns / 1ns

module top#(
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

	    parameter DATA_WIDTH = 16,
	    parameter PC_WIDTH = 8,
	    parameter ADDR_WIDTH = 16,
	    parameter DATA_RAM_DEPTH = 65536,
	    parameter INST_RAM_DEPTH = 256,
//	    parameter REG_FILE_DEPTH = 8,
	    parameter REG_FILE_DEPTH = 16,
	    parameter LUT_DEPTH = 32,
	    parameter OPCODE_WIDTH = 4,
	    parameter IMMED_ADDR_WIDTH = 8,
//	    parameter REG_ADDR_WIDTH = 3,
	    parameter REG_ADDR_WIDTH = 4,
	    parameter STATE_WIDTH = 2,
	    parameter TYPE_REG_FILE = 1,
	    parameter TYPE_PREDICTION = 2,
	    parameter TYPE_SAVE_PC = 3,

	    parameter CNT_WIDTH = 16
	    )
   (
    input      clk,
    input      reset,
    output reg halt_rise
    );
   

    /*Data signals**/
   wire [DATA_WIDTH-1:0] data_ram_output;
   wire [DATA_WIDTH-1:0] write_data_to_reg;
   wire [DATA_WIDTH-1:0] rdData1;
   wire [DATA_WIDTH-1:0] rdData2;
   wire [DATA_WIDTH-1:0] alu_output;


   /*PC signals **/
   wire [PC_WIDTH-1:0] 	 jump_pc;
   wire [PC_WIDTH-1:0] 	 next_pc;
   wire [PC_WIDTH-1:0] 	 pc_add;
   wire [PC_WIDTH-1:0] 	 pc_plus2;
   wire [PC_WIDTH-1:0] 	 branch_pc;
   wire [PC_WIDTH-1:0] 	 save_pc;
   
  
   /*Enable signals **/
   reg 			 wr_en;
   reg 			 wr_reg;
   wire 		 skip_next;
   reg 			 skip_en;
   reg 			 branch_en;
   reg 			 mem_to_reg;
   reg 			 immediate_en;
   reg 			 halt_en;
   wire 		 branch_inst;
   wire 		 prediction;
   wire 		 flush;
   

    /*Instruction signals **/
   wire [OPCODE_WIDTH-1:0] 	   opcode;
   wire [REG_ADDR_WIDTH-1:0] 	   arg1;
   wire [REG_ADDR_WIDTH-1:0] 	   arg2;
   wire [IMMED_ADDR_WIDTH-1:0] 	   immediate_addr;

   
   /*addr signals **/
   wire [ADDR_WIDTH-1:0] 	   extended_addr; 	   
   wire [ADDR_WIDTH-1:0] 	   address;
   
   /*Instruction Fatch**/
   wire [PC_WIDTH-1:0] 		   if_pc;
   wire [DATA_WIDTH-1:0] 	   if_inst;
   wire [PC_WIDTH-1:0] 		   if_save_pc;
   wire 			   if_prediction;
   
   /*Instruction Decode**/
   wire [PC_WIDTH-1:0] 		   id_pc;
   wire [DATA_WIDTH-1:0] 	   id_inst;
   wire [PC_WIDTH-1:0] 		   id_save_pc;
   wire 			   id_prediction;
   
   /*Excute Signales**/
   wire [PC_WIDTH-1:0] 		   ex_pc;
   wire [PC_WIDTH-1:0] 		   ex_save_pc;
   wire [REG_ADDR_WIDTH-1:0] 	   ex_arg1;
   wire [ADDR_WIDTH-1:0] 	   ex_extended_addr;
   wire [DATA_WIDTH-1:0] 	   ex_rdData1;
   wire [DATA_WIDTH-1:0] 	   ex_rdData2;
   wire [IMMED_ADDR_WIDTH-1:0] 	   ex_immediate_addr;
   wire [OPCODE_WIDTH-1:0] 	   ex_opcode;
   wire 			   ex_prediction;

   /*Excute Enables**/
   reg    ex_wr_en;
   reg 	  ex_immediate_en;
   reg 	  ex_skip_en;
   reg 	  ex_branch_en;
   reg 	  ex_halt_en;

   /*Write Back Enables**/
   reg 	  wb_mem_to_reg;
   reg 	  wb_wr_reg;

   /*Hlat Enable**/
   reg 	  halt_s;

      /*Counters**/
   reg [CNT_WIDTH-1:0] branch_inst_cnt;
   reg [CNT_WIDTH-1:0] flush_cnt;
   reg [CNT_WIDTH-1:0] skip_en_cnt;
   reg [CNT_WIDTH-1:0] skip_flush_cnt;
   

   
    /*Instruction Definations**/
   assign	opcode = id_inst[DATA_WIDTH-1:DATA_WIDTH-OPCODE_WIDTH]; 
   assign	arg1 = id_inst[DATA_WIDTH-OPCODE_WIDTH-1:DATA_WIDTH-OPCODE_WIDTH-REG_ADDR_WIDTH];
   assign	arg2 = id_inst[DATA_WIDTH-OPCODE_WIDTH-REG_ADDR_WIDTH-1:DATA_WIDTH-OPCODE_WIDTH-2*REG_ADDR_WIDTH];
   assign	immediate_addr = id_inst[IMMED_ADDR_WIDTH-1:0];
    
    
  /*Data Ram**/
ram #(.WIDTH(DATA_WIDTH),
	.DEPTH(DATA_RAM_DEPTH)) 

   data_ram(
	    .clk(clk),
	    .reset(reset),
	    .data_in(alu_output),
	    .addr(address),
	    .wr_en(ex_wr_en),
	    .data_out(data_ram_output)
	  );

  /*Instruction Ram**/
   ram #(.WIDTH(DATA_WIDTH),
	 .DEPTH(INST_RAM_DEPTH)) 
   inst_ram(
	    .clk(clk),
	    .reset(reset),
	    .data_in(16'h0),
	    .addr(pc_add),
	    .wr_en(1'b0),
	    .data_out(if_inst)
	    );
   
  /*Registers**/
   reg_file #(.WIDTH(DATA_WIDTH),
	      .DEPTH(REG_FILE_DEPTH),
	      .TYPE(TYPE_REG_FILE)) 
   reg_file(
	    .clk(clk),
	    .reset(reset),
	    .wr_reg(wb_wr_reg),
	    .wrData(write_data_to_reg),
	    .wrAddr(ex_arg1),
	    .rdAddr1(arg1),
	    .rdAddr2(arg2),
	    .rdData1(rdData1),
	    .rdData2(rdData2)
	    );
   
   /*Control Unit**/
   control_unit #(.NOPE(NOPE),
		  .LOADI(LOADI),
		  .LOAD(LOAD),
		  .STORE(STORE),
		  .INC(INC),
		  .DEC(DEC),
		  .SNIB(SNIB),
		  .SNIE(SNIE),
		  .MOVE(MOVE),
		  .BUN(BUN),
		  .HALT(HALT),
		  .WIDTH(DATA_WIDTH),
		  .OPCODE_WIDTH(OPCODE_WIDTH)
		  ) 
   control_unit(
		.clk(clk),
		.instruction(if_inst),
		.opcode(opcode),
		.wr_reg(wr_reg),
		.wr_en(wr_en),
		.mem_to_reg(mem_to_reg),
		.immediate_en(immediate_en),
		.skip_en(skip_en),
		.branch_en(branch_en),
		.halt_en(halt_en)
		);

   /*ALU**/
   alu #(.NOPE(NOPE),
	 .LOADI(LOADI),
	 .LOAD(LOAD),
	 .STORE(STORE),
	 .INC(INC),
	 .DEC(DEC),
	 .SNIB(SNIB),
	 .SNIE(SNIE),
	 .MOVE(MOVE),
	 .BUN(BUN),
	 .HALT(HALT),
	 .WIDTH(DATA_WIDTH),
	 .OPCODE_WIDTH(OPCODE_WIDTH)
	 ) 
	 alu(
	     .opcode(ex_opcode),
	     .alu_input1(ex_rdData1),
	     .alu_input2(ex_rdData2),
	     .alu_output(alu_output)
	     );
   
   /*Program Counter**/
   pc #(.WIDTH(PC_WIDTH))
   pc(
      .clk(clk),
      .reset(reset),
      .flush(flush),
      .next_pc(next_pc),
      .save_pc(ex_save_pc),
      .branch_pc(branch_pc),
      .pc_add(pc_add)    
      ); 

   
 /*IF-ID Pipeline **/
   IF_ID #(.INST_WIDTH(DATA_WIDTH),
	   .PC_WIDTH(PC_WIDTH)
	   )
   IF_ID(.clk(clk),
	 .reset(reset),
	 .flush(flush),
	 .pc_in(if_pc),
	 .inst_in(if_inst),
	 .prediction_in(if_prediction),
	 .save_pc_in(if_save_pc),
	 .pc_out(id_pc),
	 .inst_out(id_inst),
	 .prediction_out(id_prediction),
	 .save_pc_out(id_save_pc)
	 );

   
   /*ID-EX Pipeline **/
   ID_EX #(.PC_WIDTH(PC_WIDTH),
	   .DATA_WIDTH(DATA_WIDTH),
	   .ADDR_WIDTH(ADDR_WIDTH),
	   .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
	   .IMMED_ADDR_WIDTH(IMMED_ADDR_WIDTH),
	   .ALU_OPCODE_WIDTH(OPCODE_WIDTH)
	   )
   ID_EX(.clk(clk),
	 .reset(reset),
	 .flush(flush),
	 .pc_in(id_pc),
	 .rd_data1_in(rdData1),
	 .rd_data2_in(rdData2),
	 .extended_addr_in(extended_addr),
	 .reg_addr_wr_in(arg1),
	 .immediate_in(immediate_addr),
	 .alu_opcode_in(opcode),
	 .prediction_in(id_prediction),
	 .save_pc_in(id_save_pc),
	 .pc_out(ex_pc),
	 .rd_data1_out(ex_rdData1),
	 .rd_data2_out(ex_rdData2),
	 .extended_addr_out(ex_extended_addr),
	 .reg_addr_wr_out(ex_arg1),
	 .immediate_out(ex_immediate_addr),
	 .alu_opcode_out(ex_opcode),
	 .prediction_out(ex_prediction),
	 .save_pc_out(ex_save_pc)
	 );

    /*EX-Enables **/
   Execute Execute(.clk(clk),
		   .reset(reset),
		   .flush(flush),
		   .wr_en_in(wr_en),
		   .immediate_en_in(immediate_en),
		   .skip_en_in(skip_en),
		   .branch_en_in(branch_en),
		   .halt_en_in(halt_en),
		   .wr_en_out(ex_wr_en),
		   .immediate_en_out(ex_immediate_en),
		   .skip_en_out(ex_skip_en),
		   .branch_en_out(ex_branch_en),
		   .halt_en_out(ex_halt_en)
		   );

       /*WB-Enables **/
   WB WB(.clk(clk),
	 .reset(reset),
	 .flush(flush),
	 .mem_to_reg_in(mem_to_reg),
	 .wr_reg_in(wr_reg),
	 .mem_to_reg_out(wb_mem_to_reg),
	 .wr_reg_out(wb_wr_reg)
	 );


   /*Sign Externder **/
   sign_extender #(.WIDTH(IMMED_ADDR_WIDTH)) 
   sign_extender(
		 .extend(immediate_addr),
		 .extended(extended_addr)
		 );

   /*Branch Predictor **/
   branch_predictor #(.PC_WIDTH(PC_WIDTH),
		      .STATE_WIDTH(STATE_WIDTH),
		      .LUT_DEPTH(LUT_DEPTH),
		      .PREDICTION(TYPE_PREDICTION),
		      .SAVE_PC(TYPE_SAVE_PC)
		      )
   branch_predictor(.clk(clk),
		    .reset(reset),
		    .pc_addr(pc_add),
		    .pc_addr_idex(ex_pc),
		    .branch_pc(branch_pc),
		    .branch_result(alu_output[15]),
		    .branch_inst(branch_inst),
		    .prediction(prediction),
		    .next_pc(next_pc),
		    .save_pc(save_pc)
		    );
   
   /*Flusher **/
   flusher#(.WIDTH(PC_WIDTH)
	    )
   flusher(.clk(clk),
	 .reset(reset),
	 .branch_inst(branch_inst),
	 .result(alu_output[15]),
	 .prediction(ex_prediction),
	 .save_pc(ex_save_pc),
	 .flush(flush)
	       );
   
		    
   
   
   assign write_data_to_reg = wb_mem_to_reg ? data_ram_output : alu_output;  

   assign address = ex_immediate_en ? ex_extended_addr : ex_rdData2;  

   assign pc_plus2 =  ex_pc + 8'h2;
 
   assign jump_pc = skip_next ? pc_plus2 : ex_pc;
   
   assign skip_next = alu_output[15] & ex_skip_en;

   assign branch_pc = ex_branch_en ? ex_immediate_addr : jump_pc;

   assign if_pc = pc_add;

   assign if_prediction = prediction;

   assign if_save_pc = save_pc;

   assign halt = ex_halt_en;

   assign branch_inst = ex_skip_en || ex_branch_en;



   always @(posedge clk or posedge reset) begin
      if (reset)
	halt_s <= 1'b0;
      else
	halt_s <= ex_halt_en;
   end

   assign halt_rise = ex_halt_en & ~halt_s;

    always @(posedge clk)
     if(reset)
       begin
	  branch_inst_cnt <= 0;
	  flush_cnt <= 0;
	  skip_en_cnt <= 0;
	  skip_flush_cnt <= 0;
       end
     else if (branch_inst && flush)
       begin
	  branch_inst_cnt <= branch_inst_cnt +1;
	  flush_cnt <= flush_cnt +1;
	  if (ex_skip_en)
	    begin
	       skip_en_cnt <= skip_en_cnt +1;
	       skip_flush_cnt <=  skip_flush_cnt +1;	       
	    end
       end
     else if (branch_inst && !flush)
           begin
	  branch_inst_cnt <= branch_inst_cnt +1;
	  if (ex_skip_en)
	    skip_en_cnt <= skip_en_cnt +1;
       end
 
   
 endmodule

