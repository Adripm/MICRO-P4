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
        instalar_40h PROC

        instalar_40h ENDP

;Desinstalador de la rutina de INT 40h
desinstalar:
        desinstalar_40h PROC

        desinstalar_40h ENDP


rutina_interrumpcion:
        rutina_int60 PROC FAR

        rutina_int60 ENDP

main: ;Código principal


CODIGO  ENDS
        END inicio
