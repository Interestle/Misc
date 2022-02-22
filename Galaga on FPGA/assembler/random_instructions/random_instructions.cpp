#include <iostream> // read/write to terminal, not currently used.
#include <fstream>  // read/write to files
#include <stdio.h>  // printf()
#include <stdlib.h> // rand() function lives here.
#include <time.h>   // how to get decent seed for rand.


int main()
{
  // Number of instruction to write.
  int max_instructions = 6;

  // Set seed. Change 'time(0)' to get particular seed.
  srand(time(0)); 

  // File to write to.
  // The w means it writes to the file and will erase everything if the file
  // already existed. Use caution if you liked a particular file. 
  FILE *fptr = fopen("random_instr.hex", "w");

  // Basic error-checking on file.
  if(fptr == NULL)
  {
    printf("Could not open file...\n");
    return 0;
  }


  // Array that holds instructions. The numbers are arbitrary, but based on the
  // ISA.pdf that was given to us. So far 0 -> ADD, 1 -> ADDI, and so on.
  // Right now, do 6 known instructions and 4 random instructions
  // ADD, ADD, ADDI, SUBI, AND, SUB, then random instructions
  int instr_array[max_instructions];

  // Now to do the random part of the instruction. Comment this block out to
  // default the value to 0 for basic ADD operations.
  // Alternatively, to do all random instructions, make i = 0.
  for(int i = 0; i < max_instructions; i++)
  {
    instr_array[i] = rand() % 5;
  }


  // The fun thing about $readmemh is that it allows for comments and will
  // skip over that when writing it to the FPGA. 
  fprintf(fptr, "// Writing %i instructions!\n", max_instructions);


  // Now to actually create those instructions. If nothing beyond this point
  // makes sense, that's okay. 
  for(int i = 0; i < max_instructions; i++)
  {
    short instruction = 0; // Shorts are 16-bits.
   
    int Rsrc = 0;
    int Rdest = 0;
    int Imm = 0;

    // Case statement in C/C++. Really similar to case statement in Verilog.
    // You can do something based on an array, or just make the data random.
    switch(instr_array[i]) {
      case 0: // ADD
        // Create the instruction.
        // Uses special bit-wise operations to extract specific values.
        instruction = rand() & 0x0F0F;
        instruction = instruction | 0x0050;

        // Extract the interesting bits.
        Rsrc = instruction & 0x000F;
        Rdest = (instruction & 0x0F00) >> 8;
        
        // Print it out.
        fprintf(fptr,"%04hX // ADD R%i, R%i\n", instruction, Rsrc, Rdest); 
        break;

      case 1: // ADDI
        instruction = rand() & 0x0FFF;
        instruction = instruction | 0x5000;

        Imm = instruction & 0x00FF;
        Rdest = (instruction & 0x0F00) >> 8;
        fprintf(fptr,"%04hX // ADDI 0x%02X, R%i\n", instruction, Imm, Rdest);
        break;

      case 2: // SUB
        instruction = rand() & 0x0F0F;
        instruction = instruction | 0x0090;

        Rsrc = instruction & 0x000F;
        Rdest = (instruction & 0x0F00) >> 8;
        
        fprintf(fptr,"%04hX // SUB R%i, R%i\n", instruction, Rsrc, Rdest); 
        break;

      case 3: // SUBI
        instruction = rand() & 0x0FFF;
        instruction = instruction | 0x9000;

        Imm = instruction & 0x00FF;
        Rdest = (instruction & 0x0F00) >> 8;
      
        fprintf(fptr,"%04hX // SUBI 0x%02X, R%i\n", instruction, Imm, Rdest);
        break;

      case 4: // AND 
        instruction = rand() & 0x0F0F;
        instruction = instruction | 0x0010;

        Rsrc = instruction & 0x000F;
        Rdest = (instruction & 0x0F00) >> 8;
        
        fprintf(fptr,"%04hX // AND R%i, R%i\n", instruction, Rsrc, Rdest); 
        break;
      // case 5: ... just adjust upper bound on rand_instruction.
    }     
  }
  
  
}

