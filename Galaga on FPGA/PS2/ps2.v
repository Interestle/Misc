/*
 * Module for PS/2 keyboard input.
 *
 * For every valid key press, the module will output a byte of data corresponding to the keys being pressed.
 * The current scheme from MSB to LSB is:
 *
 * [7   6    5     4     3      2   1 0]
 * [UP DOWN LEFT RIGHT SELECT START B A]
 * [UP DOWN LEFT RIGHT SHIFT  ENTER X Z]
 *
 * THIS CAN BE CHANGED VERY EASILY FOR OUR PROJECT! Treat it as an initial attempt.
 *
 * inputs:
 *		clk: 50 MHz clock
 *    rst: posedge reset
 *    ps2_clk: ps2 clock (PIN_AD7)
 *    ps2_data: ps2 data (PIN_AE7)
 *
 * outputs:
 *    data_out: byte representing the buttons pressed. If multiple buttons 
 *					 are held, they should light up simultaneously.
 *
 *    (Perhaps consider an output signal representing a change of input?)
 *
 *	last updated: November 7, 2020
 */
module ps2(clk, rst, ps2_clk, ps2_data, data_out);

input clk;
input rst;

input ps2_clk;
input ps2_data;

output reg [7:0] data_out;
reg break_code;

wire [7:0] byte_data;
wire full_byte_received;

// Keyboard input module.
ps2_in keyboard (.clk(clk), 
					  .rst(rst), 
					  .wait_for_data(1'b1), 
					  .start_receiving_data(1'b0), 
					  .ps2_clk(ps2_clk), 
					  .ps2_data(ps2_data), 
					  .byte_data(byte_data), 
					  .full_byte_received(full_byte_received)
					  );

	always@(posedge clk)
	begin
		data_out <= data_out;
		break_code <= break_code;
		
		if(rst) 
		begin
			data_out <= 8'b0;
			break_code <= 1'b0;
		end
		else if(full_byte_received)
		begin
			case(byte_data)
			8'h12: // shift (select)
				begin
					data_out[3] <= ~break_code;
					break_code <= 1'b0;
				end
			8'h1A: // Z (A)
				begin
					data_out[0] <= ~break_code;
					break_code <= 1'b0;
				end
			8'h22: // X (B)
				begin
					data_out[1] <= ~break_code;
					break_code <= 1'b0;
				end
			8'h5A: // Enter (start)
				begin
					data_out[2] <= ~break_code;
					break_code <= 1'b0;
				end
				
			8'h6B: // Left (E0 comes before, but we can forget it)
				begin
					data_out[5] <= ~break_code; 
					break_code <= 1'b0;
				end		
			8'h72: // Down (E0 comes before, but we can forget it)
				begin
					data_out[6] <= ~break_code;
					break_code <= 1'b0;
				end
			8'h74: // Right (E0 comes before, but we can forget it)
				begin
					data_out[4] <= ~break_code;
					break_code <= 1'b0;
				end	
			8'h75: // Up (E0 comes before, but we can forget it)
				begin
					data_out[7] <= ~break_code;
					break_code <= 1'b0;
				end	
			8'hF0: // Break code.
				begin
					data_out <= data_out;
					break_code <= 1'b1;
				end
			default: // Everything else
				begin
					data_out <= data_out;
					break_code <= 1'b0;
				end		
			endcase
		end
	end
	
endmodule
