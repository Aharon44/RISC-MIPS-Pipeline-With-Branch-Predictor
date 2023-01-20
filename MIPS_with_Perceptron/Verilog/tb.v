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

   integer flush_cnt;
   integer flush_cnt1;
   integer flush_cnt2;


   reg [31:0] counter;
   
   
    always @(posedge clk) begin
      if (reset)begin  
	 counter <=0;
      end
      else begin
	flush_cnt1 <= flush_cnt;
	 flush_cnt2 <= flush_cnt1;
      end    
    end		   
    



   top#(.HISTORY(HISTORY))
   top(.clk(clk),
       .reset(reset),
       .halt_rise(halt_rise)
       );

 

   always #10 clk = !clk;
   
   initial
     begin
	reset = 1;
	clk = 0;
	$readmemh("data_ram.txt",top.data_ram.mem); // 50 Numbers
//	$readmemh("data_ram_1000.txt",top.data_ram.mem);  // 1000 Numbers
//	$readmemh("new_inst_test.txt",top.inst_ram.mem); // Loop Even and Odd
//	$readmemh("inst_test.txt",top.inst_ram.mem); // simple loop
//	$readmemh("instructions.txt",top.inst_ram.mem); // Bubble sort 8 regs
	$readmemh("instructions_sixteen.txt",top.inst_ram.mem); // Bubble sort 16 regs
//	$readmemh("şşinstructions_SelectionSort.txt",top.inst_ram.mem); // Selection Sort 16 regs
	repeat(50)
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

   

endmodule // tb

