/*
 * Fourth attempt VGA bitgen. 
 * Display a few CORRECT glyphs on a 160x120 grid of 4x4 pixel regions.
 * This one is mostly stolen from Kris. This design lets us use any two 
 * 24-bit color values for a foreground and background color.
 *
 *
 */
module bitgen (vga_blank_n, pixel_en, fg_pixel, bg_pixel, rgb);
	input vga_blank_n;
	input pixel_en;
	input [23:0] fg_pixel, bg_pixel;
	
	output reg [23:0] rgb;
	
	always@(*)
		if(vga_blank_n) 
			if(pixel_en) 
				if(fg_pixel == 24'h000000) rgb = bg_pixel;
				else rgb = fg_pixel;
			else rgb = bg_pixel;
		else rgb = 24'h000000;

endmodule
