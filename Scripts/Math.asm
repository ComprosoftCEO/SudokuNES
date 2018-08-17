;Simple 6502 math functions
;---------------------------


;modulus Function (remainder)
;
; Parameters:
;	 A = The number being moded
;    ModValue = The value to mod by
;
; Results:
; 	A = return result
Mod:
	SEC
.Modulus:
	SBC ModValue  ; memory addr B
	BCS .Modulus
	ADC ModValue
	RTS
 

;Division Function (Rounded down)
;
; Parameters:
;	 A = The number being divided
;    ModValue = The value to divide by
;
; Results:
; 	A = return result
;	Temp1 Modified
Divide:
	STX Temp1
	LDX #$00
	SEC
.Division:
	INX
	SBC DivValue
	BCS .Division
	TXA      ;get result into accumulator
	LDX Temp1
	RTS
