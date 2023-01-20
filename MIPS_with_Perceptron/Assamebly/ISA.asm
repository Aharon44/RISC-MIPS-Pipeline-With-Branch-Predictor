
0:	NOPE	// Do Nothing
A:	HLT 	// Halt the CPU
	
	//// Memory-reference ////


1:	LOADI 	// Load memory word to Register (immediate)
2:	LOAD	// Load memory word to Register
3:	STORE 	// Store contents from register to memory	
9:	BUN	// Branch unconditionally


	//// Register-reference ////


4:	INC 	// Increment Register A (Reg A = Reg A +1)
5:	DEC	// Decrement Register A	(Reg A = Reg A -1)
6:	SNIB 	// Skip Next Instruction if Bigger (Reg A > Reg B)
7:	SNIE	// Skip Next Instruction if Equel (Reg A == Reg B)
8:	MOVE	// Move Memory word from Register A to Register B (Reg A -> Reg B)
B:	SNIEV 	// Skip Next Instruction if Reg A is Even (Reg A %2 ==0)
C:	SNIOD	// Skip Next Instruction if Reg A is Odd  (Reg A %2 ==1)
D:	RESET	// Reset Register A to '0' (Reg A = 0)
E:	ADD	// ADD Register B to Register A (Reg A = Reg A + Reg B)
F:	SNIZ	// Skip Next Instruction if Reg A is zero (Reg A == 0)




	
	
