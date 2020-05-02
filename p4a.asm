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

; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
        ASSUME CS: CODE

        ORG 256

        INICIO PROC NEAR

            instalar: JMP instalador

            ;Fin del programa
            MOV AX, 4C00H
            INT 21H

        INICIO ENDP

        ;Rutina de servicio a la interrupción
        rsi PROC FEAR
        rsi ENDP

        ;Instalador
        instalador PROC
        instalador ENDP


; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
END INICIO
