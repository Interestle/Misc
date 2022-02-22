/*
 * Simple Demo for ALU Module for Group 9
 * Group Members: Ben Leaptrot, Christian Giauque, Colton Watson, Nathan Hummel
 *
 * Last updated: September 10, 2020
 *
 *
 * It's a simple finite-state machine that moves between states with each 
 * button press.
 *
 * For the states input_a and input_b, the switches control all 16 bits.
 * Its currently set so that the lowest bits 3-0 are controlled by SW3 - SW0
 * Then each nybble greater than that is controlled by each switch.
 *
 * For the state input_op, switches 7 - 0 controls the opcode bits to use for the 
 * operation.
 *
 * Finally, output_c just displays whatever C was in the alu on the 7-segment hexes
 *
 * Pressing the continue button advances each state.
 * Reset obviously resets everything.
 *
 *
 */

module alu_demo(clk, reset, cont, sw, hex1, hex2, hex3, hex4, hex5, flag_leds);
	input clk;   // 50 MHz clk
	input reset; // KEY0
	input cont;  // Continue (advance state) - KEY3
	input [9:0] sw; // switches 9-0
	
	output [0:6] hex1, hex2, hex3, hex4, hex5; // HEX5, HEX3, HEX2, HEX1, HEX0
	output [4:0] flag_leds; // LEDR4-0
	
	reg [15:0] A, prev_A;
	reg [15:0] B, prev_B;
	reg [7:0] Opcode, prev_Op;
	
	wire [15:0] C;
	
	reg [1:0] prev_cont;
	reg cont_flag;
	
	reg [3:0] h1, h2, h3, h4, h5;
	
	
	// ALU and 7-segment displays
	alu aludem (.A(A), .B(B), .C(C),	.Opcode(Opcode), .Flags(flag_leds));
	hex2seg hx1 (.hex(h1), .seg(hex1));
	hex2seg hx2 (.hex(h2), .seg(hex2));
	hex2seg hx3 (.hex(h3), .seg(hex3));
	hex2seg hx4 (.hex(h4), .seg(hex4));
	hex2seg hx5 (.hex(h5), .seg(hex5));
	
	
	// FSM
	reg [3:0] current_state;
	reg [3:0] next_state;
	
	parameter reset_s  = 3'd0;
	parameter input_a  = 3'd1;
	parameter input_b  = 3'd2;
	parameter input_op = 3'd3;
	parameter output_c = 3'd4;
	
	
	always@(posedge clk)
	begin		
		prev_A <= A;
		prev_B <= B;
		prev_Op <= Opcode;
		prev_cont <= {prev_cont[0], cont};
		
		// Only advance state on one button press
		if(!cont_flag && prev_cont == 2'b10)
			cont_flag <= 1'b1;
		else
			cont_flag <= 1'b0;
	
		
		case(current_state)
			reset_s:
			begin				
				A <= 16'b0;
				B <= 16'b0;
				Opcode <= 8'b0;
				
				h1 <= 4'h8; // HEX 5
				h2 <= 4'hb; // HEX 3
				h3 <= 4'he; // HEX 2
				h4 <= 4'he; // HEX 1
				h5 <= 4'hf; // HEX 0
			end
			
			input_a:
			begin
				A <= {sw[9], sw[8], sw[7], sw[6], sw[5], sw[5], sw[5], sw[5], sw[4], sw[4], sw[4], sw[4], sw[3], sw[2], sw[1], sw[0]};
				B <= prev_B;
				Opcode <= prev_Op;
				
				h1 <= 4'ha; // disp A					
				h2 <= A[15:12];
				h3 <= A[11:8];
				h4 <= A[7:4];
				h5 <= A[3:0];
			end
				
			input_b:
			begin					
				A <= prev_A;
				B <= {sw[9], sw[8], sw[7], sw[6], sw[5], sw[5], sw[5], sw[5], sw[4], sw[4], sw[4], sw[4], sw[3], sw[2], sw[1], sw[0]};
				Opcode <= prev_Op;
				
				h1 <= 4'hb; // disp B					
				h2 <= B[15:12];
				h3 <= B[11:8];
				h4 <= B[7:4];
				h5 <= B[3:0];				
			end
				
			input_op:
			begin
				A <= prev_A;
				B <= prev_B;
				Opcode <= {sw[7], sw[6], sw[5], sw[4], sw[3], sw[2], sw[1], sw[0]}; 
				
				h1 <= 4'h0; // disp 0 (I'm too lazy to make an o)	
				h2 <= 4'b0000;
				h3 <= 4'b0000;
				h4 <= Opcode[7:4];
				h5 <= Opcode[3:0];
			end
			
			output_c:
			begin
				A <= prev_A;
				B <= prev_B;
				Opcode <= prev_Op;
					
				h1 <= 4'hc; // disp C
				h2 <= C[15:12];
				h3 <= C[11:8];
				h4 <= C[7:4];
				h5 <= C[3:0];
			end
			
			default:
			begin				
				A <= 16'd0;
				B <= 16'd0;
				Opcode <= 8'b0;
				
				h1 <= 4'hc;
				h2 <= 4'hb;
				h3 <= 4'he;
				h4 <= 4'he;
				h5 <= 4'hf;
			end
			
		endcase
	end
	
	
	/* FSM CONTROL */
	always@(posedge clk)
	begin
		if (!reset) current_state <= reset_s;
		else			current_state <= next_state;	
	end
	
	always@(*)
	begin
		next_state = current_state;
		
		case(current_state)
			reset_s:
			begin
				next_state = input_a;
			end
			
			input_a:
			begin
				if(cont_flag) next_state = input_b;
			end
			
			input_b:
			begin
				if(cont_flag) next_state = input_op;
			end
			
			input_op:
			begin
				if(cont_flag) next_state = output_c;
			end
			
			output_c:
			begin
				if(cont_flag) next_state = input_a;
			end
			
			default:
			begin
				next_state = reset_s;
			end		
		endcase
	end
	
	

endmodule
