DummyData:
  .db 1,0,2, 0,4,0, 9,0,5
  .db 5,7,4, 0,0,0, 0,0,0
  .db 6,8,3, 0,0,0, 0,0,0
  
  .db 8,0,0, 0,0,0, 0,0,0
  .db 2,0,0, 0,0,0, 0,0,0
  .db 0,0,0, 0,0,0, 0,0,0
  
  .db 0,0,0, 0,0,0, 0,0,0
  .db 6,0,0, 0,0,0, 0,0,0
  .db 0,0,0, 0,0,0, 0,0,0

Mod9:	;Used for rand & 0xF
  .db 0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6
Mod3:	;Used for rand & 0x3
  .db 0,1,2,0
  
SquareTable:		;Lookup table for the 3x3 squares in a sudoku board
  .db 0,0,0, 3,3,3, 6,6,6
  .db 0,0,0, 3,3,3, 6,6,6
  .db 0,0,0, 3,3,3, 6,6,6
  
  .db 27,27,27, 30,30,30, 33,33,33 
  .db 27,27,27, 30,30,30, 33,33,33 
  .db 27,27,27, 30,30,30, 33,33,33
  
  .db 54,54,54, 57,57,57, 60,60,60
  .db 54,54,54, 57,57,57, 60,60,60
  .db 54,54,54, 57,57,57, 60,60,60

SquareAddition:		;What value to add during each step in the loop
  .db 1,1,7, 1,1,7, 1,1,7
	
SolveLookupLow:
  .db LOW(SudokuStacks+0),LOW(SudokuStacks+9),LOW(SudokuStacks+18),LOW(SudokuStacks+27),LOW(SudokuStacks+36),LOW(SudokuStacks+45),LOW(SudokuStacks+54),LOW(SudokuStacks+63),LOW(SudokuStacks+72)
  .db LOW(SudokuStacks+81),LOW(SudokuStacks+90),LOW(SudokuStacks+99),LOW(SudokuStacks+108),LOW(SudokuStacks+117),LOW(SudokuStacks+126),LOW(SudokuStacks+135),LOW(SudokuStacks+144),LOW(SudokuStacks+153)
  .db LOW(SudokuStacks+162),LOW(SudokuStacks+171),LOW(SudokuStacks+180),LOW(SudokuStacks+189),LOW(SudokuStacks+198),LOW(SudokuStacks+207),LOW(SudokuStacks+216),LOW(SudokuStacks+225),LOW(SudokuStacks+234)
  .db LOW(SudokuStacks+243),LOW(SudokuStacks+252),LOW(SudokuStacks+261),LOW(SudokuStacks+270),LOW(SudokuStacks+279),LOW(SudokuStacks+288),LOW(SudokuStacks+297),LOW(SudokuStacks+306),LOW(SudokuStacks+315)
  .db LOW(SudokuStacks+324),LOW(SudokuStacks+333),LOW(SudokuStacks+342),LOW(SudokuStacks+351),LOW(SudokuStacks+360),LOW(SudokuStacks+369),LOW(SudokuStacks+378),LOW(SudokuStacks+387),LOW(SudokuStacks+396)
  .db LOW(SudokuStacks+405),LOW(SudokuStacks+414),LOW(SudokuStacks+423),LOW(SudokuStacks+432),LOW(SudokuStacks+441),LOW(SudokuStacks+450),LOW(SudokuStacks+459),LOW(SudokuStacks+468),LOW(SudokuStacks+477)
  .db LOW(SudokuStacks+486),LOW(SudokuStacks+495),LOW(SudokuStacks+504),LOW(SudokuStacks+513),LOW(SudokuStacks+522),LOW(SudokuStacks+531),LOW(SudokuStacks+540),LOW(SudokuStacks+549),LOW(SudokuStacks+558)
  .db LOW(SudokuStacks+567),LOW(SudokuStacks+576),LOW(SudokuStacks+585),LOW(SudokuStacks+594),LOW(SudokuStacks+603),LOW(SudokuStacks+612),LOW(SudokuStacks+621),LOW(SudokuStacks+630),LOW(SudokuStacks+639)
  .db LOW(SudokuStacks+648),LOW(SudokuStacks+657),LOW(SudokuStacks+666),LOW(SudokuStacks+675),LOW(SudokuStacks+684),LOW(SudokuStacks+693),LOW(SudokuStacks+702),LOW(SudokuStacks+711),LOW(SudokuStacks+720)

SolveLookupHigh:
  .db HIGH(SudokuStacks+0),HIGH(SudokuStacks+9),HIGH(SudokuStacks+18),HIGH(SudokuStacks+27),HIGH(SudokuStacks+36),HIGH(SudokuStacks+45),HIGH(SudokuStacks+54),HIGH(SudokuStacks+63),HIGH(SudokuStacks+72)
  .db HIGH(SudokuStacks+81),HIGH(SudokuStacks+90),HIGH(SudokuStacks+99),HIGH(SudokuStacks+108),HIGH(SudokuStacks+117),HIGH(SudokuStacks+126),HIGH(SudokuStacks+135),HIGH(SudokuStacks+144),HIGH(SudokuStacks+153)
  .db HIGH(SudokuStacks+162),HIGH(SudokuStacks+171),HIGH(SudokuStacks+180),HIGH(SudokuStacks+189),HIGH(SudokuStacks+198),HIGH(SudokuStacks+207),HIGH(SudokuStacks+216),HIGH(SudokuStacks+225),HIGH(SudokuStacks+234)
  .db HIGH(SudokuStacks+243),HIGH(SudokuStacks+252),HIGH(SudokuStacks+261),HIGH(SudokuStacks+270),HIGH(SudokuStacks+279),HIGH(SudokuStacks+288),HIGH(SudokuStacks+297),HIGH(SudokuStacks+306),HIGH(SudokuStacks+315)
  .db HIGH(SudokuStacks+324),HIGH(SudokuStacks+333),HIGH(SudokuStacks+342),HIGH(SudokuStacks+351),HIGH(SudokuStacks+360),HIGH(SudokuStacks+369),HIGH(SudokuStacks+378),HIGH(SudokuStacks+387),HIGH(SudokuStacks+396)
  .db HIGH(SudokuStacks+405),HIGH(SudokuStacks+414),HIGH(SudokuStacks+423),HIGH(SudokuStacks+432),HIGH(SudokuStacks+441),HIGH(SudokuStacks+450),HIGH(SudokuStacks+459),HIGH(SudokuStacks+468),HIGH(SudokuStacks+477)
  .db HIGH(SudokuStacks+486),HIGH(SudokuStacks+495),HIGH(SudokuStacks+504),HIGH(SudokuStacks+513),HIGH(SudokuStacks+522),HIGH(SudokuStacks+531),HIGH(SudokuStacks+540),HIGH(SudokuStacks+549),HIGH(SudokuStacks+558)
  .db HIGH(SudokuStacks+567),HIGH(SudokuStacks+576),HIGH(SudokuStacks+585),HIGH(SudokuStacks+594),HIGH(SudokuStacks+603),HIGH(SudokuStacks+612),HIGH(SudokuStacks+621),HIGH(SudokuStacks+630),HIGH(SudokuStacks+639)
  .db HIGH(SudokuStacks+648),HIGH(SudokuStacks+657),HIGH(SudokuStacks+666),HIGH(SudokuStacks+675),HIGH(SudokuStacks+684),HIGH(SudokuStacks+693),HIGH(SudokuStacks+702),HIGH(SudokuStacks+711),HIGH(SudokuStacks+720) 