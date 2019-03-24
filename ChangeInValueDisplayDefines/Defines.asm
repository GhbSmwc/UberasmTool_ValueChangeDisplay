;Size of table:
 !Setting_ChangeDisplay_TableSlots = 4
 ;^Number of slots (which is how many number displays).

;Freeram addresses
 if !sa1 == 0
  !Freeram_NumberDisplayLowByte = $7FAD49
 else
  !Freeram_NumberDisplayLowByte = $4001B9
 endif
  ;^[BytesUsed = !Setting_ChangeDisplay_TableSlots]
  ;Number to display (low byte).
  
 if !sa1 == 0
  !Freeram_NumberDisplayHighByte = $7FAD4D
 else
  !Freeram_NumberDisplayHighByte = $4001BB
 endif
  ;^[BytesUsed = !Setting_ChangeDisplay_TableSlots]
  ;Number to display (high byte).
  
 if !sa1 == 0
  !Freeram_DisplayTimer = $7FAD51
 else
  !Freeram_DisplayTimer = $4001BF
 endif
  ;^[BytesUsed = !Setting_ChangeDisplay_TableSlots]
  ; Timer (in frames) for the duration of the number to stay before disappearing.

;Status bar stuff
 !StatusBarFormat                     = $02
  ;^Number of grouped bytes per 8x8 tile for the status bar (not the overworld border):
  ; $01 = each 8x8 tile have two bytes each separated into "tile numbers" and "tile properties" group;
  ;       Minimalist/SMB3 [TTTTTTTT, TTTTTTTT]...[YXPCCCTT, YXPCCCTT] or SMW's default ([TTTTTTTT] only).
  ; $02 = each 8x8 tile byte have two bytes located next to each other;
  ;       Super status bar/Overworld border plus [TTTTTTTT YXPCCCTT, TTTTTTTT YXPCCCTT]...

 !Setting_StatusBar_DisplayPos = $7FA000
  ;^position to write the numbers as well as clearing the tiles a while later.

;Other settings:
 !ClearTile = $FC
  ;^Blank tile when the numbers disappear.
  ; Some tile examples:
  ; $FC = blank tile
  ; $27 = "-"
;Don't touch
 !HexDecDigitTable = $02
 if !sa1 != 0
  !HexDecDigitTable = $04
 endif

;Display memory range:
 print "-----------------------------------------------------------------------------------------------"
 print "Freeram_NumberDisplayLowByte: $", hex(!Freeram_NumberDisplayLowByte), " to $", hex(!Freeram_NumberDisplayLowByte+(!Setting_ChangeDisplay_TableSlots-1))
 print "Freeram_NumberDisplayHighByte: $", hex(!Freeram_NumberDisplayHighByte), " to $", hex(!Freeram_NumberDisplayHighByte+(!Setting_ChangeDisplay_TableSlots-1))
 print "Freeram_DisplayTimer: $", hex(!Freeram_DisplayTimer), " to $", hex(!Freeram_DisplayTimer+(!Setting_ChangeDisplay_TableSlots-1))
 print "-----------------------------------------------------------------------------------------------"