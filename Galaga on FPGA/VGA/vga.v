module vga (clk, rst, addr_b, q_b, hsync, vsync, vga_blank_n, vga_clk, rgb);
	input clk, rst;
	output [15:0] addr_b;
	input [15:0] q_b;
	output hsync, vsync;
	output vga_blank_n, vga_clk;
	output [23:0] rgb;
	
	/* Control */
	wire [9:0] hcount, vcount;
	
	vga_control control (.clk(clk), 
								.rst(rst),
								.hsync(hsync),
								.vsync(vsync),
								.vga_blank_n(vga_blank_n),
								.vga_clk(vga_clk),
								.hcount(hcount),
								.vcount(vcount)
								);	
								
	/* Generator */
	wire [23:0] pixel_out;
	address_generator addr_gen (.clk(clk), 
										 .vga_blank_n(vga_blank_n), 
										 .hcount(hcount), 
										 .vcount(vcount), 
										 .ram_q(q_b), 
										 .ram_addr(addr_b), 
										 .pixel_out(pixel_out)
										 );
								
	/* bitgen */	
	bitgen bgen (.vga_blank_n(vga_blank_n), 
					  .pixel_en(1'b1),       // Logic due to change.
					  .fg_pixel(pixel_out), 
					  .bg_pixel(24'h000000), // Logic due to change. 
					  .rgb(rgb)
					  );
								
	

endmodule
