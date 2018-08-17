;=====================================================
;Functions associated with testing, calculating, etc.
;  on a sudoku grid
;=====================================================


;Callable Functions:
;--------------------
;	CalculateAvailableNumbers
;	TestCell
;	FixStack




;Create a mini stack with all available numbers for a given cell
;
;	Parameters:
;		CurrentCell = The number to test & calculate
;
;	Results:
;		AvailableNumbers = The count of available numbers
;		AvailableStack   = A list of valid numbers (0 to AvailableNumbers - 1)
;		ACC  		     = AvailableNumbers
CalculateAvailableNumbers:
	
	JSR TestCell		;Always test the current cell first!!!
	JSR FixStack		;Update all of the stack information
	LDA AvailableNumbers
	RTS		


	
	
;Test the cell located at CurrentCell
;	and store in CellNumbers
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
	
	;Calculate the cellcol and cellrow
	LDA CurrentCell
.loop
	SEC
	SBC #$09		;Subtract 9 until a carry occurs
	BCS .loop
	CLC
	ADC #$09
	STA CellCol
	
	LDA CurrentCell
	SEC					;Subtract cellcol from the current cell to get the cellrow
	SBC CellCol
	STA CellRow
	
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

	JSR FixStack

	LDA CellInvalid
	RTS




;Fill the sudoku grid with all 0's
;
;	Results:
;		SudokuPuzzle   = All Reset
;		SudokuSolution = All reset
ResetGrid:
	LDA #$00
	LDX #$81
.loop
	STA SudokuPuzzle, X
	STA SudokuSolution, X
	DEX
	BNE .loop
	RTS



;Reset the numbers in AvailableStack
;
;	Results:
;		AvailableStack = All numbers 1 to 9
;		[0] = 1
;		[1] = 2
;		[8] = 9
ResetAvailableStack:
	LDX #$01
.loop
	TXA
	STA AvailableStack-1,X
	INX
	CPX #10
	BNE .loop
	RTS


;Reset numbers in TempAvailableStack
;
;	Results:
;		TempAvailableStack = Numbers 1 to 9
ResetTempAvailableStack:
	LDX #$01
.loop
	TXA
	STA TempAvailableStack-1,X
	INX
	CPX #10
	BNE .loop
	RTS


;Fill available stack with all 0's
;
;	Results:
;		AvailableStack = All 0's (null data)
ClearAvailableStack:
	LDA #$00
	TAX
.loop
	STA AvailableStack, X
	INX
	CPX #$09
	BNE .loop
	RTS



;Combine the two stacks
;   AvailableStack and TempAvailableStack
; *Also check for errors, and return
;
;	Parameters:
;		AvailableStack
;		TempAvailableStack
;
;	Results:
;		AvailableStack = AvailableStack || TempAvailableStack
CombineAvailableStack:	
	LDA CellInvalid
	BEQ .valid

	JSR ClearAvailableStack		;There was an error! Reset all!
	PLA
	PLA			;Pull 2 values to return from parent subroutine
	RTS

.valid
	LDX #$00	;X = stack location
.loop
	LDA TempAvailableStack, X
	BNE .skip
	STA AvailableStack, X			;Only combine if temp stack = 0
.skip
	INX
	CPX #$09
	BNE .loop
	RTS



;Modify the AvailableStack so all numbers
;  are in order
;
;	Results:
;		AvailableStack = All numbers in order
;		AvailableNumbers = The count of numbers
FixStack:
	LDA #$00
	TAX							;X = counter in stack
	TAY							;Y = position to move to
.loop
	LDA AvailableStack, X	;Grab from position
	BEQ .next
	STA AvailableStack, Y	;Store in Y position
	INY
.next
	INX
	CPX #$09		;Run through all 9 positions
	BNE .loop
	STY AvailableNumbers		;Update the counter
	RTS
	


	
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
