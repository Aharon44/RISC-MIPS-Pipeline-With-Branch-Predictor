
0:	NOPE	// Do Nothing
A:	HLT 	// Halt the CPU
	
	//// Memory-reference ////


1:	LOADI 	// Load memory word to Register (immediate)
2:	LOAD	// Load memory word to Register
3:	STORE 	// Store contents from register to memory	
9:	BUN	// Branch unconditionally


	//// Register-reference ////


4:	INC 	// Incerment Register
5:	DEC	// Decrement Register	
6:	SNIB 	// Skip Next Instruction if Bigger (Reg A > Reg B)
7:	SNIE	// Skip Next Instruction if Equel
8:	MOVE	// Move Memory word from Register A to Register B
