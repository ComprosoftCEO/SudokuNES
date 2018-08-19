;Test the cell located at CurrentCell and store in SudokuStack
;
;	Parameters:
;	  CurrentCell  = The cell to test
;	  SudokuPuzzle = The puzzle being tested
;	  SudokuStack  = Where to store the results (indirect indexing)
;
;	Results:
;	  SudokuStacks[SudokuStack] = List of numbers available
;
TestCell:
	
	;Reset the stack
	LDA #$00
	TAY
.reset
	STA [SudokuStack], Y 
	INY
	CPY #$09
	BNE .reset

	
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
	

	;Do the actual testing here...
	JSR TestVertCells
	JSR TestHorCells
	JSR TestSquareCells

	
	;Calculate the "Inverse" of the stack
	JSR StackInverse
	JSR RandomizeStack
	RTS
	

	
;Test the cells in CellCol and store in SudokuStack
;
;	Parameters:
;	  CellCol = The column number being tested
;	  SudokuStack  = Where to store the results (indirect indexing)
;
;	Results:
;	  SudokuStacks[SudokuStack] = List of numbers taken
TestVertCells:
	
	LDX CellCol
.loop
	LDA SudokuPuzzle, X
	BEQ .skip				;0 = No number there (do nothing)

	TAY
	DEY
	STA [SudokuStack], Y
	
.skip	
	TXA
	CLC				;Move ahead 9 spaces
	ADC #$09
	TAX
	
	CPX #81			;Do this until the X moves beyond the range
	BCC .loop
	RTS




;Test the cells in CellRow and store in SudokuStack
;
;	Parameters:
;	  CellRow = The row number being tested
;	  SudokuStack  = Where to store the results (indirect indexing)
;
;	Results:
;	  SudokuStacks[SudokuStack] = List of numbers taken
TestHorCells:
	
	LDA #$00
	STA RowCounter
	LDX CellRow
.loop
	LDA SudokuPuzzle, X
	BEQ .skip				;0 = No number there (do nothing)

	TAY
	DEY
	STA [SudokuStack], Y
	
.skip	
	INX				;Move ahead 1 space
	INC RowCounter
	LDA RowCounter
	CMP #9
	BNE .loop
	RTS




;Test the cells in CellSquare and store in SudokuStack
;
;	Parameters:
;	  CellSquare = The 3x3 cell being tested
;	  SudokuStack  = Where to store the results (indirect indexing)
;
;	Results:
;	  SudokuStacks[SudokuStack] = List of numbers taken
TestSquareCells:
	
	LDA #$00
	STA SquareCounter		;Reset the square counter
	LDX CellSquare
.loop
	LDA SudokuPuzzle, X
	BEQ .skip				;0 = No number there (do nothing)

	TAY
	DEY
	STA [SudokuStack], Y
	
.skip
	;Use SquareCounter to move ahead by +1, +1, then +7, etc...
	LDY SquareCounter
	TXA
	CLC
	ADC SquareAddition, Y
	TAX
	
	INY
	STY SquareCounter
	CPY #9
	BNE .loop
	RTS
	
	
	
;Compute the inverse of SudokuStack.
;	Every cell with a number becomes 0
;	Every cell with 0 becomes a number (1 to 9)
;
;	Parameters:
;	  SudokuStack  = Where to store the results (indirect indexing)
;
;	Results:
;	  SudokuStacks[SudokuStack] = Inverse of the stack
StackInverse:
	LDY #$00
.inverse
	LDA [SudokuStack], Y
	BNE .remove		;If A !=0, then number taken (set to 0)
	INY				;Number is available, so set to Index+1
	TYA
	DEY
	JMP .next
.remove
	LDA #$00
.next
	STA [SudokuStack], Y
	INY
	CPY #$09
	BNE .inverse
	RTS 