PILA    SEGMENT STACK "STACK"
        DW 40H DUP (0)
PILA    ENDS

CODIGO  SEGMENT
        ASSUME CS:CODIGO, SS:PILA

        MOV SP, 64

inicio:

        ;INT 60H

        MOV AX, 4C00H
        INT 21H

CODIGO  ENDS
        END inicio
