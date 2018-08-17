;All algorithms associated with generating and solving sudoku puzzles

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
	CLC
	ADC #$3B
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
	
	
;------------Use a complex algorithm to generate a sudoku puzzle---------

GenerateSudoku:
	
	;Reset the pick random
	LDA #$00
	;STA PickRandom
	
	;Start by filling the stack
	LDA #80
	STA NumbersLeft
	JSR FillSudokuStack

	;How to generate a puzzle:
	;1 - Pick a spot from all available spots
	;2 - Pick a number from all available numbers
	;3 - Test if the puzzle is valid (If not, goto step 1)
	;4 - Repeat until all numbers are done
	
Generateloop:

	;Pick a random spot using the Rand0N function
	LDA NumbersLeft
	STA RandMax
	JSR Rand0N
	STA SpotToPull
	
	;Get that number from the stack
	TAX
	LDA SudokuStack, X
	STA CurrentCell
	STA LastCell
	
	;Calculate which numbers can go onto the stack
	JSR TestCell
	JSR CalculateAvailableNumbers

	LDA AvailableNumbers
	CMP #$FF
	BNE .numberAvailable		;Repick a spot if invalid
	JMP BruteForce
.numberAvailable	
	STA RandMax
	JSR Rand0N
	STA NumberInCell		;Store in case of brute force
	TAX
	LDA AvailableStack, X		;Pull from a stack of all available numbers
	
	LDX LastCell			;Store the number into the puzzle
	STA SudokuPuzzle, X
ValidateSudoku:
	;Now test if the puzzle is still valid
	JSR TestPuzzleInvalid
	CMP #$00
	BEQ .cont		;If so, then continue with the rest of the puzzle
	
	LDA #$00				;Reset this cell and repick numbers
	LDX LastCell
	STA SudokuPuzzle, X
	JMP BruteForce		;This failed, so use BruteForce
.cont	
	LDA NumbersLeft			;When there are 0 numbers left, end the program
	CMP #00
	BEQ .exit
	JSR PullSudokuStack		;Remove this spot from the stack
	JMP Generateloop
.exit
	
	RTS


;When the LSFR fail, use brute force
BruteForce:
	;Start by resetting the cells and calculating the numbers available
	JSR TestCell
	JSR CalculateAvailableNumbers

	INC NumberInCell
	LDA NumberInCell
	CMP AvailableNumbers
	BCC RedoFiller		;Continue if A<=Available Numbers
	BEQ RedoFiller
.NextCell
	LDX #$00
	STX NumberInCell
	INC SpotToPull
	LDA SpotToPull
	CMP NumbersLeft
	BCC RedoFiller		;Continue if A<=Numbers Left List
	BEQ RedoFiller
.resetCell
	LDA #$00
	STA SpotToPull
	
RedoFiller:
	LDX SpotToPull
	LDA SudokuStack, X
	STA LastCell
	STA CurrentCell
	
	JSR TestCell
	JSR CalculateAvailableNumbers

	
	LDX NumberInCell
	LDA AvailableStack, X		;Pull from a stack of all available numbers
	
	LDX LastCell			;Store the number into the puzzle
	STA SudokuPuzzle, X
	
	JMP ValidateSudoku
;-----------------Sudoku Stack Commands-----------------
	
;Fill the stack with numbers 0 - 80
FillSudokuStack:
	LDA #$00
	LDX #$00
.loop
	STA SudokuStack, X
	CLC
	ADC #$01
	INX
	CPX #81
	BNE .loop
	RTS
	
	
	
;Pull a number off the stack from SpotToPull
PullSudokuStack:

	LDX SpotToPull
	CPX NumbersLeft		;Don't move any numbers if x is at the end of the stack
	BEQ .skipLoop

	;Pull all of the numbers down to X
.loop
	LDA SudokuStack+1, X
	STA SudokuStack, X
	INX
	CPX NumbersLeft
	BNE .loop
	
.skipLoop	
	
	DEC NumbersLeft
	LDA #$00		;Reset the top most spot in the stack
	STA SudokuStack, X
	RTS
	
	

;Create a mini stack with all available number
;   from TestCell
CalculateAvailableNumbers:
	LDA #$FF
	STA AvailableNumbers		;Reset the stack counter
	
	LDA #$09
	LDX #$00
	LDY #$00

.loop
	ROL CellNumbers+1		;Roll the bits
	ROL CellNumbers
	
	BCS .skip		;If there is a number, skip the stack update
	STA AvailableStack, Y	;Update the stack
	INC AvailableNumbers
	INY
.skip
	INX
	SEC
	SBC #$01
	CPX #$09
	BNE .loop
	RTS	
	
	
	
	
;---------------Test if the current sudoku puzzle is valid----------------
;If ACC = 1, then puzzle is invalid 
;Puzzle is invalid if current cell = 0 and all numbers are taken
TestPuzzleInvalid:
	LDA #$00
	STA CurrentCell
.loop
	LDX CurrentCell		;Test if there is no number on the current cell
	LDA SudokuPuzzle, X
	BNE .cont

	JSR TestCell		;Test the cell
	
	LDA CellNumbers
	CMP #$FF			;Test if all numbers are taken
	BNE .cont
	
	LDA CellNumbers+1
	CMP #$80
	BNE .cont
		
	;The puzzle is invalid!!! There are no numbers left!!!
	LDA #$01
	RTS
	
	
.cont
	INC CurrentCell
	LDA CurrentCell
	CMP #81
	BNE .loop

	LDA #$00		;Yep, it is valid
	RTS
	
	
	
	
	
	
	
	
	
	
	
;----------------Test the cell located at CurrentCell, and store in CellNumbers------------------
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

	JSR ResetCellNumbers
	
	JSR TestVertCells
	JSR CombineCellNumbers
	JSR TestHorCells
	JSR CombineCellNumbers
	JSR TestSquareCells
	JSR CombineCellNumbers

	RTS

	
ResetCellNumbers:
	LDA #$00
	STA CellNumbers			;Reset the cell numbers
	STA CellNumbers+1
	RTS
	
ResetTempCellNumbers:
	LDA #$00
	STA TempCellNumbers
	STA TempCellNumbers+1
	RTS
	
;OR CellNumbers and TempCellNumbers
CombineCellNumbers:	
	LDA CellNumbers
	ORA TempCellNumbers
	STA CellNumbers

	LDA CellNumbers+1
	ORA TempCellNumbers+1
	STA CellNumbers+1
	
	RTS
	
	
	
;Test the cells in CellCol and store in TempCellNumbers
TestVertCells:

	JSR ResetTempCellNumbers

	LDX CellCol
	LDY #$01		;Y = number being tested 
.loop				;Test 1,2,3,etc.
	LDA SudokuPuzzle, X
	STA Temp1
	CPY Temp1
	BEQ .equal		;Test if the current number is equal to the cell	
	
	TXA
	CLC				;Move ahead 9 spaces
	ADC #$09
	TAX
	
	CPX #81			;Do this until the X moves beyond the range
	BCC .loop
	CLC				;If not equal, carry = 0
	JMP .shift
	
.equal
	SEC		;If equal, carry = 1
	
.shift
	ROR TempCellNumbers
	ROR TempCellNumbers+1
	
	LDX CellCol		;Reset the X
	INY
	CPY #10		;Loop through all 9 numbers
	BNE .loop
	RTS 
	
	
	
;Test the cells in CellRow and store in TempCellNumbers	
TestHorCells:

	JSR ResetTempCellNumbers

	LDA CellRow
	CLC
	ADC #$09
	STA Temp2		;Use Temp2 as the compare for row+9

	LDX CellRow
	LDY #$01		;Y = number being tested 
.loop				;Test 1,2,3,etc.
	LDA SudokuPuzzle, X
	STA Temp1
	CPY Temp1
	BEQ .equal		;Test if the current number is equal to the cell	
	
	INX				;Move to the next position in the memory
	CPX Temp2
	
	BNE .loop
	CLC				;If not equal, carry = 0
	JMP .shift
	
.equal
	SEC		;If equal, carry = 1
	
.shift
	ROR TempCellNumbers
	ROR TempCellNumbers+1
	
	LDX CellRow		;Reset the X
	INY
	CPY #10		;Loop through all 9 numbers
	BNE .loop
	RTS 
	


;Test the cells in CellSquare and store in TempCellNumbers		
TestSquareCells:

	JSR ResetTempCellNumbers
	
	LDA #$00			;Temp2 stores the counter for addition data
	STA Temp2

	LDX CellSquare
	LDY #$01		;Y = number being tested 
.loop				;Test 1,2,3,etc.
	LDA SudokuPuzzle, X
	STA Temp1
	CPY Temp1
	BEQ .equal		;Test if the current number is equal to the cell	
	
	;Add a value from the lookup table
	TXA
	LDX Temp2
	CLC
	ADC SquareAddition, X
	TAX

	INC Temp2		;Run through all 9 additions
	LDA Temp2
	CMP #09
	BNE .loop
	CLC				;If not equal, carry = 0
	JMP .shift
	
.equal
	SEC		;If equal, carry = 1
	
.shift
	ROR TempCellNumbers
	ROR TempCellNumbers+1
	
	LDA #$00		;Reset the counter
	STA Temp2
	LDX CellSquare	;Reset the X Value
	
	INY
	CPY #10		;Loop through all 9 numbers
	BNE .loop
	RTS 
