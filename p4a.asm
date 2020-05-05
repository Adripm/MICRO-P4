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

            CMP AH, 12H
            JE conv_dec_hex
            CMP AH, 13H
            JE conv_hex_dec

            JMP fin_rutina_int60h

conv_dec_hex:
            ;obtener valor de ds:bx

            JMP fin_rutina_int60h

conv_hex_dec:

            JMP fin_rutina_int60h

fin_rutina_int60h:
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
        MSG1 DB 'Adrian Palmero y Daniel Molano',0DH,0AH,"Grupo 2212",0DH,0AH,'$'
        MSG2 DB 'Argumentos:',0DH,0AH,"- /I: Instalar",0DH,0AH,"- /D: Desinstalar",0DH,0AH,'$'
        MSG3 DB 'Desinstalacion terminada','$'
        MSG4 DB 'Instalacion terminada','$'
        MSG5 DB 'El driver se encuentra instalado','$'
        MSG6 DB 'El driver no esta instalado','$'

CODIGO  ENDS
        END inicio
