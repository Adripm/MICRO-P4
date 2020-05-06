;****************************************************************************************************
; SBM 2020. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR											*	
;																									*
; Autores:																							*
;		   Adrián Palmero Martínez																	*
;		   Daniel Molano Caraballo																	*
;																									*
; Grupo: 2211 																						*
;																									*
;****************************************************************************************************

; DATA SEGMENT DEFINITION
DATOS   SEGMENT
        CADENA DB 10 DUP (0)
DATOS   ENDS

; STACK SEGMENT DEFINITION
PILA    SEGMENT STACK "STACK"
        DB 40H DUP (0)
PILA    ENDS

; EXTRA SEGMENT DEFINITION
EXTRA   SEGMENT
EXTRA   ENDS

; DATA SEGMENT DEFINITION
CODIGO  SEGMENT
        ASSUME CS:CODIGO, DS:DATOS, ES:EXTRA, SS:PILA

        MOV AX, DATOS
        MOV DS, AX

        MOV AX, PILA
        MOV SS, AX

        MOV AX, EXTRA
        MOV ES, AX

        MOV SP, 64

;****************************************************************************************************
; En el siguiente codigo se pedira una cadena, numero entero, por pantalla y se llamara a la in- 	*
; terrupción 60h, en la cual se ejecutara el driver instalado previamente el cual transformara    	*
; la cadena dada a hexadecimal																		*
;****************************************************************************************************

INICIO:
										;************************************************************
        MOV AH, 0AH						;En el siguiente bloque de datos se solicitara por pantalla *	
        MOV DX, OFFSET CADENA			;la cadena a transformar.									*
        MOV CADENA[0],10				;Esta contiene un numero entero de maximo 5 digitos			*
        INT 21H							;************************************************************
		
										;************************************************************
        LEA SI, CADENA+1				;En el siguiente bloque cambiaremos el ultimo caracter de 	*
        MOV AX, 0H						;la cadena, aquel que se introduce al pulsar la tecla ENTER *
        MOV AL, [SI]					;por el caracter "$"										*
        MOV DI, AX						;															*
        MOV BYTE PTR[DI+CADENA+2], 36	;************************************************************

										;************************************************************
        MOV AH, 12H						;En el siguiente bloque bloque cargaremos en BX la direccion*
        LEA BX, CADENA					;de la cadena donde se encuentra el numero entero			*
										;************************************************************
										
										;************************************************************
        INT 60H         				;Aqui llamaremos a la interrupcion							*
										;************************************************************

        MOV AX, 4C00H
        INT 21H


CODIGO  ENDS
        END inicio
