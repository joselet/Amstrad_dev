; ===========================================================
;  os.asm - Amstrad OS, versión 0.0 (prueba de arranque)
;
;  Toma el control total del CPC: sin firmware ni ROM, con su
;  propio manejador de interrupciones y escribiendo directamente
;  en el hardware. Todavía no hay shell: solo comprueba que la
;  cadena de compilación funciona y que la máquina es nuestra.
; ===========================================================

FUENTE  equ #9000               ; 2 KB para la fuente 8x8 (ver referencia/mapa.md)
VARS    equ #8F00               ; variables en RAM, separadas del código (futura versión ROM)
ticks   equ VARS                ; contador de interrupciones (300 por segundo)

PANTALLA equ #C000
; Dirección en pantalla (modo 2, desplazamiento 0) de la fila f y la columna c
macro DIRPANT f,c
        ld de,PANTALLA+{f}*80+{c}
mend

        org #4000

inicio:
        di                      ; a partir de aquí, nadie nos interrumpe
        ld sp,#C000             ; pila propia justo debajo de la pantalla

; --- 1. Copiar la fuente de la ROM inferior (#3800) a RAM ---
        ld bc,#7F8A             ; Gate Array: modo 2, ROM inferior ACTIVADA, superior no
        out (c),c
        ld hl,#3800             ; matriz de caracteres de la ROM (256 x 8 bytes)
        ld de,FUENTE
        ld bc,#0800
        ldir                    ; leemos de ROM y escribimos en RAM

; --- 2. Desactivar las dos ROM: a partir de aquí, solo RAM ---
        ld bc,#7F8E             ; Gate Array: modo 2, sin ROM inferior ni superior
        out (c),c

; --- 3. Paleta: fondo y borde azules, texto amarillo ---
        ld hl,paleta
        ld e,3                  ; 3 parejas (pluma, color)
pal_bucle:
        ld a,(hl)               ; pluma (o #10 = borde)
        out (c),a               ; B sigue valiendo #7F (puerto del Gate Array)
        inc hl
        ld a,(hl)               ; color hardware (#40 + código)
        out (c),a
        inc hl
        dec e
        jr nz,pal_bucle

; --- 4. CRTC: la pantalla empieza en #C000 sin desplazamiento ---
        ld bc,#BC0C             ; registro 12
        out (c),c
        ld bc,#BD30             ; #30 -> bloque #C000
        out (c),c
        ld bc,#BC0D             ; registro 13
        out (c),c
        ld bc,#BD00             ; desplazamiento 0
        out (c),c

; --- 5. Borrar la pantalla (todo a pluma 0) ---
        ld hl,PANTALLA
        ld de,PANTALLA+1
        ld bc,#3FFF
        ld (hl),0
        ldir

; --- 6. Nuestro manejador de interrupciones en #0038 (IM 1) ---
        xor a
        ld (ticks),a
        ld a,#C3                ; código de JP nn
        ld (#0038),a
        ld hl,manejador
        ld (#0039),hl
        im 1
        ei

; --- 7. Textos ---
        ld hl,txt_titulo
        DIRPANT 1,2
        call imprime
        ld hl,txt_linea1
        DIRPANT 3,2
        call imprime
        ld hl,txt_linea2
        DIRPANT 4,2
        call imprime
        ld hl,txt_linea3
        DIRPANT 5,2
        call imprime
        ld hl,txt_prompt
        DIRPANT 7,2
        call imprime

; --- 8. Bucle principal: el cursor parpadea gracias a las interrupciones ---
CURSOR  equ PANTALLA+7*80+4     ; justo después de "> "
bucle:
        halt                    ; dormir hasta la siguiente interrupción
        ld a,(ticks)
        cp 150                  ; 150 interrupciones = medio segundo
        jr c,bucle
        xor a
        ld (ticks),a
        ld hl,CURSOR            ; invertir las 8 líneas de la celda del cursor
        ld b,8
cur_bucle:
        ld a,(hl)
        cpl
        ld (hl),a
        ld a,h
        add a,8                 ; siguiente línea de píxeles: +#800
        ld h,a
        djnz cur_bucle
        jr bucle

; -----------------------------------------------------------
; manejador: se ejecuta 300 veces por segundo
; Solo cuenta. Conserva todos los registros.
; -----------------------------------------------------------
manejador:
        push af
        ld a,(ticks)
        inc a
        ld (ticks),a
        pop af
        ei
        ret

; -----------------------------------------------------------
; imprime: escribe una cadena en pantalla (modo 2)
; Entrada: HL = cadena terminada en 0, DE = dirección en pantalla
; Modifica: AF, BC, DE, HL
; -----------------------------------------------------------
imprime:
        ld a,(hl)
        or a
        ret z                   ; fin de la cadena
        push hl
        push de
        ld l,a                  ; HL = FUENTE + carácter*8
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,FUENTE
        add hl,bc
        ld b,8                  ; 8 líneas de píxeles por carácter
imp_linea:
        ld a,(hl)
        ld (de),a
        inc hl
        ld a,d
        add a,8                 ; siguiente línea de píxeles: +#800
        ld d,a
        djnz imp_linea
        pop de
        pop hl
        inc de                  ; siguiente columna
        inc hl                  ; siguiente carácter
        jr imprime

; --- Datos ---
paleta:
        db 0,#44                ; pluma 0: azul
        db 1,#43                ; pluma 1: amarillo brillante
        db #10,#44              ; borde: azul

txt_titulo: db "AMSTRAD OS  v0.0",0
txt_linea1: db "Firmware desactivado: el Z80 es todo nuestro.",0
txt_linea2: db "Modo 2 (80 columnas), interrupciones propias, sin ROM.",0
txt_linea3: db "Shell, teclado y M4: proximamente.",0
txt_prompt: db "> ",0

fin:

; --- Genera OS.BIN dentro de la imagen de disco os.dsk ---
        save "os.bin",inicio,fin-inicio,DSK,"build/os.dsk"
