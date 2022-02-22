/*
 * Current working ALU design for Group 9 
 * Group Members: Ben Leaptrot, Christian Giauque, Colton Watson, Nathan Hummel
 *
 * Last updated: September 10, 2020
 *
 * Inputs: 
 *   A: Source A - 16-bit value
 *   B: Source B - 16-bit value
 *   Opcode: 8-bit opcode designating which instruction to execute
 *
 * Outputs:
 *   C: 16-bit value from opcode computation.
 *   Flags: 5-bit array of bits. 1=true, 0=false. The bits currently correspond to these flags:
 *            Carry flag    (carry/borrow from addition/subtraction) - Bit 4
 *            Low flag      (unsigned integer comparison)            - Bit 3
 *            Overflow flag (signed arithmetic overflow)             - Bit 2
 *            Zero flag     (operation left zero in the output)      - Bit 1
 *            Negative flag (signed integer comparison)              - Bit 0
 *
 * Notes:
 *   Baseline Operations not currently implemented (I'm not sure how yet): LOAD, STOR, BCOND, JCOND, JAL
 *   Are logical/arithmetic shifts incorporated correctly?
 *     arithmetic shifts aren't baseline, but are highly recommneded (they are implemented)
 *   Double check the shift operations to make sure they're right
 * 
 */
module alu(A, B, C, Opcode, Flags);

	input  [15:0] A, B;
	input  [7:0]  Opcode;
	
	output reg [15:0] C;
	output reg [4:0]  Flags;
	
	reg C_in;
	
	// Flags
	parameter carry_f    = 3'd4;
	parameter low_f      = 3'd3;
	parameter overflow_f = 3'd2;
	parameter zero_f     = 3'd1;
	parameter negative_f = 3'd0;

	// Opcodes
	// * = Baseline instructions
	// Obviously delete unused/unneeded parameters.
	parameter ADD  = 8'b00000101; // *
	parameter ADDI = 8'b0101xxxx; // *
	parameter ADDU = 8'b00000110;
	parameter ADDUI= 8'b0110xxxx;
	parameter ADDC = 8'b00000111;
	parameter ADDCI= 8'b0111xxxx;
	
	parameter SUB  = 8'b00001001; // *
	parameter SUBI = 8'b1001xxxx; // *
	parameter SUBC = 8'b00001010;
	parameter SUBCI= 8'b1010xxxx; 
	parameter CMP  = 8'b00001011; // *
	parameter CMPI = 8'b1011xxxx; // *
	parameter AND  = 8'b00000001; // *
	parameter ANDI = 8'b0001xxxx; // *
	parameter OR   = 8'b00000010; // *
	parameter ORI  = 8'b0010xxxx; // *
	parameter XOR  = 8'b00000011; // *
	parameter XORI = 8'b0011xxxx; // *
	parameter MOV  = 8'b00001101; // *
	parameter MOVI = 8'b1101xxxx; // *
	parameter LSH  = 8'b10000100; // *
	parameter LSHI = 8'b1000000x; // x -> sign (0=left, 2's comp)
	parameter ASHU = 8'b10000110;
	parameter ASHUI= 8'b1000001x; // x -> sign (0=left, 2's comp)
	parameter LUI  = 8'b1111xxxx; // *
	
	/* Yet currently implented in ALU */
	parameter LOAD = 8'b01000000; // *
	parameter STOR = 8'b01000100; // *
	parameter Bcond= 8'b1100xxxx; // *
	parameter Jcond= 8'b01001100; // *
	parameter JAL  = 8'b01001000; // *
	
	
	always@(*)
	begin		
		C_in = Flags[carry_f]; // Capture Carry in for ADDC(I)/SUBC(I)
		C = 16'b0;
		Flags = 5'b0;
		
		casex (Opcode)
		ADD: // Integer addition
			begin
			{Flags[carry_f], C} = A + B; 
			
			// Overflow occurs when (pos) + (pos) = neg
			//             and when (neg) + (neg) = pos
			if((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])) 
				Flags[overflow_f] = 1'b1;
			end
			
		ADDI: // Integer addition immediate
			begin
			// B is thought of as being an 8-bit number, sign-extend it.
			{Flags[carry_f], C} = A + {{8{B[7]}} , B[7:0]};
			
			if((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])) 
				Flags[overflow_f] = 1'b1;
			end
			
		ADDU: // Unsigned integer addition. PSR flags are not affected (Not Baseline)
			begin
			C = A + B;
			end
			
		ADDUI: // Unsigned integer addition with immediate. PSR flags are not affected (Not Baseline)
			begin
			C = A + {8'b0, B[7:0]};
			end
			
		ADDC: // Integer addition with carry (Not Baseline)
			begin
			{Flags[carry_f], C} = A + B + C_in;
			
			if((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])) 
				Flags[overflow_f] = 1'b1;
			end
			
		ADDCI: // Integer addition, sign-extended immediate with Carry in (Not Baseline)
			begin
			{Flags[carry_f], C} = A + {{8{B[7]}} , B[7:0]} + C_in;
			
			if((~A[15] & ~B[15] & C[15]) | (A[15] & B[15] & ~C[15])) 
				Flags[overflow_f] = 1'b1;
			end
			
		SUB: // Integer subtraction
			begin
			{Flags[carry_f], C} = A - B;
			
			if(A == B) 
				Flags[zero_f] = 1'b1; 
			
			// Overflow occurs when (pos) - (neg) = neg
			//             and when (neg) - (pos) = pos
			if((A[15] & ~B[15] & ~C[15]) | (~A[15] & B[15] & C[15])) 
				Flags[overflow_f] = 1'b1;
			
			if(A < B)
				Flags[low_f] = 1'b1;
				
			if($signed(A) < $signed(B))
				Flags[negative_f] = 1'b1;			
			end
			
		SUBI: // Integer subtraction immediate
			begin
			{Flags[carry_f], C} = A - {{8{B[7]}} , B[7:0]};
			
			if(A == B) 
				Flags[zero_f] = 1'b1; 
			
			if((A[15] & ~B[7] & ~C[15]) | (~A[15] & B[7] & C[15])) 
				Flags[overflow_f] = 1'b1;
			
			if(A < B)
				Flags[low_f] = 1'b1;
			
			if($signed(A) < $signed(B))
				Flags[negative_f] = 1'b1;			
			end
			
		SUBC: // Integer subtraction with carry (Not Baseline)
			begin
			{Flags[carry_f], C} = A - (B + C_in);
			
			if(A == B) 
				Flags[zero_f] = 1'b1; 
			
			// Overflow occurs when (pos) - (neg) = neg
			//             and when (neg) - (pos) = pos
			if((A[15] & ~B[15] & ~C[15]) | (~A[15] & B[15] & C[15])) 
				Flags[overflow_f] = 1'b1;
			
			if(A < B)
				Flags[low_f] = 1'b1;
				
			if($signed(A) < $signed(B))
				Flags[negative_f] = 1'b1;	
			end
			
		SUBCI: // Integer subtraction with sign-extended immediate and carry (Not Baseline)
			begin
			{Flags[carry_f], C} = A - ({{8{B[7]}} , B[7:0]} + C_in);
			
			if(A == B) 
				Flags[zero_f] = 1'b1; 
			
			if((A[15] & ~B[7] & ~C[15]) | (~A[15] & B[7] & C[15])) 
				Flags[overflow_f] = 1'b1;
			
			if(A < B)
				Flags[low_f] = 1'b1;
			
			if($signed(A) < $signed(B))
				Flags[negative_f] = 1'b1;
			end
		
		CMP: // Comparison. Affects PSR.Z, PSR.N, PSR.L.
			begin
			
			if(A == B)
				Flags[zero_f] = 1'b1;
				
			if($signed(A) < $signed(B))
				Flags[negative_f] = 1'b1;
				
			if(A < B)
				Flags[low_f] = 1'b1;
			
			end
			
		CMPI: // Comparison immediate
			begin 
			if(A == {{8{B[7]}} , B[7:0]})
				Flags[zero_f] = 1'b1;
				
			if($signed(A) < $signed({{8{B[7]}} , B[7:0]}))
				Flags[negative_f] = 1'b1;
				
			if(A < {8'b0 , B[7:0]})
				Flags[low_f] = 1'b1;
			end

		AND: // Logical AND
			begin
			C = A & B;
			
			if(C == 16'b0)
				Flags[zero_f] = 1'b1;
			end
			
		ANDI: // Logical AND with zero-extended immediate
			begin
			C = A & {8'b0 , B[7:0]}; 
			
			if(C == 16'b0)
				Flags[zero_f] = 1'b1;
			end
			
		OR: // Logical OR
			begin
			C = A | B; 
			end
			
		ORI: // Logical OR with zero-extended immediate
			begin
			C = A | {8'b0 , B[7:0]}; 
			end
			
		XOR: // Logical XOR 
			begin
			C = A ^ B;
			end
			
		XORI: // Logical XOR with zero-extended immediate
			begin
			C = A ^ {8'b0 , B[7:0]}; 
			end
			
		MOV: // Move
			begin
			C = A; 
			end
			
		MOVI: // Move with zero-extended immediate 
			begin
			C = {8'b0 , B[7:0]}; 
			end
			
		LSH: // Logical Shift
			begin
			if(B[15] == 1'b0) 
				C = A << B; // left shift
			else
				C = A >> (-B); // right shift 
			end			
			
		LSHI: // Logical shift immediate
			begin
			if(Opcode[0] == 1'b0) // Opcode[0] designates left/right shift
				C = A << {1'b0, B[3:0]}; // Only care about ImmLo
			else
				begin
				C = A >> {1'b0, B[3:0]}; // Hacky way to force B to be positive
				end
			end
			
		ASHU: // Arithmetic Shift
			begin
			if(B[15] == 1'b0)
				C = $signed(A) <<< B; 
			else
				C = $signed(A) >>> (-B);
			end
			
		ASHUI: // Arithmetic Shift immediate
			begin
			if(Opcode[0] == 1'b0)
				C = $signed(A) <<< {1'b0, B[3:0]};
			else
				C = $signed(A) >>> {1'b0, B[3:0]}; 
			end
			
		LUI: // Load upper immediate (Move, but fill MSB with immediate)
			begin
			C = {B [7:0], 8'b0}; 
			end
			
		LOAD: // Load from Memory
			begin
			C = B;
			end
//    STOR: // Store in memory
//			begin
//			// mem[A] = B; 
//			C = B;
//			end

//
//		Bcond: // Conditional Branch
//			begin
//				case(A[3:0])
//				4'h0: //BEQ
//				begin
//					if(Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]}; // Displace LABEL
//					else
//						C = PC + 1'b1; // Make PC go to next instruction
//				end
//				4'h1: // BNE
//				begin
//					if(!Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1; 
//				end
//				4'h2: // BCS
//				begin
//					if(Flags[carry_f])
//						C = PC - {{8{B[7]}} , B[7:0]}; 
//					else
//						C = PC + 1'b1; 
//				end
//				4'h3: // BCC
//				begin
//					if(!Flags[carry_f])
//						C = PC - {{8{B[7]}} , B[7:0]}; 
//					else
//						C = PC + 1'b1; 
//				end
//				4'h4: // BHI
//				begin
//					if(Flags[low_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'h5: // BLS (Less than or same)
//				begin
//					if(!Flags[low_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'h6: // BGT
//				begin
//					if(Flags[negative_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'h7: // BLE (Less than or equal)
//				begin
//					if(!Flags[negative_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'h8: // BFS
//				begin
//					if(Flags[overflow_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'h9: // BFC
//				begin
//					if(!Flags[overflow_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hA: // BLO
//				begin
//					if(!Flags[low_f] && !Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hB: // BHS (Higher than or same as)
//				begin
//						if(Flags[low_f] && Flags[zero_flag])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hC: // BLT (Less than)
//				begin
//					if(Flags[negative_f] && Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hD: // BGE (greater than or equal)
//				begin
//					if(Flags[negative_f] || Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hE: // BUC
//				begin
//					C = PC - {{8{B[7]}} , B[7:0]};
//				end
//				4'hF: // Never Jump	
//				begin
//					C = PC;
//				end
//
//				endcase
//			end
//
//		Jcond: // Conditional Jump
//			begin
//			case(A[3:0])
//				4'h0: //JEQ
//				begin
//					if(Flags[zero_f])
//						C = B; // Displace LABEL
//					else
//						C = PC + 1'b1; // Make PC go to next instruction
//				end
//				4'h1: // JNE
//				begin
//					if(!Flags[zero_f])
//						C = B;
//					else
//						C = PC + 1'b1; 
//				end
//				4'h2: // JCS
//				begin
//					if(Flags[carry_f])
//						C = PC - B; 
//					else
//						C = PC + 1'b1; 
//				end
//				4'h3: // JCC
//				begin
//					if(!Flags[carry_f])
//						C = B; 
//					else
//						C = PC + 1'b1; 
//				end
//				4'h4: // JHI
//				begin
//					if(Flags[low_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'h5: // JLS (Less than or same)
//				begin
//					if(!Flags[low_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'h6: // JGT
//				begin
//					if(Flags[negative_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'h7: // JLE (Less than or equal)
//				begin
//					if(!Flags[negative_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'h8: // JFS
//				begin
//					if(Flags[overflow_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'h9: // JFC
//				begin
//					if(!Flags[overflow_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'hA: // JLO
//				begin
//					if(!Flags[low_f] && !Flags[zero_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'hB: // BHS (Higher than or same as)
//				begin
//					if(Flags[low_f] && Flags[zero_flag])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'hC: // JLT (Less than)
//				begin
//					if(Flags[negative_f] && Flags[zero_f])
//						C = PC - {{8{B[7]}} , B[7:0]};
//					else
//						C = PC + 1'b1;
//				end
//				4'hD: // JGE (greater than or equal)
//				begin
//					if(Flags[negative_f] || Flags[zero_f])
//						C = B;
//					else
//						C = PC + 1'b1;
//				end
//				4'hE: // JUC (JMP)
//				begin
//					C = B;
//				end
//				4'hF: // Never Jump	
//				begin
//					C = PC;
//				end
//
//				endcase			
//			end
			
//		JAL: // Jump and Link
//			begin
//			// Rlink = PC + offset
//			// C = PC + 4
//			
//			C = B + offset?
//			end
		
		default:
			begin
				C = A;
				Flags = Flags;
			end		
		endcase
		
	end
	
endmodule
