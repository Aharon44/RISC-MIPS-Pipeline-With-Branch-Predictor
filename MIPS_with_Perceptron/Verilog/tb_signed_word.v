`timescale 1ns/1ns

module tb();
   
   parameter HISTORY = 4;
   reg clk;
   reg delayed_clk;
   
   reg reset;
   reg halt_rise;
   integer percent;
   integer percent2;
   integer count1;
   integer count2;
   integer count3;
   integer count4;
   
   
   wire    data_mem_clk;
   reg [21:0] ww [31:0];
   reg [21:0] delayed_ww [31:0];
   reg [21:0] last_ww[31:0];
   reg [21:0] lut_weight [31:0] ;
   reg [3:0]  ghr;
   reg [4:0]  pc;
   reg [4:0]  pc_ex;
   reg 	      predict;
   reg 	      outcome;
   reg 	      branch_pc;
   reg 	      branch_pc_d;
   reg 	      branch_inst;
   
   
   reg 	      flush;
   
   reg 	      learn_predict;
   reg 	      learn_outcome;
   
   

   integer    jj;
   integer    ii;
   integer    y;

   reg [39:0] cycles;
   reg [7:0]  counter;
   
   
   
   event      error_event;

   
   /*
    * 
   always @(posedge clk) begin 
      for (ii = 0; ii < 32; ii = ii + 1)
	begin
//	   last_ww[ii] <= ww[ii];
	   delayed_ww[ii] <= ww[ii];
	   last_ww[ii] <= delayed_ww[ii];
	   if (delayed_ww[ii] != top.branch_predictor.lut_weight.register[ii])
	     begin
		$display("Mismatch: error in cycle %d: delayed ww[%d] = %h lut[%d] = %h",
			 cycles,ii,delayed_ww[ii],ii,top.branch_predictor.lut_weight.register[ii]);
		$display("last ww[%d] = %h",
			 ii,last_ww[ii]);                                                     	
	//	-> error_event;
		counter = counter + 1;
		$display("Curent time = %t", $time);
		if(counter == 100)
		  $stop;
		
		if (predict != top.branch_predictor.prediction)
		  $display("Mismatch: error in cycle %d: predict = %h prediction = %h; y=%d & total sum = %h",
			   cycles,predict,top.branch_predictor.prediction,y,top.branch_predictor.perceptron_prediction.total_sum);
	     end // if (delayed_ww[ii] != top.branch_predictor.lut_weight.register[ii])
	end // for (ii = 0; ii < 32; ii = ii + 1)
	end // always @ (posedge clk)
    */
   

   // Prediction //
   
   always @(posedge clk) begin
      if (reset)begin
	 // for (ii = 0; ii < 32; ii = ii + 1)
	 //  ww[ii] <= -1;
	 //	 ghr <= 0;
	 counter <=0;
	 cycles <= 0;
	 predict <= 0;
      end
      else if(branch_pc)begin
	 cycles <= cycles +1;
	 y = 0;
	 for(jj = 0; jj < 4 ; jj = jj + 1) ///??????
	   begin
	      if(ghr[jj] == 1)
		y = y + ww[pc][jj*4+:4] ;
	      else
		y = y - ww[pc][jj*4+:4];
	   end
	 if(learn_outcome == 1)
	   y = y + ww[pc][21:15] ;
	 else
	   y = y - ww[pc][21:15];
	 predict = (y >= 0);
      end
      else
	cycles <= cycles +1;
   end // always @ (posedge clk)

   
   // Lreaning //
   
     
   always @(posedge clk) begin
      if (reset)begin
	 for (ii = 0; ii < 32; ii = ii + 1)
           ww[ii] =  22'h3fffff;
      end
      else if(branch_inst && (learn_outcome != learn_predict))begin
	 for(jj = 0; jj < 5 ; jj = jj + 1)
	   begin
	      if(jj != 4)
		begin
		   if(ghr[jj] == 1)
		     begin
			if(ww[pc_ex][4*jj +: 4] == 15)
			  ww[pc_ex][4*jj +: 4] =  ww[pc_ex][4*jj +: 4] ;
			
			else if(ww[pc_ex][4*jj +: 4] != 15)
			  ww[pc_ex][4*jj +: 4] =  ww[pc_ex][4*jj +: 4] + 1 ;
		//	$display("ghr[%d] = %b",
	//			 jj,ghr[jj]);
		//	$display("Curent time = %t", $time);	
		     end
		   else if (ghr[jj] == 0)
		     begin
			if(ww[pc_ex][4*jj +: 4] == 0)
			  ww[pc_ex][4*jj +: 4] =  ww[pc_ex][4*jj +: 4] ;
			
			else if(ww[pc_ex][4*jj +: 4] != 0)
			  ww[pc_ex][4*jj +: 4] =  ww[pc_ex][4*jj +: 4] - 1 ;
	
		//	ww[pc_ex][4*jj +: 4] = ww[pc_ex][4*jj +: 4] = 0 ? ww[pc_ex][4*jj +: 4] : ww[pc_ex][4*jj +: 4] - 1 ;
			//	ww[pc_ex][4*jj +: 4]=  ww[pc_ex][4*jj +: 4] - 1 ;  
///			$display("ghr[%d] = %b",
//				 jj,ghr[jj]);
		     end // else: !if(ghr[jj] == 1)
		end // if (jj != 4)
	      else if(jj== 4)
		begin
		   if(learn_outcome == 1)
		     begin
			if(ww[pc_ex][4*jj +: 6] == 31)
			  ww[pc_ex][4*jj +: 6] = ww[pc_ex][4*jj +: 6];
			else if(ww[pc_ex][4*jj +: 6] != 31)
			  ww[pc_ex][4*jj +: 6]=  ww[pc_ex][4*jj +: 6] + 1 ;
	//		$display("outcome = %b",
	//			 outcome);
		     end
		   else if(learn_outcome == 0)
		     begin
			if(ww[pc_ex][4*jj +: 6] == 6'h20)
			  ww[pc_ex][4*jj +: 6] = ww[pc_ex][4*jj +: 6];
			else if(ww[pc_ex][4*jj +: 6] != 6'h20)
			  ww[pc_ex][4*jj +: 6] = ww[pc_ex][4*jj +: 6] - 1 ;   
		//	$display("outcome = %b",
		//		 outcome);
		     end
		end // if (jj== 4)
	   end // for (jj = 0; jj < 5 ; jj = jj + 1)
      end // if (branch_inst && (learn_outcome != learn_predict))
   end // always @ (posedge clk)
   
   
   
		   
   
				    

   assign pc = top.branch_predictor.lut_pc_addr;

   assign pc_ex =top.branch_predictor.lut_pc_idex_addr;

   assign data_mem_clk = top.data_ram.clk;

   assign outcome = top.true_result;

   assign branch_pc = top.branch_predictor.select_pc.branch_inst_from_lut;

   assign branch_inst = top.branch_predictor.branch_inst;

   assign ghr = top.branch_predictor.learn_perceptron.global_history_reg;
  
   assign branch_pc_d = top.branch_predictor.branch_inst_d;

   assign flush = top.flusher.flush;

   assign learn_outcome = top.branch_predictor.learn_perceptron.result;
   
   assign learn_predict = top.branch_predictor.learn_perceptron.prediction;
   



   top#(.HISTORY(HISTORY))
   top(.clk(clk),
       .reset(reset),
       .halt_rise(halt_rise)
       );

 

   always #10 clk = !clk;
 //  always delayed_clk = #10 clk;
   
   initial
     begin
	//	cycles = 0;
	reset = 1;
	clk = 0;
	$readmemh("data_ram.txt",top.data_ram.mem);
//	$readmemh("new_inst_test.txt",top.inst_ram.mem); // Loop Even and Odd
//	$readmemh("inst_test.txt",top.inst_ram.mem); // simple loop
	$readmemh("instructions.txt",top.inst_ram.mem); // Bubble sort
	repeat(20)
	  @(posedge clk);
	
	reset = 0;
	
     end // initial begin

   
   always @(posedge clk)begin
     if(halt_rise)
       begin
	  $writememh("data_ram_after_sorting.txt",top.data_ram.mem);
	  $display("Success rate of all Branch instructions : %d", percent);
	  $display("Success rate of only Skip instructions : %d", percent2);
	  $display("With History of : %d", HISTORY);
	  reset = 1;	  
	  #100;
	  $stop;
       end
   end // always @ (posedge clk)
   
   assign count1 = top.branch_inst_cnt;
   assign count2 = top.flush_cnt;
   assign count3 = top.skip_en_cnt;
   assign count4 = top.skip_flush_cnt;
   assign percent = (count1 - count2) * 100 / count1;
   assign percent2 = (count3 - count4) * 100 / count3;

   
   
   
	parameter NOPE = 0;
	parameter LOADI = 1;
	parameter LOAD = 2;
	parameter STORE = 3;
	parameter INC = 4;
	parameter DEC = 5;
	parameter SNIB = 6;
	parameter SNIE = 7;
	parameter MOVE = 8;
	parameter BUN = 9;
	parameter HALT = 10;
	parameter SNIEV = 11;
	parameter SNIOD = 12;

        parameter SW_HISTORY = 4;      //                                  A
   

 	reg [15:0] sw_regs [8];
   
   reg [1023:0][31:0][SW_HISTORY*4+5:0] sw_ww;

	integer sw_inst_count;
        integer sw_inst_count2;
        integer sw_skip_cnt;
        integer sw_branch_cnt;
	integer sw_percent; 
        integer sw_percent2;
   

        reg [SW_HISTORY-1:0] sw_history;       
        reg [SW_HISTORY-1:0] new_sw_history;
   
        reg [7:0]  sw_pc;
        reg [7:0]  sw_pc_inc;
	reg [3:0]  sw_opcode;
	reg[15:0]  sw_inst;
	integer sw_ii;
        integer sw_jj;
	reg [15:0] sw_data_mem [65536];
        reg [15:0] sw_inst_mem [256];	
        reg 		   sw_result;
        reg 		   sw_predict;
        reg 		   sw_branch_pc;
   
        reg 		     sw_result_d;
        reg 		     sw_result_2d;

        integer 		   x;
        integer 		   x1;
   integer 			   x2;
   
   
   
	reg [2:0] sw_reg_idx1;
	reg [2:0] sw_reg_idx2;
	reg [7:0] sw_imm;
	reg [15:0] sw_imm_ex;
    
    integer logfile;

   assign sw_percent = (sw_branch_cnt - sw_inst_count) * 100 / sw_branch_cnt;
   assign sw_percent2 = (sw_skip_cnt - sw_inst_count2) * 100 / sw_skip_cnt;

	initial begin
        logfile = $fopen("logfile.log","w");
           sw_pc = 0;
	   sw_pc_inc = 0;
	   sw_history = 0;
	   new_sw_history = 0;
	   sw_inst_count = 0;
	   sw_inst_count2 = 0;
	   sw_skip_cnt = 0;
	   sw_branch_cnt = 0;
	   sw_result = 0;
	   sw_predict = 0;
	   sw_branch_pc = 0;
	   sw_opcode = 0;
		for (sw_ii = 0; sw_ii < 8; sw_ii = sw_ii + 1)
			sw_regs[sw_ii] = 'hdead;
		$readmemh("data_ram.txt", sw_data_mem);
	   	$readmemh("instructions.txt",sw_inst_mem); // Bubble sort
	        sw_ww[0] = -1;	   
           #1;
		while (!(sw_opcode == HALT)) begin
		      #1	
	      
		   sw_pc = sw_pc + sw_pc_inc;
		   sw_inst = sw_inst_mem[sw_pc];
		   sw_reg_idx1 = sw_inst[11-:3];		   
		   sw_reg_idx2 = sw_inst[8-:3];		   
		   sw_imm = sw_inst[0+:8];		   
		   sw_imm_ex = {{8{sw_imm[7]}}, sw_imm};		   
		   sw_opcode = sw_inst[15:12];
		   sw_history = new_sw_history;
		   


		   /*
		    * $fwrite(logfile,
        //    $display(
            "PC = %h, inst = %h, inst_mem[pc] = %h, opcode = %h %s, \t Reg number %1d, Data before %4h, Data insert to reg %4h\n", sw_pc, sw_inst, sw_inst_mem[sw_pc], sw_opcode,
                (sw_opcode == NOPE ? "NOP" :
                sw_opcode == LOADI ? "LOADI":
                sw_opcode == LOAD ? "LOAD" :
                sw_opcode == STORE ? "STORE" :
                sw_opcode == INC ? "INC" :
                sw_opcode == DEC ? "DEC" :
                sw_opcode == SNIB ? "SNIB" :
                sw_opcode == SNIE ? "SNIE" :
                sw_opcode == SNIEV ? "SNIEV" :
                sw_opcode == SNIOD ? "SNIOD" :
                sw_opcode == MOVE ? "MOVE" :
                sw_opcode == BUN ? "BUN" :
                sw_opcode == HALT ? "HALT" :
                 "ERROR"), 
		    (sw_opcode == LOADI || LOAD || INC || DEC ||MOVE ? sw_reg_idx1 : 
		     sw_opcode == STORE ? sw_reg_idx2:
		     0),
 		    (sw_opcode == LOADI || LOAD || INC || DEC || MOVE ? sw_regs[sw_reg_idx1]: 		     
		     0),
		    (sw_opcode == LOADI ? sw_data_mem[sw_imm_ex]  :
		     sw_opcode == LOAD ? sw_data_mem[sw_regs[sw_reg_idx2]]:
		     sw_opcode == MOVE ? sw_regs[sw_reg_idx2]:
		     sw_opcode == INC ?	sw_regs[sw_reg_idx1] + 1:
		     sw_opcode == DEC ? sw_regs[sw_reg_idx1] - 1:
		     0)
		     );
		    */
			case (sw_opcode)
			        NOPE: begin
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				LOADI: begin
					sw_regs[sw_reg_idx1] = sw_data_mem[sw_imm_ex];
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				LOAD: begin
			       	   sw_regs[sw_reg_idx1] = sw_data_mem[sw_regs[sw_reg_idx2]];
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				STORE: begin
					sw_data_mem[sw_regs[sw_reg_idx2]] = sw_regs[sw_reg_idx1];
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				INC: begin
					sw_regs[sw_reg_idx1] = sw_regs[sw_reg_idx1] + 1;
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				DEC: begin
					sw_regs[sw_reg_idx1] = sw_regs[sw_reg_idx1] - 1;
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				MOVE: begin
					sw_regs[sw_reg_idx1] = sw_regs[sw_reg_idx2];
					//sw_pc = sw_pc + 1;
					sw_pc_inc = 1;
				        sw_result = 0;
				end
				SNIB: begin
					if (sw_regs[sw_reg_idx1] > sw_regs[sw_reg_idx2]) begin
						//sw_pc = sw_pc + 2;
						sw_pc_inc = 2;
					         sw_result = 1;
					end
				   
					else begin
						//sw_pc = sw_pc + 1;
						sw_pc_inc = 1;
					        sw_result = 0;
					   end
				end
				SNIE: begin
					if (sw_regs[sw_reg_idx1] == sw_regs[sw_reg_idx2])
					  begin
						//sw_pc = sw_pc + 2;
						sw_pc_inc = 2;
					         sw_result = 1;
					end
					else begin
						//sw_pc = sw_pc + 1;
						sw_pc_inc = 1;
					         sw_result = 0;
					   end
				end
				SNIEV: begin
					if (sw_regs[sw_reg_idx1] % 2 == 0) begin
						//sw_pc = sw_pc + 2;
						sw_pc_inc = 2;
					         sw_result = 1;
					end
					else begin
						//sw_pc = sw_pc + 1;
						sw_pc_inc = 1;
					        sw_result = 0;
					   end
				end
				SNIOD: begin
					if (sw_regs[sw_reg_idx1] % 2 == 1) begin
						//sw_pc = sw_pc + 2;
						sw_pc_inc = 2;
					        sw_result = 1;
					end
					else begin
						//sw_pc = sw_pc + 1;
						sw_pc_inc = 1;
				                sw_result = 0;
					   end
				end
				BUN: begin
					sw_pc_inc = sw_imm - sw_pc;
				         sw_result = 1;
				end
				default: begin
				   sw_result = 0;
				end
			endcase // case (sw_opcode)
	   
		   

		   case (sw_opcode) 
		     SNIB, SNIE, SNIEV, SNIOD, BUN: begin
			sw_branch_cnt = sw_branch_cnt + 1;
			sw_branch_pc = 1'b1;

			/// PREDICTION ///
			for(jj = 0; jj < SW_HISTORY ; jj = jj + 1) 
			  
			  begin
			     if(sw_history[jj] == 1)
			       x = x + sw_ww[sw_inst_count][sw_pc][jj*4+:4] ;
			     else
			       x = x - sw_ww[sw_inst_count][sw_pc][jj*4+:4] ;
			  end


	       		x1 ={{27{sw_ww[sw_inst_count][sw_pc][21]}},sw_ww[sw_inst_count][sw_pc][5+:SW_HISTORY*4]};
			x2=x1+x;
			if(sw_opcode == BUN)
			  sw_predict = 1'b1;
			
			   else 
			sw_predict = (x2 >= 0);			
			new_sw_history =  {new_sw_history[SW_HISTORY-2:0], sw_result};                     
			
		     end // case: SNIB, SNIE, SNIEV, SNIOD, BUN
		 
		     default: begin
			sw_branch_cnt = sw_branch_cnt;
			sw_branch_pc = 1'b0;
		     end	       
		   endcase // case (sw_opcode)
		    	   
   


			
			/// LEARNING ///
		   case (sw_opcode) 
		     SNIB, SNIE, SNIEV, SNIOD, BUN: begin
                    	if(sw_result != sw_predict) begin
			   sw_inst_count = sw_inst_count + 1;
			   sw_ww[sw_inst_count] = sw_ww[sw_inst_count - 1];
			   for(jj = 0; jj < SW_HISTORY+1 ; jj = jj + 1)                                            
			     begin
				if(jj != SW_HISTORY)                                                            
				  begin
				     if(sw_history[jj] == 1)
				       begin
					  if(sw_ww[sw_inst_count][sw_pc][4*jj +: 4] == 7)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 4] =  sw_ww[sw_inst_count][sw_pc][4*jj +: 4] ;
					  
					  else if(sw_ww[sw_inst_count][sw_pc][4*jj +: 4] != 7)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 4] =  sw_ww[sw_inst_count][sw_pc][4*jj +: 4] + 1 ;	
				       end
				     else if (sw_history[jj] == 0)
				       begin
					  if(sw_ww[sw_inst_count][sw_pc][4*jj +: 4] == 4'h8)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 4] =  sw_ww[sw_inst_count][sw_pc][4*jj +: 4] ;
					  
					  else if(sw_ww[sw_inst_count][sw_pc][4*jj +: 4] != 4'h8)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 4] =  sw_ww[sw_inst_count][sw_pc][4*jj +: 4] - 1 ;
				       end
				  end // if (jj != SW_HISTORY)
				else if(jj== SW_HISTORY)                            
				  begin
				     if(sw_result == 1)
				       begin
					  if(sw_ww[sw_inst_count][sw_pc][4*jj +: 6] == 31)                                           ///BIAS
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 6] = sw_ww[sw_inst_count][sw_pc][4*jj +: 6];
					  else if(sw_ww[sw_inst_count][sw_pc][4*jj +: 6] != 31)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 6]=  sw_ww[sw_inst_count][sw_pc][4*jj +: 6] + 1 ;
				       end
				     else if(sw_result == 0)
				       begin
					  if(sw_ww[sw_inst_count][sw_pc][4*jj +: 6] == 6'h20)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 6] = sw_ww[sw_inst_count][sw_pc][4*jj +: 6];
					  else if(sw_ww[sw_inst_count][sw_pc][4*jj +: 6] != 6'h20)
					    sw_ww[sw_inst_count][sw_pc][4*jj +: 6] = sw_ww[sw_inst_count][sw_pc][4*jj +: 6] - 1 ;        // END BIAS
				       end
				  end // if (jj== SW_HISTORY)
				end          
	 		end // if (sw_result != sw_predict)
			     
			     end // case: SNIB, SNIE, SNIEV, SNIOD, BUN
		     default: begin
			sw_predict = 0;
		     end
			   	     
		   endcase // case (sw_opcode)

		   case(sw_opcode)
		     SNIB, SNIE, SNIEV, SNIOD: begin
			sw_skip_cnt = sw_skip_cnt + 1;
			if(sw_result != sw_predict) 
			  sw_inst_count2 = sw_inst_count2 + 1;
		     end
		     default: begin
			sw_skip_cnt = sw_skip_cnt ;
			sw_inst_count2 = sw_inst_count2;
		     end
		   endcase // case (sw_opocde)
		   
		   
		end // while (!(sw_opcode == HALT))
	   

	  	$display("Curent time = %t", $time);
	   $display("Success rate of all Branch instructions (sw) : %d", sw_percent);
	   $display("Success rate of skip instructions (sw) : %d", sw_percent2);

	end // initial begin
   
   
   always @(sw_pc) begin
      	 x = 0;
        
   end // always @ (sw_pc)

endmodule // tb

