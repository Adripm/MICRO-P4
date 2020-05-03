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

        ASSUME CS:CODIGO

        ORG 256

inicio:
        JMP main

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
            INT 27H
        instalar_60h ENDP

;Desinstalador de la rutina de INT 40h
desinstalar:
        desinstalar_60h PROC
            PUSH AX BX CX DS ES

            MOV CX, 0
            MOV DS, CX
            MOV ES, DS:[60H*4+2]
            MOV BX, ES:[2CH]

            MOV AH, 49H
            INT 21H
            MOV ES, BX
            INT 21H

            CLI
            MOV DS:[60H*4], CX
            MOV DS:[60H*4+2], CX
            STI

            POP ES DS CX BX AX
            RET
        desinstalar_60h ENDP


rutina_interrumpcion:
        rutina_int60 PROC FAR

        rutina_int60 ENDP

main: ;Código principal

        MOV AX, 4C00H ; Fin del programa
        INT 21H

CODIGO  ENDS
        END inicio
