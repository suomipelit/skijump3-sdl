MODEL TPASCAL
IDEAL
JUMPS
P386

EXTRN  SegA000:Word, Graffa:Word, SiirtoOsoite:dWord, SivuKoko:Word, \
       Video:Word, LinjanPituus:Word, X:dWord, Y:dWord

PUBLIC KopioiKirjoitusSivu, LueTavu, KirjoitaTavu, \
       KopioiMaki, KopioiRuutu, Sprite

 rivinvaihto equ 704
 ruudunloppu equ 64000
 
; ==========================================================================

MACRO Siirra label
label:
  Mov EAX,[ESI]
  Mov [ES:DI],EAX
  Add ESI,4
  Add DI, 4
  Loop label
ENDM

MACRO SiirraB label
label:
  Mov al,[ESI]
  Mov [ES:DI],al
  Inc ESI
  Inc DI
  Loop label
ENDM

CODESEG ;-------------------------------------------------------------------

PROC   KopioiKirjoitusSivu
  Push DS
  Mov  ESI,[SiirtoOsoite]
  Mov  CX, [SivuKoko]
  Mov  ES, [Video]
  Xor  DI, DI
  Mov  DS, [Graffa]
  Shr  CX, 2

@kks_loop1:
  Mov EAX,[ES:DI]
  Mov [ESI],EAX
  Add ESI,4
  Add DI, 4
  Loop @kks_loop1

  Pop  DS
  RET
ENDP

PROC   LueTavu Osoite:dWord
  Mov  ES, [Graffa]
  Mov  EDI,[Osoite]
  Mov  AL, [ES:EDI]
  RET
ENDP


PROC   KirjoitaTavu Osoite:dWord, Arvo:Byte
  Mov  ES, [Graffa]
  Mov  EDI,[Osoite]
  Mov  AL, [Arvo]
  Mov  [ES:EDI],AL
  RET
ENDP

PROC   KopioiMaki AlkuOsoite:dWord, Delta:dWord
  Mov  AX, DS
  Mov  GS, AX
  Mov  ES, [Video]
  Xor  DI, DI
  Lea  BX, [LinjanPituus]
  Mov  AX, [word Y]
  Add  BX, AX
  Add  BX, AX
  Mov  DS, [Graffa]
  Mov  ESI,[AlkuOsoite]

@km_seuraavalinja:
    Mov  DX, [GS:BX]
    Mov  EAX,[GS:X]
    Add  ESI,EAX
    Sub  DX, AX
    Jle  @km_SkyOnly
    Cmp  DX, 320
    Jae  @km_GroundOnly

@km_skip0:
    Mov  CX, DX
    Shr  CX, 2
    Jz   short @km_skip1
    Siirra @km_loop1
  @km_skip1:
    Mov  AX, DX
    And  AX, 3
    Cmp  AX, 1
    Jl   short @km_tapaus1
    Je   short @km_tapaus2
    Ja   short @km_tapaus3

    @km_tapaus4:
      Mov AX,[ESI]
      Mov cl,[ESI+2]
      Mov [ES:DI],AX
      Mov [ES:DI+2],cl
      Add ESI,[Delta]
      Mov al,[ESI+3]
      Mov [ES:DI+3],al
      Jmp short @km_jatka

    @km_tapaus3:
      Cmp AX,3
      Je  short @km_tapaus4
      Mov AX,[ESI]
      Mov [ES:DI],AX
      Add ESI,[Delta]
      Mov AX,[ESI+2]
      Mov [ES:DI+2],AX
      jmp short @km_jatka

    @km_tapaus2:
      Mov al,[ESI]
      Mov [ES:DI],al
      Add ESI,[Delta]
      Mov cl,[ESI+1]
      Mov AX,[ESI+2]
      Mov [ES:DI+1],cl
      Mov [ES:DI+2],AX
      jmp short @km_jatka

    @km_tapaus1:
      Add ESI,[Delta]
      Mov EAX,[ESI]
      Mov [ES:DI],EAX

  @km_jatka:
    Add  ESI,4
    Add  DI, 4
    Mov  CX, DX
    Shr  CX, 2
    Neg  CX
    Add  CX, 79
    Jle  short @km_skip2
    Siirra @km_loop2
  @km_skip2:
    Sub  ESI,[GS:X]
    Sub  ESI,[Delta]
    Add  BX,2
    Add  ESI,RivinVaihto
    cmp  DI,ruudunloppu
    Jb   @km_seuraavalinja
    jmp  short @km_loppu

  @km_skyonly:
    Add  ESI,[Delta]
    Mov  CX, 80
    Siirra @km_loop3
    jmp  short @km_skip2

  @km_groundonly:
    Mov  CX, 80
    Siirra @km_loop4
    Add  ESI,[Delta]
    jmp  short @km_skip2

@km_loppu:
  Mov  AX, GS
  Mov  DS, AX

  RET
ENDP


PROC   KopioiRuutu
  Push DS
  Mov  ES, [SegA000]
  Xor  DI, DI
  Mov  DS, [Video]
  Xor  ESI,ESI
  Mov  CX, 16000

  Siirra @dkm_loop1

  Pop  DS
  RET
ENDP


PROC   Sprite SpriteData:Word, _X_:Word, _Y_:Word
local Height:word
  Push DS
  Mov  ES,[Video]
  Mov  AX,[_Y_]
  Mov  DI,AX
  Shl  AX,8     ;DI=Y*320
  Shl  DI,6     ;
  Add  DI,AX
  Add  DI,[_X_] ;DI+X
  Mov  DS,[SpriteData]
  Mov  SI,4
  Mov  DX,[DS:0]
  Mov  BX,DX    ;BX=skip
  Add  BX,[_X_]
  Sub  BX,320
  Ja   @s_skip2
  Xor  BX,BX    ;BX=0
@s_skip2:
  Sub  DX,BX
  Jle  short @s_quit
  Mov  AX,[DS:2]
  Mov  [Height],AX
@s_loop1:
  Mov  CX,DX
@s_loop2:
  LodSB
  Cmp  al,0
  Jz   short @s_skip1
  Mov  [ES:DI],al
@s_skip1:
  Inc  DI
  loop @s_loop2
  Add  DI,320
  Add  SI,BX
  Sub  DI,DX
  Dec  [Height]
  Jnz  short @s_loop1
@s_quit:
  Pop  DS
  RET
ENDP

PROC   OldSprite SpriteData:Word, _X_:Word, _Y_:Word
  Push DS
  Mov  ES,[Video]
  Mov  AX,[_Y_]
  Mov  DI,AX
  Shl  AX,8     ;DI=Y*320
  Shl  DI,6     ;
  Add  DI,AX
  Add  DI,[_X_] ;DI+X
  Mov  DS,[SpriteData]
  Mov  SI,4
  Mov  DX,[DS:0]
  Mov  BX,[DS:2]
@os_loop1:
  Mov  CX,DX
@os_loop2:
  LodSB
  Cmp  al,0
  Jz   short @os_skip1
  Mov  [ES:DI],al
@os_skip1:
  Inc  DI
  loop @os_loop2
  Add  DI,320
  Sub  DI,DX
  Dec  BX
  Jnz  short @os_loop1
  Pop  DS
  RET
ENDP

ENDS
END ;-----------------------------------------------------------------------
