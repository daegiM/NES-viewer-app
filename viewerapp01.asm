



;Variables
L_byte         = $0000
H_byte         = $0001
bg_X_pos       = $0002
bg_Y_pos       = $0003
NMI_index      = $0004



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;iNES header data (16bytes)
;32KB PRG + 8KB CHR + NROM-256 + Vertical Mirroring
  .db $4E,$45,$53,$1A,$02,$01,$01,$00
  .db $00,$00,$00,$00,$00,$00,$00,$00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRG codes $8000 ~ $FFFF (32KB)
  .base $8000


RESET:
   SEI
   CLD

;Turn off NMI and rendering
   LDA #%00000000
   STA $2000
   LDA #%00000000
   STA $2001

;PPU warm up
   LDA $2002
vBlank_wait1:
   BIT $2002
   BPL vBlank_wait1
vBlank_wait2:
   BIT $2002
   BPL vBlank_wait2

;Clear RAM
   LDA #$00
   LDX #$00
clear_loop:
   STA $0000, X
   STA $0100, X
   STA $0200, X
   STA $0300, X
   STA $0400, X
   STA $0500, X
   STA $0600, X
   STA $0700, X
   INX
   CPX #$00
   BNE clear_loop

;Name table + Attribute
   LDA $2002
   LDA #$20
   STA $2006
   LDA #$00
   STA $2006
   LDA #<bg_nam
   STA L_byte
   LDA #>bg_nam
   STA H_byte
   LDX #$00
   LDY #$00
nam_loop:
   LDA ($00), Y
   STA $2007
   INY
   CPY #$00
   BNE nam_loop
   INC H_byte
   INX
   CPX #$04
   BNE nam_loop

;Background color setup
   LDA $2002
   LDA #$3F
   STA $2006
   LDA #$00
   STA $2006
   LDX #$00
bg_pal_loop:
   LDA bg_pal, X
   STA $2007
   INX
   CPX #$10
   BNE bg_pal_loop

;Reset Scroll
   LDA #$00
   STA $2005
   LDA #$00
   STA $2005
   
;Turn on NMI and rendering
   LDA #%00000000
   STA $2000
   LDA #%00001010
   STA $2001

   
;Prepare controllers to read
prepare:
   LDA #$01
   STA $4016
   LDA #$00
   STA $4016





;Prepare controllers to read
   LDA #$01
   STA $4016
   LDA #$00
   STA $4016

;Check A
   LDA $4016
   AND #%00000001
   CMP #%00000001
   bne prepare
reset02:   
   SEI
   CLD 

;Turn off NMI and rendering
   LDA #%00000000
   STA $2000
   LDA #%00000000
   STA $2001

;PPU warm up
   LDA $2002
vBlank_wait01:
   BIT $2002
   BPL vBlank_wait01
vBlank_wait02:
   BIT $2002
   BPL vBlank_wait02

   LDA #$00
   LDX #$00
clear_loop02 :
   STA $0000, X
   STA $0100, X
   STA $0200, X
   STA $0300, X
   STA $0400, X
   STA $0500, X
   STA $0600, X
   STA $0700, X
   INX
   CPX #$00
   BNE clear_loop02
   LDA $2002
   LDA #$20
   STA $2006
   LDA #$00
   STA $2006
   LDA #<bg_nam01
   STA L_byte
   LDA #>bg_nam01
   STA H_byte
   LDX #$00
   LDY #$00
nam_loop02:
   LDA ($00), Y
   STA $2007
   INY
   CPY #$00
   BNE nam_loop02
   INC H_byte
   INX
   CPX #$04
   BNE nam_loop02
   
;Background color setup
   LDA $2002
   LDA #$3F
   STA $2006
   LDA #$00
   STA $2006
   LDX #$00
bg_pal_loop02:
   LDA bg_pal01, X
   STA $2007
   INX
   CPX #$10
   BNE bg_pal_loop02



;Reset Scroll
   LDA #$00
   STA $2005
   LDA #$00
   STA $2005
   
   
;Turn on NMI and rendering
   LDA #%00000000
   STA $2000
   LDA #%00001010
   STA $2001


A_not_pressed : 

forever :

jmp forever


;---------------------------;
vblank_wait:
   LDA NMI_index
not_yet:
   CMP NMI_index
   BEQ not_yet
   RTS   
;---------------------------;
NMI:
   INC NMI_index
   RTI
;---------------------------;
IRQ:
   RTI
;---------------------------;

bg_nam:
  .incbin "pic0501.nam"

bg_pal:
  .incbin "pic05.pal"

bg_nam01:
  .incbin "pic0502.nam"

bg_pal01:
  .incbin "pic05.pal"
;---------------------------;  
  .pad $FFFA,$FF   
;Vectors
  .org $FFFA
  .dw NMI
  .dw RESET
  .dw IRQ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CHR data $0000 ~ $1FFF (8KB)
  .base $0000
  .incbin "pic05.chr"
  .pad $2000,$FF                   ; add instructions here to do something when button IS pressed (1)
