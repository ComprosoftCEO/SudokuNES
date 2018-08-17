ShufflePalette:
	LDX #$03

.loop
	JSR RandomColor
	STA PaletteData+16, X
	INX
	INX
	INX
	INX
	CPX #19
	BNE .loop
	JSR GetRandom2


RandomColor:		;Return a valid color from the table
	LDA #$00
	STA RandMin
	LDA #48
	STA RandMax
	JSR RandInt
	TAY
	LDA AllowedColors, Y
	RTS
	
	

	
LoadGameplayPalette:
	LDX #$00
.PaletteLoop
	LDA Palette, X
	STA PaletteData, X
	INX
	CPX #$20
	BNE .PaletteLoop
	RTS

AllowedColors:		;Totals about 48
  .db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C
  .db $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C
  .db $21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C
  .db $31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C
  
PlayFieldColors:
  .db $15,$16,$26,$27,$28,$39,$29,$2A,$2B,$2C,$21,$11,$12,$13,$14,$25