;Various graphic functions

DisableScreen:
	PHA
	LDA #$00
	STA $2000
	STA $2001
	PLA
	RTS

;Update the PPU with the settings stored in memory
UpdatePPU:	
	LDA PPU_Setting1
	STA $2000
	LDA PPU_Setting2
	STA $2001
	RTS
	
;Reset the $2005 latch to remove any scrolling
NoScroll:
	LDA $2002
	LDA #$00
	STA $2006
	STA $2006
	STA $2005
	STA $2005
	RTS 
	
	
;Reset all graphics on the screen
ResetBackground:
	
	PHA
	TXA
	PHA		;Store registers
	TYA
	PHA
	
	LDA $2002
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
	
	LDY #$1E
.loop
	LDX #$20
.loop2
	STA $2007
	DEX
	BNE .loop2
	DEY
	BNE .loop

	PLA
	TAY
	PLA		;Get registers
	TAX
	PLA
	
	RTS
	
	
ResetAttrib:
	
	PHA
	TXA		;Store registers
	PHA
	
	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	
	LDX #$40
	LDA #$00
.loop
	STA $2007
	DEX
	BNE .loop
	
	PLA
	TAX		;Get registers
	PLA
	
	RTS
	
WaitNMI:
	LDA #$00
	STA NMI_Fired
.loop
	LDA NMI_Fired
	BEQ .loop
	RTS 
	
	
ResetSprites:
	LDA #$FF
	LDX #$00
.loop
	STA $0200, X
	INX
	BNE .loop
	RTS
	
	
	
	
CalculatePPUXY:
	;Get a PPU address with PPU_High and PPU_Low
	;Return TempX and TempY
	
	LDA #$00
	STA TempX		;Reset TempX and Y
	STA TempY
	
	LDA PPU_High		;Subtract #$1F to zero this number, but allow for one subtraction
	SEC
	SBC #$1F
	STA PPU_High
	
	;First, calculate the Y value
	;Subtract 32 from X until temp3 = 0
.loop
	LDA TempY
	CLC			;Add 8 to Y every time
	ADC #$08
	STA TempY
	
	LDA PPU_Low	;Load Low Byte
	SEC
	SBC #32		;Subtract 32 until a carry occurs
	STA PPU_Low
	BCS .loop
	
	DEC PPU_High	;Subtract one from high byte
	BNE .loop	;Keep looping until this equals 0
	
	LDA TempY
	SEC				;This loop returns the roof, so do the floor
	SBC #$09
	STA TempY

	LDA PPU_Low		;Load the low byte
	CLC
	ADC #32		;Add 32 to fix the overflow
	ASL A
	ASL A			;Shift left 4 times to multiply by 8
	ASL A
	STA TempX
	
	RTS 
	
	
	
GetAttributeXY:
	;Takes in an XY coordinate from TempX and TempY
	;Turn these into PPU Coordinates at PPU_Low and PPU_High
	
	LDA TempX	;Load X
	LSR A
	LSR A
	LSR A	;Divide by 32
	LSR A
	LSR A
	STA Temp3
	
	LDA TempY	;Load Y
	CLC
	ADC #$01	;Y is off by 1 scanline
	AND #%11100000	;Cancel out last 5 digits
	LSR A	;Divide by 32, multiply by 8
	LSR A
	
	CLC
	ADC #$C0		;Attributes start at $C0
	CLC
	ADC Temp3
	STA PPU_Low
	
	LDA #$23
	STA PPU_High
	
	RTS 
	
	
PutAttribute:
	;Grabs the attribute from PPU_NewAttrib (0 - 3)
	;Replaces the TempX,TempY attribute

	TXA	
	PHA			;Store X and Y onto stack
	TYA
	PHA
	
	JSR GetAttributeXY		;Always calculate PPU_Low and PPU_High from TempX, TempY

	;Now set up the PPU to read the current attribute
	LDA $2002
	LDA PPU_High
	STA $2006
	LDA PPU_Low
	STA $2006
	
	LDA $2007		;First read is invalid
	LDA $2007
	STA PPU_Attrib		;Store the attribute to modify

	;Reset the PPU to insert a new value
	LDA $2002
	LDA PPU_High
	STA $2006
	LDA PPU_Low
	STA $2006
	
	;Where in the attribute byte to modify??? (00,11,22,33)
	LDX #$00		;X = Counter
	
	LDA TempX		;Get X
	AND #%00010000	;Divide by 16, and find the remainder
	BEQ .skip		;Skip when not 0
	INX				;Add 1 to counter (2^0 Bit)
.skip

	LDA TempY		;Get Y
	CLC
	ADC #$01		;Y if off by 1 scanline
	AND #%00010000	;Divide by 16, and find the remainder
	BEQ .skip2		;Skip when 0
	INX
	INX				;Add 2 to counter (2^1 Bit)
	
.skip2	
	TXA
	TAY		;Backup X to Y

	;Now shift to figure out which bits to cancel out
	LDA #%00000011
	CPX #$00
	BEQ .exitLoop
.loop1
	ASL A
	ASL A
	DEX
	BNE .loop1
	
.exitLoop	
	EOR #$FF	
	AND PPU_Attrib	;Cancel out the bits with AND function
	TAX				;Store this value into X
	
	LDA PPU_NewAttrib	;Shift the replacement value into the replace position
	AND #$03			;Always force bits just to be safe
	CPY #$00
	BEQ .exitLoop2
.loop2
	ASL A
	ASL A
	DEY
	BNE .loop2
.exitLoop2
	STA PPU_NewAttrib
	TXA
	ORA PPU_NewAttrib		;And replace
	STA $2007
	
	PLA
	TAY
	PLA		;Get register values back
	TAX
	
	RTS	
	
	
;Grab the palette from the RAM
UpdatePalette:
	LDA PalUpdateOn
	BNE .cont			;Verify that the flag is on
	RTS

.cont
	LDA $2002		;Reset latch
	LDA #$3F
	STA $2006		;Palette data is at $3F00
	LDA #$00
	STA $2006
	LDX #$00
.loop
	LDA PaletteData, X
	STA $2007
	INX
	CPX #32		;Copy 32 bytes
	BNE .loop	
	RTS
	
	
;Copy the attributes from the RAM
UpdateAttributes:
	LDA AttribUpdateOn
	BNE .cont				;Verify that the flag is on
	RTS
.cont
	LDA $2002		;Reset latch
	LDA #$23
	STA $2006		;Attributes are at $23C0
	LDA #$C0
	STA $2006
	LDX #$00
.loop
	LDA AttributeData, X
	STA $2007
	INX
	CPX #64		;Copy 64 bytes
	BNE .loop
	RTS
	
