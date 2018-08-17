;==========================================
;Code used to solve a sudoku puzzle stored
; in SudokuPuzzle
;==========================================

;Callable Functions:
;--------------------
;	SolvePuzzle



;Solve a sudoku puzzle using a depth-first search algorithm	
;
;	Parameters:
;		SudokuPuzzle   = The puzzle to solve
;
;	Results:
;		SudokuPuzzle   = The solved puzzle
;		SudokuSolution = The origional puzzle
SolvePuzzle:

	;All cells in the tree are eigher:
	;	$00 = Nothing, yet
	;	$FF = Filled cell
	;	A,B	= A: Where I started;   B: Where I am now

	JSR ResetTree
	
	LDA #$00
	STA TreePosition
.MainLoop
	LDX TreePosition
	LDA SudokuTree, X
	CMP #$FF				;Don't do any maths on this space
	BEQ .NextSpace		
	
	STX CurrentCell		;Test to see if invalid in puzzle
	JSR TestCell
	BNE .Incrament		;INVALID! Go to next number for this space

	;Prepare stack for tree work
	LDX TreePosition
	LDA	SudokuTree, X		;Is Tree[Pos] = 0???
	BEQ .New
	;Okay, do the incrament

.Incrament
	JSR .IncramentSpace		;Update the numbering of this space
	JMP .Update

.New
	JSR .NewNumber	;Add a new node to the tree here

.Update
	JSR .UpdateGrid


;Go to the next spot in the tree
.NextSpace
	INC TreePosition
	LDX TreePosition
	CPX #81
	BEQ .ValidateExit
	JMP .MainLoop


;Go to the previous space in the tree
.PreviousSpace
	LDX TreePosition
	LDA #$00
	STA SudokuTree, X	  ;Fill tree with a zero 
	STA SudokuPuzzle, X
.PreviousInternal	
	DEX
	STX TreePosition	;Move to previous spot

	CPX #$FF			;Test for underflow
	BEQ .exit			;Exit, as this puzzle has no solution
	
	LDA SudokuTree, X
	CMP #$FF
	BEQ .PreviousInternal
	
	STX CurrentCell					;Set up information to do incrament spot
	JSR TestCell
	LDA AvailableNumbers
	;JSR CalculateAvailableNumbers
	JMP .Incrament

.ValidateExit
	;Hey, there are no more spaces left! You are done (sort of)
	
.exit
	RTS



;Create a new number in the Tree
.NewNumber

	;Find out which numbers can go in this space
	LDA AvailableNumbers
	BNE .GoNew				;There are no numbers, so go back
	PLA
	PLA
	JMP .PreviousSpace 
.GoNew
	STA RandMax
	JSR Rand0N			;Pick a random starting space
	
	AND #$0F
	STA Temp1
	ASL A
	ASL A			;Make the 4 highest bits equal the four lowest bits
	ASL A
	ASL A
	ORA Temp1

	LDX TreePosition	;Store this into the tree cell
	STA SudokuTree, X
	RTS

;Change the current arrangement of this space
.IncramentSpace
	LDX TreePosition
	LDY SudokuTree, X		;Y stores the master value
	TYA
	LSR A
	LSR A			;Get upper 4 bits
	LSR A
	LSR A
	STA Temp1		;Temp1 = The stopping position
	
	TYA
	AND #$0F		;Get lower four bits
	CLC
	ADC #$01		;Move to next number

	;Calculate when to wrap around to next number
	CMP AvailableNumbers
	BNE .continue
	LDA #$00
.continue
	CMP Temp1			;Figure out when it has completely
	BNE .keepGoing		;  looped around
	
	PLA		;Undo the last subroutine
	PLA
	JMP .PreviousSpace	;Go to previous space

.keepGoing
	STA Temp1	
	LDA SudokuTree, X		;Recombine the tree data
	AND #$F0
	ORA Temp1
	STA SudokuTree, X
	RTS



;Update the sudoku grid to match the tree
;
;	Results:
;		SudokuPuzzle = TreePosition cell matches the puzzle
.UpdateGrid
	LDX TreePosition
	LDA SudokuTree, X	;Grab the value off the tree
	AND #$0F			;   Index in available numbers
	TAY
	LDA AvailableStack, Y		;Find the index in availale numbers
	STA SudokuPuzzle, X			;Store said number into the puzzle
	RTS
	


;Reset the tree used to solve a puzzle, and fill with data
;  from SudokuPuzzle
;
;	Results:
;		SudokuTree 	   = All 0's, except for $FF for numbers in SudokuPuzzle
ResetTree:
	LDX #$00
.loop
	LDA SudokuPuzzle, X
	STA SudokuSolution, X
	BEQ .store		;$00 = There is no data for this space
	LDA #$FF		;$FF = Data exists on this space
.store
	STA SudokuTree, X
	INX
	CPX #81
	BNE .loop
	RTS	



