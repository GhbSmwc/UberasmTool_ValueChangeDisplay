incsrc "../ChangeInValueDisplayDefines/Defines.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Input:
; $00-$01: The number to display, will add each time this is executed.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BriefNumberDisplay:
	REP #$20			;\Show running total
	LDA !Freeram_NumberDisplay	;|
	CLC				;|
	ADC $00				;|
	STA !Freeram_NumberDisplay	;|
	STA $00				;|
	SEP #$20			;/
	LDA.b #60			;\Set timer of display
	STA !Freeram_DisplayTimer	;/
	
	JSL ConvertToDigits
	
	if !StatusBarFormat == $01
		LDX.b #4
		-
		LDA !HexDecDigitTable,x
		STA !Setting_StatusBar_DisplayPos,x
		DEX
		BPL -
	else
		LDX.b #4
		LDY.b #8
		-
		LDA !HexDecDigitTable,x
		PHX
		TYX
		STA !Setting_StatusBar_DisplayPos,x
		PLX
		DEX
		DEY #2
		BPL -
	endif
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
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ClearBriefNumberDisplay:
	LDA !Freeram_DisplayTimer		;\Decrement by 1 each frame until 0
	BEQ +					;|
	DEC A					;/
	STA !Freeram_DisplayTimer		
	BNE +					;>If decrements from 1 to 0, clear status bar.
	
	LDA #$FC
	LDX.b #(4)*!StatusBarFormat
	-
	STA !Setting_StatusBar_DisplayPos,x
	DEX #!StatusBarFormat
	BPL -
	
	LDA #$00
	STA !Freeram_NumberDisplay
	STA !Freeram_NumberDisplay+1
	+
	RTL