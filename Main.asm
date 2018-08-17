;Sudoku and Mazes NES
;Programmed by Bryan McClain


;iNES Header
	.inesprg 2   ; one (1) bank of 16 K program code
	.ineschr 1   ; one (1) bank of 8 K picture data
	.inesmap 0   ; we use mapper 0
	.inesmir 0   ; Vertical mirroring
	

;-------------Define some basic constants----------------
PPUC1_Default=%10001000
PPUC2_Default=%00011000


;------------------Define Variables----------------------
	;0000 = Global Variables
	;0100 = Stack
	;0200 = Sprites
	;0300 = Audio
	;0400 = Graphic Cache
	;0500 = ?
	;0600 = Generated Sudoku Puzzles
	;0700 = Other Sudoku Data
	
  .rsset $0000

RandMin		.rs 1
RandMax		.rs 1
RandDif		.rs 1 
  
TempLow		.rs 1		;Temp Low,High for indirect indexing
TempHigh	.rs 1

Temp1		.rs 1
Temp2		.rs 1
Temp3		.rs 1		;Some random temp locations
Temp4		.rs 1		
Temp5		.rs 1  
Temp6		.rs 1  

TempX		.rs 1		;Temp locations for XY values
TempY		.rs 1

IntroTileCount	.rs 1		;How many tiles are currently being displayed?
IntroXPos		.rs 1		;What is the X Position in the PPU?
SkipIntro		.rs 1		;1 = You can skip; 0 = No skip

sound_ptr .rs 2			;Sound pointers
sound_ptr2 .rs 2  

Random1_Seed	.rs 1		
Random2_Seed	.rs 1		;Seeds for PRNG using Linear Shift Feedback Register
Random3_Seed	.rs 1
Random4_Seed 	.rs 1
Random1_XOR		.rs 1
Random2_XOR		.rs 1		;XOR Values for linear shift feedback register
Random3_XOR		.rs 1
Random4_XOR		.rs 1
Entropy			.rs 1		;Used for extra randomness in the program

ModValue		.rs 1		;Variables for math functions
DivValue		.rs 1

PPU_Setting1	.rs 1			;Change the PPU settings for the NMI
PPU_Setting2  	.rs 1
PPU_High		.rs 1			;Temp locations for PPU high and low addresses
PPU_Low			.rs 1
PPU_Attrib		.rs 1			;Temp location for the attribute
PPU_NewAttrib	.rs 1			;The new attribute to insert into the PPU
NMI_Fired		.rs 1			;Had a NMI occured?

C1Data		.rs 1		;Controller 1
C2Data		.rs 1		;Controller 2
StKeyPress	.rs 1		;Start key press


  .rsset $0400
PaletteData		.rs 32			;Palette is stored in RAM to write to on next NMI
AttributeData	.rs 64			;Attributes are stored in RAM to write on next NMI 

PalUpdateOn		.rs 1			;If 0, don't update
AttribUpdateOn	.rs 1			;If 0, don't update


  .rsset $0600
  
SudokuPuzzle	.rs 81			;The current sudoku puzzle (Where puzzle is generated)
SudokuSolution	.rs 81			;The solution to the puzzle
SudokuTree		.rs 81			;A tree that stores all 81 possible locations on the board
SudokuBoard = SudokuTree		;   Also serves as the active board for the gameplay (So the board can be reset)
  
CurrentCell		.rs 1		;The current cell being tested								
CellCol			.rs 1		;The column of the cell being tested
CellRow			.rs 1		;The row of the cell being tested
CellSquare		.rs 1		;The 3x3 square of the cell being tested

CellInvalid		.rs 1		;1 = Cell tested is invalid		

	.rsset $0700
		
AvailableNumbers	.rs 1	;How many numbers are available in the current space
AvailableStack 		.rs 9	;A tiny stack for all available sudoku numbers
TempAvailableStack	.rs 9	;Temp stack to store before copying into the available stack

TreePosition		.rs 1	;Where am I in the tree??


;------------------Start of Code-------------------------	
  .bank 0
  .org $8000
  
Reset:

	.include "Scripts/Reset.asm"
	
	;Set up random numbers
	LDA XorVals+3
	STA Random1_XOR
	STA Random2_XOR
	STA Random3_XOR
	STA Random4_XOR

	LDA #$01
	STA PalUpdateOn
	
	;JSR ComprosoftIntro
	
	LDA #$00		;Turn off display to load default assets
	STA $2000
	STA $2001

;Load the basic palette into the RAM
	JSR LoadGameplayPalette
	
Title:
	;Reset any sound data
	LDX #$00
	LDA #$00
.loop
	STA $0300, X
	INX
	BNE .loop

	;Enable sound channels
    jsr sound_init
	
	;JSR CopyDummyData
	
	JSR GenerateSudoku
	STA TempLow
	
	JSR DisableScreen
	JSR DrawSudoku
	

	
	LDA #PPUC1_Default
	STA $2000
	
	
	
forever:
	JMP forever
	
	
	
	
	
	
	
	
;----------------------NMI Code----------------------	
	
	
NMI:
	PHA			;Backup the accumulator & X to the stack
	TXA
	PHA
	TYA
	PHA
	
	LDA #$00   ;Disable NMI until end of NMI Code
    STA $2000
	
	;Use DMA to copy the sprites on every frame
    LDA #$00
    STA $2003  ; set the low byte (00) of the RAM address
    LDA #$02
    STA $4014  ; set the high byte (02) of the RAM address, start the transfer	

  ;Update the palette and the attributes using the data stored in the RAM
	JSR UpdatePalette
	JSR UpdateAttributes
	
  ;This is the PPU clean up section, so rendering the next frame starts properly.
	JSR NoScroll       ;tell the ppu there is no background scrolling
	JSR UpdatePPU
	
	JSR sound_play_frame    ;run our sound engine after all drawing code is done.
                            ;this ensures our sound engine gets run once per frame.
	
	JSR GetTrueRandom		;Always shuffle up the random numbers

	LDA #$FF
	STA NMI_Fired		;Let the person know that the NMI fired

	PLA 
	TAY
	PLA		;And retrieve the accumulator & X
	TAX
	PLA
	
	RTI   
  

;--------------------Other Data--------------------------
  
Palette:
  .db $0F,$0F,$30,$2, $0F,$16,$1A,$37, $0F,$28,$12,$3B, $0F,$0F,$0F,$0F	;Background (0,1,2,3)
  .db $0F,$30,$30,$27,$0F,$30,$30,$3C,$0F,$1C,$30,$14,$0F,$02,$30,$3C	;Sprites (0,1,2,3)  

	.include "Data/ComprosoftData.asm"
	.include "Data/SudokuData.asm"
		
  .bank 1
    .org $A000	
	
;-----------------Subroutines------------------ 
	.include "Scripts/ComprosoftIntro.asm"
	.include "Scripts/Controller.asm"
	.include "Scripts/Graphics.asm"
	.include "Scripts/Random.asm"
	.include "Scripts/Math.asm"
	.include "Scripts/Palette.asm"
	.include "Scripts/Sudoku/SudokuFunctions.asm"
	.include "Scripts/Sudoku/SudokuSolver.asm"
	.include "Scripts/Sudoku/SudokuGenerator.asm"	

;---------------------Other data----------
  .bank 2
	.org $C000
		
	
;-------------Sound Engine----------------------	
  .bank 3
    .org $E000
	
	.include "Audio/sound_engine.asm"
	.include "Audio/sound_opcodes.asm"
	.include "Audio/note_length_table.i"
	.include "Audio/note_table.i"
	.include "Audio/vol_envelopes.i"
	
;------------Sound Effects--------------            
song_headers:
    ;.word intro_header
    
	;.include "Audio/My Songs/Intro.asm"
	
;------------------Interrupts-----------------------------
  
  
  .org $FFFA     ;interrupts start at $FFFA

	.dw NMI      ; location of NMI Interrupt
	.dw Reset    ; code to run at reset
	.dw 0		 ;IQR interrupt (not used)
	


;--------------------Graphics-----------------------------
	
  .bank 4        ; change to bank 4 - Graphics information
  .org $0000     ;Graphics start at $0000

	.incbin "Graphics.chr"  ; Include Binary file that will contain all program graphics
