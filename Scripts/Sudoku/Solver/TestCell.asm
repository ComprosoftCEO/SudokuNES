;Test the cell located at CurrentCell and store in CellNumbers
;
;	Parameters:
;	  CurrentCell  = The cell to test
;	  SudokuPuzzle = Which puzzle to test (Constant)
;
;	Results:
;		AvailableStack = A list of valid numbers (0 to AvailableNumbers - 1)
;		AvailableNumbers = The count of available numbers
;		Acc = Cell invalid??? (1 = invalid, 0 = valid)
;
;  If cell invalid, then AvailableStack is cleared to all 0's
;	 otherwise, the stack is fixed...
TestCell:
	
	;Calculate CellCol
	LDA CurrentCell
.loop
	SEC
	SBC #$09		;Subtract 9 until a carry occurs
	BCS .loop
	CLC
	ADC #$09
	STA CellCol
	

	;Calculate CellRow
	LDA CurrentCell
	SEC					;Subtract cellcol from the current cell to get the cellrow
	SBC CellCol
	STA CellRow
	
	;Calculate CellSquare
	LDX CurrentCell		;Get the 3x3 cell from a lookup table
	LDA SquareTable, X
	STA CellSquare

	JSR ResetAvailableStack
	
	;Do the actual testing here...
	JSR TestVertCells
	JSR CombineAvailableStack
	JSR TestHorCells
	JSR CombineAvailableStack
	JSR TestSquareCells
	JSR CombineAvailableStack

	JSR FixAvailableStack

	LDA CellInvalid
	RTS
