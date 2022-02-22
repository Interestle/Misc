/*
 * A simple DAC based on the implementation from: https://www.ti.com/lit/an/slyt076/slyt076.pdf?ts=1636807616808&ref_url=https%253A%252F%252Fwww.google.com%252F
 * Uses the sigma-delta calculations and definitions from Figure 3 and discussion in the paper. 
 * The average analog output voltage is equal to (DAC_in/(2^WIDTH)) * voltage
 *
 * parameters:
 * 	WIDTH - the width to use for the DAC, defaults to a 10-bit DAC. 
 * 
 * inputs:
 * 	clk - clock
 * 	rst - positive reset
 * 	DAC_in - WIDTH sized unsigned integer to use for repeated pulse signals
 *
 * outputs: a pulse signal to send to a low pass filter whose average on-time is equal to DAC_in/(2^WIDTH).
 */
module DAC #(parameter WIDTH = 10) (
	input clk, 
	input rst, 
	input [WIDTH-1:0] DAC_in,
	
	output reg DAC_out
	);
		
	reg [(WIDTH-1)+2:0] sigma;

	always@(posedge clk) begin
	
		// Calculate Sigma-delta.			
		sigma   <= sigma + (sigma[(WIDTH-1)+2] ? 2'b11 << WIDTH : {((WIDTH-1)+2){1'b0}}) + DAC_in; 
		DAC_out <= sigma[(WIDTH-1)+2];
			
		if (rst) begin
			sigma   <= 1'b1 << WIDTH; // Set the 2nd MSB to 1 to remove extraneous calculations for smaller initial values.
			DAC_out <= 1'b0;			      
		end
	end	
	
endmodule