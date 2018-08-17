;Test the cells in CellCol and store in TempAvailableStack
;
;	Parameters:
;		CellCol = The column number being tested
;
;	Results:
;		TempAvailableStack = List of numbers allowed
TestVertCells:

	JSR ResetTempAvailableStack
	
	LDX CellCol		;X = the location in the Sudoku puzzle
.loop
	LDA SudokuPuzzle, X		;Get the number from the puzzle
	BEQ .skip				;0 = No number there (do nothing)

	TAY
	LDA TempAvailableStack-1, Y	;Make sure the number hasn't already
	BEQ .invalid				;   been found
	LDA #$00
	STA TempAvailableStack-1, Y
	JMP .skip

.invalid
	LDA #$01
	STA CellInvalid		;Two numbers exist in same row
	RTS					;Return! Error!!!

.skip	
	TXA
	CLC				;Move ahead 9 spaces
	ADC #$09
	TAX
	
	CPX #81			;Do this until the X moves beyond the range
	BCC .loop
	RTS 
