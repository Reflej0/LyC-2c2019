include macros2.asm 


.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 40

.DATA
    _45 dd 45.0
    var2 dd 45.0
    _2_3 dd 2.3
    _1 dd 1.0
    _2 dd 2.0
    _70 dd 70.0
    _5 dd 5.0
    _3 dd 3.0
    _6 db '6','$', 1 dup (?)
    _asd db 'asd','$', 3 dup (?)
    prueba db 'asd','$', 3 dup (?)
    _filter dd ?
    _6_5 dd 6.5
    _4 dd 4.0
    _99_2 dd 99.2
    _1_99 dd 1.99
    _test db 'test','$', 4 dup (?)
    _666 dd 666.0
    _123 dd 123.0
    r dd ?
    d dd ?
    c dd ?
    b dd ?
    a dd ?
    var1 db MAXTEXTSIZE dup (?),'$'
    b1 dd ?
    a1 dd ?
    z db MAXTEXTSIZE dup (?),'$'
    e1 dd ?
    c1 dd ?
    _SUM dd ?
    _MINUS dd ?
    _DIVIDE dd ?
    _MULTIPLY dd ?
    _AUXILIAR dd ?


.code
    begin: .startup
    mov AX,@DATA
    mov DS,AX
    mov ES,AX
    finit



    ; ROUTINES
STRLEN PROC
    mov bx,0
STRL01:
    cmp BYTE PTR [SI+BX],'$'
    je STREND
    inc BX
    cmp BX, MAXTEXTSIZE
    jl STRL01
STREND:
    ret
STRLEN ENDP

COPY PROC
    call STRLEN
    cmp bx,MAXTEXTSIZE
    jle COPYSIZEOK
    mov bx,MAXTEXTSIZE
COPYSIZEOK:
    mov cx,bx
    cld
    rep movsb
    mov al,'$'
    mov BYTE PTR [DI],al
    ret
COPY ENDP




    ; ASIGNACION 
    FLD _123
    FSTP b

    ; ASIGNACION 
    FLD _666
    FSTP c

    ; ASIGNACION 
    FLD b
    FSTP a

    ; ASIGNACION 
    LEA SI, _test
    LEA DI,var1
    CALL COPY

    ; ASIGNACION 
    LEA SI, _1_99
    LEA DI,a1
    CALL COPY

    ; ASIGNACION 
    LEA SI, _99_2
    LEA DI,b1
    CALL COPY

    ; SUMA 
    FLD _4
    FLD r
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; > 
    FLD d
    FLD _SUM
    FCOM
    JLE LABEL_IF_1

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; <= 
    FLD d
    FLD _6_5
    FCOM
    JG LABEL_IF_1

    ; ASIGNACION 
    FLD d
    FSTP _filter
LABEL_IF_1:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; > 
    FLD c
    FLD _SUM
    FCOM
    JLE LABEL_IF_3

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; <= 
    FLD c
    FLD _6_5
    FCOM
    JG LABEL_IF_3

    ; ASIGNACION 
    FLD c
    FSTP _filter
LABEL_IF_3:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; > 
    FLD b
    FLD _SUM
    FCOM
    JLE LABEL_IF_5

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; <= 
    FLD b
    FLD _6_5
    FCOM
    JG LABEL_IF_5

    ; ASIGNACION 
    FLD b
    FSTP _filter
LABEL_IF_5:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; > 
    FLD a
    FLD _SUM
    FCOM
    JLE LABEL_IF_7

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; <= 
    FLD a
    FLD _6_5
    FCOM
    JG LABEL_IF_7

    ; ASIGNACION 
    FLD a
    FSTP _filter
LABEL_IF_7:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; SUMA 
    FLD a
    FLD _filter
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _SUM
    FSTP a

    ; ASIGNACION 
    LEA SI, _asd
    LEA DI,prueba
    CALL COPY

    ; READ
    getString d

    ; PRINT
    displayString _6

    ; MULTIPLICA 
    FLD a
    FLD _3
    FMUL
    FSTP _MULTIPLY

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; < 
    FLD a
    FLD _MULTIPLY
    FCOM
    JGE LABEL_IF_10

    ; ASIGNACION 
    FLD _5
    FSTP a

    ; > 
    FLD a
    FLD c
    FCOM
    JLE LABEL_IF_11

    ; SUMA 
    FLD a
    FLD _5
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _SUM
    FSTP a
LABEL_IF_11:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; RESTA 
    FLD a
    FLD _5
    FSUB
    FSTP _MINUS

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _MINUS
    FSTP a
LABEL_IF_10:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; > 
    FLD _3
    FLD _4
    FCOM
    JLE LABEL_IF_15

    ; SUMA 
    FLD a
    FLD b
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; SUMA 
    FLD _SUM
    FLD _70
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _SUM
    FSTP c
LABEL_IF_15:

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


LABEL_REPEAT_0:

    ; ASIGNACION 
    LEA SI, _2_3
    LEA DI,a
    CALL COPY

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _1
    FSTP _1

    ; DIVIDE 
    FLD _5
    FLD a
    FDIV
    FSTP _DIVIDE

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; RESTA 
    FLD _DIVIDE
    FLD _2
    FSUB
    FSTP _MINUS

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; SUMA 
    FLD _MINUS
    FLD _1
    FADD
    FSTP _SUM

    ; STACK CLENUP
    FFREE st(0)
    FFREE st(1)
    FFREE st(2)
    FFREE st(3)
    FFREE st(4)
    FFREE st(5)
    FFREE st(6)
    FFREE st(7)


    ; ASIGNACION 
    FLD _SUM
    FSTP b

    JMP LABEL_REPEAT_0

LABEL_REPEAT_OUT_0:

    ; ASIGNACION 
    FLD _45
    FSTP var2



    ; END PROGRAM 

    mov AX, 4C00h
    int 21h
END begin
