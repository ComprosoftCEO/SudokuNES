;Test the cells in the horizontal row
;
;	Parameters:
;		CellRow = The row number being tested
;
;	Results:
;		TempAvailableStack = List of numbers found
TestHorCells:

	JSR ResetTempAvailableStack

	LDA CellRow
	CLC
	ADC #$09
	STA Temp1		;Use Temp1 as the compare for row+9

	LDX CellRow		;X = the position in the sudoku puzzle
.loop
	LDA SudokuPuzzle, X		;Get the number from the puzzle
	BEQ .skip				;0 = no number there (do nothing)

	TAY
	LDA TempAvailableStack-1, Y	;Make sure the number hasn't already
	BEQ .invalid				;   been found
	LDA #$00
	STA TempAvailableStack-1, Y
	JMP .skip

.invalid
	LDA #$01
	STA CellInvalid		;Two numbers exist in same col
	RTS					;Return! Error!!!

.skip
	INX				;Move to the next position in the memory
	CPX Temp1
	BNE .loop
	RTS 
