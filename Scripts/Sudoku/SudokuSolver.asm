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
;	  SudokuPuzzle   = The puzzle to solve
;	  SolveParams    = Bit 7 = Random Stack, Bit 6 = Check for multiple solutions
;
;	Results:
;	  SudokuPuzzle = The solved puzzle
;	  Acc = 1 if solved, 2 if duplicates exists, or 0 if not solved
SolvePuzzle:
	LDA #$00			;Reset to Cell 0
	STA CurrentCell

;Recursive routine that actually solves the puzzle
SolvePuzzleRecurse:
;	JSR WaitNMI
;	JSR WaitNMI
;	JSR WaitNMI
;	JSR WaitNMI
;	JSR WaitNMI	
;	JSR WaitNMI
;	JSR WaitNMI	
;	JSR WaitNMI	
;	JSR WaitNMI	
	
	LDX CurrentCell
	CPX #81
	BEQ .retTrue	;We have reached the end of the puzzle

	LDA SudokuPuzzle, X
	BEQ .test	;Skip this cell if != 0 (it already has a number)
	  INC CurrentCell			;Move to the next cell
	  JSR SolvePuzzleRecurse	;Recurse!!
	  CMP #$00
	  BEQ .retFalse
	  JMP .retTrue

.test
	JSR .copyAddr			;Load in the TestCell indexes
	JSR TestCell			;Find all valid numbers for this cell

	;Now loop through each number in the calculated fields
	LDX CurrentCell
	LDA #$00
	STA SudokuCounters, X	;Be sure to reset the counters
.loop
	LDX CurrentCell			;Also messes up X index
	JSR .copyAddr			;Recursion messes up address
	LDA SudokuCounters, X
	TAY
	LDA [SudokuStack], Y
	BEQ .skipZero			;Don't do numbers that are 0
	STA SudokuPuzzle, X		;Store the number in the puzzle for testing
	INC CurrentCell			;Move to the next cell
	JSR SolvePuzzleRecurse	;Recurse
	CMP #$01
	BEQ .retTrue			;Yes, a solution was found!!!

	;No, go to next number
.skipZero
	LDX CurrentCell
	INC SudokuCounters, X	;Update the counter
	LDA SudokuCounters, X
	CMP #9
	BNE .loop	;Do next number
	
.quit
	LDA #$00				;Store a 0 into the cell before returning false
	STA SudokuPuzzle, X
.retFalse:
	LDA #$00
	DEC CurrentCell
	RTS
.retTrue:
	LDA #$01
	DEC CurrentCell
	RTS
.retDup:
	LDA #$02
	DEC CurrentCell
	RTS
	

;Copy the address from the Sudoku lookup table
.copyAddr:
	LDA SolveLookupLow, X
	STA SudokuStack
	LDA SolveLookupHigh, X
	STA SudokuStack+1
	RTS 