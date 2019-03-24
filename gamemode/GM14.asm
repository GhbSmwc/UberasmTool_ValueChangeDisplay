main:
	LDA $16				;\Press up to increment number
	AND.b #%10000000		;|
	BEQ +				;/
	REP #$20			;\Display running total
	LDA #$0003			;|
	STA $00				;|
	SEP #$20			;|
	JSL Routines_BriefNumberDisplay	;/
	+
	
	JSL Routines_ClearBriefNumberDisplay	;>Clear running total when it stops incrementing for a while.
	RTL