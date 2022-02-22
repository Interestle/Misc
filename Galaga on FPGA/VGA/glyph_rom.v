/*
 * glyph rom for vga_4. 
 * Only has 256 address because it made compilation much faster.
 * For final project, figure out what the max should be.
 * For 16 bits (2^16 addresses), we can squeeze 256 16x16 glyphs. That should be more than 
 * sufficient for us, but will add to the compile time.
 */
module glyph_rom (clk, glyph_addr, glyph_pixel);
	input clk;
	input [15:0] glyph_addr; 
	output reg [23:0] glyph_pixel;
	
	// ADJUST ACCORDING TO THE NUMBER OF PIXELS IN GLYPHS!
	reg [23:0] glyph_rom [0:8191 /*65535*/]; 
	
	// There probably is a way to use relative location, but this is where I held the glyph data.
	initial begin
		$readmemh("glyph.txt", glyph_rom);
	end
	
	always@(posedge clk)	glyph_pixel <= glyph_rom[glyph_addr]; // Don't do negedge, makes picture out of sync.
		
endmodule
