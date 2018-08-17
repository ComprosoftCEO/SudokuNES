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
