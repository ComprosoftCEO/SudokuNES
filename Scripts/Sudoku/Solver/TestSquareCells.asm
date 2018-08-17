;Test the cells in a 3x3 Square
;  this one is quite complicated...
;
;	Parameters:
;		CellSquare = 3x3 square being tested
;
;	Results:
;		TempAvailableStack = Flags of numbers found	
TestSquareCells:

	JSR ResetTempAvailableStack
	
	LDA #$00			;Temp1 stores the counter for addition data
	STA Temp1

	LDX CellSquare		;X = the position in the puzzle array
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
	STA CellInvalid		;Two numbers exist in same square
	RTS					;Return! Error!!!

.skip

	;Add a value from the lookup table
	TXA
	LDX Temp1
	CLC
	ADC SquareAddition, X
	TAX

	INC Temp1		;Run through all 9 additions
	LDA Temp1
	CMP #09
	BNE .loop
	RTS 


SquareTable:		;Lookup table for the 3x3 squares in a sudoku board
  .db 0,0,0, 3,3,3, 6,6,6
  .db 0,0,0, 3,3,3, 6,6,6
  .db 0,0,0, 3,3,3, 6,6,6
  
  .db 27,27,27, 30,30,30, 33,33,33 
  .db 27,27,27, 30,30,30, 33,33,33 
  .db 27,27,27, 30,30,30, 33,33,33
  
  .db 54,54,54, 57,57,57, 60,60,60
  .db 54,54,54, 57,57,57, 60,60,60
  .db 54,54,54, 57,57,57, 60,60,60


SquareAddition:		;What value to add during each step in the loop
  .db 1,1,7, 1,1,7, 1,1,7  
