`timescale 1ns/1ns

module tb();
  
   reg clk;
   reg reset;
   reg halt_rise;

   integer percent;
   integer percent2;
   integer count1;
   integer count2;
   integer count3;
   integer count4;
   
   
   
   top top(.clk(clk),
	   .reset(reset),
	   .halt_rise(halt_rise)
	   );
   
always #10 clk = !clk;
   
   initial
     begin
	reset = 1;
	clk = 0;
	$readmemh("data_ram.txt",top.data_ram.mem); // 50 Numbers
//	$readmemh("instructions.txt",top.inst_ram.mem); // Bubble Sort
	$readmemh("þþinstructions_SelectionSort.txt",top.inst_ram.mem); // Selection Sort
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
	//  $display("With History of : %d", HISTORY);
	  reset = 1;	  
	  #100;
	  $stop;
       end
   end // always @ (posedge clk)   always @(posedge clk)


   assign count1 = top.branch_inst_cnt;
   assign count2 = top.flush_cnt;
   assign count3 = top.skip_en_cnt;
   assign count4 = top.skip_flush_cnt;
   assign percent = (count1 - count2) * 100 / count1;
   assign percent2 = (count3 - count4) * 100 / count3;
   
endmodule // tb

