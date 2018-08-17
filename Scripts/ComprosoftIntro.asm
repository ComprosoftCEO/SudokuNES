;Draw the Comprosoft Intro
ComprosoftIntro:

	JSR DisableScreen

	;Start by loading the Comprosoft palette
	JSR LoadComprosoftPalette
	
	LDA #$01		;Enable the skip intro
	STA SkipIntro

	LDA #%00001000	;Disable the NMI for the intro
	STA $2000
	LDA #%00011000	;Enable display for the intro
	STA $2001
	
	LDA #$02
	STA IntroTileCount		;IntroTileCount = # of tiles (*2)
	LDA #$6E
	STA IntroXPos		;IntroXPos = X Position in the PPU
	
	JSR CWait1Sec		;Wait before starting
	
;Load the starting address into the PPU for the underscore
	LDA $2002	;Reset the High/Low Latch
	LDA #$21
	STA $2006	;Fill in the address to draw
	LDA #$AF
	STA $2006	
	
	JSR DrawUndrscore
	
	
	
	;--------------The C:\> text---------------
InitialText:
	JSR CWait1Sec
	LDY #$00
	
InitialDrawLoop:
	
	JSR InputNextLine
	LDX #$00
	
DrawILetter1:		;Line 1
	LDA ComprosoftFirstText1, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawILetter1
	
	JSR IncramentLineAddress
	JSR InputNextLine
	LDX #$00
	
DrawILetter2:		;Line 2
	LDA ComprosoftFirstText2, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawILetter2	
	
	JSR IncramentLineAddress
	JSR InputNextLine
	LDX #$00
	
DrawILetter3:		;Line 3
	LDA ComprosoftFirstText3, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawILetter3
	
	JSR DrawUndrscore
	JSR CWait1Sec
	
	;Do the math to run the loop again
	LDA IntroTileCount
	CLC
	ADC #$02	;The number of tiles
	STA IntroTileCount
	
	LDA IntroXPos
	SEC
	SBC #$41	;Reset the x position of the tile
	STA IntroXPos
	
	INY
	CPY #$04
	BEQ InitialCont
	JMP InitialDrawLoop
	
	
	
	
	
InitialCont:
	
	;Now, prepare the data for the long copying process
	LDA #$04		;Tiles in the word Comprosoft
	STA IntroTileCount
	LDA #$6B		;X positon
	STA IntroXPos
	
	LDY #$00
	
	
	
	
	
;------------Copy the full Comprosoft Text, then add the colon on to the end of each row---------
ComprosoftTextLoop:
	JSR InputNextLine
	LDX #$00
	
DrawCLetter1:		;===Line 1===
	LDA ComprosoftLogo1, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawCLetter1
	
	LDX #$00
DrawColon1:
	LDA ComprosoftColon1, X
	STA $2007
	INX
	CPX #$06
	BNE DrawColon1

	JSR IncramentLineAddress
	JSR InputNextLine
	LDX #$00	

DrawCLetter2:		;===Line 2===
	LDA ComprosoftLogo2, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawCLetter2
	
	LDX #$00
DrawColon2:
	LDA ComprosoftColon2, X
	STA $2007
	INX
	CPX #$06
	BNE DrawColon2

	JSR IncramentLineAddress
	JSR InputNextLine
	LDX #$00	

DrawCLetter3:		;===Line 3===
	LDA ComprosoftLogo3, X
	STA $2007
	INX
	CPX IntroTileCount
	BNE DrawCLetter3
	
	LDX #$00
DrawColon3:			;Add the :\>
	LDA ComprosoftColon3, X
	STA $2007
	INX
	CPX #$06
	BNE DrawColon3
	
	JSR IncramentLineAddress
	JSR InputNextLine
	LDX #$00		
	
	JSR CWaitHalfSec

	

;Do the math to run the loop again
	LDA IntroTileCount
	CLC
	ADC #$02	;The number of tiles
	STA IntroTileCount
	
	LDA IntroXPos
	SEC
	SBC #$61	;Reset the x position of the tile
	STA IntroXPos
	
	INY
	CPY #$09
	BEQ PresentsText
	JMP ComprosoftTextLoop	
	
	
	
PresentsText:		;--Finally, add the text that says "Presents"

	LDA $02
	CMP #$FF
	BEQ EndIntro

	JSR CWaitHalfSec		;Wait 2 half seconds
	JSR CWaitHalfSec
	
	LDX #$00
	LDA #$22
	STA $2006
	LDA #$2C
	STA $2006
	
PresentsLoop:
	LDA ComprosoftPresents, X
	STA $2007
	INX
	CPX #$08
	BNE PresentsLoop

EndIntro:

	LDA #$00		;Disable the skip intro
	STA SkipIntro

	JSR CWait1Sec
	JSR CWait1Sec
	
	RTS
	
	
	
;--------------Subroutines Used---------------------	
	
;Draw the underscore after the text is drawn	
DrawUndrscore:
	LDA #$F9
	STA $2007
	LDA #$FA
	STA $2007
	RTS
	
	
;Go to the next line when drawing Comprosoft (The graphics take 3 PPU lines)
IncramentLineAddress:		
	LDA IntroXPos
	CLC
	ADC #$20
	STA IntroXPos
	RTS
	

;Reset the PPU Pointer to redraw the Comprosoft text
InputNextLine:
	LDA #$21
	STA $2006		
	LDA IntroXPos
	STA $2006
	RTS
	

;Read the controller to determine if you can skip the intro
TestComprosoftSkip:
	LDA SkipIntro	;Test if skipping is disabled
	BEQ .noSkip
	
	JSR GetControls
	LDA C1Data		;Test for the start key
	AND #%00010000
	BEQ .noSkip
	JMP SkipComprosoft
	
.noSkip
	RTS
	
	
;Write the whole word Comprosoft to the screen
SkipComprosoft:
	PLA
	PLA		;Remove last 2 subtroutines
	PLA
	PLA
	
	LDA #$00		;Disable the skip intro
	STA SkipIntro
	
	LDA #$14				;Configure the tile count and XY positions
	STA IntroTileCount
	LDA #$63
	STA IntroXPos

	LDX #$00				;Draw the presents text
	LDA #$22
	STA $2006
	LDA #$2C
	STA $2006
	
.Presents:
	LDA ComprosoftPresents, X
	STA $2007
	INX
	CPX #$08
	BNE .Presents
	
	LDY #$08
	JMP ComprosoftTextLoop
	
	
;Load the Comprosoft Palette into the PPU Memory
LoadComprosoftPalette:	
	LDA $2002
	LDA #$3F
	STA $2006		;Palette data is at $3F00
	LDA #$00
	STA $2006
	
	LDX #$00
.loop
	LDA ComprosoftPalette, X
	STA $2007
	INX
	CPX #$04
	BNE .loop	
	RTS

	
;-----------Comprosoft Intro Timing Codes-------


;Wait 1 second before updating the frame
CWait1Sec:
	LDA #$00        ;tell the ppu there is no background scrolling
	STA $2005
	STA $2005 
	LDX #$00
.wait
	JSR CWaitNMI
	JSR TestComprosoftSkip

	INX
	CPX #$40		;Repeat 64 times to delay approx. 1 sec
	BNE .wait
	RTS

	
;Wait a half second before updating the frame
CWaitHalfSec:
	JSR NoScroll	;Turn off the scrolling
	LDX #$00
.wait	
	JSR CWaitNMI
	JSR TestComprosoftSkip		
	
	INX
	CPX #$08			;Repeat 8 times to delay a short "half" second
	BNE .wait
	RTS	

;Wait for a vblank
CWaitNMI:
	JSR NoScroll
.waitvblank: 
	BIT $2002
	BPL .waitvblank
	RTS	