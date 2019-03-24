;Freeram addresses
 if !sa1 == 0
  !Freeram_NumberDisplay = $60
 else
  !Freeram_NumberDisplay = $60
 endif
  ;^[2 bytes] Number to display.
  
 if !sa1 == 0
  !Freeram_DisplayTimer = $62
 else
  !Freeram_DisplayTimer = $62
 endif
  ;^[1 byte] Timer (in frames) for the duration of the number to stay before disappearing.

;Status bar stuff
 !StatusBarFormat                     = $02
  ;^Number of grouped bytes per 8x8 tile for the status bar (not the overworld border):
  ; $01 = each 8x8 tile have two bytes each separated into "tile numbers" and "tile properties" group;
  ;       Minimalist/SMB3 [TTTTTTTT, TTTTTTTT]...[YXPCCCTT, YXPCCCTT] or SMW's default ([TTTTTTTT] only).
  ; $02 = each 8x8 tile byte have two bytes located next to each other;
  ;       Super status bar/Overworld border plus [TTTTTTTT YXPCCCTT, TTTTTTTT YXPCCCTT]...

 !Setting_StatusBar_DisplayPos = $7FA000
  ;^position to write the numbers as well as clearing the tiles a while later.

;Don't touch
 !HexDecDigitTable = $02
 if !sa1 != 0
  !HexDecDigitTable = $04
 endif