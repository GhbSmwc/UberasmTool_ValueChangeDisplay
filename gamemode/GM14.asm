incsrc "../ChangeInValueDisplayDefines/Defines.asm"
init:
	LDA #$00
	LDX.b #(!Setting_ChangeDisplay_TableSlots-1)
	-
	STA !Freeram_NumberDisplayLowByte,x
	STA !Freeram_NumberDisplayHighByte,x
	DEX
	BPL -
	RTL
main:
	LDX #$00
	LDA $16				;\Press up to increment number
	AND.b #%10000000		;|
	BEQ +				;/
	REP #$20			;\Display running total
	LDA #$0003			;|
	STA $00				;|
	SEP #$20			;|
	JSL Routines_BriefNumberDisplay	;/
	+
	LDX #$01
	LDA $16				;\Press up to increment number
	AND.b #%00000001		;|
	BEQ +				;/
	REP #$20			;\Display running total
	LDA #$0003			;|
	STA $00				;|
	SEP #$20			;|
	JSL Routines_BriefNumberDisplay	;/
	+
	
	
	;This must run once per frame:
	JSL Routines_ClearBriefNumberDisplay	;>Clear running total when it stops incrementing for a while.
	RTL