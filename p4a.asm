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
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
DATOS ENDS


;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
        DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS


;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
EXTRA ENDS


;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
        ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA

        ; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
        INICIO PROC NEAR
        ; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
        MOV AX, DATOS
        MOV DS, AX
        MOV AX, PILA
        MOV SS, AX
        MOV AX, EXTRA
        MOV ES, AX
        MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
        ; FIN DE LAS INICIALIZACIONES

        ; ---------------------------------
        ; COMIENZO DEL PROGRAMA



        ; FIN DEL PROGRAMA
        ; ---------------------------------

        MOV AX, 4C00H
        INT 21H
        INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS

; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO
