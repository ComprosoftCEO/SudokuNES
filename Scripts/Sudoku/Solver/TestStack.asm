;=======================================================================
; TestCell uses a series of stacks (TempAvailableStack and AvailableStack)
;	This module has a series of functions to manipulate that stack
;=======================================================================


;Reset the numbers in AvailableStack
;
;	Results:
;		AvailableStack = All numbers 1 to 9
;		[0] = 1
;		[1] = 2
;		...
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
;		[0] = 1
;		[1] = 2
;		...
;		[8] = 9
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
FixAvailableStack:
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
