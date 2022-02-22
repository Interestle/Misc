`timescale 1ns / 1ps

/*
 * Colton's ALU tests
 * Last updated: September 7, 2020
 *
 */

module alutest_colton;

	// Inputs
	reg [15:0] A;
	reg [15:0] B;
	reg [7:0] Opcode;
	
	// Outputs
	wire [15:0] C;
	wire [4:0] Flags;

	integer i;
		
	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.C(C), 
		.Opcode(Opcode), 
		.Flags(Flags)
	);

	initial 
		begin
		
		$monitor("A: 0x%0h (%0d), B: 0x%0h (%0d), C: 0x%0h (%0d), Flags[4:0]: %b, time:%0d", A, $signed(A), B, $signed(B), C, $signed(C), Flags[4:0], $time );

		
		// Initialize Inputs
		A = 0;
		B = 0;
		Opcode = 8'b00000101; // ADD
		
		
		$display("\nTesting ADD instruction\n");
		
		#10;
	
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = $random % 65536;
		end
		
		#100;
		$display("\nTesting ADDI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b0101xxxx; // ADDI
		
		#10;
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = {$random} % 256;
		end
		
		
		
		// Try to get overflow flag.
		// It seems to work, uncomment to see full output
		/*
		A = 16'hFFFF; // -1
		
		for( i = 0; i< 257; i = i+1)
		begin
		  B = i;
		  #10;
		end
		
		#10	
		
		A = 16'h8000; // -32768
		
		for( i = 0; i< 257; i = i+1)
		begin
		  B = i;
		  #10;
		end
		
		#10		
		
		A = 16'h7FFF; // 32767
		
		for( i = 0; i< 257; i = i+1)
		begin
		  B = i;
		  #10;
		end
		
		*/
		
		#100;
		$display("\nTesting ADDU instruction\n");
	
		A = 0;
		B = 0;
		Opcode = 8'b00000110; // ADDU
		#10;
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = $random % 65536;
		end
		
		#100;
		$display("\nTesting ADDUI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b0110xxxx; // ADDUI
		#10;
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = {$random} % 256;
		end
		
		#100;
		$display("\nTesting ADDC instrtruction\n");
		
	
		A = 0;
		B = 0;
		Opcode = 8'b00000111; // ADDC
		#10;
		
		A = 16'hFFFF;
		B = 16'hFFFF;
		#10;
		
		A = 16'b0;
		B = 16'b0;
		
		#10;  //C should now be 1.
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = $random % 65536;
		end
		

		#100;
		$display("\nTesting ADDCI instruction\n");
		
			
		A = 0;
		B = 0;
		Opcode = 8'b0111xxxx; // ADDCI
		#10;
		
		
		A = 16'hFFFF;
		B = 16'd10;
		
		#10;
		
		A = 16'b0;
		B = 16'b0;
		
		#10;
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			#10;
			A = $random % 65536;
			B = {$random} % 256;
		end
		
		
		#100;
		$display("\nTesting SUB instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00001001; // SUB
		
		#10;
		
		// 0 - 1 = -1, set borrow flag
		A = 0;
		B = 1;
		
		#10;		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting SUBI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b1001xxxx; // SUBI
		
		#10;
		
		// 0 - 1 = -1, set borrow flag
		A = 0;
		B = 1;
		
		#10;	
	
		// Test overflow
		A = 16'h7FFF; // +32767
		B = -1;
		
		#10
		
	
		A = 16'h8000; // -32768
		B = 1;
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		
		#100;
		$display("\nTesting SUBC instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00001010; // SUBC
		
		#10;
		A = 16'h0001;
		B = 16'hFFFF;
		
		#10;
		
		A = 16'b0;
		B = 16'b0;
		
		#10;
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting SUBCI instruction\n");
		
		A = 0;
		B = 0;
		Opcode = 8'b1010xxxx; // SUBCI
		
		#10;
		A = 16'h0001;
		B = 16'hFFFF;
		
		#10;
		
		A = 16'b0;
		B = 16'b0;
		
		#10;		
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		#100;
		$display("\nTesting CMP instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00001011; // CMP
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting CMPI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b1011xxxx; // CMPI
		
		#10
		
		// Low flag
		A = 10;
		B = 20;
		
		#10
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		#100;
		$display("\nTesting AND instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00000001; // AND
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting ANDI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b0001xxxx; // ANDI
		
		#10
		
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		
		#100;
		$display("\nTesting OR instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00000010; // OR
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting ORI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b0010xxxx; // ORI
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		#100;
		$display("\nTesting XOR instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00000011; // XOR
		
		#10
		
			//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting XORI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b0011xxxx; // XORI
		
		#10
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		#100;
		$display("\nTesting MOV instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b00001101; // MOV
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 65536;
			#10;
		end
		
		#100;
		$display("\nTesting MOVI instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b1101xxxx; // MOVI
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		#100;
		$display("\nTesting LUI instruction\n");
				
		A = 0;
		B = 0;
		Opcode = 8'b1111xxxx; // LUI
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = {$random} % 256;
			#10;
		end
		
		
		#100;
		$display("\nTesting LSH instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b10000100; // LSH
		#10;
		
		
		// Left shift
		// C should be 0x5656
		A = 16'h2b2b;
		B = 1;
		#10;
		
		// Right shift
		// C should be 0x1595
		A = 16'h2b2b;
		B = -1;
		#10;
		
		// Left shift
		// C should be 0x5554
		A = 16'hAAAA;
		B = 1;
		#10;
		
		// Right shift
		// C should be 0x5555
		A = 16'hAAAA;
		B = -1;
		#10;
		
		
		// Zero shift?
		// Effectively a move: C = A
		A = 16'hFFFF;
		B = 0;
		#10;
		
		// General multiplication
		A = 4;
		B = 5;
		#10;
		
		// General division
		A = 100;
		B = -2;
		#10;
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B[15:4] = -({$random} % 2); // will give either all 1's or 0's.
			B[3:0] = {$random} % 16;
			#10;
		end
		
		
		#100;
		$display("\nTesting LSHI instruction\n");
		
		
		A = 0;
		B = 0;
		// Opcode = 8'b1000000x // LSHI
		// Opcode = 8'b10000000 // left shift
		// Opcode = 8'b10000001 // 2'comp
		Opcode = 8'b10000000; 		
		#10;
		
		//Left shift:
		Opcode = 8'b10000000;
		A = 8;
		B = 2;
		// C = 32
		#10;
		
		//Right shift:
		Opcode = 8'b10000001;
		A = 16'hFFFF;
		B = 16'h000F;
		#10;
		
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			Opcode[0] = {$random} % 2;
			$display("Shift: %0b", Opcode[0]);
			A = $random % 65536;
			B = ({$random} % 3) + 1'b1; // Small shifts, force shifts
			#10;
			
		end
		
		for( i = 0; i< 10; i = i + 1)
		begin
			Opcode[0] = $random % 2;
			$display("Shift: %0b", Opcode[0]);
			A = $random % 65536;
			B = {$random} % 16; // Last nybble will be from 0000 to 1111
			#10;
			
		end
		
		#100;
		$display("\nTesting ASHU instruction\n");
		
		
		A = 0;
		B = 0;
		Opcode = 8'b10000110;
		#10;
		
		A = 16'h8000;
		B = 16'h3;
		#10;
		
		A = 16'h8000;
		B = -(16'd3);
		#10;
		
		// Shift -1 arithmetically right
		A = 16'hFFFF; // -1
		B = 16'hFFFF;
		#10; 
		
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			A = $random % 65536;
			B = $random % 16;
			#10;
		end
		
		#100;
		$display("\nTesting ASHUI instruction\n");
			
		// b1000001x
		A = 0;
		B = 0;
		Opcode = 8'b10000010; // Shift left
		#10;
		
		A = 16'h8000;
		B = 16'h3;
		#10;
		
		Opcode = 8'b10000011; // Shift right
		A = 16'h8000;
		B = (16'd3);
		#10;
		
		A = 16'hEE0E;
		B = 16'h0001; // Shift right by one. C should be 0xf707
		
		#10;
		Opcode = 8'b10000010;				
				
		//Random simulation
		for( i = 0; i< 10; i = i + 1)
		begin
			Opcode[0] = $random % 2;
			$display("Shift: %0b", Opcode[0]);
			A = $random % 65536;
			B = ({$random} % 3) + 1'b1; // Small shifts, force something interesting
			#10;
			
		end
		
		for( i = 0; i< 10; i = i + 1)
		begin
			Opcode[0] = $random % 2;
			$display("Shift: %0b", Opcode[0]);
			A = $random % 65536;
			B = {$random} % 16;
			#10;
			
		end
		
		$finish(2);
		

	end
      
endmodule

