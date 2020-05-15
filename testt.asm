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
        JMP process        				;Aqui llamaremos a la interrupcion							*
										;************************************************************

end_main:
        MOV AX, 4C00H
        INT 21H

process:
        hex_to_dec PROC

            PUSH AX BX DX SI

            ;conv_dec_hex:
            MOV DX, 0
            MOV SI, 0

        comienzo_bucle:
            MOV AX, 0
            MOV AL, DS:[SI+BX+2] ; Salta los dos primeros caracteres
            CMP AL, 24H  ; 36, SI $ Salir del bucle
            JE fin_bucle

            SUB AX, 30H ; -48 Paso de ascii a numero decimal

            MOV CX, 0
            MOV CL, DS:[BX+1]; Tamaño de la cadena
            SUB CX, SI

            CMP CX, 5
            JE mul_5
            CMP CX, 4
            JE mul_4
            CMP CX, 3
            JE mul_3
            CMP CX, 2
            JE mul_2
            CMP CX, 1
            JE mul_1

        mul_5:
            MOV CX, 2710H
            JMP mul_eff
        mul_4:
            MOV CX, 03E8H
            JMP mul_eff
        mul_3:
            MOV CX, 064H
            JMP mul_eff
        mul_2:
            MOV CX, 0AH
            JMP mul_eff
        mul_1:
            MOV CX, 01H
            JMP mul_eff

        mul_eff:
            PUSH DX ; Guardar valor acumulado porque MUL usa DX
            MUL CX
            POP DX
            ADD DX, AX

            INC SI
            JMP comienzo_bucle

        fin_bucle:

            CADENA_FINAL DB 10 DUP (0)
            MOV BX, OFFSET CADENA_FINAL

            ; Obtener primeros dos digitos
            MOV SI, 0
            MOV CX, 0
            MOV CH, DH
            MOV CL, DH

            JMP get_digits

        ultimos_digitos:
            ;Obtener ultimos dos digitos
            MOV SI, 2
            MOV CX, 0
            MOV CH, DL
            MOV CL, DL

            JMP get_digits

        get_digits:
            SHR CL, 1 ; CL tendrá el primer digito
            SHR CL, 1
            SHR CL, 1
            SHR CL, 1

            SHL CH, 1 ; CH tendrá el segundo digito
            SHL CH, 1
            SHL CH, 1
            SHL CH, 1
            SHR CH, 1
            SHR CH, 1
            SHR CH, 1
            SHR CH, 1

            MOV WORD PTR[SI+BX], CX

            CMP SI, 0
            JE ultimos_digitos

            MOV SI, 4
            MOV WORD PTR[SI+BX], 24H ;

            ; Pasar de digitos hex a ascii

            MOV SI, 0
        bucle_ascii:
            MOV AX, 0
            MOV AL, DS:[SI+BX]
            CMP AL, 24H
            JE fin_bucle_ascii

            ; Comprobar si el digito se representa con una letra
            CMP AL, 0AH
            JE sum_letra
            CMP AL, 0BH
            JE sum_letra
            CMP AL, 0CH
            JE sum_letra
            CMP AL, 0DH
            JE sum_letra
            CMP AL, 0EH
            JE sum_letra
            CMP AL, 0FH
            JE sum_letra

            JMP sum_numero

        sum_letra:
            ADD AL, 37H
            JMP escribir_caracter

        sum_numero:
            ADD AL, 30H

        escribir_caracter:
            MOV DS:[SI+BX], AL

            INC SI
            JMP bucle_ascii

        fin_bucle_ascii:

            MOV CX, BX

            POP SI DX BX AX

        hex_to_dec ENDP

        JMP end_main


CODIGO  ENDS
        END inicio
