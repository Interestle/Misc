/*
 * Here is an alternative DAC design just using PWM. I've designed it in a way 
 * that allows for counting up or counting down based on the parameter chosen.
 *
 * The internal counter does not currently reset itself upon new PWM_in values,
 * so after changing the value, do not expect it to perfectly match what it should, 
 * but the cycle of the PWM will be accurate to its own cycle.
 *
 * Parameters:
 * 	COUNT_UP - Boolean value to determine if PWM should count up or count down.
 *		WIDTH - the width to use for the DAC.
 *
 * inputs:
 * 	clk - clock
 * 	rst - positive reset
 * 	PWM_in - WIDTH sized unsigned integer representing the value to 
 * 				compare to the internal counter.
 * 	
 * outputs: a PWM signal whose width is based on the ratio of PWM_in to the internal counter.
 *
 */
 
module PWM #(parameter COUNT_UP = 1'b1, WIDTH = 10)(
	input clk,
	input rst,
	input [WIDTH-1:0] PWM_in,
	
	output PWM_out
	);

	reg [WIDTH-1:0] count;
	
	always@(posedge clk) begin
		count <= count + 1'b1;
		
		if (rst) count <= {WIDTH-1{1'b0}};
	end
	
	
	assign PWM_out = COUNT_UP ~^ (PWM_in > count);	
endmodule
