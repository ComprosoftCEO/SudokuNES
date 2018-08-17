;---------------------Random Numbers--------------------------
;  Compact library created by Bryan McClain
;     Uses 4 simple, linear shift feedback registers to create randomness



;Simple macro for getting random numbers, using LSFR
;
;	Parameters:
;		1) The seed
;		2) The XOR value
GetRandom:	.macro
	LDA \1
	BEQ .DoEor\@
	ASL A
	BEQ .NoEor\@
	BCC .NoEor\@
.DoEor\@:
	EOR \2
.NoEor\@:
	STA \1
	RTS
	.endm


;Use entropy to call a random function from a list
;   (Slower, but more secure)
;
;   Parameters:
;	   1) The type of entropy to use (Normal or Plus)
;	   2) The AND for the total number of items (1,3,7,F,etc.)
;	   3) The lookup table to use
CallRandomFunction:	.macro
	TXA		
	PHA			;Store X on stack
	JSR \1		;Get from random entropy source

	AND \2		;Number of bits to cancel out
	ASL A		;Multiply by 2 for lookup table
	TAX
	LDA \3, X
	STA TempLow
	LDA (\3)+1, X
	STA TempHigh

	PLA			;Get X back from STack
	TAX
	JMP [TempLow]
	.endm


;Calculate the entropy for a given RAM space
;
;  Parameters
;	 1) The starting memory address
;	 2) The number of bytes to count
EntropySource:	.macro
	TXA
	PHA			;Store X/Y on the stack
	TYA
	PHA

	LDX \2	  	   ;Loop through the counter, backwards to save a byte
	LDA Entropy	  ;Use the current entropy
.eloop\@
	EOR \1, x		;Get the random number
	TAY
	LDA HashLookup, y		;Get the hash value
	DEX
	CPX #$00
	BNE .eloop\@				;Continue until zero 
	
	STA Entropy

	PLA
	TAY		;Return the values from the stack
	PLA
	TAX
	LDA Entropy
	RTS
	.endm


;Update the XOR value using entropy and a
;   lookup table
;
;   Parameters:
;	  1) The XOR to modify
UpdateXOR:	.macro
	TXA
	PHA
	JSR ComputeEntropy		;Grab the new XOR using entropy
	AND #$0F				;Only 16 possible XOR values
	TAX
	LDA XorVals, X
	STA \1					;Store in corresponding spot
	PLA
	TAX
	RTS
	.endm


;Four PRNG random number pickers
;   (fast, but insecure)
;
; X/Y = Unchanged
; A   = New random number
GetRandom1:			
	GetRandom Random1_Seed,Random1_XOR
GetRandom2:			
	GetRandom Random2_Seed,Random2_XOR
GetRandom3:			
	GetRandom Random3_Seed,Random3_XOR
GetRandom4:			
	GetRandom Random4_Seed,Random4_XOR	


;Use entropy to update XOR numbers
;  
;  X/Y = Unchanged
;  A   = (Garbage Data)
RandomXOR1:
	UpdateXOR Random1_XOR
RandomXOR2:
	UpdateXOR Random2_XOR
RandomXOR3:
	UpdateXOR Random3_XOR
RandomXOR4:
	UpdateXOR Random4_XOR


;Get a better random integer using the entropy
;   (Slower, but more secure)
;
; X/Y = Unchanged
; A   = New random number
GetTrueRandom:
	CallRandomFunction ComputeEntropy, #$03, RandomJumpTable


;Get a really good random integer using the full entropy
;   (Slower, but more secure)
;
; X/Y = Unchanged
; A   = New random number
GetTrueRandom_Plus:
	CallRandomFunction ComputeEntropy_Plus, #$03, RandomJumpTable




;Mix up a random XOR value
;
; X/Y = Unchanged
; A   = (Garbage)
MixXOR:
	TXA
	PHA
	LDX #$08	;Run the whole loop 8 times
.outerLoop
	JSR .MixXORInside
	DEX
	;RTS
	BNE .outerLoop

	PLA
	TAX		;Get the X back
	RTS

.MixXORInside
	CallRandomFunction ComputeEntropy_Plus, #$03, XORJumpTable


;Mix up random seed values
;
; X/Y = Unchanged
; A   = (Garbage)
MixSeed:
	TXA
	PHA
	LDX #$08	;Run the whole loop 8 times
.loop
	JSR .MixSeedInside
	;DEX
	;BNE .loop

	PLA
	TAX		;Get the X back
	RTS

.MixSeedInside
	CallRandomFunction ComputeEntropy_Plus, #$03, RandomJumpTable




;Hash all of the random numbers to get
;   the default entropy
;
; X/Y = Unchanged
; A   = New entropy source
ComputeEntropy:
	EntropySource Random1_Seed-1, #$08


;Hash the entire zero page of RAM
;   to get a better entropy
;
; X/Y = Unchanged
; A   = New entropy source
ComputeEntropy_Plus:
	EntropySource $00, #$80





;Produce a random value from Min <= X <= Max
;
; Parameters
;	RandMin = Minimul value
;	RandMax = Maximul Value
;
; Results:
; 	A = Random number
RandInt:

	LDA RandMin
	CMP RandMax			;Test if they are equal
	BEQ .Return

	LDA RandMax
	SEC
	SBC RandMin
	CLC
	ADC #$01			;Find the difference between the range
	STA RandDif
	JSR GetTrueRandom
	
.TestMax
	CMP RandMax		;Subtract until over top of Max
	BCC .TestMin
	SEC
	SBC RandDif
	JMP .TestMax
.TestMin
	CMP RandMin		;Add until greater than Min
	BCS .Return
	CLC
	ADC RandDif
	JMP .TestMin	
	
.Return
	RTS 
	
;Produce a random value from 0 to Max
;
; Parameters
;	RandMax = Maximul Value
;
; Results:
; 	A = Random number
Rand0N:
	LDA RandMax
	BEQ .exit		;If input is 0, exit function
	STA ModValue
	
	JSR GetTrueRandom	;Acc = random number
	JSR Mod				;Find the remainder
.exit
	RTS 



;Lookup table for the entropy hash function
;   0 - 255 shuffled in a random order

HashLookup:
  .db 98,  6, 85,150, 36, 23,112,164,135,207,169,  5, 26, 64,165,219
  .db 61, 20, 68, 89,130, 63, 52,102, 24,229,132,245, 80,216,195,115
  .db 90,168,156,203,177,120,  2,190,188,  7,100,185,174,243,162, 10
  .db 237, 18,253,225,  8,208,172,244,255,126,101, 79,145,235,228,121
  .db 123,251, 67,250,161,  0,107, 97,241,111,181, 82,249, 33, 69, 55
  .db 59,153, 29,  9,213,167, 84, 93, 30, 46, 94, 75,151,114, 73,222
  .db 197, 96,210, 45, 16,227,248,202, 51,152,252,125, 81,206,215,186
  .db 39,158,178,187,131,136,  1, 49, 50, 17,141, 91, 47,129, 60, 99
  .db 154, 35, 86,171,105, 34, 38,200,147, 58, 77,118,173,246, 76,254
  .db 133,232,196,144,198,124, 53,  4,108, 74,223,234,134,230,157,139
  .db 189,205,199,128,176, 19,211,236,127,192,231, 70,233, 88,146, 44
  .db 183,201, 22, 83, 13,214,116,109,159, 32, 95,226,140,220, 57, 12
  .db 221, 31,209,182,143, 92,149,184,148, 62,113, 65, 37, 27,106,166
  .db 3, 14,204, 72, 21, 41, 56, 66, 28,193, 40,217, 25, 54,179,117
  .db 238, 87,240,155,180,170,242,212,191,163, 78,218,137,194,175,110
  .db 43,119,224, 71,122,142, 42,160,104, 48,247,103, 15, 11,138,239


;All possible XORs for the Linear Shift Feedback Register
XorVals:
  .db $1d,$2b,$2d,$4d,$5f,$63,$65,$69,$71,$87,$8d,$a9,$c3,$cf,$e7,$f5


;Jump table for which PRNG to use
RandomJumpTable:
  .dw GetRandom1, GetRandom2, GetRandom3, GetRandom4

;Jump table for XOR updating code
XORJumpTable:
  .dw RandomXOR1, RandomXOR2, RandomXOR3, RandomXOR4
