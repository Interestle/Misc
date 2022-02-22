`timescale 1ns / 1ns

module DAC_tb;

	reg clk;
	reg rst;
	reg [9:0] DAC_in;
	
	wire DAC_out;
	
	DAC #(.WIDTH(10)) uut (.clk(clk), .rst(rst), .DAC_in(DAC_in), .DAC_out(DAC_out));
	
	integer i;
	integer frac;
	
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		DAC_in = 10'b0;
		
		#10;
		rst = 1'b0;
		#10;
		
		// Calculate fractional values of DAC_in. There's probably a way to determine
		// the average on-time of the signal, such as capturing its state over the course
		// of the waiting period, and comparing it to what it should be, but I'm 
		// not sure how I would do that in Verilog at the moment.
		// So instead, here's a way to visually inspect the signal and see that it turns
		// on and off rapidly enough over a course of a signal. The amount of times 
		// DAC_out should be on should be proportional to (DAC_in / 1024).
				
		frac = 8;
		for(i = frac; i >= 0; i = i - 1) begin
			DAC_in = (10'h3FF * i) / frac; 
			#1000;			
		end
		
		$stop;	
	end

	always 
		#5 clk = ~clk;

endmodule
