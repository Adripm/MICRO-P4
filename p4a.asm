;**************************************************************************
; SBM 2020.
;
; Autores:
;		   Adrián Palmero Martínez
;		   Daniel Molano Caraballo
;
; Grupo: 2211
;
;**************************************************************************

CODIGO  SEGMENT

        ASSUME CS:CODIGO, DS:CODIGO, ES:CODIGO

        ORG 256

inicio:
        JMP main

rutina_interrupcion:
        rutina_int60 PROC FAR

            PUSH AX BX DX SI

            CMP AH, 12H
            JE conv_dec_hex
            CMP AH, 13H
            JNE saltar_fin
            JMP conv_hex_dec ; Los saltos condicionales tienen un máximo de distancia

saltar_fin:
            JMP fin_rutina_int60h

conv_dec_hex:
            ;obtener valor de ds:bx

            MOV DX, 0
            MOV SI, 0
    comienzo_bucle:
            MOV AX, 0
            MOV AL, DS:[SI+BX+2] ; Salta los dos primeros caracteres
            CMP AL, 24H ; 36, $, salir de bucle
            JE fin_bucle

            SUB AX, 30H ; 48 ; Paso de ascii a numero decimal

            MOV CX, 0
            MOV CL, DS:[BX+1] ; Tamaño de la cadena
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
            PUSH DX ; Guardar valor acumulador porque MUL usa DX
            MUL CX  ; ax = ax * cx
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

            JMP fin_rutina_int60h
            ; FIN conv_dec_hex

conv_hex_dec:

            JMP fin_rutina_int60h
            ; FIN conv_hex_dec

fin_rutina_int60h:

            POP SI DX BX AX

            IRET

        rutina_int60 ENDP

;Instalador de la rutina
instalar:
        instalar_60h PROC
            MOV AX, 0
            MOV ES, AX
            MOV AX, OFFSET rutina_int60
            MOV BX, CS
            CLI
            MOV ES:[60H*4], AX
            MOV ES:[60H*4+2], BX
            STI
            MOV DX, OFFSET instalar_60h

            MOV AH, 9H
            LEA DX, MSG4
            INT 21H         ;Mensaje de instalación

            INT 27H
        instalar_60h ENDP

;Desinstalador de la rutina de INT 40h
desinstalar:
        desinstalar_60h PROC
            PUSH AX BX CX DS ES

            MOV CX, 0
            MOV DS, CX              ; Segmento de vectores interrupcion
            MOV ES, DS:[60H*4+2]    ; Lee segmento RSI
            MOV BX, ES:[2CH]        ; Lee segmento de entorno del PSP de RSI

            MOV AH, 49H
            INT 21H                 ; Libera segmento de RSI (es)
            MOV ES, BX
            INT 21H                 ; Libera segmento de variables de entorno de RSI

            CLI                     ; Pone a cero vecto de interrumpción 40h
            MOV DS:[60H*4], CX
            MOV DS:[60H*4+2], CX
            STI

            POP ES DS CX BX AX
            RET
        desinstalar_60h ENDP

main:   ; Código principal
        ; Guarda los dos primeros caracteres de los argumentos en el registro AX
        ; (orden inverso)

        MOV AX, DS:[82H] ; Acceso al PSP

        ; Argumentos:   /D => AX = 442F
        ;               /I => AX = 492F

        CMP AX, 442FH
        JE argumento_d

        CMP AX, 492FH
        JE argumento_i

        ; Si no existen los argumentos /D ni /I

        JMP no_args

argumento_d:
        ; Ejecucion con /D
        CALL desinstalar_60h

        MOV AH, 9H
        LEA DX, MSG3
        INT 21H

        JMP fin

argumento_i:
        ; Ejecucion con /I
        CALL instalar_60h
        ; La funcion instalar termina el programa con la interrupcion INT 27H

no_args:
        ; Ejecucion sin argumentos

        ; Mostrar estado de instalación del driver (instalado o no), grupo,
        ; nombres de los componentes de la pareja e instrucciones de uso
        MOV AH, 9H

        LEA DX, MSG1
        INT 21H

        LEA DX, MSG2
        INT 21H

        MOV AX, 0
        MOV ES, AX

        MOV AX, ES:[60H*4] ;
        LEA BX, rutina_int60

        CMP AX, BX
        JE instalado

        MOV AH, 9H
        LEA DX, MSG6
        INT 21H

        JMP fin
instalado:

        MOV AH, 9H
        LEA DX, MSG5
        INT 21H

        JMP fin

fin:
        INT 20H ; Fin del programa

        ;DATOS
        MSG1 DB 'Adrian Palmero y Daniel Molano',0DH,0AH,"Grupo 2211",0DH,0AH,'$'
        MSG2 DB 'Argumentos:',0DH,0AH,"- /I: Instalar",0DH,0AH,"- /D: Desinstalar",0DH,0AH,'$'
        MSG3 DB 'Desinstalacion terminada','$'
        MSG4 DB 'Instalacion terminada','$'
        MSG5 DB 'El driver se encuentra instalado','$'
        MSG6 DB 'El driver no esta instalado','$'

CODIGO  ENDS
        END inicio
