;==============================================
;All algorithms associated with generating and
;  solving sudoku puzzles
;==============================================


;Callable Functions:
;--------------------
;	GenerateSudoku
;	DrawSudoku



;Draw the sudoku puzzle to the screen, using the data
;From the Sudoku stack
DrawSudoku:
	LDA SudokuLine
	CMP #81
	BNE .start		;Don't reset anything

	;Reset the starting address
	LDA #$20
	STA PPU_High
	LDA #$00
	STA PPU_Low
	STA SudokuLine
	
.start		;Start the loop
	LDX SudokuLine
	LDY #$00
.loop1
	LDA $2002
	LDA PPU_High
	STA $2006
	LDA PPU_Low
	STA $2006

.loop2
	LDA SudokuPuzzle, X
	BNE .calc
	LDA #$02	;Null tile
	JMP .cont

.calc
	CLC
	ADC #$3B
.cont
	STA $2007
	INX
	INY
	CPY #$09
	BNE .loop2
	JSR NoScroll
	LDY #$00
	
	LDA PPU_Low
	CLC
	ADC #$20
	STA PPU_Low
	BCC .skip
	INC PPU_High

.skip
	STX SudokuLine
	RTS
	;CPX #81
	;BNE .loop1
	;RTS

	
	
	
CopyDummyData:
	LDX #$00
.loop
	LDA DummyData, X
	STA SudokuPuzzle, X
	INX
	CPX #81
	BNE .loop
	RTS
	
	


GenerateSudoku:
	
	;How to generate a Sudoku Puzzle:
	;================================
	;	1 - Fill in the diagonal 3x3 grids the the numbers 1 to 9
	;	2 - Use a randomized depth-first algorithm to
	;		  solve the puzzle (no solution = goto step 1)
	;	3 - Carve out holes, corresponding to the difficulty

	JSR ResetGrid
	JSR InitialNumbers
	JSR SolvePuzzle

	RTS
	


;Fill the sudoku grid with all 0's
;
;	Results:
;		SudokuPuzzle   = All Reset
;		SudokuSolution = All reset
ResetGrid:
	LDA #$00
	LDX #81
.loop
	STA SudokuPuzzle, X
	DEX
	BNE .loop
	RTS

;Shuffle up the digits in the stack
;
;	Parameters:
;		SudokuStack = The stack to shuffle
;
;	Results:
;		SudokuStacks[SudokuStack] = Shuffled stack
RandomizeStack:
	JSR GetRandom3
	AND #$07				;Shuffle 1 to 8 times
	CLC
	ADC #$01
	STA RandomCounter		;Number of loop iterations
.loop
	JSR GetRandom1			;Number 1 index to swap
	AND #$0F				;Do a modulus 9 lookup
	TAY
	LDA Mod9, Y
	TAY
	STY RandomIndex
	LDA [SudokuStack], Y	;Get Number 1
	TAX						;Store it in X
	JSR GetRandom2			;Number 2 index to swap
	AND #$0F				;Do a modulus 9 lookup
	TAY
	LDA Mod9, Y
	TAY
	LDA [SudokuStack], Y	;Get Number 2
	STA RandomNumber		;Store it in a temporary location
	TXA
	STA [SudokuStack], Y	;Store Number 1 in Number 2
	LDA RandomNumber
	LDY RandomIndex
	STA [SudokuStack], Y	;Store Number 2 in Number 1
	DEC RandomIndex
	BNE .loop
	RTS

	
;Copy the stack from RandomStack to a 3x3 cell in the Sudoku puzzle
;
;	Parameters:
;	  X = Starting index in the sudoku puzzle
CopyStack:
	LDY #$00
	STY SquareCounter
.loop
	LDA RandomStack, Y
	STA SudokuPuzzle, X
	
	;Add +1, +, +7, etc
	TXA
	LDX SquareCounter
	INC SquareCounter
	CLC
	ADC SquareAddition, X
	TAX
	
	INY
	CPY #9
	BNE .loop
	RTS
	
	
;Fill the sudoku puzzle with the starting numbers
;
;	Results:
;		SudokuPuzzle = Diagonal 3x3 grids filled with the numbers 1 to 9
InitialNumbers:

	;Set up the stack shuffler
	LDA #LOW(RandomStack)
	STA SudokuStack
	LDA #HIGH(RandomStack)
	STA SudokuStack+1

	;Fill the random stack with the numbers 1 to 9
	LDX #$00
	LDA #$01
.loop
	STA RandomStack, X
	INX
	CLC
	ADC #$01
	CPX #9
	BNE .loop
	
	;First 3x3 cell
	JSR RandomizeStack
	LDX #00
	JSR CopyStack
	
	;Second 3x3 cell
	JSR RandomizeStack
	LDX #30
	JSR CopyStack
	
	;Final 3x3 cell
	JSR RandomizeStack
	LDX #60
	JSR CopyStack
	
	RTS 