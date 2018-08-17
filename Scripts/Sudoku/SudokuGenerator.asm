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
	LDA #$20
	STA PPU_High
	LDA #$00
	STA PPU_Low
	LDX #$00
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
	LDY #$00
	LDA PPU_Low
	CLC
	ADC #$20
	STA PPU_Low
	BCC .skip
	INC PPU_High
.skip	
	CPX #81
	BNE .loop1
	RTS

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
	;	1 - Fill the grid with 11 random numbers
	;	2 - Use a randomized depth-first algorithm to
	;		  solve the puzzle (no solution = goto step 1)
	;	3 - Carve out holes, corresponding to the difficulty

	JSR ResetGrid
	JSR InitialNumbers
	JSR SolvePuzzle

	RTS
	




;Fill the sudoku puzzle with the starting numbers
;
;	Results:
;		SudokuPuzzle = Filled with 11 random numbers
InitialNumbers:
	;1 - Pick a spot from all available spots
	;2 - Pick a number from all available numbers
	;3 - Repeat 11 times

	LDA #11
	STA Temp2	;Temp2 is the counter

.loop
	;Pick a random spot using the Rand0N function
	LDA #81
	STA RandMax
.repick
	JSR Rand0N
	TAX
	LDA SudokuPuzzle, X		;Verify that the number is blank
	BNE .repick

	STX CurrentCell		;Use this cell...

	;Calculate which numbers can go onto the stack
	JSR TestCell
	BNE .repick						;If there are no options, pick another space
	
	;Now pick a random number to fill in
	STA RandMax
	JSR Rand0N

	;And store that number in the puzzle
	TAX
	LDA AvailableStack, X
	LDX CurrentCell
	STA SudokuPuzzle, X

	DEC Temp2
	BNE .loop
	RTS
