incsrc "../ChangeInValueDisplayDefines/Defines.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Status bar write table
;Each slot is assigned to a given status bar position.
;
;Memory layout usage:
; -Each byte of the 24-bit (3-byte) address is split
;  into each table, as to accommodate the indexing,
;  for example: slot 0 contains a status bar position
;  of $7FA000, when stored in the table it should be:
;                 Index:                   0    1    2    3
;  TempNumbDisplayByte_StatusBarPos0: db $00, $xx, $yy, $zz ;$ 7F  A0 [00]
;  TempNumbDisplayByte_StatusBarPos1: db $A0, $xx, $yy, $zz ;$ 7F [A0] 00
;  TempNumbDisplayByte_StatusBarPos2: db $7F, $xx, $yy, $zz ;$[7F] A0  00
;
;And if you want to edit the next slot status bar position,
;it would be on "index 1"'s column ($xx).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                           Index:      0    1    2    3
TempNumbDisplayByte_StatusBarPos0: db $00, $36, $00, $36
TempNumbDisplayByte_StatusBarPos1: db $A0, $A0, $A1, $A1
TempNumbDisplayByte_StatusBarPos2: db $7F, $7F, $7F, $7F

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Max digits table.
;This is the maximum number of digits, minus 1 for
;each slot. (so put a 2 if you want a 3-digit number).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       Index:      0    1    2    3
TempNumbDisplayByte_MaxDigits: db $03, $04, $04, $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Input:
; $00-$01: The number to display, will add each time this is executed.
; X = what index to modify.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BriefNumberDisplay:
	LDA !Freeram_NumberDisplayLowByte,x	;\Running total
	CLC					;|
	ADC $00					;|
	STA !Freeram_NumberDisplayLowByte,x	;|
	STA $00					;|
	LDA !Freeram_NumberDisplayHighByte,x	;|
	ADC $01					;|
	STA !Freeram_NumberDisplayHighByte,x	;|
	STA $01					;/
	LDA.b #60				;\Set timer of display
	STA !Freeram_DisplayTimer,x		;/
	
	JSL ConvertToDigits
	
	.RemoveLeadingZeroes
	LDY #$00
	
	..Loop
	LDA !HexDecDigitTable|!dp,y	;\if current digit non-zero, don't omit trailing zeros
	BNE .NonZero			;/
	LDA #$FC			;\blank tile to replace leading zero
	STA !HexDecDigitTable|!dp,y	;/
	INY				;>next digit
	CPY #$04			;>last digit to check (tens place). So that it can display a single 0.
	BCC ..Loop			;>if not done yet, continue looping.
	
	.NonZero
	.StatusBarWrite
	
	LDA TempNumbDisplayByte_MaxDigits,x		;\$00 contains the number of digits -1 to write
	STA $00						;/
	if !StatusBarFormat == $02
		ASL						;\Status bar addressing
	endif
	TAY						;/
	LDA TempNumbDisplayByte_StatusBarPos0,x		;\$08-$0A contains an address of the status bar to write.
	STA $08						;|
	LDA TempNumbDisplayByte_StatusBarPos1,x		;|
	STA $09						;|
	LDA TempNumbDisplayByte_StatusBarPos2,x		;|
	STA $0A						;/
	
	PHX
	LDX #$04
	.Loop
	;$00 = how many digits to write.
	;X = what digit
	;Y = what status bar address
	LDA !HexDecDigitTable,x
	STA [$08],Y
	
	..Next
	DEX						;>Next digit
	DEY #!StatusBarFormat				;>Next tile on status bar
	LDA $00						;\Number of digits to write
	DEC A						;|
	STA $00						;/
	BPL .Loop					;>If all digits written, break loop
	PLX
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;16-bit hex to 4 (or 5)-digit decimal subroutine
;Input:
;$00-$01 = the value you want to display
;Output:
;!HexDecDigitTable to !HexDecDigitTable+4 = a digit 0-9 per byte table (used for
; 1-digit per 8x8 tile):
; +$00 = ten thousands
; +$01 = thousands
; +$02 = hundreds
; +$03 = tens
; +$04 = ones
;
;!HexDecDigitTable is address $02 for normal ROM and $04 for SA-1.
;
;Note: Because SA-1's multiplication/division registers are signed,
;values over 32,767 ($7FFF) will glitch when you patch SA-1 on your
;game. Therefore, I added a Sa-1 detection to use an unsigned division
;as the SNES registers become inaccessible on SA-1 mode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ConvertToDigits:
	if !sa1 == 0
		PHX
		PHY

		LDX #$04	;>5 bytes to write 5 digits.

		.Loop
		REP #$20	;\Dividend (in 16-bit)
		LDA $00		;|
		STA $4204	;|
		SEP #$20	;/
		LDA.b #10	;\base 10 Divisor
		STA $4206	;/
		JSR .Wait	;>wait
		REP #$20	;\quotient so that next loop would output
		LDA $4214	;|the next digit properly, so basically the value
		STA $00		;|in question gets divided by 10 repeatedly. [Value/(10^x)]
		SEP #$20	;/
		LDA $4216	;>Remainder (mod 10 to stay within 0-9 per digit)
		STA $02,x	;>Store tile

		DEX
		BPL .Loop

		PLY
		PLX
		RTL

		.Wait
		JSR ..Done		;>Waste cycles until the calculation is done
		..Done
		RTS
	else
		PHX
		PHY

		LDX #$04

		.Loop
		REP #$20		;>16-bit XY
		LDA.w #10		;>Base 10
		STA $02			;>Divisor (10)
		SEP #$20		;>8-bit XY
		JSL MathDiv		;>divide
		LDA $02			;>Remainder (mod 10 to stay within 0-9 per digit)
		STA.b !HexDecDigitTable,x	;>Store tile

		DEX
		BPL .Loop

		PLY
		PLX
		RTL
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Clear digits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ClearBriefNumberDisplay:
	LDX.b #(!Setting_ChangeDisplay_TableSlots-1)
	
	.Loop
	LDA !Freeram_DisplayTimer,x		;\Decrement by 1 each frame until 0
	BEQ ..Next				;|
	DEC A					;|
	STA !Freeram_DisplayTimer,x		;/
	BNE ..Next				;>If decrements from 1 to 0, clear status bar.
	
	..ClearNumber
	LDA TempNumbDisplayByte_MaxDigits,x	;\Tell when to stop writing blank tiles.
	STA $00					;/
	if !StatusBarFormat == $02
		ASL
	endif
	TAY					;/
	
	LDA TempNumbDisplayByte_StatusBarPos0,x		;\$01-$03 contains an address of the status bar to write.
	STA $01						;|
	LDA TempNumbDisplayByte_StatusBarPos1,x		;|
	STA $02						;|
	LDA TempNumbDisplayByte_StatusBarPos2,x		;|
	STA $03						;/
	
	...Loop
	;$00 number of digits to clear (within the max number of digits)
	;Y = what tile to clear
	LDA #$FC
	STA [$01],y
	
	....NextTile
	DEY #!StatusBarFormat
	LDA $00					;\Number of digits left to clear.
	DEC A					;|
	STA $00					;/
	BPL ...Loop
	
	...Done
	LDA #$00
	STA !Freeram_NumberDisplayLowByte,x
	STA !Freeram_NumberDisplayHighByte,x
	
	..Next
	DEX
	BPL .Loop
	RTL