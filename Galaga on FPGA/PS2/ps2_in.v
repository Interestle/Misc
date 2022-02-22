/*
 * PS/2 keyboard implementation.
 * Figuring out how it worked came from:
 * http://www.burtonsys.com/ps2_chapweske.htm
 * http://www.eecg.toronto.edu/~jayar/ece241_08F/AudioVideoCores/ps2/ps2.html
 * Could be made better, but this seems to work, and is modular if we wanted to add more to it.
 *
 */
module ps2_in(clk, rst, wait_for_data, start_receiving_data, ps2_clk, ps2_data, byte_data, full_byte_received);
	input clk;
	input rst;
	
	input wait_for_data;
	input start_receiving_data;
	
	input ps2_clk;
	input ps2_data;
	
	output reg [7:0] byte_data;
	output reg full_byte_received;
	
	// States for the FSM.
	parameter [2:0] idle             = 3'b000;
	parameter [2:0] waiting          = 3'b001;
	parameter [2:0] receiving_data   = 3'b010;
	parameter [2:0] receiving_parity = 3'b011;
	parameter [2:0] receiving_stop   = 3'b100;

	// Registers.
	reg [2:0] count;
	reg [7:0] data_shift;
	
	reg [2:0] next_state;
	reg [2:0] current_state;
	
	// Detect falling/rising edge of PS/2 clock
	reg [1:0] ps2_clk_count;
	always @(posedge clk) ps2_clk_count <= {ps2_clk_count[0], ps2_clk};
	wire ps2_clk_posedge = (ps2_clk_count[1:0] == 2'b01); 
	// Only the posedge is currently used in this design, but if the negedge is
   //	desired, uncomment the next line.
	//wire ps2_clk_negedge = (ps2_clk_count[1:0] == 2'b10);
	
	
	// FSM
	always @(posedge clk) begin
		if(rst) current_state <= idle;
		else    current_state <= next_state;
	end
	
	
	always @(*) begin
		
		next_state <= idle;
		
		case(current_state)
			idle: // In idle, the keyboard shouldn't be expecting to receive anything or send anything.
				begin
					if((wait_for_data) && (~full_byte_received))
						next_state <= waiting;
					else if((start_receiving_data) && (~full_byte_received))
						next_state <= receiving_data;
					else
						next_state <= idle;					
				end
			waiting: // Waiting for the data to go low, signaling that data will be coming in soon.
				begin
					if((~ps2_data) && (ps2_clk_posedge))
						next_state <= receiving_data;
					else if (~wait_for_data)
						next_state <= idle;
					else
						next_state <= waiting;
				end
			receiving_data: // receive all 8 bits of data.
				begin
					if((count == 3'b111) && (ps2_clk_posedge))
						next_state <= receiving_parity;
					else
						next_state <= receiving_data;
				end
			receiving_parity:
				begin
					if(ps2_clk_posedge) // Wait for the clk to go high.
						next_state <= receiving_stop;
					else
						next_state <= receiving_parity;
				end
			receiving_stop:
				begin
					if(ps2_clk_posedge) // Wait for the clk to go high.
						next_state <= idle;
					else
						next_state <= receiving_stop;
				end
			default:
				begin
					next_state <= idle; // Shouldn't happen.
				end
		endcase
	end
	
	// All of the sequential logic.
	
	// Control the counter for receiving data.
	always @(posedge clk) begin
		if(rst) begin
			count <= 3'b000;
		end
		else if((current_state == receiving_data) && (ps2_clk_posedge)) begin
			count <= count + 3'b001;
		end
		else if(current_state != receiving_data) begin
			count <= 3'b000;
		end
	end
	

	// Control the shift register.
	always @(posedge clk) begin
		if (rst) begin
			data_shift <= 8'b0;
		end
		else if((current_state == receiving_data) && (ps2_clk_posedge)) begin 
			// Data is latched on the positive edge, LSB first.
			data_shift <= {ps2_data, data_shift[7:1]};
		end
	end
	
	// Control the byte to output
	always @(posedge clk) begin
		if (rst) begin
			byte_data <= 8'b0;
		end
		else if(current_state == receiving_stop) begin
			byte_data <= data_shift;
		end
	end
	
	// Control full_byte_receive
	always @(posedge clk) begin
		if (rst) begin
			full_byte_received <= 1'b0;
		end
		else if((current_state == receiving_stop) && (ps2_clk_posedge)) begin
			full_byte_received <= 1'b1;
		end
		else begin
			full_byte_received <= 1'b0;
		end
	end
endmodule
