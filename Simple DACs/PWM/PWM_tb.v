`timescale 1ns / 1ns

module PWM_tb;
	reg clk;
	reg rst;
	reg [9:0] PWM_in;
	
	wire PWM_out_up;
	wire PWM_out_down;
	
	PWM #(.COUNT_UP(1)) uut1 (.clk(clk), .rst(rst), .PWM_in(PWM_in), .PWM_out(PWM_out_up));
	PWM #(.COUNT_UP(0)) uut2 (.clk(clk), .rst(rst), .PWM_in(PWM_in), .PWM_out(PWM_out_down));
	
	integer i;
	
	initial begin
		clk = 1'b0;
		rst = 1'b1;
		PWM_in = 10'b0;
		
		#10;		
		rst = 1'b0;		
		#10;
		
		for(i = 0; i < 10; i = i + 1) begin
			PWM_in = 10'h3FF >> i;
			#10000;
		end
		
		$stop;
	
	end
	
	always
		#5 clk = ~clk;

endmodule