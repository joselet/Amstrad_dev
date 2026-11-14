; ===========================================================
;  hola.asm - Primer programa para Amstrad CPC
;  Muestra un mensaje, espera una tecla y reinicia la máquina.
; ===========================================================

        org #4000               ; Dirección de memoria donde se carga el programa

inicio:
        ld hl,mensaje           ; HL apunta al primer carácter del mensaje
bucle:
        ld a,(hl)               ; A = carácter actual
        or a                    ; ¿Es 0 (fin del texto)?
        jr z,espera             ;   sí -> dejamos de imprimir
        call #BB5A              ; TXT OUTPUT (firmware): imprime el carácter en A
        inc hl                  ; siguiente carácter
        jr bucle

espera:
        call #BB06              ; KM WAIT CHAR (firmware): espera a que se pulse una tecla
        rst 0                   ; Salta a la dirección 0 = reinicio completo del CPC

mensaje:
        db "Pulsa una tecla...",0

fin:

; --- Genera HOLA.BIN dentro de la imagen de disco hola.dsk ---
        save "hola.bin",inicio,fin-inicio,DSK,"build/hola.dsk"
