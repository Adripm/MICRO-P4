DATOS   SEGMENT
        CADENA DB 10 DUP (0)
DATOS   ENDS

PILA    SEGMENT STACK "STACK"
        DB 40H DUP (0)
PILA    ENDS

EXTRA   SEGMENT
EXTRA   ENDS

CODIGO  SEGMENT
        ASSUME CS:CODIGO, DS:DATOS, ES:EXTRA, SS:PILA

        MOV AX, DATOS
        MOV DS, AX

        MOV AX, PILA
        MOV SS, AX

        MOV AX, EXTRA
        MOV ES, AX

        MOV SP, 64

inicio:

        MOV AH, 0AH
        MOV DX, OFFSET CADENA
        MOV CADENA[0],10
        INT 21H

        LEA SI, CADENA+1
        MOV AX, 0H
        MOV AL, [SI]
        MOV DI, AX
        MOV BYTE PTR[DI+CADENA+2], 36

        MOV AH, 12H
        LEA BX, CADENA
        INT 60H         ;Llamada a la interrumpcion

        LEA CX, CADENA[2] ; prueba

        MOV AH, 9H
        MOV DX, CX
        INT 21H

        MOV AX, 4C00H
        INT 21H


CODIGO  ENDS
        END inicio
