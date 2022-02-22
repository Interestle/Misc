/*
 * Generates addresses for bitgen.
 * outputs a 24-bit color.
 *
 *
 */
module address_generator (clk, vga_blank_n, hcount, vcount, ram_q, ram_addr, pixel_out);
	input clk;
	input vga_blank_n;
	input [9:0] hcount, vcount;
	input [15:0] ram_q;
	output [15:0] ram_addr;
	output [23:0] pixel_out;
	
	parameter VGA_BASE_ADDR = 16'hB000;
	
	wire [9:0] x_pos, y_pos;
	assign x_pos = hcount - 10'd158;
	assign y_pos = vcount;
	
	
	// Find where the current glyph resides
	assign ram_addr = vga_blank_n * ((x_pos >> 2) + ((y_pos >> 2) * 8'hA0) + VGA_BASE_ADDR);
	
	wire [15:0] glyph_addr;
	
	// Get the actual pixel location.
	assign glyph_addr = (x_pos & 16'h3) + ((y_pos & 16'h3) * 16'h4) + ram_q;
	
	glyph_rom glyphs (.clk(clk), .glyph_addr(glyph_addr), .glyph_pixel(pixel_out));
	
	
	
endmodule
